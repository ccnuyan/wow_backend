--local user: provider=local, provider_key=username
--local user with token: provider=token, provider_key = 'token'
--oauth user: provider=token, provider_key=oauth_provider

create table logins(
  id bigint primary key default id_generator(),

  user_id bigint not null,
  
  provider varchar(64) not null default 'local',
  provider_key varchar(255),
  provider_token varchar(255) not null
);