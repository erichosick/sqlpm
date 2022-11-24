DO $$
BEGIN

-- -----------------------------------------------------------------------------
-- test - test
-- 
-- -----------------------------------------------------------------------------

  PERFORM test.it_should_exception('
    RAISE EXCEPTION "A url should be case-insensitive.";',
    'It should catch an exception'
  );

END $$;