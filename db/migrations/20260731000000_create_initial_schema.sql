-- migrate:up

-- 1. Locations
CREATE TABLE location (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL,
  is_outdoor BOOLEAN NOT NULL DEFAULT FALSE
);

-- 2. Companions
CREATE TABLE companion (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);

-- 3. Workout Types
CREATE TABLE workout_type (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);

-- 4. Feelings
CREATE TABLE feeling (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);

-- 5. Workout Sessions
CREATE TABLE workout_session (
  id SERIAL PRIMARY KEY,
  workout_date DATE NOT NULL,
  start_time TIME,
  end_time TIME,
  duration_minutes INTEGER NOT NULL,
  location_id INTEGER REFERENCES location(id) ON DELETE SET NULL,
  feeling_id INTEGER REFERENCES feeling(id) ON DELETE SET NULL,
  effort INTEGER CHECK (effort >= 1 AND effort <= 5)
);

-- Many-to-Many junctions
CREATE TABLE workout_session_companion (
  workout_session_id INTEGER REFERENCES workout_session(id) ON DELETE CASCADE,
  companion_id INTEGER REFERENCES companion(id) ON DELETE CASCADE,
  PRIMARY KEY (workout_session_id, companion_id)
);

CREATE TABLE workout_session_workout_type (
  workout_session_id INTEGER REFERENCES workout_session(id) ON DELETE CASCADE,
  workout_type_id INTEGER REFERENCES workout_type(id) ON DELETE CASCADE,
  PRIMARY KEY (workout_session_id, workout_type_id)
);

-- Performance indices
CREATE INDEX idx_workout_session_date ON workout_session(workout_date);
CREATE INDEX idx_workout_session_location ON workout_session(location_id);

-- migrate:down
DROP TABLE workout_session_workout_type;
DROP TABLE workout_session_companion;
DROP TABLE workout_session;
DROP TABLE feeling;
DROP TABLE workout_type;
DROP TABLE companion;
DROP TABLE location;
