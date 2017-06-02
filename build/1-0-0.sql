set search_path=membership;
drop schema if exists membership CASCADE;

create schema membership;
set search_path = membership;

select 'Schema initialized' as result;

create extension if not exists pgcrypto with schema membership;
set search_path = membership;

select * from register('ccnuyan', 'password', true);
set search_path = membership;

create sequence id_sequence;
create or replace function id_generator(out new_id bigint)
as $$
DECLARE
  our_epoch bigint := 1483200000000; -- 2017/05/01
  seq_id bigint;
  now_ms bigint;
  shard_id int := 1;
BEGIN
  SELECT nextval('id_sequence') %1024 INTO seq_id;
  SELECT FLOOR(EXTRACT(EPOCH FROM now()) * 1000) INTO now_ms;
  new_id := (now_ms - our_epoch) << 23;
  new_id := new_id | (shard_id << 10);
  new_id := new_id | (seq_id);
END;
$$
LANGUAGE PLPGSQL;


set search_path = membership;

create or replace function random_string(len int default 36)
returns text
as $$
select upper(substring(md5(random()::text), 0, len+1));
$$ 
language sql;

set search_path = membership;

create table containers(
  id bigint primary key not null default id_generator(),
  tenant_id bigint not null,
  created_by bigint not null,
  created_at timestamptz default now() not null,
  active boolean default true,
  name varchar(127)
);


--local user: provider=local, provider_key=username
--local user with token: provider=token, provider_key = 'token'
--oauth user: provider=token, provider_key=oauth_provider

create table logins(
  id bigint primary key default id_generator(),
  user_id bigint not null,
  provider varchar(50) not null default 'local',
  provider_key varchar(255),
  provider_token varchar(255) not null
);
create table users(
  id bigint primary key not null default id_generator(),
  user_key varchar(18) default random_string(18) not null,
  username varchar(255) unique not null,
  role int default 10, -- 99/student 10/teacher; 0/admin
  login_count int default 0 not null,
  last_login timestamptz,
  created_at timestamptz default now() not null
);
drop function if exists add_login(varchar,varchar,varchar,varchar);
create function add_login(un varchar(255), key varchar(50), token varchar(255), new_provider varchar(50))
returns TABLE(
  message varchar(255),
  success boolean
) as
$$
DECLARE
  success boolean :=false;
  message varchar(255) := 'User not found with this username';
  found_id bigint;
  data_result json;
BEGIN
  set search_path = membership;
  select id into found_id from users where username = un;

  if found_id is not null then
    --replace the provider for this user completely
    delete from logins where 
      found_id = logins.user_id AND 
      logins.provider = new_provider;

    --add the login
    insert into logins(user_id, provider_key, provider_token, provider)
    values (found_id, key,token,new_provider);

    --add log entry
    insert into logs(subject,entry,user_id, created_at)
    values('Authentication','Added ' || new_provider || ' login',found_id,now());

    success := true;
    message :=  'Added login successfully';
  end if;

  return query
  select message, success;

END;
$$
language plpgsql;
create or replace function authenticate(key varchar, token varchar, prov varchar default 'local')
returns table(
  id bigint,
  username varchar(255),
  role int,
  success boolean,
  message varchar(255)
) as $$
DECLARE
  found_user membership.users;
  return_message varchar(50);
  success boolean := false;
  found_id bigint;
BEGIN
  set search_path=membership;
  --find the user by token/provider and key

 if(prov = 'local') then
    select locate_user_by_password(key, token) into found_id;
  else
    select user_id from logins where
    provider = prov and
    provider_key = key and
    provider_token = token into found_id;
  end if;
  
  if(found_id is not null) then
    select * from users where users.id = found_id into found_user;
    --set a last_login
    update users set last_login=now(), login_count=login_count+1
    where users.id=found_id;

    success := true;
    return_message := 'Welcome!';
  else
    return_message := 'Invalid login credentials';
  end if;
  
  return query
  select found_id, found_user.username, found_user.role, success, return_message;
END;
$$
language plpgsql;

create or replace function authenticate_by_token(token varchar)
returns table(
  id bigint,
  username varchar(255),
  role int,
  success boolean,
  message varchar(255)
) as $$
begin
  return query
  select * from authenticate('token', token, 'token');
end;
$$
language plpgsql;

set search_path = membership;

create or replace function change_password(username varchar, old_pass varchar, new_pass varchar)
returns users
as $$
DECLARE
  found_id bigint;
BEGIN
  set search_path=membership;
  --find the user based on username/password
  select locate_user_by_password(username, old_pass) into found_id;
  if found_id is not null then
    --change the password if all is OK
    update logins set provider_token = crypt(new_pass, gen_salt('bf',10))
    where user_id=found_id and provider='local';
  end if;
  select * from users where users.username = username;
END;
$$
language plpgsql;




-- get
set search_path=membership;

create or replace function get_containers_by_ids(cids bigint[])
returns setof containers
as $$
BEGIN
  set search_path=membership;

  return query
  select * from containers where containers.id = any(cids);
END;
$$ LANGUAGE plpgsql;

create or replace function get_container_by_id(cid bigint)
returns containers
as $$
DECLARE
found_container containers;
BEGIN
  set search_path=membership;
  select * from containers where containers.id = cid into found_container;
  return found_container;
END;
$$ LANGUAGE plpgsql;

-- tenant_containers

create or replace function get_tenant_containers(tid bigint)
returns setof containers
as $$
BEGIN
  return query
  select 		
    *
  from 
    containers
  where 
    containers.tenant_id = tid;
END;
$$ LANGUAGE plpgsql;

-- create_container

create or replace function create_container(uid bigint, tid bigint, nm membership.containers.name%type)
returns containers
as $$
DECLARE
new_container_id bigint;
BEGIN


  set search_path=membership;

  insert into containers(created_by, tenant_id, name) values (uid, tid, nm) returning containers.id into new_container_id;

  return get_container_by_id(new_container_id);
END;
$$ LANGUAGE plpgsql;

-- delete_container

create or replace function delete_container(uid bigint, tid bigint, cid bigint)
returns containers
as $$
DECLARE
container_tobe_delete containers;
BEGIN
  set search_path=membership;
  container_tobe_delete:=get_container_by_id(cid);
  delete from 
    containers 
  where 
    id=cid 
  and created_by = uid and containers.tenant_id = tid;
  return container_tobe_delete;
END;
$$ LANGUAGE plpgsql;

-- lock_containers

create or replace function lock_container(uid bigint, cid bigint)
returns containers
as $$
BEGIN
  set search_path=membership;
  update containers set active = false
  where id=cid and tenant_id = uid;
  return get_container_by_id(cid);
END;
$$ LANGUAGE plpgsql;

-- unlock_containers

create or replace function unlock_container(uid bigint, cid bigint)
returns containers
as $$
BEGIN
  set search_path=membership;
  update containers set active = true
  where id=cid and tenant_id = uid;
  return get_container_by_id(cid);
END;
$$ LANGUAGE plpgsql;
create or replace function locate_user_by_password(username varchar, pass varchar)
returns bigint
as $$
  set search_path=membership;
  select user_id from logins where
  provider_key = username and
  provider_token = crypt(pass,provider_token);
$$
language sql;

create or replace function register(un varchar, password varchar, is_admin boolean default false)
returns table(
  id bigint,
  username varchar(255),
  authentication_token varchar(36),
  role int,
  success boolean,
  message varchar(255)
) as $$
BEGIN
  set search_path=membership;
  -- see if they exist
  if not exists (select users.username from users where users.username = un) 
  then
    -- add them, get new id
    if is_admin 
    then
      insert into users(username, role)
      values (un,0)
      returning users.id, users.role into id, role;
    else
      insert into users(username)
      values (un)
      returning users.id, users.role into id, role;
    end if;
    -- add login for local
    insert into logins(user_id, provider_key, provider_token)
    values(id, un, crypt(password, gen_salt('bf', 10)));

    -- for token-based login
    authentication_token := random_string(36);
    insert into logins(user_id, provider, provider_key, provider_token)
    values(id, 'token', 'token', authentication_token);

    success := true;
    message := 'Welcome!';
  else
    success := false;
    select 'This username is already registered' into message;
  end if;

  -- return the goods
  return query
  select id, un, authentication_token, role, success, message;
END;
$$
language plpgsql;
-- get
set search_path=membership;

create or replace function get_tenants_by_ids(tids bigint[])
returns setof users
as $$
BEGIN
  set search_path=membership;

  return query
  select * from users where users.id = any(tids);
END;
$$ LANGUAGE plpgsql;

create or replace function get_tenant_by_id(tid bigint)
returns users
as $$
DECLARE
found_tenant users;
BEGIN
  set search_path=membership;
  select * from tenants where users.id = tid into found_tenant;
  return found_tenant;
END;
$$ LANGUAGE plpgsql;

-- tenant_tenants

create or replace function get_all_tenants()
returns setof users
as $$
BEGIN
  return query
  select 		
    *
  from 
    users
  where 
    users.role = 10;
END;
$$ LANGUAGE plpgsql;
ALTER TABLE logins
ADD CONSTRAINT logins_users
FOREIGN KEY (user_id) REFERENCES users(id)
ON DELETE CASCADE;

ALTER TABLE containers
ADD CONSTRAINT admin_created_containers
FOREIGN KEY (created_by) REFERENCES users(id)
ON DELETE CASCADE;

ALTER TABLE containers
ADD CONSTRAINT tenant_owned_containers
FOREIGN KEY (created_by) REFERENCES users(id)
ON DELETE CASCADE;