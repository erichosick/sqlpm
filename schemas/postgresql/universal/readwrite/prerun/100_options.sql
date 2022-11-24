/* Copyright (c) 2022 Eric Hosick All Rights Reserved. See LICENSE.md. */

-- -----------------------------------------------------------------------------
-- universal - prerun
-- -----------------------------------------------------------------------------

-- When true, where required, tables will contain a mult-tenant column used to
-- assign an owner to that column named tenant_persona_id
SET my.settings.multi_tenant = true;

-- When true, data for a given table could have multiple sources. A column
-- named source_persona_id is provided noting the source of the entity.
SET my.settings.multi_source = false;

-- When true, a primary key column will be added to every table even when it is
-- likely the column is not necessary: bridge tables for example. When false,
-- a single primary key column will only be added to tables that require it.
-- The column name is always the table name with _id appended to it. For
-- example, if the table is named 'deal' then a primary key column will be
-- created with the name 'deal_id'.
SET my.settings.pk_on_every_table = false;


-- When true, a created at column will be added to the table. When false,
-- no created_at column is added.
SET my.settings.created_at_column.add_to_table = true;
SET my.settgins.created_at_column.locked_roles = 'mutator';

-- When true, an updated at column will be added to the table. When false,
-- no updated column is added.
SET my.settings.last_updated_at_column.add_to_table = true;
SET my.settgins.last_updated_at_column.locked_roles = 'mutator';