-- migrate:up
CREATE TABLE tag (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE
);

-- migrate:down
DROP TABLE tag;
