/* Copyright (c) 2022 Eric Hosick All Rights Reserved */

-- SCHEMA ----------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS test;
COMMENT ON SCHEMA test IS 'contains resources that can be used for testing';

-- FUNCTIONS -------------------------------------------------------------------

CREATE OR REPLACE FUNCTION test.it_should_exception (
  p_sql_statement varchar,
  p_test_message varchar,
  p_sqlerrm_expected varchar = ''
) RETURNS void LANGUAGE plpgsql AS
$$
DECLARE d_exception_thrown boolean = false;
DECLARE d_sqlerrm varchar;
DECLARE d_sqlstate varchar;
BEGIN
  BEGIN
    EXECUTE p_sql_statement;
  EXCEPTION
    WHEN others THEN
      d_exception_thrown = true;
      d_sqlerrm = SQLERRM;
      d_sqlstate = SQLSTATE;
  END;

  IF d_exception_thrown = false THEN
    RAISE EXCEPTION '%', p_test_message;
  ELSIF p_sqlerrm_expected <> '' AND d_sqlerrm <> p_sqlerrm_expected THEN
    RAISE EXCEPTION 'Expected SQLERRM to be ''%'' but was ''%''', p_sqlerrm_expected, d_sqlerrm;
  END IF;
END;
$$;
COMMENT ON FUNCTION test.it_should_exception IS 'Executest the sql provided in p_sql_statement: expecting an exception of any kind to be thrown. The p_test_message is displayed if no exceptoin is thrown.';
