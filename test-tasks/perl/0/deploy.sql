DROP TABLE users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY NOT NULL,
  name VARCHAR(23) NOT NULL,
  password CHAR(32) NOT NULL,
  login_time TIMESTAMP,
  auto_ctime TIMESTAMP DEFAULT NOW(),
  UNIQUE (name)
); 
CREATE INDEX check_login ON users (name, password);
