/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- persona - reset
-- -----------------------------------------------------------------------------

DROP TABLE IF EXISTS persona.persona_social_external;
DROP TABLE IF EXISTS persona.persona_social;
DROP VIEW IF EXISTS persona.persona_score_total;
DROP TABLE IF EXISTS persona.persona_score;
DROP VIEW IF EXISTS persona.persona_last_activity;
DROP VIEW IF EXISTS persona.persona_persona_count;
DROP TABLE IF EXISTS persona.persona_persona;
DROP TABLE IF EXISTS persona.persona_external;
DROP TABLE IF EXISTS persona.persona_url;
DROP VIEW IF EXISTS persona.persona_admin;
DROP VIEW IF EXISTS persona.persona_detail;
DROP TABLE IF EXISTS persona.persona;

DROP SCHEMA IF EXISTS persona;
