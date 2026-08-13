import envoy
import gleam/dynamic/decode
import gleam/erlang/process
import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/otp/actor
import gleam/time/calendar
import pog

fn insert_companion(db: pog.Connection, name: String) -> Int {
  let assert Ok(pog.Returned(rows: [id], ..)) =
    "INSERT INTO companion (name) VALUES ($1) RETURNING id;"
    |> pog.query
    |> pog.parameter(pog.text(name))
    |> pog.returning({
      use id <- decode.field(0, decode.int)
      decode.success(id)
    })
    |> pog.execute(db)
  id
}

fn insert_feeling(db: pog.Connection, name: String) -> Int {
  let assert Ok(pog.Returned(rows: [id], ..)) =
    "INSERT INTO feeling (name) VALUES ($1) RETURNING id;"
    |> pog.query
    |> pog.parameter(pog.text(name))
    |> pog.returning({
      use id <- decode.field(0, decode.int)
      decode.success(id)
    })
    |> pog.execute(db)
  id
}

fn insert_location(db: pog.Connection, name: String, is_outdoor: Bool) -> Int {
  let assert Ok(pog.Returned(rows: [id], ..)) =
    "INSERT INTO location (name, is_outdoor) VALUES ($1, $2) RETURNING id;"
    |> pog.query
    |> pog.parameter(pog.text(name))
    |> pog.parameter(pog.bool(is_outdoor))
    |> pog.returning({
      use id <- decode.field(0, decode.int)
      decode.success(id)
    })
    |> pog.execute(db)
  id
}

fn insert_workout_type(db: pog.Connection, name: String) -> Int {
  let assert Ok(pog.Returned(rows: [id], ..)) =
    "INSERT INTO workout_type (name) VALUES ($1) RETURNING id;"
    |> pog.query
    |> pog.parameter(pog.text(name))
    |> pog.returning({
      use id <- decode.field(0, decode.int)
      decode.success(id)
    })
    |> pog.execute(db)
  id
}

fn insert_workout_session(
  db: pog.Connection,
  date: calendar.Date,
  start_time: Option(calendar.TimeOfDay),
  end_time: Option(calendar.TimeOfDay),
  duration_minutes: Int,
  location_id: Option(Int),
  feeling_id: Option(Int),
  effort: Option(Int),
) -> Int {
  let assert Ok(pog.Returned(rows: [id], ..)) =
    "INSERT INTO workout_session (workout_date, start_time, end_time, duration_minutes, location_id, feeling_id, effort) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id;"
    |> pog.query
    |> pog.parameter(pog.calendar_date(date))
    |> pog.parameter(pog.nullable(pog.calendar_time_of_day, start_time))
    |> pog.parameter(pog.nullable(pog.calendar_time_of_day, end_time))
    |> pog.parameter(pog.int(duration_minutes))
    |> pog.parameter(pog.nullable(pog.int, location_id))
    |> pog.parameter(pog.nullable(pog.int, feeling_id))
    |> pog.parameter(pog.nullable(pog.int, effort))
    |> pog.returning({
      use id <- decode.field(0, decode.int)
      decode.success(id)
    })
    |> pog.execute(db)
  id
}

fn associate_companion(
  db: pog.Connection,
  session_id: Int,
  companion_id: Int,
) -> Nil {
  let assert Ok(_) =
    "INSERT INTO workout_session_companion (workout_session_id, companion_id) VALUES ($1, $2);"
    |> pog.query
    |> pog.parameter(pog.int(session_id))
    |> pog.parameter(pog.int(companion_id))
    |> pog.execute(db)
  Nil
}

fn associate_workout_type(
  db: pog.Connection,
  session_id: Int,
  workout_type_id: Int,
) -> Nil {
  let assert Ok(_) =
    "INSERT INTO workout_session_workout_type (workout_session_id, workout_type_id) VALUES ($1, $2);"
    |> pog.query
    |> pog.parameter(pog.int(session_id))
    |> pog.parameter(pog.int(workout_type_id))
    |> pog.execute(db)
  Nil
}

pub fn main() {
  io.println("Feeding development data...")
  let name = process.new_name("pog_seed")
  let assert Ok(database_url) = envoy.get("DATABASE_URL")
  let assert Ok(config) = pog.url_config(name, database_url)
  let assert Ok(actor.Started(data: db, ..)) = pog.start(config)

  io.println("Truncating existing tables...")
  let assert Ok(_) =
    "TRUNCATE TABLE 
       workout_session_companion, 
       workout_session_workout_type, 
       workout_session, 
       companion, 
       feeling, 
       location, 
       workout_type
     RESTART IDENTITY CASCADE;"
    |> pog.query
    |> pog.execute(db)

  io.println("Inserting companions...")
  let companion_alice = insert_companion(db, "Alice")
  let companion_bob = insert_companion(db, "Bob")
  let companion_charlie = insert_companion(db, "Charlie")

  io.println("Inserting feelings...")
  let feeling_great = insert_feeling(db, "Great")
  let feeling_tired = insert_feeling(db, "Tired")
  let feeling_energetic = insert_feeling(db, "Energetic")
  let feeling_exhausted = insert_feeling(db, "Exhausted")
  let feeling_average = insert_feeling(db, "Average")

  io.println("Inserting locations...")
  let location_gym = insert_location(db, "ClimbingGym", False)
  let location_park = insert_location(db, "Park", True)
  let location_forest = insert_location(db, "Forest", True)
  let _location_home = insert_location(db, "Home", False)

  io.println("Inserting workout types...")
  let wt_gym = insert_workout_type(db, "gym")
  let wt_lead = insert_workout_type(db, "lead")
  let wt_top_rope = insert_workout_type(db, "top-rope")
  let wt_auto_belay = insert_workout_type(db, "auto-belay")
  let wt_boulder = insert_workout_type(db, "boulder")

  io.println("Inserting workout sessions...")

  // Session 1: Boulder at ClimbingGym (Both start and end time missing)
  let session_1 =
    insert_workout_session(
      db,
      calendar.Date(year: 2026, month: calendar.August, day: 1),
      None,
      None,
      90,
      Some(location_gym),
      Some(feeling_great),
      Some(4),
    )
  associate_workout_type(db, session_1, wt_boulder)
  associate_workout_type(db, session_1, wt_gym)

  // Session 2: Lead Climbing with Alice in Forest (Fully specified times)
  let session_2 =
    insert_workout_session(
      db,
      calendar.Date(year: 2026, month: calendar.August, day: 2),
      Some(calendar.TimeOfDay(hours: 10, minutes: 0, seconds: 0, nanoseconds: 0)),
      Some(calendar.TimeOfDay(hours: 14, minutes: 0, seconds: 0, nanoseconds: 0)),
      240,
      Some(location_forest),
      Some(feeling_energetic),
      Some(5),
    )
  associate_companion(db, session_2, companion_alice)
  associate_workout_type(db, session_2, wt_lead)

  // Session 3: Top-rope with Bob at ClimbingGym (Both start and end time missing)
  let session_3 =
    insert_workout_session(
      db,
      calendar.Date(year: 2026, month: calendar.August, day: 4),
      None,
      None,
      120,
      Some(location_gym),
      Some(feeling_tired),
      Some(3),
    )
  associate_companion(db, session_3, companion_bob)
  associate_workout_type(db, session_3, wt_top_rope)
  associate_workout_type(db, session_3, wt_gym)

  // Session 4: Auto-belay Solo at ClimbingGym (Both start and end time missing)
  let session_4 =
    insert_workout_session(
      db,
      calendar.Date(year: 2026, month: calendar.August, day: 5),
      None,
      None,
      60,
      Some(location_gym),
      Some(feeling_average),
      Some(3),
    )
  associate_workout_type(db, session_4, wt_auto_belay)
  associate_workout_type(db, session_4, wt_gym)

  // Session 5: Boulder with Charlie at Park (Fully specified times)
  let session_5 =
    insert_workout_session(
      db,
      calendar.Date(year: 2026, month: calendar.August, day: 7),
      Some(calendar.TimeOfDay(hours: 13, minutes: 0, seconds: 0, nanoseconds: 0)),
      Some(calendar.TimeOfDay(
        hours: 16,
        minutes: 30,
        seconds: 0,
        nanoseconds: 0,
      )),
      210,
      Some(location_park),
      Some(feeling_great),
      Some(4),
    )
  associate_companion(db, session_5, companion_charlie)
  associate_workout_type(db, session_5, wt_boulder)

  // Session 6: Lead & Top-rope with Alice & Bob at ClimbingGym (Fully specified times)
  let session_6 =
    insert_workout_session(
      db,
      calendar.Date(year: 2026, month: calendar.August, day: 9),
      Some(calendar.TimeOfDay(hours: 17, minutes: 0, seconds: 0, nanoseconds: 0)),
      Some(calendar.TimeOfDay(
        hours: 19,
        minutes: 30,
        seconds: 0,
        nanoseconds: 0,
      )),
      150,
      Some(location_gym),
      Some(feeling_exhausted),
      Some(5),
    )
  associate_companion(db, session_6, companion_alice)
  associate_companion(db, session_6, companion_bob)
  associate_workout_type(db, session_6, wt_lead)
  associate_workout_type(db, session_6, wt_top_rope)
  associate_workout_type(db, session_6, wt_gym)

  io.println("Successfully seeded database with development data!")
}
