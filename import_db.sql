DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(50) NOT NULL,
  lname VARCHAR(50) NOT NULL

);

DROP TABLE if exists questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  users_id INTEGER NOT NULL,

  FOREIGN KEY (users_id) REFERENCES users(id)
);

DROP TABLE if exists question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  users_id INTEGER NOT NULL,
  questions_id INTEGER NOT NULL,

  FOREIGN KEY (users_id) REFERENCES users(id)
  FOREIGN KEY (questions_id) REFERENCES questions(id)
);

DROP TABLE if exists replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  parent_id INTEGER,
  users_id INTEGER NOT NULL,
  questions_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (users_id) REFERENCES users(id)
  FOREIGN KEY (questions_id) REFERENCES questions(id)
  FOREIGN KEY (parent_id) REFERENCES replies(parent_id)
);

DROP TABLE if exists question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  users_id INTEGER NOT NULL,
  questions_id INTEGER NOT NULL,

  FOREIGN KEY (users_id) REFERENCES users(id)
  FOREIGN KEY (questions_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Artem', 'Kharshan'),
  ('Maxine', 'Chui');

INSERT INTO
  questions (title, body,users_id)
VALUES
  ('SQL', 'Helpppp', (SELECT id FROM users WHERE fname = 'Artem')),
  ('DB', 'How do we create a table?!?!', (SELECT id FROM users WHERE fname = 'Maxine'));


  INSERT INTO
    question_follows (users_id, questions_id)
  VALUES

    ((SELECT id FROM users WHERE fname like 'Artem'), (SELECT id FROM questions WHERE title like 'SQL')),
    ((SELECT id FROM users WHERE fname = 'Artem'), (SELECT id FROM questions WHERE body LIKE 'How do we create a table?!?!'));

  INSERT INTO
    replies (parent_id, users_id, questions_id, body)
  VALUES
  (NULL,(SELECT id FROM users WHERE fname like 'Artem'), (SELECT id FROM questions WHERE title like 'SQL'), "this is a reply to question about sql");

  INSERT INTO
    replies (parent_id, users_id, questions_id, body)
  VALUES
  (1,(SELECT id FROM users WHERE fname like 'Artem'), (SELECT id FROM questions WHERE title like 'SQL'), "this is a reply to question about sql");

  INSERT INTO
    question_likes ( users_id, questions_id)
  VALUES
    ((SELECT id FROM users WHERE fname like 'Artem'),(SELECT id FROM questions WHERE title like 'SQL'));
