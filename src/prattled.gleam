import app/router
import app/web
import gleam/erlang/process
import mist
import sqlight
import wisp
import wisp/wisp_mist

const db_name = "prattled.sqlite3"

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  // A database creation is created here, when the program starts.
  // This connection is used by all requests.
  use db <- database.with_connection(db_name)

  // A context is constructed to hold the database connection.
  let context = web.Context(db: db)

  // The handle_request function is partially applied with the context to make
  // the request handler function that only takes a request.
  let handler = router.handle_request(_, context)

  let assert Ok(_) =
    wisp_mist.handler(router.handle_request, secret_key_base)
    |> mist.new()
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}
