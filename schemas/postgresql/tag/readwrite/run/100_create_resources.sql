/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- tag - run
-- -----------------------------------------------------------------------------

-- SCHEMA ----------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS tag;
COMMENT ON SCHEMA tag IS 'support tagging including domains and hierarchical tags via ltree (https://www.postgresql.org/docs/14/ltree.html).';

CALL universal.roles_setup('tag');

-- EXTENSIONS ------------------------------------------------------------------

-- Support ltree
-- https://www.postgresql.org/docs/current/ltree.html
CREATE EXTENSION IF NOT EXISTS ltree;

-- Supports uuid type and generating uuid
-- https://www.postgresql.org/docs/current/uuid-ossp.html
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- DOMAIN ----------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN tag.ltreelower AS ltree
  CONSTRAINT tag_ltree_lower_case_required
    CHECK (VALUE::text = lower(VALUE::text));
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN tag.ltreelower IS 'An ltree type that only supports lower case values.';

-- TABLES ----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tag.check_tag_array(
  p_tag_ids tag.ltreelower[],
  p_descendant tag.ltreelower,
  p_table_name text,
  p_field_name text
)
RETURNS boolean LANGUAGE PLPGSQL STRICT IMMUTABLE PARALLEL RESTRICTED AS $$
DECLARE d_bad_tag text;
BEGIN
  SELECT tag_items.tag_id INTO d_bad_tag
  FROM tag.tag AS tag
  RIGHT JOIN (
    SELECT unnest(p_tag_ids) AS tag_id
  ) AS tag_items ON tag_items.tag_id = tag.tag_id
  WHERE tag.tag_id IS NULL
  LIMIT 1;
  
  IF NOT d_bad_tag IS NULL THEN
    RAISE EXCEPTION 'ERROR: insert or update on table "%" violates foreign key constraint on table tag.tag
     DETAIL:  Key (%)=(%) is not present in table "tag.tag".', p_table_name, p_field_name, d_bad_tag;
  END IF;

  SELECT tag_items.tag_id INTO d_bad_tag
  FROM (
    SELECT unnest(p_tag_ids) AS tag_id
  ) AS tag_items
  WHERE tag_id <@ p_descendant = false
  LIMIT 1;

  IF NOT d_bad_tag IS NULL THEN
    RAISE EXCEPTION 'ERROR: insert or update on table "%" violates check constraint.
     DETAIL:   Tag (%)=(%) must be a decendent of %.', p_table_name, p_field_name, d_bad_tag, p_descendant;
  END IF;
  RETURN true;
END;
$$;
COMMENT ON FUNCTION tag.check_tag_array(tag.ltreelower[], tag.ltreelower, text, text) IS
'Raises an exception if an entry in an array is not in the tag.tag table.

@tag_ids - The array of tags we are verifying.
@descendant - The required decendant of all tags in tag_ids. An empty decendant means any tag_id is valid.
@table_name - The name of the table the function was called from. This is only used for error messages.
@field_name - The name of the field the function was called from. This is only used for error messages.
';

CREATE TABLE IF NOT EXISTS tag.tag (
  tag_id tag.ltreelower NOT NULL CHECK (tag_id::text = lower(tag_id::text)),
  enabled boolean NOT NULL DEFAULT true,
  sort_order int NOT NULL DEFAULT 100000,
  color_hex lib.color_hex NULL,
  label_short varchar(32) NOT NULL DEFAULT '',
  label lib.label NOT NULL,
  description lib.description NOT NULL DEFAULT '',
  tagid_range int4range NULL,
  CONSTRAINT tag_tag_id_pk PRIMARY KEY (tag_id),

  -- TODO: Figure out how to make a label unique at a given ltree decendent
  -- level. For example, unique by invoice.type
  CONSTRAINT tag_tag_label_unique UNIQUE(label)
);
COMMENT ON TABLE tag.tag IS 'Tags are a general purpose way of annotating some kind of information. For example, a Person may have a `tags ltree[]` column which could contain tags like status.enabled, role.manager, etc. A tag should not need other meta data. For example, we would not have a tag of characteristic:height:6feet.';
COMMENT ON COLUMN tag.tag.tag_id IS 'A unique id for the tag. The tag value is hierarchial (scoped).';
COMMENT ON COLUMN tag.tag.enabled IS 'When true, the tag is available and presented to users. When false, the tag is not shown.';
COMMENT ON COLUMN tag.tag.sort_order IS 'Use this to sort tags in drop down lists boxes, etc. when the lable can''t be used to sort the tag.';
COMMENT ON COLUMN tag.tag.color_hex IS '(optional/nullable) The html hex color to use to display the tag when a value is present.';
COMMENT ON COLUMN tag.tag.label_short IS 'The shortened version of the label.';
COMMENT ON COLUMN tag.tag.label IS 'The tag label is what is shown to the user.';
COMMENT ON COLUMN tag.tag.description IS 'An optional description providing additional information about the tag.';
COMMENT ON COLUMN tag.tag.tagid_range IS 'Optionally, for a given tag, provide an range of valid integer values. For example, a tag with tag_id of interval.recurring may be assigned numerical values between 100 and 200.';

CREATE OR REPLACE FUNCTION tag.tag_before_verify() RETURNS TRIGGER AS $$
  BEGIN
    IF new.tag_id::text != lower(new.tag_id::text) THEN
      RAISE EXCEPTION '% row for relation "%.%" violates check constraint
        DETAIL:  Failing row (%) contains upper case characters.', 
        CASE WHEN TG_OP = 'INSERT' THEN 'new' ELSE 'updated' END,
        TG_TABLE_SCHEMA, TG_TABLE_NAME, new.tag_id;
    END IF;

    -- When adding an id range to a tag, verify that any decendents haven't
    -- already assigned a tagid range to them. If a decendant has a tagid range
    -- assigned, then the new entry is already included in a range.
    IF EXISTS (
      SELECT 1
      FROM tag.tag
      WHERE NEW.tag_id <@ tag_id
      AND tagid_range IS NOT NULL
      AND NEW.tagid_range IS NOT NULL
    ) THEN
      RAISE EXCEPTION '% row for relation "%.%" violates check constraint
        DETAIL:  Failing row (%) attempted to add a tagid range already defined in a descendant.', 
        CASE WHEN TG_OP = 'INSERT' THEN 'new' ELSE 'updated' END,
        TG_TABLE_SCHEMA, TG_TABLE_NAME, new.tag_id;
    END IF;

    RETURN new;
  END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION tag.tag_before_verify IS 'Verifies that a tag is lower case: providing a friendly error message when it isn''t. Further verifies that if adding a tagid_range, the range does not overlap with a descendant.';

-- NOTE: tag.tag does not have multi-tenant because the persona.persona table
-- hasn't been created yet.
SELECT universal.apply_table_settings('tag', 'tag', '{"multi_tenant": false}'::jsonb);

DO $$ BEGIN
  CREATE TRIGGER tag_tag_010_before_upsert BEFORE INSERT OR UPDATE ON tag.tag
    FOR EACH ROW EXECUTE PROCEDURE tag.tag_before_verify();
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

CREATE INDEX IF NOT EXISTS tag_tag_tagid_range_idx
  ON tag.tag USING GIST (tagid_range); 

-- We will cluster on the tag_id field
ALTER TABLE tag.tag
  CLUSTER ON tag_tag_id_pk;

-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION tag.tagid_before_verify() RETURNS TRIGGER AS $$
BEGIN
  -- Verify that the tagid is within a range of the tag_id or any of the
  -- decendants of tag_id
  IF NOT EXISTS (
    SELECT 1
    FROM tag.tag AS tg
    WHERE NEW.tag_id <@ tg.tag_id -- any descendant
    AND tg.tagid_range @> NEW.tagid_id

  ) THEN
    RAISE EXCEPTION '% row for relation "%.%" violates check constraint
      DETAIL:  Failing row (%) attempted to add a tagid_id value that is not within a range defined by a descendant to (%).',
      CASE WHEN TG_OP = 'INSERT' THEN 'new' ELSE 'updated' END,
      TG_TABLE_SCHEMA, TG_TABLE_NAME, NEW.tagid_id, NEW.tag_id;
  END IF;

  RETURN new;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION tag.tag_before_verify IS 'Verifies that a tag is lower case: providing a friendly error message when it isn''t. Further verifies that if adding a tagid_range, the range does not overlap with a descendant.';

CREATE TABLE IF NOT EXISTS tag.tagid (
  tagid_id int NOT NULL,
  tag_id tag.ltreelower NOT NULL REFERENCES tag.tag(tag_id),
  CONSTRAINT tag_tagid_pk PRIMARY KEY (tagid_id),
  CONSTRAINT tag_tagid_tag_id_idx UNIQUE (tag_id)
);
COMMENT ON TABLE tag.tagid IS 'Assign a tag.tag a unique numerical id. Used in cases where an integer foreign key is preferred over an ltree. Before providing any value in this table, first setup a range for a given tag.tag.tag_id. The intent of a tagid''s is to give them a value ahead of someone using the database (tagid''s are not added by a user of the database). As such, tagid_id not a serial type (auto-increment).';
COMMENT ON COLUMN tag.tagid.tagid_id IS 'A unique id for the tagid table. The value must be within the range assigend to the tree or subtree of the ltree value located in the tagid.tag_id property.';
COMMENT ON COLUMN tag.tagid.tag_id IS 'The tag the id is associated with.';

SELECT universal.apply_table_settings('tag', 'tagid', '{"multi_tenant": false}'::jsonb);

DO $$ BEGIN
  CREATE TRIGGER tag_tagid_010_before_upsert BEFORE INSERT OR UPDATE ON tag.tagid
    FOR EACH ROW EXECUTE PROCEDURE tag.tagid_before_verify();
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;


ALTER TABLE tag.tagid
  CLUSTER ON tag_tagid_pk;

-- -----------------------------------------------------------------------------

INSERT INTO tag.tag
( tag_id                 , label_short            , label                  , description        ) VALUES
( 'media.image.large'    , 'large'                , 'large image'          , 'A large image'    )
ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS tag.tag_image (
  tag_image_id uuid NOT NULL DEFAULT uuid_generate_v1(),
  tag_id tag.ltreelower NOT NULL REFERENCES tag.tag(tag_id),
  image_type_tag_id tag.ltreelower NOT NULL REFERENCES tag.tag(tag_id)
    CONSTRAINT tag_tag_image_must_be_in_sub_tree_media_image
      CHECK (image_type_tag_id <@ 'media.image'),
  image_url lib.url NOT NULL,
  CONSTRAINT tag_tag_image_pk PRIMARY KEY (tag_image_id),
  CONSTRAINT tag_tag_image_tad_id_image_type_idx UNIQUE (tag_id, image_type_tag_id)
);
COMMENT ON TABLE tag.tag_image IS 'Tags can have one or more images associated with them such as a small, medium or large icon. Just an image, etc.';
COMMENT ON COLUMN tag.tag_image.tag_image_id IS 'A unique id for the tag_image.';
COMMENT ON COLUMN tag.tag_image.tag_id IS 'The tag the image is associated with.';
COMMENT ON COLUMN tag.tag_image.image_type_tag_id IS 'The type of image such as a small, medium or large icon, etc.';
COMMENT ON COLUMN tag.tag_image.image_url IS 'The image url.';

SELECT universal.apply_table_settings('tag', 'tag_image', '{"multi_tenant": false}'::jsonb);

-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS tag.tag_svg (
  tag_svg_id uuid NOT NULL DEFAULT uuid_generate_v1(),
  tag_id tag.ltreelower NOT NULL REFERENCES tag.tag(tag_id),
  image_type_tag_id tag.ltreelower NOT NULL REFERENCES tag.tag(tag_id),
  svg text NOT NULL,
  CONSTRAINT tag_tag_svg_pk PRIMARY KEY (tag_svg_id),
  CONSTRAINT tag_tag_svg_tad_id_image_type_idx UNIQUE (tag_id, image_type_tag_id)
);
COMMENT ON TABLE tag.tag_svg IS 'Tags can have one or more svgs associated with them.';
COMMENT ON COLUMN tag.tag_svg.tag_svg_id IS 'A unique id for the tag_svg.';
COMMENT ON COLUMN tag.tag_svg.tag_id IS 'The tag the svg is associated with.';
COMMENT ON COLUMN tag.tag_svg.image_type_tag_id IS 'The type of svg such as a small, medium or large icon, etc.';
COMMENT ON COLUMN tag.tag_svg.svg IS 'The svg markdown.';

SELECT universal.apply_table_settings('tag', 'tag_svg', '{"multi_tenant": false}'::jsonb);

-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS tag.tag_language (
  tag_language_id uuid NOT NULL DEFAULT uuid_generate_v1(),
  tag_id tag.ltreelower NOT NULL REFERENCES tag.tag(tag_id),
  alpha2 iso.alpha2 NOT NULL REFERENCES iso.language_alpha2(language_alpha2_id),
  label_short varchar(32) NOT NULL DEFAULT '',
  label lib.label NOT NULL,
  description lib.description NOT NULL DEFAULT '',

  CONSTRAINT tag_tag_language_pk PRIMARY KEY (tag_language_id),
  CONSTRAINT tag_tag_language_tad_id_image_type_idx UNIQUE (tag_id, alpha2)
);
COMMENT ON TABLE tag.tag_language IS 'Tags can have one or more languages applied to a tag.';
COMMENT ON COLUMN tag.tag_language.tag_language_id IS 'A unique id for the tag_language.';
COMMENT ON COLUMN tag.tag_language.tag_id IS 'The tag the language is associated with.';
COMMENT ON COLUMN tag.tag_language.label_short IS 'The shortened version of the label in the language represented by the alpha2 value.';
COMMENT ON COLUMN tag.tag_language.label IS 'The tag label is what is shown to the user in the language represented by the alpha2 value.';
COMMENT ON COLUMN tag.tag_language.description IS 'An optional description providing additional information about the tag in the language represented by the alpha2 value.';

SELECT universal.apply_table_settings('tag', 'tag_language', '{"multi_tenant": false}'::jsonb);

-- -----------------------------------------------------------------------------

-- TODO: This needs to be dynamically generated based on the universal settings.
CREATE OR REPLACE FUNCTION tag.tag_by_language (
  alpha2 iso.alpha2 = 'en'
)
RETURNS SETOF tag.tag LANGUAGE PLPGSQL AS $$
BEGIN
  RETURN QUERY
  SELECT
    tag.tag_id,
    tag.enabled,
    tag.sort_order, 
    tag.color_hex,
    COALESCE(lang.label_short, tag.label_short) AS label_short,
    COALESCE(lang.label, tag.label) AS label,
    COALESCE(lang.description, tag.description) AS description,
    tagid_range,
    tag.tenant_persona_id,
    COALESCE(lang.created_at, tag.created_at) AS created_at,
    COALESCE(lang.last_updated_at, tag.last_updated_at) AS last_updated_at
  FROM tag.tag AS tag
  LEFT JOIN tag.tag_language AS lang ON lang.tag_id = tag.tag_id;
END
$$;
COMMENT ON FUNCTION tag.tag_by_language(iso.alpha2) IS
'Returns all tag codes based on the provided langaguage. Any tag without an alternate provided for the language will return the english representation of the tag.

@alpha2 (iso.alpha2) - (Optional defaults to en) The ISO 639-1 two character language code.
';

-- -----------------------------------------------------------------------------

CREATE OR REPLACE VIEW tag.tag_detail AS
SELECT
  tag.tag_id,
  tag.sort_order,
  tag.color_hex,
  tag.label_short,
  tag.label,
  tag.description,
  tag.tagid_range,
  tagid.tagid_id
FROM tag.tag AS tag
LEFT JOIN tag.tagid AS tagid ON tagid.tag_id = tag.tag_id
WHERE tag.enabled = true;
COMMENT ON VIEW tag.tag_detail IS 'Bring together information about a tag from difference tables.';
