-- src/sql/get_workout_session_by_id.sql
SELECT 
  ws.id,
  ws.workout_date,
  ws.start_time,
  ws.end_time,
  ws.duration_minutes,
  ws.effort,
  l.name AS location_name,
  l.is_outdoor AS location_is_outdoor,
  f.name AS feeling_name
FROM workout_session ws
LEFT JOIN location l ON ws.location_id = l.id
LEFT JOIN feeling f ON ws.feeling_id = f.id
WHERE ws.id = $1;
