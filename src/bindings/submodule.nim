from std/httpcore import HttpMethod
import pkg/asyncutils
import utils/[client, api]

proc getExample*(ex: Example): Future[string] {.fastsync.} =
  ## Get ...
  ex.setContentType("application/x-www-form-urlencoded")
  let
    req = newPureRequest(
      endpoint = build(apiRoot, "/1/get/", HttpGet)
    )
    resp = await ex.request(req)
  return resp.body


proc postExample*(ex: Example, payload: string): Future[string] {.fastsync.} =
  ## Post ...
  ex.setContentType("application/json")
  let
    req = newPureRequest(
      endpoint = build(apiRoot, "/1/post/", HttpPost),
      body = payload
    )
    resp = await ex.request(req)
  return resp.body
