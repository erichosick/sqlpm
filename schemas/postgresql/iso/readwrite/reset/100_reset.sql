/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- iso - reset
-- -----------------------------------------------------------------------------

DROP TABLE IF EXISTS iso.language_alpha2;
DROP TABLE IF EXISTS iso.country_alpha2;
DROP TABLE IF EXISTS iso.currency_alpha3;

DROP DOMAIN IF EXISTS iso.alpha3;
DROP DOMAIN IF EXISTS iso.alpha2;

DROP SCHEMA iso;