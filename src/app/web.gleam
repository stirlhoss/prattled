import app/error.{type AppError}
import sqlight
import wisp.{type Response}

pub type Context {
  Context(db: sqlight.Connection)
}

pub fn middleware(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  handle_request(req)
}

/// Return an appropriate HTTP response for a given error.
///
pub fn error_to_response(error: AppError) -> Response {
  case error {
    error.NotFound -> wisp.not_found()
    error.MethodNotAllowed -> wisp.method_not_allowed([])
    error.BadRequest -> wisp.bad_request()
    error.UnprocessableEntity | error.ContentRequired ->
      wisp.unprocessable_entity()
    error.SqlightError(_) -> wisp.internal_server_error()
  }
}

pub fn require_ok(t: Result(t, AppError), next: fn(t) -> Response) -> Response {
  case t {
    Ok(t) -> next(t)
    Error(error) -> error_to_response(error)
  }
}
