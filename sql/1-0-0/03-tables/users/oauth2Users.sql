create table oauth2Users(
  id bigint primary key not null default id_generator(),
  user_id bigint,
  key varchar(255) not null,
  provider varchar(16) not null,
  profile json
);