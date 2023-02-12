/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- lib - run
-- -----------------------------------------------------------------------------

-- SCHEMA ----------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS lib;
COMMENT ON SCHEMA lib IS 'A library of reusable Postgresql domains placed in the lib schema';

-- EXTENSIONS ------------------------------------------------------------------

-- Support case-insenstive types like email and url.
-- https://www.postgresql.org/docs/current/citext.html
CREATE EXTENSION IF NOT EXISTS citext;

-- Support ltree
-- https://www.postgresql.org/docs/current/ltree.html
CREATE EXTENSION IF NOT EXISTS ltree;

-- PostgreSQL identifiers ------------------------------------------------------

DO $$ BEGIN
  -- _ OR any letter (upper/lower) followed by _ - number or letter (upper/lower)
  CREATE DOMAIN lib.sql_identifier AS varchar(63)
    CONSTRAINT str_identifier_failed_reglar_expression  
      CHECK (VALUE ~ '^([^\W\d)]|[_])[\w_-]*$');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.sql_identifier IS 'Valid, but more strict, PostgreSql identifiers and key words (tables, columns, schema). Note: schema names can not start with pg_. See https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-IDENTIFIERS for details.';

DO $$ BEGIN
  CREATE DOMAIN lib.sql_identifier_lower AS varchar(63)
    CONSTRAINT str_identifier_lower_failed_reglar_expression  
      CHECK (VALUE ~ '^([^\W\d)]|[_])[\w_-]*$' AND VALUE::text = lower(VALUE::text));
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.sql_identifier_lower IS 'Valid, but more strict, lower case PostgreSql identifiers and key words (tables, columns, schema). Note: schema names can not start with pg_. See https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-IDENTIFIERS for details';


-- -----------------------------------------------------------------------------
-- Identity and Primary Key Domains --------------------------------------------
-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.key_uuid AS uuid NOT NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.key_uuid IS 'A key column domain of type uuid used to uniquely identifies a row of data within a table. Values in this domain are mandatory.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.key_uuid_nullable AS uuid;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.key_uuid_nullable IS 'An optional key column domain of type uuid used as a foreign key that references a column of domain lib.key_uuid.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.key_str_36 AS varchar(36) NOT NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.key_str_36 IS 'A key column domain of type string of up to 36 characters used to uniquely identifies a row of data within a table. Values in this domain are mandatory.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.key_str_64 AS varchar(64) NOT NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.key_str_64 IS 'A key column domain of type string of up to 64 characters used to uniquely identifies a row of data within a table. Values in this domain are mandatory.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.key_str_128 AS varchar(128) NOT NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.key_str_128 IS 'A key column domain of type string of up to 128 characters used to uniquely identifies a row of data within a table. Values in this domain are mandatory.';


-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.key_symbol AS varchar(128) NOT NULL
    CONSTRAINT symbol_identifier_failed_reglar_expression  
      CHECK (VALUE ~ '^[a-zA-Z0-9_]{1,128}$');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.key_symbol IS 'A key column domain used to uniquely identifies a row of data within a table that is also user friendly. Values in this domain are mandatory.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.key_bigint AS bigint NOT NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.key_bigint IS 'A key column domain of type bigint used to uniquely identifies a row of data within a table. Values in this domain are mandatory.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.key_int AS int NOT NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.key_int IS 'A key column domain of type int used to uniquely identifies a row of data within a table. Values in this domain are mandatory.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.key_smallint AS smallint NOT NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.key_smallint IS 'A key column domain of type smallint used to uniquely identifies a row of data within a table. Values in this domain are mandatory.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.key_slug_128 AS varchar(128) NOT NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.key_slug_128 IS 'The "slug" part of a URL typically refers to the specific identifier that appears at the end of the URL. It is used to identify a unique page or resource on a website. Values in this domain are mandatory.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.key_htag AS ltree NOT NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.key_htag IS 'A key column domain the type ltree. Tags are used to classify or categorize the data. Values in this domain are mandatory.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.key_lhtag AS ltree  NOT NULL
  CONSTRAINT tag_ltree_lower_case_required
    CHECK (VALUE::text = lower(VALUE::text));
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.key_lhtag IS 'A key column domain the type ltree constrained to lower case only. Tags are used to classify or categorize the data. Values in this domain are mandatory.';


-- -----------------------------------------------------------------------------
-- Internet related "types" like URLs, email, HTML and CSS Types
-- -----------------------------------------------------------------------------

-- URL -------------------------------------------------------------------------

-- TODO FINISH: Finish out this code to pull out parts of a url
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


-- TODO FINISH: Finish out this code to pull out parts of an email
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

-- HTML Hex Color --------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.color_hex AS varchar(7)
  CONSTRAINT shared_color_hex_invalid_expected
    CHECK (VALUE ~ '^#([a-fA-F0-9]{6}|[a-fA-F0-9]{3})$');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.color_hex IS 'An HTML hex color of format #rrggbb.';


-- -----------------------------------------------------------------------------
-- Human Interface domain types like labels, titles, descriptions, names -------
-- -----------------------------------------------------------------------------

-- Label -----------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.label AS varchar(128);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.label IS 'A label is a human readable value often used in, drop down list box, as a check box label, radio label, etc.';

-- Short Label -----------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.label_short AS varchar(32);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.label_short IS 'A short label is a human readable value used in situations where there isn not a lot of screen space in the ui.';

-- Title -----------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.title AS varchar(128)
    CHECK (CHAR_LENGTH(VALUE) <= 128);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.title IS 'A title is a human readable value often used in, drop down list box, as a check box label, radio label, etc.';

-- Detailed Description --------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.description AS varchar(4096);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.description IS 'A description is a human readable value providing detailed information about an entry used for things like tool-tips, documentation, explanations, etc.';

-- Name ------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.name AS varchar(512);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.name IS 'A column for storing the name of an entity such as a person, organization, or persona. A value in this column is required, and must be a string with a maximum length of 512 characters.';


-- -----------------------------------------------------------------------------
-- Percentages -----------------------------------------------------------------
-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.percent_7_1 AS decimal(8,1) NOT NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.percent_7_1 IS 'A percent with 1 digit of precision and maximum of 9,999,999.9%. Example: 120% would be stored as 1.2. A value is required.';

-- -----------------------------------------------------------------------------


DO $$ BEGIN
  CREATE DOMAIN lib.percent_7_1_null AS decimal(8,1) NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.percent_7_1_null IS 'A percent with 1 digit of precision and maximum of 9,999,999.9%. Example: 120% would be stored as 1.2. Supports a null value.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.percent_7_2 AS decimal(9,2) NOT NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.percent_7_2 IS 'A percent with 2 digits of precision and maximum of 9,999,999.99%. Example: 123% would be stored as 1.23.  A value is required.';

-- -----------------------------------------------------------------------------


DO $$ BEGIN
  CREATE DOMAIN lib.percent_7_2_null AS decimal(9,2) NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.percent_7_2_null IS 'A percent with 2 digits of precision and maximum of 9,999,999.99%. Example: 123% would be stored as 1.23.   Supports a null value..';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.percent_7_3 AS decimal(10,3) NOT NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.percent_7_3 IS 'A percent with 3 digits of precision and maximum of 9,999,999.999%. Example: 123.4% would be stored as 1.234.  A value is required.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.percent_7_3_null AS decimal(10,3) NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.percent_7_3_null IS 'A percent with 3 digits of precision and maximum of 9,999,999.999%. Example: 123.4% would be stored as 1.234.  Supports a null value.';
 
-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.percent_7_4 AS decimal(11,4) NOT NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.percent_7_4 IS 'A percent with 4 digits of precision and maximum of 9,999,999.9999%. Example: 123.45% would be stored as 1.2345.  A value is required.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.percent_7_4_null AS decimal(11,4) NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.percent_7_4_null IS 'A percent with 4 digits of precision and maximum of 9,999,999.9999%. Example: 123.45% would be stored as 1.2345.  Supports a null value.';


-- -----------------------------------------------------------------------------
-- Currency scalars ------------------------------------------------------------
-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.currency_0 AS decimal(18,0) NOT NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.currency_0 IS 'A currency with 0 digits of precision and a value between -999,999,999,999,999,999.00 and 999,999,999,999,999,999.00. The value is required.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.currency_0_null AS decimal(18,0) NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.currency_0_null IS 'A currency with 0 digits of precision and a value between -999,999,999,999,999,999.00 and 999,999,999,999,999,999.00. Supports a null value.';

-- -----------------------------------------------------------------------------
DO $$ BEGIN
  CREATE DOMAIN lib.currency_2 AS decimal(20,2) NOT NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.currency_2 IS 'A currency with 2 digits of precision and a value between -999,999,999,999,999,999.99 and 999,999,999,999,999,999.99. The value is required.';


-- -----------------------------------------------------------------------------
DO $$ BEGIN
  CREATE DOMAIN lib.currency_2_null AS decimal(20,2) NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.currency_2_null IS 'A currency with 2 digits of precision and a value between -999,999,999,999,999,999.99 and 999,999,999,999,999,999.99. Supports a null value.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.currency_4 AS decimal(22,4) NOT NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.currency_4 IS 'A currency with 4 digits of precision and a value between -999,999,999,999,999,999.9999 and 999,999,999,999,999,999.9999. The value is required.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.currency_4_null AS decimal(22,4) NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.currency_4_null IS 'A currency with 4 digits of precision and a value between -999,999,999,999,999,999.9999 and 999,999,999,999,999,999.9999. Supports a null value.';


-- Frequency scalars -----------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.frequency_8_4 AS decimal(12,4);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.frequency_8_4 IS 'A frequency (say average number of times an event occurred each second, etc.) with 4 digits of precision and maximum of 99,999,999.9999.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.frequency_8_8 AS decimal(16,8);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.frequency_8_8 IS 'A frequency (say average number of times an event occurred each second, etc.) with 8 digits of precision and maximum of 99,999,999.99999999.';

-- -----------------------------------------------------------------------------

DO $$ BEGIN
  CREATE DOMAIN lib.seconds_16_8 AS decimal(16,8) NOT NULL;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
COMMENT ON DOMAIN lib.seconds_16_8 IS 'A time value in seconds with 8 digits of precision and maximum of 99,999,999.99999999.';
