create type login_info as(
  id bigint,
  username varchar,
  college varchar, 
  student_id varchar, 
  realname varchar, 
  gender varchar,
  role int,
  success boolean,
  message varchar,
  token varchar
);