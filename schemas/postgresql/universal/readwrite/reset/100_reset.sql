/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- universal - reset
-- -----------------------------------------------------------------------------

DROP FUNCTION IF EXISTS universal.apply_table_settings;
DROP FUNCTION IF EXISTS universal.trigger_set_last_updated_at;
DROP FUNCTION IF EXISTS universal.setting_boolean;
DROP PROCEDURE IF EXISTS universal.roles_setup;
DROP PROCEDURE IF EXISTS universal.role_setup;
DROP PROCEDURE IF EXISTS universal.role_create;
DROP PROCEDURE IF EXISTS universal.role_setup_login;
DROP PROCEDURE IF EXISTS universal.role_table_policy;

DROP FUNCTION IF EXISTS universal.uuid_bot;

DROP SCHEMA IF EXISTS universal;