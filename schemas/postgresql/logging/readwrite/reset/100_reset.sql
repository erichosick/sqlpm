/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- logging - reset
-- -----------------------------------------------------------------------------

DROP PROCEDURE logging.log_info_commit(uuid,text,jsonb);
DROP PROCEDURE logging.log_error_commit(uuid,text,jsonb);
DROP TABLE logging.log;
DROP FUNCTION logging.log_trigger_notify();

DROP SCHEMA IF EXISTS logging;
