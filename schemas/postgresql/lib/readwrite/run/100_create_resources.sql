/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- lib - run
-- -----------------------------------------------------------------------------

-- SCHEMA ----------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS lib;
COMMENT ON SCHEMA lib IS 'A library of reusable Postgresql domains placed in the lib schema';


-- -----------------------------------------------------------------------------
-- lib_domain - run
-- 
-- -----------------------------------------------------------------------------

-- SCHEMA ----------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS lib;
COMMENT ON SCHEMA lib IS 'A library of reusable Postgresql domains';

-- EXTENSIONS ------------------------------------------------------------------

-- NOTE: Only superuser can create a LEAKPROOF function

-- Support case-insenstive types like email and url.
-- https://www.postgresql.org/docs/current/citext.html
CREATE EXTENSION IF NOT EXISTS citext;


-- URL -------------------------------------------------------------------------

-- TODO: Finish out this code to pull out parts of a url
-- NOTE: Only superuser can create a LEAKPROOF function
CREATE OR REPLACE FUNCTION lib.url_parts(
  IN p_uri varchar(2047)
)
RETURNS RECORD LANGUAGE sql STRICT IMMUTABLE PARALLEL RESTRICTED AS $$
  SELECT 1 AS result;
$$;
COMMENT ON FUNCTION lib.url_parts(varchar) IS 'pulls out parts of a url. See https://developer.mozilla.org/en-US/docs/Web/API/Location';

-- see https://stackoverflow.com/questions/417142/what-is-the-maximum-length-of-a-url-in-different-browsers
DO $$ BEGIN
  CREATE DOMAIN lib.url AS citext
    CONSTRAINT shared_url_is_invalid
      CHECK (
        NOT lib.url_parts(VALUE) IS NULL
        AND CHAR_LENGTH(VALUE) <= 2047
      );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.url IS 'A url (universal resource locator).';

-- Human readable types --------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.label AS varchar(128);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.label IS 'A label is a human readable value often used in, drop down list box, as a check box label, radio label, etc.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.label_short AS varchar(32);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.label_short IS 'A short label is a human readable value used in situations where there isn not a lot of screen space in the ui.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.title AS varchar(128)
    CHECK (CHAR_LENGTH(VALUE) <= 128);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.title IS 'A title is a human readable value often used in, drop down list box, as a check box label, radio label, etc.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.description AS varchar(4096);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.description IS 'A description is a human readable value providing detailed information about an entry used for things like tool-tips, documentation, explanations, etc.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.name AS varchar(512);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.name IS 'A name of something like a person, entity, persona, etc.';

-- -----------------------------------------------------------------------------


-- TODO: Finish out this code to pull out parts of an email
-- NOTE: Only superuser can create a LEAKPROOF function
CREATE OR REPLACE FUNCTION lib.email_parts(
  IN p_email varchar(256)
)
RETURNS RECORD LANGUAGE sql STRICT IMMUTABLE PARALLEL RESTRICTED AS $$
  SELECT 1 AS result;
$$;
COMMENT ON FUNCTION lib.url_parts(varchar) IS 'pulls out parts of an email.';

DO $$ BEGIN
  CREATE DOMAIN lib.email AS varchar(256)
    CONSTRAINT email_parts_is_invalid
      CHECK (NOT lib.email_parts(VALUE) IS NULL);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.email IS 'An email address.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.color_hex AS varchar(7)
  CONSTRAINT shared_color_hex_invalid_expected
    CHECK (VALUE ~ '^#([a-fA-F0-9]{6}|[a-fA-F0-9]{3})$');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.color_hex IS 'An HTML hex color of format #rrggbb.';

-- -----------------------------------------------------------------------------

-- TODO: Test for these types

DO $$ BEGIN
  -- _ OR any letter (upper/lower) followed by _ - number or letter (upper/lower)
  CREATE DOMAIN lib.sql_identifier AS varchar(63)
    CHECK (VALUE ~ '^([^\W\d)]|[_])[\w_-]*$');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.sql_identifier IS 'Valid PostgreSql identifiers and key words (tables, columns, schema). Note: schema names can not start with pg_.';

DO $$ BEGIN
  CREATE DOMAIN lib.sql_identifier_lower AS varchar(63)
    CHECK (VALUE ~ '^([^\W\d)]|[_])[\w_-]*$' AND VALUE::text = lower(VALUE::text));
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.sql_identifier_lower IS 'Valid lower case PostgreSql identifiers and key words (tables, columns, schema). Note: schema names can not start with pg_.';
