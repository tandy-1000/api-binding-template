import std/[uri, httpcore]

type
  Example*[T] = ref object
    http*: T

  Endpoint* {.pure.} = ref object
    target*: Uri
    httpMethod*: HttpMethod

  PureRequest* = ref object
    endpoint*: Endpoint
    body*: string

  PureResponse* = ref object
    code*: HttpCode
    body*: string
    headers*: HttpHeaders

  HttpRequestError* = object of IOError

func newPureRequest*(endpoint: Endpoint, body: string = ""): PureRequest =
  result = PureRequest(endpoint: endpoint, body: body)

func `$`*(e: Endpoint): string =
  return $e.target

func build*(
  apiRoot, path: string,
  httpMethod: HttpMethod,
  params: varargs[(string, string)] = []): Endpoint =
  ## Builds an endpoint given the API root, path, `httpMethod`, and any query parameters
  var uri = parseUri(apiRoot & path)
  uri.query = encodeQuery(params)
  return Endpoint(target: uri, httpMethod: httpMethod)

proc responseCheck*(code: HttpCode) =
  ## Raises exceptions and relevant error messages if status is not 200.
  case code:
  of Http400:
    raise newException(HttpRequestError, "ERROR 400 Bad Request")
  of Http401:
    raise newException(HttpRequestError, "ERROR 401 Unauthorized")
  of Http403:
    raise newException(HttpRequestError, "ERROR 403 Forbidden")
  of Http404:
    raise newException(HttpRequestError, "ERROR 404 Not Found")
  of Http405:
    raise newException(HttpRequestError, "ERROR 405 Method Not Allowed")
  of Http429:
    raise newException(HttpRequestError, "ERROR 429 Too many Requests")
  of Http500:
    raise newException(HttpRequestError, "ERROR 500 Data requested not available")
  of Http503:
    raise newException(HttpRequestError, "ERROR 503 Cannot submit listens to queue, please try again later.")
  else:
    raise newException(HttpRequestError, "ERROR Received an unexpected status response")
