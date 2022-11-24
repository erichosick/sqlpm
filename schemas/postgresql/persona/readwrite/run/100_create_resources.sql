/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- persona - run
-- -----------------------------------------------------------------------------

-- SCHEMA ----------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS persona;
COMMENT ON SCHEMA persona IS 'support users, persona entities, companies, etc.';

CALL universal.roles_setup('persona');

-- TAG DATA --------------------------------------------------------------------

INSERT INTO tag.tag
( tag_id    , label_short , label      , sort_order, description                      ) VALUES
( 'persona' , 'persona'   ,  'persona' , 1         , 'Information, such as type and association, of persona. Persona are legal entities such as a person or company.' )
ON CONFLICT DO NOTHING;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM tag.tag WHERE tag_id = 'persona.type') THEN
    INSERT INTO tag.tag
    ( tag_id           , label_short   , label           , sort_order, tagid_range              , description                                                              ) VALUES
    ( 'persona.type'   , 'persona type', 'persona type'  , 2         , '[2001, 2500]'::int4range, 'Types of legal entites such as companies, people, persona, identities.' );
  END IF;
END $$;

INSERT INTO tag.tag
( tag_id                 , label_short      , label                  , sort_order, description                                        ) VALUES
( 'persona.type.company' , 'company legal'  , 'company legal entity' , 100000    , 'A company legal entity'                           ),
( 'persona.type.person'  , 'person legal'   , 'person legal entity'  , 100000    , 'A person legal entity'                            ),
( 'persona.type.persona' , 'persona legal'  , 'persona legal entity' , 100000    , 'A persona someone has taken on'                   ),
( 'persona.type.other'   , 'other legal'    , 'other legal entity'   , 100000    , 'Other types of legal entities'                    ),
( 'persona.type.bot'     , 'bot persona'    , 'bot entity'           , 100000    , 'A entity that is a bot and/or automated service.' ),
( 'persona.type.animal'  , 'animal persona' , 'animal entity'        , 100000    , 'A entity that is a bot and/or automated service.' )
ON CONFLICT DO NOTHING;


INSERT INTO tag.tagid
( tagid_id, tag_id          ) VALUES
( 2001    , 'persona.type.company' ),
( 2002    , 'persona.type.person'  ),
( 2003    , 'persona.type.persona' ),
( 2004    , 'persona.type.other'   ),
( 2005    , 'persona.type.bot'     ),
( 2006    , 'persona.type.animal'  )
ON CONFLICT DO NOTHING;

INSERT INTO tag.tag
( tag_id               , label_short    , label           , sort_order, description                            ) VALUES
( 'persona.role'       , 'role'         , 'persona role'  , 1         , 'Different roles a persona can assume' ),
( 'persona.role.admin' , 'admin'        , 'admin role'    , 100000    , 'Administration role'                  )
ON CONFLICT DO NOTHING;


-- TABLES ----------------------------------------------------------------------

-- Naming resources looked at (so far)
-- https://docs.oracle.com/en/cloud/saas/talent-management/22a/faitm/person-name-formats.html#s20030898
-- https://en.wikipedia.org/wiki/Personal_name
-- https://en.wikipedia.org/wiki/Wikipedia:Naming_conventions_(people)

CREATE TABLE IF NOT EXISTS persona.persona (
  persona_id uuid NOT NULL DEFAULT uuid_generate_v1(),
  persona_type_tagid_id int NOT NULL REFERENCES tag.tagid(tagid_id)
    CONSTRAINT persona_persona_type_must_be_between_2001_and_2500
      CHECK (persona_type_tagid_id BETWEEN 2001 AND 2500),
  title varchar(128) NOT NULL DEFAULT '',
  full_name varchar(1024) NOT NULL DEFAULT '',
  given_name varchar(256) NOT NULL DEFAULT '',
  middle_name varchar(256) NOT NULL DEFAULT '',
  surname varchar(256) NOT NULL DEFAULT '',
  ordinal varchar(128) NOT NULL DEFAULT '',
  preferred_email lib.email NOT NULL DEFAULT '',
  tag_ids tag.ltreelower[] NOT NULL
    CONSTRAINT tag_id_must_be_valid_tags
      CHECK ( tag.check_tag_array(
        tag_ids, '', 'persona.persona', 'tag_ids'
      )) DEFAULT '{}',
  CONSTRAINT persona_persona_pk PRIMARY KEY (persona_id)
);
COMMENT ON TABLE  persona.persona IS 'A persona is considered to be a person, company, persona, etc. See persona.persona_detail which supports formatting the name (formatted_name).';
COMMENT ON COLUMN persona.persona.persona_id IS 'A unique id (uuid) for the entries in this table.';
COMMENT ON COLUMN persona.persona.persona_type_tagid_id IS 'The type of persona such as a person or company.';
COMMENT ON COLUMN persona.persona.title IS 'The title of the persona such as Mr., Mrs. Inc. (if a company) etc.';
COMMENT ON COLUMN persona.persona.full_name IS 'The full name of the persona: a company name or full name of a person if the parts are not known.';
COMMENT ON COLUMN persona.persona.given_name IS 'The given name (even of a company), first name, fore name of the persona if known.';
COMMENT ON COLUMN persona.persona.middle_name IS 'The middle name of the persona if known.';
COMMENT ON COLUMN persona.persona.surname IS 'The surname, last name or family name of the persona.';
COMMENT ON COLUMN persona.persona.ordinal IS 'The ordinal part of a name such as younger, elder, junior, senior.';
COMMENT ON COLUMN persona.persona.preferred_email IS 'The preferred email address of the user. To support multiple email address for a single persona, see persona.persona.email.';
COMMENT ON COLUMN persona.persona.tag_ids IS 'One or more tags used to indentify this person.';

SELECT universal.apply_table_settings('persona', 'persona', '{"multi_source": true}'::jsonb);

-- -----------------------------------------------------------------------------

-- Used for scenarios where we don't have a specific persona in mind. The
-- 'default' or 'unknown' persona. A 'non-owner' persona, not claimed (for
-- example we have a generic speaker so no specific persona created it)
INSERT INTO persona.persona
( persona_id          , tenant_persona_id, source_persona_id   , persona_type_tagid_id, given_name  , tag_ids                                     ) VALUES
( universal.uuid_bot(), uuid_nil()       , universal.uuid_bot(), 2005                 , 'System Bot', ARRAY['persona.role.admin'::tag.ltreelower] ),
( uuid_nil()          , uuid_nil()       , universal.uuid_bot(), 2004                 , 'Unknown'   , ARRAY['persona.role.admin'::tag.ltreelower] )
ON CONFLICT DO NOTHING;

-- -----------------------------------------------------------------------------

CREATE OR REPLACE VIEW persona.persona_detail AS
SELECT
  pr.persona_id,
  pr.persona_type_tagid_id,
  pr.title,
  -- TODO: Add much better logic to format a name.
  CASE WHEN pr.full_name = '' THEN
    TRIM(
      CONCAT(
        pr.given_name, ' ', pr.middle_name,
        CASE WHEN pr.middle_name = '' THEN '' ELSE ' ' END, pr.surname
      )
    ) ELSE pr.full_name
    END AS formatted_name,
  pr.full_name,
  pr.given_name,
  pr.middle_name,
  pr.surname,
  pr.ordinal,
  pr.preferred_email,
  pr.tag_ids,
  pr.tenant_persona_id,
  pr.source_persona_id,
  pr.created_at,
  pr.last_updated_at
FROM persona.persona AS pr;
COMMENT ON VIEW persona.persona_detail IS 'Detailed and additional information around a persona such as a formatted name.';


CREATE OR REPLACE VIEW persona.persona_admin AS
SELECT
  pd.persona_id,
  pd.formatted_name
FROM persona.persona_detail AS pd
WHERE pd.tag_ids @> 'persona.role.admin'::tag.ltreelower
ORDER BY pd.formatted_name;

-- -----------------------------------------------------------------------------

INSERT INTO tag.tag
( tag_id            , label_short    , label           , sort_order, description                                                    ) VALUES
( 'url'             , 'url'          , 'url'           , 1         , 'Universal Resource Locator'                                   ),
( 'url.review'      , 'review url'   , 'url review'    , 100000    , 'The review of a component'                                    ),
( 'url.products'    , 'prods url'    , 'url products'  , 100000    , 'The official page that lists products for the persona'        ),
( 'url.product'     , 'prod url'     , 'url product'   , 100000    , 'The official page for a product'                              ),
( 'url.homepage'    , 'homepage url' , 'url homepage'  , 100000    , 'The official page for a legal entity'                         ),
( 'url.youtube'     , 'youtube url'  , 'url youtube'   , 100000    , 'The youtube page for a legal entity'                          )
ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS persona.persona_url (
  persona_url_id uuid NOT NULL DEFAULT uuid_generate_v1(),
  persona_id uuid REFERENCES persona.persona(persona_id),
  url_type_tag_ids tag.ltreelower[] NOT NULL
    CONSTRAINT url_type_tag_idsmust_be_valid_tags
      CHECK ( tag.check_tag_array(
        url_type_tag_ids, 'url', 'persona.persona_url', 'url_type_tag_ids'
      )),
  url lib.url NOT NULL,
  CONSTRAINT persona_persona_url_pk PRIMARY KEY (persona_url_id),
  CONSTRAINT persona_persona_url_unique UNIQUE (persona_id, url)
);
COMMENT ON TABLE  persona.persona_url IS 'A url associated with the persona. Examples are webpage, blogpost, etc.';
COMMENT ON COLUMN persona.persona_url.persona_url_id IS 'A unique id (uuid) for the entries in this table.';
COMMENT ON COLUMN persona.persona_url.persona_id IS 'The id (uuid) of the persona associated with the url.';
COMMENT ON COLUMN persona.persona_url.url_type_tag_ids IS 'One or more types of urls for this url.';
COMMENT ON COLUMN persona.persona_url.url IS 'The url.';

SELECT universal.apply_table_settings('persona', 'persona_url', '{"multi_tenant": false, "multi_source": true}'::jsonb);

CREATE INDEX IF NOT EXISTS persona_persona_url_persona_id
  ON persona.persona_url (persona_id);

-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS persona.persona_external (
  persona_external_id uuid NOT NULL DEFAULT uuid_generate_v1(),
  source_persona_id uuid REFERENCES persona.persona(persona_id),
  external_id varchar(128) NOT NULL,
  -- We want to try choose an existing persona_id associated with the
  -- external_id but if the persona does not exist yet, then we need to generate
  -- a new uuid BEFORE adding that persona into the persona table. As such, we
  -- can't use the REFERENCES constraint here.
  persona_id uuid NOT NULL DEFAULT uuid_generate_v1(),
  CONSTRAINT persona_persona_external_pk PRIMARY KEY (persona_external_id),
  CONSTRAINT persona_persona_external_uniq UNIQUE(source_persona_id, external_id)
);
COMMENT ON TABLE  persona.persona_external IS 'Maps a unique 3rd party external indentifier of to an internal persona uuid. If the external identifier is an integer, it will need to be converted to a string.';
COMMENT ON COLUMN persona.persona_external.persona_external_id IS 'A unique id (uuid) for the entries in this table.';
COMMENT ON COLUMN persona.persona_external.source_persona_id IS 'The persona id (uuid) of source (the creator) of the external id.';
COMMENT ON COLUMN persona.persona_external.external_id IS 'The unique external id. ';
COMMENT ON COLUMN persona.persona_external.persona_id IS 'The id (uuid) of the persona associated with external id.';

CREATE INDEX IF NOT EXISTS persona_persona_external_persona_id
  ON persona.persona_external (persona_id);

SELECT universal.apply_table_settings('persona', 'persona_external');

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM tag.tag WHERE tag_id = 'persona.assoc') THEN
    INSERT INTO tag.tag
    ( tag_id                      , label_short      , label                        , sort_order, tagid_range           , description                                       ) VALUES
    ( 'persona.assoc'             , 'pers assoc'     , 'persona association'              , 2         , '[3001, 4000]'::int4range, 'Types of associations between persona.' );
  END IF;
END $$;

INSERT INTO tag.tagid
( tagid_id, tag_id          ) VALUES
( 3001    , 'persona.assoc' )
ON CONFLICT DO NOTHING;

-- TODO: Add a trigger that only allows update of the title and
-- not associated_tag_id, the parent and child persona. OR add count logic to
-- support update of at least the association_tagid_id and maybe
-- child_persona_id?
CREATE TABLE IF NOT EXISTS persona.persona_persona (
  persona_persona_id uuid NOT NULL DEFAULT uuid_generate_v1(),
  parent_persona_id uuid REFERENCES persona.persona(persona_id),
  child_persona_id uuid REFERENCES persona.persona(persona_id),
  title lib.title NOT NULL DEFAULT '',
  association_tagid_id int4 NOT NULL REFERENCES tag.tagid(tagid_id)
    CONSTRAINT persona_persona_association_tagid_between_3001_and_4000
      CHECK (association_tagid_id BETWEEN 3001 AND 4000)
      DEFAULT 3001,
  CONSTRAINT persona_persona_persona_pk PRIMARY KEY (persona_persona_id),
  CONSTRAINT persona_persona_persona_child_parent_uniq UNIQUE(child_persona_id, parent_persona_id, association_tagid_id),
  CONSTRAINT persona_persona_persona_parent_child_uniq UNIQUE(parent_persona_id, child_persona_id, association_tagid_id),
  CONSTRAINT persona_persona_persona_association_uniq UNIQUE(association_tagid_id, parent_persona_id, child_persona_id)
);
COMMENT ON TABLE  persona.persona_persona IS 'Maps a relationship between a child/sub persona and a parent persona. A parent to grandparent for example.';
COMMENT ON COLUMN persona.persona_persona.persona_persona_id IS 'A unique id (uuid) for the entries in this table.';
COMMENT ON COLUMN persona.persona_persona.child_persona_id IS 'The child persona id (uuid) of the relationship between the child and parent.';
COMMENT ON COLUMN persona.persona_persona.parent_persona_id IS 'The parent persona id (uuid) of the relationship between the child and parent.';
COMMENT ON COLUMN persona.persona_persona.title IS 'A description of the relationship. For example, an employee may be the CEO of the company.';
COMMENT ON COLUMN persona.persona_persona.association_tagid_id IS 'The association type between the two persona from the perspective of the child persona.';

SELECT universal.apply_table_settings('persona', 'persona_persona', '{"multi_tenant": false}'::jsonb);

-- -----------------------------------------------------------------------------

CREATE OR REPLACE VIEW persona.persona_persona_count AS
SELECT
  pp.parent_persona_id AS persona_id,
  pp.association_tagid_id,
  COUNT(*) AS child_count
FROM persona.persona_persona AS pp
GROUP BY pp.parent_persona_id, pp.association_tagid_id;

-- -----------------------------------------------------------------------------

CREATE OR REPLACE VIEW persona.persona_last_activity AS
SELECT
  pp.parent_persona_id,
  MAX(last.max_latest_activity) AS latest_activity
FROM persona.persona_persona AS pp
INNER JOIN persona.persona AS cper ON cper.persona_id = pp.child_persona_id
INNER JOIN persona.persona AS pper ON pper.persona_id = pp.parent_persona_id,
LATERAL (
  SELECT MAX(element) AS max_latest_activity FROM unnest(ARRAY[cper.created_at, pper.created_at]) AS element
) AS last
GROUP BY pp.parent_persona_id;
COMMENT ON VIEW persona.persona_last_activity IS 'The last time any activity occurred on with the parent persona: either for the parent or child persona.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM tag.tag WHERE tag_id = 'persona.score') THEN
    INSERT INTO tag.tag
    ( tag_id                      , label_short      , label                        , sort_order, tagid_range           , description                                                   ) VALUES
    ( 'persona.score'             , 'score'          , 'persona score'              , 2         , '[1, 1000]'::int4range, 'Different types of scores that can be applied to a persona.' );
  END IF;
END $$;

INSERT INTO tag.tag
( tag_id                      , label_short      , label                        , sort_order, description                                                              ) VALUES
( 'persona.score.lead'        , 'lead score'     , 'persona lead score'         , 100000    , 'Persona lead score (https://en.wikipedia.org/wiki/Lead_scoring)'        ),
( 'persona.score.lead.zapier' , 'zapier lead'    , 'persona zapier lead score'  , 100000    , 'Persona Zapier lead score (https://en.wikipedia.org/wiki/Lead_scoring)' ),
( 'persona.score.email'       , 'email activity' , 'persona email activity'     , 100000    , 'Persona email activity'                                                 ),
( 'persona.score.event'       , 'event activity' , 'persona event activity'     , 100000    , 'Persona event activity'                                                 ),
( 'persona.score.lms'         , 'lms score'      , 'persona LMS score'          , 100000    , 'Persona LMS score'                                                      )
ON CONFLICT DO NOTHING;

INSERT INTO tag.tagid
( tagid_id, tag_id                      ) VALUES
(1        , 'persona.score.lead'        ),
(2        , 'persona.score.lead.zapier' ),
(3        , 'persona.score.email'       ),
(4        , 'persona.score.event'       ),
(5        , 'persona.score.lms'         )
ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS persona.persona_score (
  persona_score_id uuid NOT NULL DEFAULT uuid_generate_v1(),
  persona_id uuid REFERENCES persona.persona(persona_id),

  score_type_tagid_id int NOT NULL REFERENCES tag.tagid(tagid_id)
    -- persona_score has been assigned tagidid of 1 through 1000.
    CONSTRAINT persona_score_score_type_must_be_between_one_and_thousand
      CHECK (score_type_tagid_id BETWEEN 1 AND 1000),
  score decimal(18,6) NOT NULL,
  CONSTRAINT persona_persona_score_pk PRIMARY KEY (persona_score_id),
  CONSTRAINT persona_persona_score_uniq UNIQUE(persona_id, score_type_tagid_id)
);
COMMENT ON TABLE  persona.persona_score IS 'A numeric scoring of some kind for a given persona. For example, lead score, credit score, etc.';
COMMENT ON COLUMN persona.persona_score.persona_score_id IS 'A unique id (uuid) for the entries in this table.';
COMMENT ON COLUMN persona.persona_score.persona_id IS 'The persona id (uuid) of the persona for the score';

COMMENT ON COLUMN persona.persona_score.score_type_tagid_id IS 'The type of score being given to the persona.';
COMMENT ON COLUMN persona.persona_score.score IS 'The score of a given type.';

SELECT universal.apply_table_settings('persona', 'persona_score', '{"multi_tenant": false}'::jsonb);

-- -----------------------------------------------------------------------------

CREATE OR REPLACE VIEW persona.persona_score_total AS
SELECT
  pp.parent_persona_id AS persona_id,
  ps.score_type_tagid_id,
  COUNT(*) AS contact_count,
  SUM(ps.score) AS score_sum,
  AVG(ps.score)::decimal(18,6) AS score_average
FROM persona.persona_persona AS pp
INNER JOIN persona.persona_score AS ps ON ps.persona_id = pp.child_persona_id
GROUP BY pp.parent_persona_id, score_type_tagid_id;
COMMENT ON VIEW persona.persona_score_total IS 'Scores and totals between a parent and child persona such as sum, average and contact count.';

-- -----------------------------------------------------------------------------

INSERT INTO tag.tag
( tag_id                   , label_short         , label                        , sort_order, description                      ) VALUES
( 'social'                 , 'social plat'       , 'social platform'           , 2        , 'Social platform.'                 ),
( 'social.facebook'        , 'facebook plat'     , 'facebook platform'         , 10000    , 'Facebook social platform.'        ),
( 'social.youtube'         , 'youtube plat'      , 'facebook platform'         , 10000    , 'Youtube social platform.'         ),
( 'social.whatsapp'        , 'whatsapp plat'     , 'facebook platform'         , 10000    , 'Whatsapp social platform.'        ),
( 'social.messenger'       , 'messenger plat'    , 'facebook platform'         , 10000    , 'Messenger social platform.'       ),
( 'social.instagram'       , 'instagram plat'    , 'facebook platform'         , 10000    , 'Instagram social platform.'       ),
( 'social.wechat'          , 'wechat plat'       , 'facebook platform'         , 10000    , 'Wechat social platform.'          ),
( 'social.tiktok'          , 'tiktok plat'       , 'facebook platform'         , 10000    , 'Tiktok social platform.'          ),
( 'social.telegram'        , 'telegram plat'     , 'facebook platform'         , 10000    , 'Telegram social platform.'        ),
( 'social.douyin'          , 'douyin plat'       , 'facebook platform'         , 10000    , 'Douyin social platform.'          ),
( 'social.qq'              , 'qq plat'           , 'facebook platform'         , 10000    , 'Qq social platform.'              ),
( 'social.snapchat'        , 'snapchat plat'     , 'facebook platform'         , 10000    , 'Snapchat social platform.'        ),
( 'social.weibo'           , 'weibo plat'        , 'facebook platform'         , 10000    , 'Weibo social platform.'           ),
( 'social.qzone'           , 'qzone plat'        , 'facebook platform'         , 10000    , 'Qzone social platform.'           ),
( 'social.kuaishou'        , 'kuaishou plat'     , 'facebook platform'         , 10000    , 'Kuaishou social platform.'        ),
( 'social.pinterest'       , 'pinterest plat'    , 'facebook platform'         , 10000    , 'Pinterest social platform.'       ),
( 'social.reddit'          , 'reddit plat'       , 'facebook platform'         , 10000    , 'Reddit social platform.'          ),
( 'social.twitter'         , 'twitter plat'      , 'facebook platform'         , 10000    , 'Twitter social platform.'         ),
( 'social.quora'           , 'quora plat'        , 'facebook platform'         , 10000    , 'Quora social platform.'           ),
( 'social.skype'           , 'skype plat'        , 'facebook platform'         , 10000    , 'Skype social platform.'           ),
( 'social.tieba'           , 'tieba plat'        , 'facebook platform'         , 10000    , 'Tieba social platform.'           ),
( 'social.viber'           , 'viber plat'        , 'facebook platform'         , 10000    , 'Viber social platform.'           ),
( 'social.linkedin'        , 'linkedin plat'     , 'facebook platform'         , 10000    , 'Linkedin social platform.'        ),
( 'social.teams'           , 'teams plat'        , 'facebook platform'         , 10000    , 'Teams social platform.'           ),
( 'social.imo'             , 'imo plat'          , 'facebook platform'         , 10000    , 'Imo social platform.'             ),
( 'social.line'            , 'line plat'         , 'facebook platform'         , 10000    , 'Line social platform.'            ),
( 'social.picsart'         , 'picsart plat'      , 'facebook platform'         , 10000    , 'Picsart social platform.'         ),
( 'social.lokee'           , 'lokee plat'        , 'facebook platform'         , 10000    , 'Lokee social platform.'           ),
( 'social.discord'         , 'discord plat'      , 'facebook platform'         , 10000    , 'Discord social platform.'         ),
( 'social.twitch'          , 'twitch plat'       , 'facebook platform'         , 10000    , 'Twitch social platform.'          ),
( 'social.stackexchange'   , 'stackexchange plat', 'facebook platform'         , 10000    , 'Stackexchange social platform.'   )
ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS persona.persona_social (
  persona_social_id uuid NOT NULL DEFAULT uuid_generate_v1(),
  persona_id uuid REFERENCES persona.persona(persona_id),
  social_tag_id tag.ltreelower NOT NULL REFERENCES tag.tag(tag_id)
    CONSTRAINT persona_social_must_be_in_social_sub_tree
      CHECK (social_tag_id <@ 'social'),
  social_id lib.name NOT NULL,
  social_name lib.name NOT NULL DEFAULT '',
  is_primary boolean NOT NULL DEFAULT false,
  CONSTRAINT persona_persona_social_pk PRIMARY KEY (persona_social_id)
);
COMMENT ON TABLE  persona.persona_social IS 'Information about a persona''s social account. ';
COMMENT ON COLUMN persona.persona_social.persona_social_id IS 'A unique id (uuid) for the entries in this table.';
COMMENT ON COLUMN persona.persona_social.persona_id IS 'The persona id (uuid) of the social platform user.';

COMMENT ON COLUMN persona.persona_social.social_tag_id IS 'The type of social platform.';
COMMENT ON COLUMN persona.persona_social.social_id IS 'The id of the persona on the social platform (email, etc.)';
COMMENT ON COLUMN persona.persona_social.social_id IS 'The id of the persona on the social platform (email, etc.)';
COMMENT ON COLUMN persona.persona_social.social_name IS 'The name/display name of the user on the social platform (email, etc.)';
COMMENT ON COLUMN persona.persona_social.is_primary IS 'Marks the social as the primary social. Used in cases where a persona may have more than one account on the same social platform.';

SELECT universal.apply_table_settings('persona', 'persona_social', '{"multi_source": true}'::jsonb);

CREATE INDEX IF NOT EXISTS persona_persona_social_persona_id_social_id
  ON persona.persona_social (persona_id, social_id);

-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS persona.persona_social_external (
  persona_social_external_id uuid NOT NULL DEFAULT uuid_generate_v1(),
  source_persona_id uuid REFERENCES persona.persona(persona_id),
  external_id varchar(128) NOT NULL,
  -- We want to try choose an existing persona_id associated with the
  -- external_id but if the persona does not exist yet, then we need to generate
  -- a new uuid BEFORE adding that persona into the persona table. As such, we
  -- can't use the REFERENCES constraint here.
  persona_social_id uuid NOT NULL DEFAULT uuid_generate_v1(),
  CONSTRAINT persona_persona_social_external_pk PRIMARY KEY (persona_social_external_id),
  CONSTRAINT persona_persona_social_external_uniq UNIQUE(source_persona_id, external_id)
);
COMMENT ON TABLE  persona.persona_social_external IS 'Maps a unique 3rd party external indentifier of to an internal social uuid. If the external identifier is an integer, it will need to be converted to a string.';
COMMENT ON COLUMN persona.persona_social_external.persona_social_external_id IS 'A unique id (uuid) for the entries in this table.';
COMMENT ON COLUMN persona.persona_social_external.source_persona_id IS 'The persona id (uuid) of source (the creator) of the external id.';
COMMENT ON COLUMN persona.persona_social_external.external_id IS 'The unique external id. ';
COMMENT ON COLUMN persona.persona_social_external.persona_social_id IS 'The id (uuid) of the personal social entry associated with external id.';

CREATE INDEX IF NOT EXISTS persona_persona_social_external_persona_id
  ON persona.persona_social_external (persona_social_id);

SELECT universal.apply_table_settings('persona', 'persona_social_external');

-- -----------------------------------------------------------------------------
