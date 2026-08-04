-- src/sql/get_session_workout_types.sql
SELECT 
  wt.name
FROM workout_session_workout_type wswt
JOIN workout_type wt ON wswt.workout_type_id = wt.id
WHERE wswt.workout_session_id = $1;
