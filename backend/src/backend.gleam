import gleam/erlang/process
import gleam/io
import mist
import router
import wisp
import wisp/wisp_mist

pub fn main() {
  io.println("Starting backend")
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let assert Ok(_) =
    wisp_mist.handler(router.handle_request, secret_key_base)
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(4711)
    |> mist.start

  process.sleep_forever()
}
