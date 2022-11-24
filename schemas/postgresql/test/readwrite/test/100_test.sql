/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- test - test
-- -----------------------------------------------------------------------------

DO $$
BEGIN

  PERFORM test.it_should_exception('
    RAISE EXCEPTION "A url should be case-insensitive.";',
    'It should catch an exception'
  );

END $$;