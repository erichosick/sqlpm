/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- lib - test
-- -----------------------------------------------------------------------------

DO $$
DECLARE d_exception_thrown boolean = false;
BEGIN

  -- lib.url ----------------------------------------------------------------

  -- TODO: implement url validation code.
  PERFORM 'https:://www.derp.com'::lib.url;

  IF NOT EXISTS (
    SELECT 1
    WHERE 'https:://www.derp.com'::lib.url = 'HTTPS:://WWW.derp.com'::lib.url
  ) THEN
    RAISE EXCEPTION 'A url should be case-insensitive.';
  END IF;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.url);
    INSERT INTO test.temp VALUES (REPEAT(''-'', 2047 + 1));',
    'label should be limited to 2047 characters'
  );

  -- lib.label --------------------------------------------------------------
  PERFORM
    'valid label'::lib.label,
    'valid é%'::lib.label,
    ''::lib.label;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.label);
    INSERT INTO test.temp VALUES (REPEAT(''-'', 128 + 1));',
    'lib.label should be limited to 128 characters'
  );

  -- lib.label_short --------------------------------------------------------
  PERFORM
    'valid é%'::lib.label_short,
    ''::lib.label_short;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.label_short);
    INSERT INTO test.temp VALUES (REPEAT(''-'', 32 + 1));',
    'lib.label_short should be limited to 32 characters'
  );

  -- lib.title --------------------------------------------------------------
  PERFORM
    'valid é%'::lib.title,
    ''::lib.title;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.title);
    INSERT INTO test.temp VALUES (REPEAT(''-'', 128 + 1));',
    'lib.title should be limited to 128 characters'
  );

  -- lib.description --------------------------------------------------------
  PERFORM
    'valid é%'::lib.description,
    ''::lib.description;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.description);
    INSERT INTO test.temp VALUES (REPEAT(''-'', 4096 + 1));',
    'lib.description should be limited to 4096 characters'
  );

  -- lib.name ---------------------------------------------------------------
  PERFORM
    'valid é%'::lib.name,
    ''::lib.name;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.name);
    INSERT INTO test.temp VALUES (REPEAT(''-'', 512 + 1));',
    'lib.name should be limited to 512 characters'
  );

  -- lib.color_hex ---------------------------------------------------------------
  PERFORM
    '#fff'::lib.color_hex,
    '#aabbcc'::lib.color_hex,
    '#000000'::lib.color_hex;

  PERFORM test.it_should_exception(
    'SELECT ''Not a hex color''::lib.color_hex;',
    'color_hex should be a valid color described using hex'
  );

  ROLLBACK;
END;
$$;
