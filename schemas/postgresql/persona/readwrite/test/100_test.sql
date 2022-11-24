/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- persona - test
-- -----------------------------------------------------------------------------

DO $$
BEGIN

  -- TODO: Persona only testing

  -- -----------------------------------------------------------------------------
  -- persona + universal - test
  -- NOTE: For multi tenant, the persona schema is required. So, tests can not
  -- be done in the universal schema. We are testing both the universal schema
  -- and persona schema's usage of the universal schema with these tests.
  -- -----------------------------------------------------------------------------

  -- no value SET

  IF NOT (universal.setting_boolean('my.test.novalue') = false) THEN
    RAISE EXCEPTION 'universal.setting_boolean should have been false when my.test.novalue was not set';
  END IF;

  IF NOT (universal.setting_boolean('my.test.novalue', false) = false) THEN
    RAISE EXCEPTION 'universal.setting_boolean should have been false when my.test.novalue was not set and a false default provided';
  END IF;

  IF NOT (universal.setting_boolean('my.test.novalue', true) = true) THEN
    RAISE EXCEPTION 'universal.setting_boolean should have been true when my.test.novalue was not set and a true default is provided';
  END IF;

  IF NOT (universal.setting_boolean('my.test.novalue', true, false) = false) THEN
    RAISE EXCEPTION 'universal.setting_boolean should have been false when overide is false: ignoring the default';
  END IF;


  SET my.test.bvalue = true;

  IF NOT (universal.setting_boolean('my.test.bvalue') = true) THEN
    RAISE EXCEPTION 'universal.setting_boolean should have been true when my.test.bvalue was set to true';
  END IF;

  IF NOT (universal.setting_boolean('my.test.bvalue', false) = true) THEN
    RAISE EXCEPTION 'universal.setting_boolean should have been true when my.test.bvalue was set to true and a false default provided';
  END IF;

  IF NOT (universal.setting_boolean('my.test.bvalue', true, false) = false) THEN
    RAISE EXCEPTION 'universal.setting_boolean should have been false when overide is false: ignoring the default and ignoring that my.test.bvalue was set to true';
  END IF;

  CREATE TABLE universal.test_table (
    id int
  );

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns AS col
    WHERE col.table_schema = 'universal' AND col.table_name = 'test_table'
    HAVING COUNT(*) = 1
  ) THEN
    RAISE EXCEPTION 'test table universal.test_table should have one column.';
  END IF; 


  PERFORM set_config('my.settings.original.multi_tenant', current_setting('my.settings.multi_tenant', true), false);
  PERFORM set_config('my.settings.original.created_at_column.add_to_table', current_setting('my.settings.created_at_column.add_to_table', true), false);
  PERFORM set_config('my.settings.original.last_updated_at_column.add_to_table', current_setting('my.settings.last_updated_at_column.add_to_table', true), false);
  SET my.settings.multi_tenant = true;
  SET my.settings.created_at_column.add_to_table = true;
  SET my.settings.last_updated_at_column.add_to_table = true;

  PERFORM universal.apply_table_settings(
    'universal',
    'test_table',
    '{
      "multi_tenant": false,
      "created_at_column": {
        "add_to_table": false
      },
      "last_updated_at_column": {
        "add_to_table": false
      }
    }'::jsonb
  );

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns AS col
    WHERE col.table_schema = 'universal' AND col.table_name = 'test_table'
    HAVING COUNT(*) = 1
  ) THEN
    RAISE EXCEPTION 'test table universal.test_table should still have one column when all values are overriden with false';
  END IF; 

  PERFORM universal.apply_table_settings(
    'universal',
    'test_table',
    '{
      "created_at_column": {
        "add_to_table": false
      },
      "last_updated_at_column": {
        "add_to_table": false
      }
    }'::jsonb
  );

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns AS col
    WHERE col.table_schema = 'universal' AND col.table_name = 'test_table'
    HAVING COUNT(*) = 2
  ) THEN
    RAISE EXCEPTION 'test table universal.test_table should have two columns, when all values except multi_tenant are overriden with false';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns AS col
    WHERE col.table_schema = 'universal' AND col.table_name = 'test_table' AND col.column_name = 'tenant_persona_id'
  ) THEN
    RAISE EXCEPTION 'test table universal.test_table should have column tenant_persona_id';
  END IF;

  PERFORM universal.apply_table_settings(
    'universal',
    'test_table'
  );

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns AS col
    WHERE col.table_schema = 'universal' AND col.table_name = 'test_table'
    HAVING COUNT(*) = 4
  ) THEN
    RAISE EXCEPTION 'test table universal.test_table should have two columns, when no values are overriden with false ';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns AS col
    WHERE col.table_schema = 'universal' AND col.table_name = 'test_table' AND col.column_name = 'created_at'
  ) THEN
    RAISE EXCEPTION 'test table universal.test_table should have column created_at';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns AS col
    WHERE col.table_schema = 'universal' AND col.table_name = 'test_table' AND col.column_name = 'last_updated_at'
  ) THEN
    RAISE EXCEPTION 'test table universal.test_table should have column last_updated_at';
  END IF;

  PERFORM set_config('my.settings.multi_tenant', current_setting('my.settings.original.multi_tenant', true), false);
  PERFORM set_config('my.settings.created_at_column.add_to_table', current_setting('my.settings.original.created_at_column.add_to_table', true), false);
  PERFORM set_config('my.settings.last_updated_at_column.add_to_table', current_setting('my.settings.original.last_updated_at_column.add_to_table', true), false);

  ROLLBACK;
END;
$$;
