--
-- acs-kernel/sql/acs-permissions-create.sql
--
-- The ACS core permissioning system. The knowledge level of system
-- allows you to define a hierarchichal system of privilages.  The
-- operational level allows you to grant to any party a privilege on
-- any object.
--
-- @author Rafael Schloming (rhs@mit.edu)
--
-- @creation-date 2000-08-13
--
-- @cvs-id $Id: acs-permissions-create.sql,v 1.6 2015/12/04 13:49:25 cvs Exp $
--


---------------------------------------------
-- KNOWLEDGE LEVEL: PRIVILEGES AND ACTIONS --
---------------------------------------------

create table acs_privileges (
	privilege	varchar(100) not null constraint acs_privileges_privilege_pk
			primary key,
	pretty_name	varchar(100),
	pretty_plural	varchar(100)
);

create table acs_privilege_hierarchy (
	privilege	varchar(100) not null 
                        constraint acs_priv_hier_priv_fk
			references acs_privileges (privilege),
        child_privilege	varchar(100) not null 
                        constraint acs_priv_hier_child_priv_fk
			references acs_privileges (privilege),
	constraint acs_privilege_hierarchy_pk
	primary key (privilege, child_privilege)
);

create index acs_priv_hier_child_priv_idx on acs_privilege_hierarchy (child_privilege);

create table acs_privilege_hierarchy_index (
	privilege       varchar(100) not null 
                        constraint acs_priv_hier_priv_fk
			references acs_privileges (privilege),
        child_privilege varchar(100) not null 
                        constraint acs_priv_hier_child_priv_fk
			references acs_privileges (privilege),
        tree_sortkey    varbit
);

create index priv_hier_sortkey_idx on 
acs_privilege_hierarchy_index (tree_sortkey);

-- Added table to materialize view that previously used 
-- acs_privilege_descendant_map name
--
-- DanW (dcwickstrom@earthlink.net) 30 Jan, 2003

create table acs_privilege_descendant_map (
	privilege       varchar(100) not null 
                        constraint acs_priv_hier_priv_fk
			references acs_privileges (privilege),
        descendant      varchar(100) not null 
                        constraint acs_priv_hier_child_priv_fk
			references acs_privileges (privilege)

);

-- DRB: Empirical testing showed that even with just 61 entries in the new table
-- this index sped things up by roughly 15%

create index acs_priv_desc_map_idx on acs_privilege_descendant_map(descendant);

-- Gustaf (Jan 2009): interesting enough, the index above is never
-- used on openacs.org and can be most likely dropped. The index below
-- (together with acs_obj_ctx_idx_object_id_idx) makes real-world
-- applications more than a factor of 10 faster (openacs/download and
-- openacs/download/one-revision?revision_id=2089636)
create index acs_priv_desc_map_privilege_idx on acs_privilege_descendant_map (privilege);

-- This trigger is used to create a pseudo-tree hierarchy that
-- can be used to emulate tree queries on the acs_privilege_hierarchy table.
-- The acs_privilege_hierarchy table maintains the permissions structure, but 
-- it has a complication in that the same privileges can exist in more than one
-- path in the tree.  As such, tree queries cannot be represented by the 
-- usual tree query methods used for openacs.  

-- DCW, 2001-03-15.

-- usage: queries directly on acs_privilege_hierarchy don't seem to occur
--        in many places.  Rather it seems that acs_privilege_hierarchy is
--        used to build the view: acs_privilege_descendant_map.  I did however
--        find one tree query in content-perms.sql that looks like the 
--        following:

-- select privilege, child_privilege from acs_privilege_hierarchy
--           connect by prior privilege = child_privilege
--           start with child_privilege = 'cm_perm'

-- This query is used to find all of the ancestor permissions of 'cm_perm'. 
-- The equivalent query for the postgresql tree-query model would be:

-- select  h2.privilege 
--   from acs_privilege_hierarchy_index h1, 
--        acs_privilege_hierarchy_index h2
--  where h1.child_privilege = 'cm_perm'
--    and h1.tree_sortkey between h2.tree_sortkey and tree_right(h2.tree_sortkey)
--    and h2.tree_sortkey <> h1.tree_sortkey;

-- Also since acs_privilege_descendant_map is simply a path enumeration of
-- acs_privilege_hierarchy, we should be able to replace the above connect-by
-- with: 

-- select privilege 
-- from acs_privilege_descendant_map 
-- where descendant = 'cm_perm'

-- This would be better, since the same query could be used for both oracle
-- and postgresql.



--
-- procedure acs_priv_hier_ins_del_tr/0
--
CREATE OR REPLACE FUNCTION acs_priv_hier_ins_del_tr(

) RETURNS trigger AS $$
DECLARE
        new_value       integer;
        new_key         varbit default null;
        v_rec           record;
        deleted_p       boolean;
BEGIN

        -- if more than one node was deleted the second trigger call
        -- will error out.  This check avoids that problem.

        if TG_OP = 'DELETE' then 
            select count(*) = 0 into deleted_p
              from acs_privilege_hierarchy_index 
             where old.privilege = privilege
               and old.child_privilege = child_privilege;     
       
            if deleted_p then

                return new;

            end if;
        end if;

        -- recalculate the table from scratch.

        delete from acs_privilege_hierarchy_index;

        -- first find the top nodes of the tree

        for v_rec in select privilege, child_privilege
                       from acs_privilege_hierarchy
                      where privilege 
                            NOT in (select distinct child_privilege
                                      from acs_privilege_hierarchy)
                                           
        LOOP

            -- top level node, so find the next key at this level.

            select max(tree_leaf_key_to_int(tree_sortkey)) into new_value 
              from acs_privilege_hierarchy_index
             where tree_level(tree_sortkey) = 1;

             -- insert the new node

            insert into acs_privilege_hierarchy_index 
                        (privilege, child_privilege, tree_sortkey)
                        values
                        (v_rec.privilege, v_rec.child_privilege, tree_next_key(null, new_value));

            -- now recurse down from this node

            PERFORM priv_recurse_subtree(tree_next_key(null, new_value), v_rec.child_privilege);

        end LOOP;

        -- materialize the map view to speed up queries
        -- DanW (dcwickstrom@earthlink.net) 30 Jan, 2003
        delete from acs_privilege_descendant_map;

        insert into acs_privilege_descendant_map (privilege, descendant) 
        select privilege, descendant from acs_privilege_descendant_map_view;

        return new;

END;
$$ LANGUAGE plpgsql;

create trigger acs_priv_hier_ins_del_tr after insert or delete
on acs_privilege_hierarchy for each row
execute procedure acs_priv_hier_ins_del_tr ();

CREATE OR REPLACE FUNCTION acs_priv_del_tr () RETURNS trigger AS $$
BEGIN

  delete from acs_privilege_descendant_map
  where privilege = old.privilege;

  return old;

END;
$$ LANGUAGE plpgsql;

create trigger acs_priv_del_tr before delete
on acs_privileges for each row
execute procedure acs_priv_del_tr ();



-- added
select define_function_args('priv_recurse_subtree','nkey,child_priv');

--
-- procedure priv_recurse_subtree/2
--
CREATE OR REPLACE FUNCTION priv_recurse_subtree(
   nkey varbit,
   child_priv varchar
) RETURNS integer AS $$
DECLARE
        new_value       integer;
        v_rec           record;
        new_key         varbit;
BEGIN

        -- now iterate over all of the children of the 
        -- previous node.
        
        for v_rec in select privilege, child_privilege
                       from acs_privilege_hierarchy
                      where privilege = child_priv

        LOOP

            -- calculate the next key for this level and parent

            select max(tree_leaf_key_to_int(tree_sortkey)) into new_value
              from acs_privilege_hierarchy_index
             where tree_sortkey between nkey and tree_right(nkey)
               and tree_level(tree_sortkey) = tree_level(nkey) + 1;

            new_key := tree_next_key(nkey, new_value);

            -- insert the new child node.

            insert into acs_privilege_hierarchy_index
                        (privilege, child_privilege, tree_sortkey)
                        values
                        (v_rec.privilege, v_rec.child_privilege, new_key);

            -- keep recursing down until no more children are found

            PERFORM priv_recurse_subtree(new_key, v_rec.child_privilege);

        end LOOP;

        -- no children found, so insert the child node as its own separate 
        -- node.

        if NOT FOUND then
           insert into acs_privilege_hierarchy_index
                       (privilege, child_privilege, tree_sortkey)
                       values 
                       (child_priv, child_priv, tree_next_key(nkey, null));
        end if;

        return null;

END;
$$ LANGUAGE plpgsql;

comment on table acs_privileges is '
 Privileges share a global namespace. This is to avoid a
 situation where granting the foo privilege on one type of object can
 have an entirely different meaning than granting the foo privilege on
 another type of object.
';

comment on table acs_privilege_hierarchy is '
 The acs_privilege_hierarchy gives us an easy way to say: The foo
 privilege is a superset of the bar privilege.
';



-- added
select define_function_args('acs_privilege__create_privilege','privilege,pretty_name;null,pretty_plural;null');

--
-- procedure acs_privilege__create_privilege/3
--
CREATE OR REPLACE FUNCTION acs_privilege__create_privilege(
   create_privilege__privilege varchar,
   create_privilege__pretty_name varchar,  -- default null
   create_privilege__pretty_plural varchar -- default null

) RETURNS integer AS $$
DECLARE
BEGIN
    insert into acs_privileges
     (privilege, pretty_name, pretty_plural)
    values
     (create_privilege__privilege, 
      create_privilege__pretty_name, 
      create_privilege__pretty_plural);
      
    return 0; 
END;
$$ LANGUAGE plpgsql;



--
-- procedure acs_privilege__create_privilege/1
--
CREATE OR REPLACE FUNCTION acs_privilege__create_privilege(
   create_privilege__privilege varchar
) RETURNS integer AS $$
DECLARE
BEGIN
    return acs_privilege__create_privilege(create_privilege__privilege, null, null);
END;
$$ LANGUAGE plpgsql;




-- added
select define_function_args('acs_privilege__drop_privilege','privilege');

--
-- procedure acs_privilege__drop_privilege/1
--
CREATE OR REPLACE FUNCTION acs_privilege__drop_privilege(
   drop_privilege__privilege varchar
) RETURNS integer AS $$
DECLARE
BEGIN
    delete from acs_privileges
    where privilege = drop_privilege__privilege;

    return 0; 
END;
$$ LANGUAGE plpgsql;



-- added
select define_function_args('acs_privilege__add_child','privilege,child_privilege');

--
-- procedure acs_privilege__add_child/2
--
CREATE OR REPLACE FUNCTION acs_privilege__add_child(
   add_child__privilege varchar,
   add_child__child_privilege varchar
) RETURNS integer AS $$
DECLARE
BEGIN
    insert into acs_privilege_hierarchy
     (privilege, child_privilege)
    values
     (add_child__privilege, add_child__child_privilege);

    return 0; 
END;
$$ LANGUAGE plpgsql;



-- added
select define_function_args('acs_privilege__remove_child','privilege,child_privilege');

--
-- procedure acs_privilege__remove_child/2
--
CREATE OR REPLACE FUNCTION acs_privilege__remove_child(
   remove_child__privilege varchar,
   remove_child__child_privilege varchar
) RETURNS integer AS $$
DECLARE
BEGIN
    delete from acs_privilege_hierarchy
    where privilege = remove_child__privilege
    and child_privilege = remove_child__child_privilege;

    return 0; 
END;
$$ LANGUAGE plpgsql;


------------------------------------
-- OPERATIONAL LEVEL: PERMISSIONS --
------------------------------------

create table acs_permissions (
	object_id		integer not null
				constraint acs_permissions_object_id_fk
				references acs_objects (object_id)
                                on delete cascade,
	grantee_id		integer not null
				constraint acs_permissions_grantee_id_fk
				references parties (party_id)
                                on delete cascade,
	privilege		varchar(100) not null 
                                constraint acs_permissions_privilege_fk
				references acs_privileges (privilege)
                                on delete cascade,
	constraint acs_permissions_pk
	primary key (object_id, grantee_id, privilege)
);

create index acs_permissions_grantee_idx on acs_permissions (grantee_id);
create index acs_permissions_privilege_idx on acs_permissions (privilege);
create index acs_permissions_object_id_idx on acs_permissions(object_id);

-- Added table to materialize view that previously used 
-- acs_privilege_descendant_map name
--
-- DanW (dcwickstrom@earthlink.net) 30 Jan, 2003

-- DRB: I switched this to UNION form because the old view was incredibly
-- slow and caused installation of packages to take exponentially increasing
-- time.   No code should be querying against this view other than the
-- trigger that recreates the denormalized map anyway ...

create view acs_privilege_descendant_map_view
as select distinct h1.privilege, h2.child_privilege as descendant
   from acs_privilege_hierarchy_index h1, acs_privilege_hierarchy_index h2
   where h2.tree_sortkey between h1.tree_sortkey and tree_right(h1.tree_sortkey)
   union
   select privilege, privilege
   from acs_privileges;

create view acs_permissions_all
as select op.object_id, p.grantee_id, p.privilege
   from acs_object_paths op, acs_permissions p
   where op.ancestor_id = p.object_id;

create view acs_object_grantee_priv_map
as select a.object_id, a.grantee_id, m.descendant as privilege
   from acs_permissions_all a, acs_privilege_descendant_map m
   where a.privilege = m.privilege;

-- New fast version of acs_object_party_privilege_map

create view acs_object_party_privilege_map as
select c.object_id, pdm.descendant as privilege, pamm.member_id as party_id
from acs_object_context_index c, acs_permissions p, acs_privilege_descendant_map pdm,
  party_approved_member_map pamm
where c.ancestor_id = p.object_id
  and pdm.privilege = p.privilege
  and pamm.party_id = p.grantee_id;

create view all_object_party_privilege_map as
select * from acs_object_party_privilege_map;


-- This table acts as a mutex for inserts/deletes from acs_permissions.
-- This is used since postgresql's exception handing mechanism is non-
-- existant.  A dup insert on acs_permissions will roll-back the 
-- transaction and give an error, which is not what we want.  Using a 
-- separate table for locking allows us exclusive access for 
-- inserts/deletes, but does not block readers.  That way we don't 
-- slow down permissions-checking which is known to have performance 
-- problems already.

-- (OpenACS - DanW)

create table acs_permissions_lock (
       lck  integer
);

CREATE OR REPLACE FUNCTION acs_permissions_lock_tr () RETURNS trigger AS $$
BEGIN
        raise EXCEPTION 'FOR LOCKING ONLY, NO DML STATEMENTS ALLOWED';
        return null;
END;
$$ LANGUAGE plpgsql;

create trigger acs_permissions_lock_tr 
before insert or update or delete on acs_permissions_lock
for each row execute procedure acs_permissions_lock_tr();



-- added
select define_function_args('acs_permission__grant_permission','object_id,grantee_id,privilege');

--
-- procedure acs_permission__grant_permission/3
--
CREATE OR REPLACE FUNCTION acs_permission__grant_permission(
   grant_permission__object_id integer,
   grant_permission__grantee_id integer,
   grant_permission__privilege varchar
) RETURNS integer AS $$
DECLARE
BEGIN
    insert into acs_permissions
      (object_id, grantee_id, privilege)
      values
      (grant_permission__object_id, grant_permission__grantee_id, 
      grant_permission__privilege);
    
    return 0;
EXCEPTION 
    when unique_violation then
      return 0;
END;
$$ LANGUAGE plpgsql;


-- procedure revoke_permission


-- added
select define_function_args('acs_permission__revoke_permission','object_id,grantee_id,privilege');

--
-- procedure acs_permission__revoke_permission/3
--
CREATE OR REPLACE FUNCTION acs_permission__revoke_permission(
   revoke_permission__object_id integer,
   revoke_permission__grantee_id integer,
   revoke_permission__privilege varchar
) RETURNS integer AS $$
DECLARE
BEGIN
    delete from acs_permissions
    where object_id = revoke_permission__object_id
    and grantee_id = revoke_permission__grantee_id
    and privilege = revoke_permission__privilege;

    return 0; 
END;
$$ LANGUAGE plpgsql;

-- Really speedy version of permission_p written by Don Baccus



-- added
select define_function_args('acs_permission__permission_p','object_id,party_id,privilege');


CREATE FUNCTION inline_0()
RETURNS integer AS $inline_0$
BEGIN

    raise notice 'starting permissions recursive -- vguerra';

    IF cmp_pg_version('8.4') >= 0 THEN
        -- recursive site_nodes recursive - START

        --
        -- procedure acs_permission__permission_p/3
        --
        CREATE OR REPLACE FUNCTION acs_permission__permission_p(
           permission_p__object_id integer,
           permission_p__party_id integer,
           permission_p__privilege varchar
        ) RETURNS boolean AS $$
        DECLARE
            exists_p                          boolean;
        BEGIN
            return exists (With RECURSIVE object_context(object_id, context_id) AS (

                    select permission_p__object_id, permission_p__object_id 
                    from acs_objects 
                    where object_id = permission_p__object_id

                    union all

                    select ao.object_id,
                    case when (ao.security_inherit_p = 'f' or ao.context_id is null) 
                    then acs__magic_object_id('security_context_root') else ao.context_id end
                    from object_context oc, acs_objects ao
                    where ao.object_id = oc.context_id
                    and ao.object_id != acs__magic_object_id('security_context_root')

                ), privilege_ancestors(privilege, child_privilege) AS (

                    select permission_p__privilege, permission_p__privilege 
                   
                    union all

                    select aph.privilege, aph.child_privilege
                    from privilege_ancestors pa join acs_privilege_hierarchy aph
                    on aph.child_privilege = pa.privilege

                ) select
                  1
                  from
                  acs_permissions p
                  join  party_approved_member_map pap on pap.party_id   =  p.grantee_id
                  join  privilege_ancestors pa  on  pa.privilege  =  p.privilege
                  join  object_context oc on  p.object_id =  oc.context_id      
                  where pap.member_id = permission_p__party_id
                );
        END;
        $$ LANGUAGE plpgsql stable;


        -- for tsearch

        perform define_function_args('acs_permission__permission_p_recursive_array','a_objects,a_party_id,a_privilege');

        CREATE OR REPLACE FUNCTION  acs_permission__permission_p_recursive_array(
            permission_p__objects integer[],
            permission_p__party_id integer, 
            permission_p__privilege varchar
        ) RETURNS table (object_id integer, orig_object_id integer) as $$
        BEGIN
            return query With RECURSIVE object_context(obj_id, context_id, orig_obj_id) AS (

                    select unnest(permission_p__objects), unnest(permission_p__objects), unnest(permission_p__objects)

                    union all

                    select ao.object_id,
                    case when (ao.security_inherit_p = 'f' or ao.context_id is null) 
                    then acs__magic_object_id('security_context_root') else ao.context_id END, 
                    oc.orig_obj_id
                    from object_context oc, acs_objects ao
                    where ao.object_id = oc.context_id
                    and ao.object_id != acs__magic_object_id('security_context_root')

                ), privilege_ancestors(privilege, child_privilege) AS (

                   select permission_p__privilege, permission_p__privilege

                   union all

                   select aph.privilege, aph.child_privilege
                   from privilege_ancestors pa join acs_privilege_hierarchy aph
                   on aph.child_privilege = pa.privilege

                ) select
                  p.object_id, oc.orig_obj_id
                  from
                  acs_permissions p
                  join  party_approved_member_map pap on pap.party_id   =  p.grantee_id
                  join  privilege_ancestors pa  on  pa.privilege  =  p.privilege
                  join  object_context oc on  p.object_id =  oc.context_id
                  where pap.member_id = permission_p__party_id
              ;
        END; 
        $$ LANGUAGE plpgsql stable;

        -- recursive site_nodes END

    ELSE

        CREATE OR REPLACE FUNCTION acs_permission__permission_p(
           permission_p__object_id integer,
           permission_p__party_id integer,
           permission_p__privilege varchar
        ) RETURNS boolean AS $$
        DECLARE
            exists_p                          boolean;
        BEGIN
          return exists (select 1
                         from acs_permissions p, party_approved_member_map m,
                           acs_object_context_index c, acs_privilege_descendant_map h
                         where p.object_id = c.ancestor_id
                           and h.descendant = permission_p__privilege
                           and c.object_id = permission_p__object_id
                           and m.member_id = permission_p__party_id
                           and p.privilege = h.privilege
                           and p.grantee_id = m.party_id);
        END;
        $$ LANGUAGE plpgsql stable;

    END IF;
    raise notice 'ending permissions recursive -- vguerra';

    return null;
END; 
$inline_0$ LANGUAGE plpgsql;

select inline_0();
drop function inline_0();
