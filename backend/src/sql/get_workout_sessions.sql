-- src/sql/get_workout_sessions.sql
SELECT 
  id,
  workout_date
FROM workout_session
ORDER BY workout_date DESC;
