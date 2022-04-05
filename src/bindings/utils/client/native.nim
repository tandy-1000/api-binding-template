# C backend support
import
  std/[httpclient, os, strutils, tables],
  pkg/asyncutils,
  pure,
  ".."/api

type
  SyncExample* = Example[HttpClient]
  AsyncExample* = Example[AsyncHttpClient]

Example.setSync(SyncExample)
Example.setAsync(AsyncExample)

proc newSyncExample*: SyncExample =
  ## Create a new `SyncExample` object
  new(result)
  result.http = newHttpClient()

proc newAsyncExample*: AsyncExample =
  ## Create a new `AsyncExample` object
  new(result)
  result.http = newAsyncHttpClient()

proc setContentType*(ex: Example, contentType: string) =
  ## Sets content type header
  ex.http.headers["Content-Type"] = contentType

proc handleRateLimit(ex: Example, req: PureRequest, headers: HttpHeaders): Future[PureResponse] {.fastsync.} =
  let resetMs = parseInt(headers["x-ratelimit-reset"])*1000
  while true:
    when ex is AsyncExample:
      await sleepAsync(resetMs)
    else:
      os.sleep(resetMs)
    let
      resp = await ex.http.request(
        url = $req.endpoint,
        httpMethod = req.endpoint.httpMethod,
        body = req.body
      )
      code = resp.code()
      payload = await resp.body()

    if not code.is2xx():
      responseCheck(code)
    else:
      return PureResponse(
        code: code,
        body: payload,
        headers: resp.headers
      )

proc request*(ex: Example, req: PureRequest): Future[PureResponse] {.fastsync.} =
  let
    resp = await ex.http.request(
      url = $req.endpoint,
      httpMethod = req.endpoint.httpMethod,
      body = req.body
    )
    code = resp.code()
    payload = await resp.body()

  if not code.is2xx():
    if code == Http429:
      return await ex.handleRateLimit(req, resp.headers)
    responseCheck(code)

  # Parse their response and give it back as a PureResponse
  return PureResponse(
    code: code,
    body: payload,
    headers: resp.headers,
  )

export pure
