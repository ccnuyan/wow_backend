-- -- get
-- set search_path=membership;

-- create or replace function get_users_by_ids(uids bigint[])
-- returns setof users
-- as $$
-- BEGIN
--   set search_path=membership;

--   return query
--   select * from users where users.id = any(uids);
-- END;
-- $$ LANGUAGE plpgsql;

-- create or replace function get_user_by_id(uid bigint)
-- returns users
-- as $$
-- DECLARE
-- found_user users;
-- BEGIN
--   set search_path=membership;
--   select * from users where users.id = uid into found_user;
--   return found_user;
-- END;
-- $$ LANGUAGE plpgsql;

-- -- user_users

-- create or replace function get_all_users()
-- returns setof users
-- as $$
-- BEGIN
--   return query
--   select 		
--     *
--   from 
--     users
--   where 
--     users.role = 10;
-- END;
-- $$ LANGUAGE plpgsql;