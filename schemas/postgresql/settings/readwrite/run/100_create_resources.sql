/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- settings - run
-- -----------------------------------------------------------------------------

-- SCHEMA ----------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS settings;
COMMENT ON SCHEMA settings IS 'contains helper functions for using PostgreSQL configuration settings';


-- FUNCTIONS -------------------------------------------------------------------

CREATE OR REPLACE FUNCTION settings.get_boolean (
  p_setting_name text,
  p_default_value boolean = false,
  p_override_value boolean = null
)
RETURNS boolean AS $$
DECLARE
  d_setting_value text;
BEGIN
  IF p_override_value IS NOT NULL THEN
    RETURN p_override_value;
  END IF;
  
  d_setting_value = CURRENT_SETTING(p_setting_name, true);
  
  -- NOTE: calling SET_CONFIG to set a value of NULL results in a empty string
  -- when that setting is read. So, we need to check for ''.
  IF NULLIF(d_setting_value, '') IS NULL THEN
    RETURN p_default_value;
  END IF;
  
  IF d_setting_value = 'true' OR d_setting_value = 'false' THEN
    RETURN d_setting_value::boolean;
  ELSE
    RAISE EXCEPTION 'The setting % contained a non boolean value (''%''). Possible values are true or false.', p_setting_name, d_setting_value;
  END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION settings.get_boolean IS
'Safely retrieves the value of a boolean configuration setting. If p_override_value is not null, that value is returned and all other logic is ignored. If the setting was not defined, then the value provided by p_default_value is returned.

Example: SELECT settings.get_boolean(''my_setting'', true, null);

@setting_name - The name of the setting to retrieve.
@default_value - The default value to return if the setting is not set.
@override_value - The value to return if not null, otherwise the function returns the value from the setting.
Exceptions:
  - If the setting value is not a boolean, then an exception is raised.
';
