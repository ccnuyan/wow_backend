create table users(
  id bigint primary key not null default id_generator(),
  
  user_key varchar(18) default random_string(18) not null,
  username varchar(255) unique not null,
  role int default 10, -- 99/student 10/teacher; 0/admin
  login_count int default 0 not null,
  last_login timestamptz,
  created_at timestamptz default now() not null,

  --from college system
  college varchar(32) not null default 'CCNU',
  student_id varchar(32) not null,
  realname varchar(64) not null,
  gender varchar(16) not null
  --profile
);