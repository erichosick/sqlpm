/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- settings - test
-- -----------------------------------------------------------------------------

-- Test Code

DO $$
BEGIN

  -- no value SET

  IF NOT (settings.get_boolean('my.test.novalue') = false) THEN
    RAISE EXCEPTION 'settings.get_boolean should have been false when my.test.novalue was not set';
  END IF;

  IF NOT (settings.get_boolean('my.test.novalue', false) = false) THEN
    RAISE EXCEPTION 'settings.get_boolean should have been false when my.test.novalue was not set and a false default provided';
  END IF;

  IF NOT (settings.get_boolean('my.test.novalue', true) = true) THEN
    RAISE EXCEPTION 'settings.get_boolean should have been true when my.test.novalue was not set and a true default is provided';
  END IF;

  IF NOT (settings.get_boolean('my.test.novalue', true, false) = false) THEN
    RAISE EXCEPTION 'settings.get_boolean should have been false when overide is false: ignoring the default';
  END IF;

  PERFORM SET_CONFIG('my.test.empty_value', NULL, false);

  IF NOT (settings.get_boolean('my.test.empty_value') = false) THEN
    RAISE EXCEPTION 'my.test.empty_value should have been set to an empty string meaning the default of false is returned';
  END IF;


  -- value set

  SET my.test.bvalue = true;

  IF NOT (settings.get_boolean('my.test.bvalue') = true) THEN
    RAISE EXCEPTION 'settings.get_boolean should have been true when my.test.bvalue was set to true';
  END IF;

  IF NOT (settings.get_boolean('my.test.bvalue', false) = true) THEN
    RAISE EXCEPTION 'settings.get_boolean should have been true when my.test.bvalue was set to true and a false default provided';
  END IF;

  IF NOT (settings.get_boolean('my.test.bvalue', true, false) = false) THEN
    RAISE EXCEPTION 'settings.get_boolean should have been false when overide is false: ignoring the default and ignoring that my.test.bvalue was set to true';
  END IF;

  PERFORM test.it_should_exception('
    SET my.test.bvalue = ''not a boolean'';
    SELECT settings.get_boolean(''my.test.bvalue'');
    ',
    'testrole, by default, should not have insert permissions on test_role_policy table.'
  );

  ROLLBACK;

END $$;