/* Copyright (c) 2022 Eric Hosick All Rights Reserved */

-- -----------------------------------------------------------------------------
-- tag - test
-- -----------------------------------------------------------------------------

DO $$
BEGIN

  INSERT INTO tag.tag
  ( tag_id        , label_short  , label           , sort_order, tagid_range, description                      ) VALUES
  ( 'per2'         , 'per2 types'  , 'per2 types'     , 1         , '[0,100]'  , 'Types of legal entites'         ),
  ( 'per2.per2son'  , 'per2son'     , 'per2 per2son'    , 100000    , null       , 'A per2son'                       ),
  ( 'per2.per2sona' , 'per2sona'    , 'per2 per2sona'   , 100000    , null       , 'A per2sona someone has taken on' ),
  ( 'derp'        , 'derposan'   , 'derpadederp'   , 100000    , null       , 'Just a derp of derping'         )
  ;

  PERFORM test.it_should_exception(
  'INSERT INTO tag.tag
  ( tag_id        , label_short  , label           , sort_order, tagid_range, description                      ) VALUES
  ( ''per2.other''   , ''other''      , ''per2 other''     , 100000    , ''[101,200]'', ''Other types of legal entities''  );',
  'should error with: DETAIL:  Failing row (per2.other) attempted to add a tagid range already defined in a descendant.'
  );

  PERFORM test.it_should_exception(
  'INSERT INTO tag.tag
  ( tag_id        , label_short  , label           , sort_order, tagid_range, description                      ) VALUES
  ( ''per2.Other''   , ''other''      , ''per2 other''     , 100000    , null, ''Other types of legal entities''  );',
  'PostgresError (code 23514) value for domain tag.ltreelower violates check constraint "tag_ltree_lower_case_required'
  );

  PERFORM test.it_should_exception(
  'INSERT INTO tag.tagid
  ( tagid_id,  tag_id       ) VALUES
  ( 1000    , ''per2.per2sona'' );',
  'should error with: DETAIL:  Failing row (%) attempted to add a tagid_id value that is not within a range defined by a descendant to (%).'
  );

  PERFORM test.it_should_exception(
  'INSERT INTO tag.tagid
  ( tagid_id,  tag_id       ) VALUES
  ( 20    , ''derp.stuff'' );',
  'should error with: DETAIL:  Failing row (%) attempted to add a tagid_id value that is not within a range defined by a descendant to (%).'
  );

  -- TODO: Improve testing on tagging.

  ROLLBACK;
END;
$$;
