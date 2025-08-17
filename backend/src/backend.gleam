import envoy
import gleam/erlang/process
import gleam/io
import mist
import pog
import router
import web
import wisp
import wisp/wisp_mist

pub fn main() {
  io.println("Starting backend")
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(63)

  let name = process.new_name("pog")

  let assert Ok(database_url) = envoy.get("DATABASE_URL")
  let assert Ok(config) = pog.url_config(name, database_url)
  let assert Ok(db) = pog.start(config)

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
