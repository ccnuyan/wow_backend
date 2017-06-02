-- -- get
-- set search_path=membership;

-- create or replace function get_teams_by_ids(cids bigint[])
-- returns setof teams
-- as $$
-- BEGIN
--   set search_path=membership;

--   return query
--   select * from teams where teams.id = any(cids);
-- END;
-- $$ LANGUAGE plpgsql;

-- create or replace function get_team_by_id(cid bigint)
-- returns teams
-- as $$
-- DECLARE
-- found_team teams;
-- BEGIN
--   set search_path=membership;
--   select * from teams where teams.id = cid into found_team;
--   return found_team;
-- END;
-- $$ LANGUAGE plpgsql;

-- -- user_teams

-- create or replace function get_user_teams(tid bigint)
-- returns setof teams
-- as $$
-- BEGIN
--   return query
--   select 		
--     *
--   from 
--     teams
--   where 
--     teams.user_id = tid;
-- END;
-- $$ LANGUAGE plpgsql;

-- -- create_team

-- create or replace function create_team(uid bigint, tid bigint, nm membership.teams.name%type)
-- returns teams
-- as $$
-- DECLARE
-- new_team_id bigint;
-- BEGIN


--   set search_path=membership;

--   insert into teams(created_by, user_id, name) values (uid, tid, nm) returning teams.id into new_team_id;

--   return get_team_by_id(new_team_id);
-- END;
-- $$ LANGUAGE plpgsql;

-- -- delete_team

-- create or replace function delete_team(uid bigint, tid bigint, cid bigint)
-- returns teams
-- as $$
-- DECLARE
-- team_tobe_delete teams;
-- BEGIN
--   set search_path=membership;
--   team_tobe_delete:=get_team_by_id(cid);
--   delete from 
--     teams 
--   where 
--     id=cid 
--   and created_by = uid and teams.user_id = tid;
--   return team_tobe_delete;
-- END;
-- $$ LANGUAGE plpgsql;

-- -- lock_teams

-- create or replace function lock_team(uid bigint, cid bigint)
-- returns teams
-- as $$
-- BEGIN
--   set search_path=membership;
--   update teams set active = false
--   where id=cid and user_id = uid;
--   return get_team_by_id(cid);
-- END;
-- $$ LANGUAGE plpgsql;

-- -- unlock_teams

-- create or replace function unlock_team(uid bigint, cid bigint)
-- returns teams
-- as $$
-- BEGIN
--   set search_path=membership;
--   update teams set active = true
--   where id=cid and user_id = uid;
--   return get_team_by_id(cid);
-- END;
-- $$ LANGUAGE plpgsql;