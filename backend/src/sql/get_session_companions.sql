-- src/sql/get_session_companions.sql
SELECT 
  c.name
FROM workout_session_companion wsc
JOIN companion c ON wsc.companion_id = c.id
WHERE wsc.workout_session_id = $1;
