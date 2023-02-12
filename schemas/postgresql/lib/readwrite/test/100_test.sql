/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- lib - test
-- -----------------------------------------------------------------------------

DO $$
DECLARE d_exception_thrown boolean = false;
BEGIN

  -- lib.sql_identifier_* ------------------------------------------------------
  
  PERFORM
    'valid_identifier_lower'::lib.sql_identifier_lower,
    'Valid_identifier_UPPER'::lib.sql_identifier
    ;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(identifier lib.sql_identifier_lower);
    INSERT INTO test.temp VALUES (REPEAT(''a'', 63 + 1));',
    'identifier should be limited to 63 characters'
  );


  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(identifier lib.sql_identifier_lower);
    INSERT INTO test.temp VALUES (REPEAT(''A'', 63));',
    'sql identifier should only contain lower case when using the sql_identifier_lower domain'
  );

  -- Identity and Primary Key Domains ------------------------------------------

  -- lib.key_uuid ------------------------------------------------------------------

  PERFORM '0e366936-9e20-11ed-9810-02d6856f817b'::lib.key_uuid;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_uuid);
    INSERT INTO test.temp VALUES (NULL);',
    'a uuid_pk can not be null',
    'domain lib.key_uuid does not allow null values'
  );

  -- lib.key_str_36 -------------------------------------------------------------

  PERFORM 'rj343343'::lib.key_str_36;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_str_36);
    INSERT INTO test.temp VALUES (NULL);',
    'a id_str_36 can not be null',
    'domain lib.key_str_36 does not allow null values'
  );

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_str_36);
    INSERT INTO test.temp VALUES (REPEAT(''-'', 36 + 1));',
    'a id_str_36 can not have a length greater than 36',
    'value too long for type character varying(36)'
  );


  -- lib.key_uuid_nullable -----------------------------------------------------

  -- supports null
  PERFORM '0e366936-9e20-11ed-9810-02d6856f817b'::lib.key_uuid_nullable,
    NULL::lib.key_uuid_nullable;

  -- lib.key_str_36 -------------------------------------------------------------

  PERFORM 'rj343343'::lib.key_str_36;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_str_36);
    INSERT INTO test.temp VALUES (NULL);',
    'a id_str_36 can not be null',
    'domain lib.key_str_36 does not allow null values'
  );

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_str_36);
    INSERT INTO test.temp VALUES (REPEAT(''-'', 36 + 1));',
    'a id_str_36 can not have a length greater than 36',
    'value too long for type character varying(36)'
  );


  -- lib.key_str_64 -------------------------------------------------------------

  PERFORM 'rj343343'::lib.key_str_64;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_str_64);
    INSERT INTO test.temp VALUES (NULL);',
    'a id_str_64 can not be null',
    'domain lib.key_str_64 does not allow null values'
  );

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_str_64);
    INSERT INTO test.temp VALUES (REPEAT(''-'', 64 + 1));',
    'a id_str_64 can not have a length greater than 64',
    'value too long for type character varying(64)'
  );

  -- lib.key_str_128 -------------------------------------------------------------

  PERFORM 'rj343343'::lib.key_str_128;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_str_128);
    INSERT INTO test.temp VALUES (NULL);',
    'a id_str_128 can not be null',
    'domain lib.key_str_128 does not allow null values'
  );

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_str_128);
    INSERT INTO test.temp VALUES (REPEAT(''-'', 128 + 1));',
    'a id_str_128 can not have a length greater than 128',
    'value too long for type character varying(128)'
  );


  -- lib.key_symbol -------------------------------------------------------------

  PERFORM 'valid_symbol'::lib.key_symbol;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_symbol);
    INSERT INTO test.temp VALUES (NULL);',
    'a lib.key_symbol can not be null',
    'domain lib.key_symbol does not allow null values'
  );

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_symbol);
    INSERT INTO test.temp VALUES (REPEAT(''-'', 128 + 1));',
    'a lib.key_symbol can not have a length greater than 128',
    'value too long for type character varying(128)'
  );

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_symbol);
    INSERT INTO test.temp VALUES (''invalid-symbol'');',
    'a lib.key_symbol can not have a - characgter in it',
    'value for domain lib.key_symbol violates check constraint "symbol_identifier_failed_reglar_expression"'
  );

  -- lib.key_bigint -------------------------------------------------------------

  PERFORM
    (-9223372036854775808)::lib.key_bigint,
    9223372036854775807::lib.key_bigint;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_bigint);
    INSERT INTO test.temp VALUES (NULL);',
    'a lib.key_bigint can not be null',
    'domain lib.key_bigint does not allow null values'
  );

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_int);
    INSERT INTO test.temp VALUES (9223372036854775807+1);',
    'a lib.key_bigint can not exceed bigint range',
    'bigint out of range'
  );


  -- lib.key_int -------------------------------------------------------------

  PERFORM
    (-2147483648)::lib.key_int,
    2147483647::lib.key_int;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_int);
    INSERT INTO test.temp VALUES (NULL);',
    'a lib.key_int can not be null',
    'domain lib.key_int does not allow null values'
  );

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_int);
    INSERT INTO test.temp VALUES (2147483647+1);',
    'a lib.key_int can not exceed integer range',
    'integer out of range'
  );


  -- lib.key_smallint ----------------------------------------------------------

  PERFORM
    (-32768)::lib.key_smallint,
    32767::lib.key_smallint;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_smallint);
    INSERT INTO test.temp VALUES (NULL);',
    'a lib.key_smallint can not be null',
    'domain lib.key_smallint does not allow null values'
  );


  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_smallint);
    INSERT INTO test.temp VALUES (NULL);',
    'a lib.key_smallint can not be null',
    'domain lib.key_smallint does not allow null values'
  );

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_smallint);
    INSERT INTO test.temp VALUES (32767+1);',
    'a lib.key_smallint can not exceed smallint range',
    'smallint out of range'
  );

  -- lib.key_slug_128 ----------------------------------------------------------

  PERFORM
    ''::lib.key_slug_128;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_slug_128);
    INSERT INTO test.temp VALUES (NULL);',
    'a lib.key_slug_128 can not be null',
    'domain lib.key_slug_128 does not allow null values'
  );

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_slug_128);
    INSERT INTO test.temp VALUES (REPEAT(''-'', 128 + 1));',
    'a lib.key_slug_128 can not have a length greater than 128',
    'value too long for type character varying(128)'
  );


  -- lib.key_htag ----------------------------------------------------------

  PERFORM
    'computer.device.monitor'::lib.key_htag,
    'Computer.Device.Monitor'::lib.key_htag;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_htag);
    INSERT INTO test.temp VALUES (NULL);',
    'a lib.key_htag can not be null',
    'domain lib.key_htag does not allow null values'
  );

  -- lib.key_lhtag ----------------------------------------------------------

  PERFORM
    'computer.device.monitor'::lib.key_lhtag;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_lhtag);
    INSERT INTO test.temp VALUES (NULL);',
    'a lib.key_lhtag can not be null',
    'domain lib.key_lhtag does not allow null values'
  );

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.key_lhtag);
    INSERT INTO test.temp VALUES (''Upper.Case.Ltree'');',
    'a lib.key_lhtag can not have upper case characters',
    'value for domain lib.key_lhtag violates check constraint "tag_ltree_lower_case_required"'
  );


  -- ---------------------------------------------------------------------------
  -- Internet related "types" like URLs, email, HTML and CSS Types
  -- ---------------------------------------------------------------------------

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

  -- lib.color_hex -------------------------------------------------------------
  PERFORM
    '#fff'::lib.color_hex,
    '#aabbcc'::lib.color_hex,
    '#000000'::lib.color_hex;

  PERFORM test.it_should_exception(
    'SELECT ''Not a hex color''::lib.color_hex;',
    'color_hex should be a valid color described using hex'
  );


  -- ---------------------------------------------------------------------------
  -- Human Interface domain types like labels, titles, descriptions, names -----
  -- ---------------------------------------------------------------------------

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

  -- lib.name ---------------------------------------------------------------

  PERFORM
    'valid é%'::lib.name,
    ''::lib.name;

  PERFORM test.it_should_exception('
    CREATE TABLE test.temp(rw lib.name);
    INSERT INTO test.temp VALUES (REPEAT(''-'', 512 + 1));',
    'lib.name should be limited to 512 characters'
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

  -- percents ------------------------------------------------------------------

  -- TODO: Tests for percent domains

  -- currencies ----------------------------------------------------------------

  -- TODO: Tests for currency domains

  -- frequencies ----------------------------------------------------------------

  -- TODO: Tests for frequency domains


  ROLLBACK;
END;
$$;
