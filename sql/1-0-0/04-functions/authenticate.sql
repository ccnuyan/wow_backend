create or replace function authenticate(key varchar, token varchar, prov varchar default 'local')
returns membership.login_info as $$
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
  
  return (found_user.id, 
    found_user.username, 
    found_user.college, 
    found_user.student_id,
    found_user.realname,
    found_user.gender, 
    found_user.role,  
    success, 
    return_message,
    '')::membership.login_info;
END;
$$
language plpgsql;

create or replace function authenticate_by_token(token varchar)
returns membership.login_info as $$
begin
  return authenticate('token', token, 'token');
end;
$$
language plpgsql;
