/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- iso - test
-- -----------------------------------------------------------------------------

DO $$
BEGIN

  IF NOT EXISTS (
    SELECT COUNT(*)
    FROM iso.language_alpha2
    HAVING COUNT(*) > 1
  ) THEN
    RAISE EXCEPTION 'The iso.language_alpha2 should have been seeded with languages. ';
  END IF;

END $$;