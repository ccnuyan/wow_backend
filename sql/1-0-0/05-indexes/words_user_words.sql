ALTER TABLE user_words
ADD CONSTRAINT words_user_words
FOREIGN KEY (word_key) REFERENCES words(key)
ON DELETE CASCADE;