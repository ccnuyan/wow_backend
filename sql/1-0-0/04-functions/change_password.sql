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



