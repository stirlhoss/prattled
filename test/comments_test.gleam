import app/router
import gleeunit/should
import wisp/testing

pub fn get_comments_test() {
  let request = testing.get("/comments", [])
  let response = router.handle_request(request)
  response.status
  |> should.equal(200)
}

pub fn post_comments_test() {
  let request = testing.post("/comments", [], "")
  let response = router.handle_request(request)
  response.status
  |> should.equal(201)
}

pub fn delete_comments_test() {
  let request = testing.delete("/comments", [], "")
  let response = router.handle_request(request)
  response.status
  |> should.equal(405)
}

pub fn get_comment_test() {
  let request = testing.get("/comments/123", [])
  let response = router.handle_request(request)
  response.status
  |> should.equal(200)
  response
  |> testing.string_body
  |> should.equal("Comment with id 123")
}

pub fn delete_comment_test() {
  let request = testing.delete("/comments/123", [], "")
  let response = router.handle_request(request)
  response.status
  |> should.equal(405)
}
