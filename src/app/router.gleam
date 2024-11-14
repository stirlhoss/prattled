import app/error.{type AppError}
import app/web.{type Context}
import app/web/word.{type Word}
import gleam/json.{array, int, null, object, string}

// import gleam/dynamic.{type Dynamic}
import gleam/http.{Get, Post}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req)

  // A new `app/web/people` module now contains the handlers and other functions
  // relating to the People feature of the application.
  //
  // The router module now only deals with routing, and dispatches to the
  // feature modules for handling requests.
  // 
  case wisp.path_segments(req) {
    [letter, word] -> one_word(req, ctx, letter, word)
    _ -> wisp.not_found()
  }
}

// This request handler is used for requests to `/:letter/:word`.
//
pub fn one_word(
  req: Request,
  ctx: Context,
  letter: String,
  word: String,
) -> Response {
  // Dispatch to the appropriate handler based on the HTTP method.
  case req.method {
    Get -> get_word(ctx, letter, word)
    _ -> wisp.method_not_allowed()
  }
}

fn get_word(ctx: Context, letter: string, word: String) -> Response {
  let result = word.read_from_database(ctx, letter, word)

  use word <- web.require_ok(result)

  word_to_json(word)
  |> wisp.html_response(200)
}

pub fn word_to_json(word: Word) -> String {
  object([#("id", int(word.id)), #("word", string(word.word))])
  |> json.to_string
}
