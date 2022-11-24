/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- logging - run
-- -----------------------------------------------------------------------------

-- SCHEMA ----------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS logging;
COMMENT ON SCHEMA logging IS 'contains features around logging, notifications, and notices.';

CALL universal.roles_setup('logging');

-- Logging tags

INSERT INTO tag.tag
( tag_id               , label_short    , label                       , sort_order, description                            ) VALUES
( 'log'                , 'log'          , 'logging'                   , 1         , 'Tags around logging'                  ),
( 'log.lvl'            , 'log level'    , 'logging level'             , 200       , 'Logging levels'                       ),
( 'log.lvl.info'       , 'log info'     , 'logging level information' , 210       , 'Logging some information'             ),
( 'log.lvl.err'        , 'log error'    , 'logging level error'       , 210       , 'Logging an error'                     )
ON CONFLICT DO NOTHING;

CREATE OR REPLACE FUNCTION logging.log_trigger_notify()
RETURNS TRIGGER AS $$
DECLARE d_notification TEXT;
BEGIN
  d_notification = (jsonb_build_object('log_id', NEW.log_id, 'log_group_id', NEW.log_group_id, 'description', NEW.description) || NEW.metadata)::text;

  RAISE NOTICE '%', d_notification;

  -- https://www.postgresql.org/docs/current/sql-notify.html
  PERFORM pg_notify('log', d_notification);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION logging.log_trigger_notify() IS 'On inserting into the log, a notice is raised and the logging_log pg_channel is also notified.';

CREATE TABLE IF NOT EXISTS logging.log (
  log_id uuid NOT NULL DEFAULT uuid_generate_v1(),
  log_group_id uuid NOT NULL,
  log_level_tag_id tag.ltreelower NOT NULL REFERENCES tag.tag(tag_id)
    CONSTRAINT logging_log_level_tag_must_be_in_sub_tree_log_lvl
      CHECK (log_level_tag_id <@ 'log.lvl'),
  description TEXT NOT NULL,
  metadata jsonb NOT NULL DEFAULT '{}',

  CONSTRAINT logging_log_key PRIMARY KEY (log_id)
);

COMMENT ON TABLE  logging.log IS 'A very simple, general purpose log. Notifications (https://www.postgresql.org/docs/current/sql-notify.html) are supported and sent to the log channel. A notice is raised.';
COMMENT ON COLUMN logging.log.log_id IS 'A unique id (uuid) for the entry in this table.';
COMMENT ON COLUMN logging.log.log_group_id IS 'A unique id (uuid) used to group together one or more logged events.';
COMMENT ON COLUMN logging.log.log_level_tag_id IS 'The log level.';

COMMENT ON COLUMN logging.log.description IS 'A description of the log event.';
COMMENT ON COLUMN logging.log.metadata IS 'Additional information about the logged event such as schedule_id, etc.';

SELECT universal.apply_table_settings('logging', 'log');

DO $$ BEGIN
  CREATE TRIGGER logging_log_010_before_upsert BEFORE INSERT ON logging.log
    FOR EACH ROW EXECUTE PROCEDURE logging.log_trigger_notify();
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;


-- -----------------------------------------------------------------------------

-- TODO: Support multi tenant logging
CREATE OR REPLACE PROCEDURE logging.log_info_commit (
  p_log_group_id uuid,
  p_description TEXT,
  metadata jsonb = '{}'
) LANGUAGE plpgsql AS
$$
DECLARE erro text ;
BEGIN
  INSERT INTO logging.log(log_group_id, log_level_tag_id, description, metadata)
  VALUES (
    p_log_group_id,
    'log.lvl.info'::tag.ltreelower,
    p_description,
    metadata
  );
  COMMIT;
END;
$$;

CREATE OR REPLACE PROCEDURE logging.log_error_commit (
  p_log_group_id uuid,
  p_description TEXT,
  metadata jsonb = '{}'
) LANGUAGE plpgsql AS
$$
DECLARE erro text ;
BEGIN
  INSERT INTO logging.log(log_group_id, log_level_tag_id, description, metadata)
  VALUES (
    p_log_group_id,
    'log.lvl.err'::tag.ltreelower,
    p_description,
    metadata
  );
 COMMIT;
END;
$$;

CREATE TABLE IF NOT EXISTS noprop ();