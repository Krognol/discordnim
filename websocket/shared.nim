import random, net, asyncdispatch, asyncnet, base64, times, strutils, securehash,
  nativesockets, streams, tables, oids, uri

## Example
## -------
##
## .. code-block::nim
##   import websocket, asyncnet, asyncdispatch
##
##   let ws = waitFor newAsyncWebsocket("echo.websocket.org",
##     Port 80, "/?encoding=text", ssl = false)
##   echo "connected!"
##
##   proc reader() {.async.} =
##     while true:
##       let read = await ws.sock.readData(true)
##       echo "read: " & $read
##
##   proc ping() {.async.} =
##     while true:
##       await sleepAsync(6000)
##       echo "ping"
##       await ws.sock.sendPing(true)
##
##   asyncCheck reader()
##   asyncCheck ping()
##   runForever()


import private/hex

const WebsocketUserAgent* = "websocket.nim (https://github.com/niv/websocket.nim)"

type
  PingRequest = Future[void]
  AsyncWebSocketObj = object of RootObj
    sock*: AsyncSocket
    protocol*: string
    pingtable: Table[int, PingRequest]

  AsyncWebSocket* = ref AsyncWebSocketObj

type
  ProtocolError* = object of Exception

  Opcode* {.pure.} = enum
    ##
    Cont = 0x0 ## Continued Frame (when the previous was fin = 0)
    Text = 0x1 ## Text frames need to be valid UTF-8
    Binary = 0x2 ## Binary frames can be anything.
    Close = 0x8 ## Socket is being closed by the remote, or we intend to close it.
    Ping = 0x9 ## Ping
    Pong = 0xa ## Pong. Needs to echo back the app data in ping.

  Frame* = tuple
    ## A frame read off the netlayer.

    fin: bool ## Last frame in current packet.
    rsv1: bool ## Extension data: negotiated in http prequel, or 0.
    rsv2: bool ## Extension data: negotiated in http prequel, or 0.
    rsv3: bool ## Extension data: negotiated in http prequel, or 0.

    masked: bool ## If the frame was received masked/is supposed to be masked.
                 ## Do not mask data yourself.

    opcode: Opcode ## The opcode of this frame.

    data: string ## App data

proc newAsyncWebsocket*(host: string, port: Port, path: string, ssl = false,
    additionalHeaders: seq[(string, string)] = @[],
    protocols: seq[string] = @[],
    userAgent: string = WebsocketUserAgent
   ): Future[AsyncWebSocket] {.async.} =
  ## Create a new websocket and connect immediately.
  ## Optionally give a list of protocols to negotiate; keep empty to accept the
  ## one the server offers (if any).
  ## The negotiated protocol is in `AsyncWebSocket.protocol`.

  let key = encode($(getTime().int))

  let s = newAsyncSocket()
  if ssl:
    when not defined(ssl):
      raise newException(Exception, "Cannot connect over SSL without -d:ssl")
    else:
      let ctx = newContext(protSSLv23, verifyMode = CVerifyNone)
      ctx.wrapSocket(s)

  await s.connect(host, port)
  await s.send("GET " & path & " HTTP/1.1\c\L")
  await s.send("Host: " & host & ":" & $port & "\c\L")
  await s.send("User-Agent: " & userAgent & "\c\L")
  await s.send("Upgrade: websocket\c\L")
  await s.send("Connection: Upgrade\c\L")
  await s.send("Cache-Control: no-cache\c\L")
  await s.send("Sec-WebSocket-Key: " & key & "\c\L")
  await s.send("Sec-WebSocket-Version: 13\c\L")
  if protocols.len > 0:
    await s.send("Sec-WebSocket-Protocol: " & protocols.join(", ") & "\c\L")
  for h in additionalHeaders:
    await s.send(h[0] & ": " & h[1] & "\c\L")

  await s.send("\c\L")

  let hdr = await s.recvLine()
  if not hdr.startsWith("HTTP/1.1 101 "):
    s.close()
    raise newException(ProtocolError,
      "server did not reply with a websocket upgrade: " & hdr)

  let ws = new AsyncWebSocket
  ws.pingtable = initTable[int, PingRequest]()
  ws.sock = s

  while true:
    let ln = await s.recvLine()
    if ln == "\c\L": break
    let sp = ln.split(": ")
    if sp.len < 2: continue
    echo sp
    if sp[0].toLower == "sec-websocket-protocol":
      if protocols.len > 0 and protocols.find(sp[1]) == -1:
        raise newException(ProtocolError, "server does not support any of our protocols")
      else: ws.protocol = sp[1]

    # raise newException(ProtocolError, "unknown server response " & ln)
    if sp[0].toLower == "sec-websocket-accept":
      # The server appends the fixed string 258EAFA5-E914-47DA-95CA-C5AB0DC85B11
      # (a GUID) to the value from Sec-WebSocket-Key header (which is not decoded
      # from base64), applies the SHA-1 hashing function, and encodes the result
      # using base64.
      let theirs = sp[1]
      let expected = secureHash(key & "258EAFA5-E914-47DA-95CA-C5AB0DC85B11")
      if theirs != decodeHex($expected).encode:
        raise newException(ProtocolError, "websocket-key did not match. proxy messing with you?")

  result = ws

proc makeFrame*(f: Frame): string =
  ## Generate valid websocket frame data, ready to be sent over the wire.
  ## This is useful for rolling your own impl, for example
  ## with AsyncHttpServer

  var ret = newStringStream()

  var b0: byte = (f.opcode.byte and 0x0f)
  b0 = b0 or (1 shl 7) # fin

  ret.write(byte b0)

  var b1: byte = 0

  if f.data.len <= 125: b1 = f.data.len.uint8
  elif f.data.len > 125 and f.data.len <= 0x7fff: b1 = 126u8
  else: b1 = 127u8

  let b1unmasked = b1
  if f.masked: b1 = b1 or (1 shl 7)

  ret.write(byte b1)

  if f.data.len > 125 and f.data.len <= 0x7fff:
    ret.write(int16 f.data.len.int16.htons)
  elif f.data.len > 0x7fff:
    ret.write(int64 f.data.len.int32.htonl)

  var data = f.data

  if f.masked:
    # TODO: proper rng
    randomize()
    let maskingKey = [ random(256).char, random(256).char,
      random(256).char, random(256).char ]

    for i in 0..<data.len: data[i] = (data[i].uint8 xor maskingKey[i mod 4].uint8).char

    ret.write(maskingKey)

  ret.write(data)
  ret.setPosition(0)
  result = ret.readAll()

  assert(result.len == (
    2 +
    (if f.masked: 4 else: 0) +
    (if b1unmasked == 126u8: 2 elif b1unmasked == 127u8: 8 else: 0) +
    data.len
  ))


proc makeFrame*(opcode: Opcode, data: string, masked: bool): string =
  ## A convenience shorthand.
  result = makeFrame((fin: true, rsv1: false, rsv2: false, rsv3: false,
    masked: masked, opcode: opcode, data: data))

proc newAsyncWebsocket*(uri: Uri, additionalHeaders: seq[(string, string)] = @[], 
    protocols: seq[string] = @[],
    userAgent: string = WebsocketUserAgent
   ): Future[AsyncWebSocket] {.async.} =
  var ssl: bool
  if uri.scheme == "ws":
    ssl = false
  elif uri.scheme == "wss":
    ssl = true
  else:
    raise newException(ProtocolError, "uri scheme has to be 'ws' for plaintext or 'wss' for websocket over ssl.")

  let port = Port(uri.port.parseInt())
  return await newAsyncWebsocket(uri.hostname, port , uri.path, ssl,
    additionalHeaders, protocols, userAgent)
  
proc newAsyncWebsocket*(uri: string, additionalHeaders: seq[(string, string)] = @[], 
    protocols: seq[string] = @[],
    userAgent: string = WebsocketUserAgent
   ): Future[AsyncWebSocket] {.async.} =
  let uriBuf = parseUri(uri)
  return await newAsyncWebsocket(uriBuf, additionalHeaders, protocols, userAgent)

# proc sendFrameData(ws: AsyncWebSocket, data: string): Future[void] {.async.} =
#   await ws.sock.send(data)

proc close*(ws: AsyncWebSocket): Future[void] {.async.} =
  ## Closes the socket.

  defer: ws.sock.close()
  await ws.sock.send(makeFrame(Opcode.Close, "", true))

# proc readData(ws: AsyncWebSocket): auto {.async.} =
#   ## This is an alias for







proc recvFrame*(ws: AsyncWebSocket): Future[Frame] {.async.} =
  ## Read a full frame off the given socket.
  ##
  ## You probably want to use the higher-level variant, `readData`.

  template `[]`(b: byte, idx: int): bool =
    const lookupTable = [128u8, 64, 32, 16, 8, 4, 2, 1]
    (b and lookupTable[idx]) != 0

  var f: Frame
  let hdr = await(ws.sock.recv(2))
  if hdr.len != 2: raise newException(IOError, "socket closed\c\L")

  let b0 = hdr[0].uint8
  let b1 = hdr[1].uint8

  f.fin  = b0[0]
  f.rsv1 = b0[1]
  f.rsv2 = b0[2]
  f.rsv3 = b0[3]
  f.opcode = (b0 and 0x0f).Opcode

  if f.rsv1 or f.rsv2 or f.rsv3:
    raise newException(ProtocolError,
      "websocket tried to use non-negotiated extension")

  var finalLen: int = 0

  let hdrLen = b1 and 0x7f
  if hdrLen == 0x7e:
    var lenstr = await(ws.sock.recv(2, {}))
    if lenstr.len != 2: raise newException(IOError, "socket closed")

    finalLen = cast[ptr int16](lenstr[0].addr)[].htons

  elif hdrLen == 0x7f:
    var lenstr = await(ws.sock.recv(8, {}))
    if lenstr.len != 8: raise newException(IOError, "socket closed")
    # we just assume it's a 32bit int, since no websocket will EVER
    # send more than 2GB of data in a single packet. Right? Right?
    finalLen = cast[ptr int32](lenstr[4].addr)[].htonl

  else:
    finalLen = hdrLen

  f.masked = (b1 and 0x80) == 0x80
  var maskingKey = ""
  if f.masked:
    maskingKey = await(ws.sock.recv(4, {}))
    # maskingKey = cast[ptr uint32](lenstr[0].addr)[]

  f.data = await(ws.sock.recv(finalLen, {}))
  if f.data.len != finalLen: raise newException(IOError, "socket closed")

  if f.masked:
    for i in 0..<f.data.len: f.data[i] = (f.data[i].uint8 xor maskingKey[i mod 4].uint8).char

  result = f

# Internal hashtable that tracks pings sent out, per socket.
# key is the socket fd
# # tuple[data: string, fut: Future[void]]
#  var reqPing = initTable[int, PingRequest]()

proc readData*(ws: AsyncWebSocket, isClientSocket: bool):
    Future[tuple[opcode: Opcode, data: string]] {.async.} =

  ## Reads reassembled data off the websocket and give you joined frame data.
  ##
  ## Note: You will still see control frames, but they are all handled for you
  ## (Ping/Pong, Cont, Close, and so on).
  ##
  ## The only ones you need to care about are Opcode.Text and Opcode.Binary, the
  ## so-called application frames.
  ##
  ## As per the websocket specifications, all clients need to mask their responses.
  ## It is up to you to to set `isClientSocket` with a proper value, depending on
  ## if you are reading from a server or client socket.
  ##
  ## Will raise IOError when the socket disconnects and ProtocolError on any
  ## websocket-related issues.
  var resultData = ""
  var resultOpcode: Opcode
  while true:
    let f = await ws.recvFrame()
    # Merge sequentially read frames.
    resultData &= f.data
    case f.opcode
      of Opcode.Close:
        # handle case: ping never arrives and client closes the connection
        let ex = newException(IOError, "socket closed by remote peer\c\L"&resultData)

        if ws.pingtable.hasKey(ws.sock.getFD().AsyncFD.int):
          ws.pingtable[ws.sock.getFD().AsyncFD.int].fail(ex)
          ws.pingtable.del(ws.sock.getFD().AsyncFD.int)

        raise ex

      of Opcode.Ping:
        await ws.sock.send(makeFrame(Opcode.Pong, f.data, isClientSocket))

      of Opcode.Pong:
        if ws.pingtable.hasKey(ws.sock.getFD().AsyncFD.int):
          ws.pingtable[ws.sock.getFD().AsyncFD.int].complete()

        else: discard  # thanks, i guess?

      of Opcode.Cont:
        if not f.fin: continue

      of Opcode.Text, Opcode.Binary:
        resultOpcode = f.opcode
        # read another!
        if not f.fin: continue

      else:
        ws.sock.close()
        raise newException(ProtocolError, "received invalid opcode: " & $f.opcode)

    result = (resultOpcode, resultData)
    return


proc sendText*(ws: AsyncSocket, p: string, masked: bool): Future[void] {.async.} =
  ## Sends text data. Will only return after all data has been sent out.
  await ws.send(makeFrame(Opcode.Text, p, masked))

proc sendBinary*(ws: AsyncSocket, p: string, masked: bool): Future[void] {.async.} =
  ## Sends binary data. Will only return after all data has been sent out.
  await ws.send(makeFrame(Opcode.Binary, p, masked))

proc sendPing*(ws: AsyncSocket, masked: bool, token: string = ""): Future[void] {.async.} =
  ## Sends a WS ping message.
  ## Will generate a suitable token if you do not provide one.

  let pingId = if token == "": $genOid() else: token
  await ws.send(makeFrame(Opcode.Ping, pingId, masked))

  # Old crud: send/wait. Very deadlocky.
  # let start = epochTime()
  # let pingId: string = $genOid()
  # var fut = newFuture[void]()
  # await ws.send(makeFrame(Opcode.Ping, pingId))
  # reqPing[ws.getFD().AsyncFD.int] = fut
  # echo "waiting"
  # await fut
  # reqPing.del(ws.getFD().AsyncFD.int)
  # result = ((epochTime() - start).float64 * 1000).int
