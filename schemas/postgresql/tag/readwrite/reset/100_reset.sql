/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- tag - reset
-- -----------------------------------------------------------------------------

DROP VIEW IF EXISTS tag.tag_detail;
DROP TABLE IF EXISTS tag.tag_language;
DROP TABLE IF EXISTS tag.tag_svg;
DROP TABLE IF EXISTS tag.tag_image;
DROP TABLE IF EXISTS tag.tagid;
DROP FUNCTION IF EXISTS tag.tagid_before_verify();
DROP FUNCTION IF EXISTS tag.tag_by_language(iso.alpha2);
DROP FUNCTION IF EXISTS tag.check_tag_array(tag.ltreelower[],tag.ltreelower,text,text);
DROP TABLE IF EXISTS tag.tag;
DROP FUNCTION IF EXISTS tag.tag_before_verify();
DROP DOMAIN IF EXISTS tag.ltreelower;

DROP SCHEMA IF EXISTS tag;
