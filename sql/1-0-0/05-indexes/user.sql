ALTER TABLE users
ADD CONSTRAINT college_student UNIQUE (college, student_id);