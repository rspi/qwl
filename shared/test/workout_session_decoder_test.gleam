import gleam/json
import gleam/option.{None, Some}
import gleam/time/calendar
import shared/workout_session.{
  Location, WorkoutSession, WorkoutSessionListItem,
  workout_session_decoder, workout_session_list_item_decoder,
  workout_session_list_item_to_json, workout_session_to_json,
}

pub fn list_item_codec_test() {
  let item =
    WorkoutSessionListItem(
      id: 42,
      workout_date: calendar.Date(2026, calendar.August, 13),
    )

  let encoded = workout_session_list_item_to_json(item)
  let json_str = json.to_string(encoded)

  let decoded =
    json.parse(from: json_str, using: workout_session_list_item_decoder())

  let assert Ok(decoded_item) = decoded
  let assert 42 = decoded_item.id
  let assert calendar.Date(2026, calendar.August, 13) = decoded_item.workout_date
}

pub fn workout_session_codec_test() {
  let session =
    WorkoutSession(
      id: 101,
      workout_date: calendar.Date(2026, calendar.August, 13),
      start_time: Some(calendar.TimeOfDay(14, 30, 0, 0)),
      end_time: Some(calendar.TimeOfDay(15, 30, 0, 0)),
      duration_minutes: 60,
      effort: Some(8),
      location: Some(Location("Gym", False)),
      feeling: Some("Energized"),
      workout_types: ["Strength", "Cardio"],
      companions: ["Alice", "Bob"],
    )

  let encoded = workout_session_to_json(session)
  let json_str = json.to_string(encoded)

  let decoded = json.parse(from: json_str, using: workout_session_decoder())

  let assert Ok(decoded_session) = decoded
  let assert 101 = decoded_session.id
  let assert calendar.Date(2026, calendar.August, 13) =
    decoded_session.workout_date
  let assert Some(calendar.TimeOfDay(14, 30, 0, 0)) = decoded_session.start_time
  let assert Some(calendar.TimeOfDay(15, 30, 0, 0)) = decoded_session.end_time
  let assert 60 = decoded_session.duration_minutes
  let assert Some(8) = decoded_session.effort
  let assert Some(Location("Gym", False)) = decoded_session.location
  let assert Some("Energized") = decoded_session.feeling
  let assert ["Strength", "Cardio"] = decoded_session.workout_types
  let assert ["Alice", "Bob"] = decoded_session.companions
}

pub fn workout_session_optional_codec_test() {
  let session =
    WorkoutSession(
      id: 102,
      workout_date: calendar.Date(2026, calendar.August, 13),
      start_time: None,
      end_time: None,
      duration_minutes: 45,
      effort: None,
      location: None,
      feeling: None,
      workout_types: [],
      companions: [],
    )

  let encoded = workout_session_to_json(session)
  let json_str = json.to_string(encoded)

  let decoded = json.parse(from: json_str, using: workout_session_decoder())

  let assert Ok(decoded_session) = decoded
  let assert 102 = decoded_session.id
  let assert calendar.Date(2026, calendar.August, 13) =
    decoded_session.workout_date
  let assert None = decoded_session.start_time
  let assert None = decoded_session.end_time
  let assert 45 = decoded_session.duration_minutes
  let assert None = decoded_session.effort
  let assert None = decoded_session.location
  let assert None = decoded_session.feeling
  let assert [] = decoded_session.workout_types
  let assert [] = decoded_session.companions
}
