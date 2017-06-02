create table user_words(
  id bigint primary key not null default id_generator(),

  user_id bigint,
  word_key varchar(64)
);