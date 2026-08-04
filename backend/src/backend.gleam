import envoy
import gleam/erlang/process
import gleam/io
import gleam/otp/actor
import mist
import pog
import router
import web
import wisp
import wisp/wisp_mist

fn get_env_or_throw(env_variable: String) -> String {
  let envoy_error = "Missing environment variable " <> env_variable
  let assert Ok(value) = envoy.get(env_variable) as envoy_error
  value
}

pub fn main() {
  io.println("Starting backend!")
  wisp.configure_logger()
  let name = process.new_name("pog")

  let secret_key_base = get_env_or_throw("WISP_SECRET")
  let database_url = get_env_or_throw("DATABASE_URL")
  let pog_error = "Unable to connect to " <> database_url
  let assert Ok(config) = pog.url_config(name, database_url) as pog_error
  let assert Ok(actor.Started(data: db, ..)) = pog.start(config)

  let handler = router.handle_request(_, web.Context(db: db))

  let assert Ok(_) =
    handler
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(4711)
    |> mist.start

  process.sleep_forever()
}
