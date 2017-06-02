create or replace function locate_user_by_password(username varchar, pass varchar)
returns bigint
as $$
  set search_path=membership;
  select user_id from logins where
  provider_key = username and
  provider_token = crypt(pass,provider_token);
$$
language sql;
