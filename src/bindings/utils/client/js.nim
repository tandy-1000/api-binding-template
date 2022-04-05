## Frontend JavaScript support
import
  std/[httpcore, strutils, tables],
  pkg/nodejs/jshttpclient,
  pkg/asyncutils,
  pure,
  ../api

type
  SyncExample* = Example[JsHttpClient]
  AsyncExample* = Example[JsAsyncHttpClient]

Example.setSync(SyncExample)
Example.setAsync(AsyncExample)

proc newExample*: SyncExample =
  ## Create a new `AsyncExample` object
  new(result)
  result.http = newJsHttpClient()

proc newAsyncExample*: AsyncExample =
  ## Create a new `AsyncExample` object
  new(result)
  result.http = newJsAsyncHttpClient()

proc setContentType*(ex: Example, contentType: string) =
  ## Sets content type header
  ex.http.headers["Content-Type".cstring] = cstring(contentType)

proc setTimeoutSync(ms: int) = {.emit: "setTimeout(function() { }, `ms`);".}

proc setTimeoutAsync(ms: int): Future[void] =
  let promise = newPromise() do (res: proc(): void):
    discard setTimeout(res, ms)
  return promise

proc parseHeaders(headers: Headers): HttpHeaders =
  var httpHeaders = newHttpHeaders()
  let ckeys = headers.keys()
  for ckey in ckeys:
    let
      cval = headers[ckey]
      key = $ckey
      val = $cval
    httpHeaders[key] = val
  return httpHeaders

proc newRequest(req: PureRequest): JsRequest =
  return newJsRequest(
    url = cstring($req.endpoint),
    `method` = req.endpoint.httpMethod,
    body = cstring(req.body)
  )

proc handleRateLimit(ex: Example, req: PureRequest, respHeaders: Headers): Future[PureResponse] {.fastsync.} =
  let resetMs = 1000 * parseInt($respHeaders["x-ratelimit-reset-in"])
  while true:
    when ex is AsyncExample:
      await setTimeoutAsync(resetMs)
    else:
      setTimeoutSync(resetMs)

    let
      newReq = newRequest(req)
      resp = await ex.http.request(newReq)
      payload = resp.responseText
      code = resp.status

    if not code.is2xx():
      responseCheck(code)
    else:
      let headers = parseHeaders(resp.headers)
      return PureResponse(
        code: code,
        body: $payload,
        headers: headers
      )

proc request*(ex: Example, req: PureRequest): Future[PureResponse] {.fastsync.} =
  let
    newReq = newRequest(req)
    resp = await ex.http.request(newReq)
    payload = resp.responseText
    code = resp.status

  if not code.is2xx():
    if code == Http429:
      return await ex.handleRateLimit(req, resp.headers)
    responseCheck(code)

  # Parse their response and give it back as a PureResponse
  let headers = parseHeaders(resp.headers)
  return PureResponse(
    code: code,
    body: $payload,
    headers: headers
  )

export pure