ALTER TABLE user_words
ADD CONSTRAINT users_user_words
FOREIGN KEY (user_id) REFERENCES users(id)
ON DELETE CASCADE;