create table scores(
  id bigint primary key,
  user_id bigint not null,
  score int default 0
);