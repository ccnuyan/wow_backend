create or replace function register(
  un varchar, 
  password varchar, 
  clg varchar, 
  sid varchar, 
  realname varchar, 
  gender varchar default 'MALE',
  is_admin boolean default false)
returns membership.login_info
as $$
DECLARE
  new_user membership.users;
  token varchar(64);
  success boolean default false;
  message varchar(64);
BEGIN
  set search_path=membership;
    
  if not exists (select users.username from users where users.username = un or (users.college = clg and users.student_id = sid)) 
  then
    -- add them, get new id
    if is_admin 
    then
      insert into users(username, college, student_id, realname, gender, role)
      values (un, clg, sid, realname, gender, 0)
      returning * into new_user;
    else
      insert into users(username, college, student_id, realname, gender)
      values (un, clg, sid, realname, gender)
      returning * into new_user;
    end if;

    -- add login for local
    -- username as provider_key
    insert into logins(user_id, provider_key, provider_token)
    values(new_user.id, new_user.username, crypt(password, gen_salt('bf', 10)));

    -- for token-based login
    -- generate the token
    token := random_string(36);
    insert into logins(user_id, provider, provider_key, provider_token)
    values(new_user.id, 'token', 'token', token);

    success := true;
    message := 'Welcome!';
  else
    success := false;
    select 'This username is already registered' into message;
  end if;

  -- return the goods
  return (new_user.id, 
    new_user.username, 
    new_user.college, 
    new_user.student_id,
    new_user.realname,
    new_user.gender, 
    new_user.role, 
    success,
    message, 
    token)::membership.login_info;
END;
$$
language plpgsql;