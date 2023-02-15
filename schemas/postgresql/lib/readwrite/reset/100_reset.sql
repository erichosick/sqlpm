/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- lib - reset
-- -----------------------------------------------------------------------------

-- lib.sql_identifier_* --------------------------------------------------------

DROP DOMAIN IF EXISTS lib.sql_identifier_lower;
DROP DOMAIN IF EXISTS lib.sql_identifier;

-- Identifier and Key Domains ------------------------------------------

DROP DOMAIN IF EXISTS lib.key_uuid;
DROP DOMAIN IF EXISTS lib.key_uuid_nullable;
DROP DOMAIN IF EXISTS lib.key_str_36;
DROP DOMAIN IF EXISTS lib.key_str_64;
DROP DOMAIN IF EXISTS lib.key_str_128;
DROP DOMAIN IF EXISTS lib.key_symbol;
DROP DOMAIN IF EXISTS lib.key_bigint;
DROP DOMAIN IF EXISTS lib.key_int;
DROP DOMAIN IF EXISTS lib.key_smallint;
DROP DOMAIN IF EXISTS lib.key_slug_128;

DROP DOMAIN IF EXISTS lib.key_htag;
DROP DOMAIN IF EXISTS lib.key_lhtag;

-- Percentages -----------------------------------------------------------------

DROP DOMAIN IF EXISTS lib.percent_7_1;
DROP DOMAIN IF EXISTS lib.percent_7_1_null;
DROP DOMAIN IF EXISTS lib.percent_7_2;
DROP DOMAIN IF EXISTS lib.percent_7_2_null;
DROP DOMAIN IF EXISTS lib.percent_7_3;
DROP DOMAIN IF EXISTS lib.percent_7_3_null;
DROP DOMAIN IF EXISTS lib.percent_7_4;
DROP DOMAIN IF EXISTS lib.percent_7_4_null;

-- Currency --------------------------------------------------------------------

DROP DOMAIN IF EXISTS lib.currency_0;
DROP DOMAIN IF EXISTS lib.currency_0_null;
DROP DOMAIN IF EXISTS lib.currency_2;
DROP DOMAIN IF EXISTS lib.currency_2_null;
DROP DOMAIN IF EXISTS lib.currency_4;
DROP DOMAIN IF EXISTS lib.currency_4_null;

-- Internet related domains like URLs, email, HTML and CSS Types ---------------

DROP DOMAIN IF EXISTS lib.url;
DROP FUNCTION IF EXISTS lib.url_parts;
DROP DOMAIN IF EXISTS lib.email;
DROP FUNCTION IF EXISTS lib.email_parts;
DROP DOMAIN IF EXISTS lib.color_hex;

-- Human readable domains ------------------------------------------------------

DROP DOMAIN IF EXISTS lib.name;
DROP DOMAIN IF EXISTS lib.label;
DROP DOMAIN IF EXISTS lib.label_short;
DROP DOMAIN IF EXISTS lib.title;
DROP DOMAIN IF EXISTS lib.description;

-- Frequency -------------------------------------------------------------------

DROP DOMAIN IF EXISTS lib.frequency_8_4;
DROP DOMAIN IF EXISTS lib.frequency_8_8;

-- Time -------------------------------------------------------------------

DROP DOMAIN IF EXISTS lib.seconds_16_8;

DROP SCHEMA lib;
