import ratelimit, websocket, httpclient, tables

type
    Cache* = ref object
    EventKind* = enum
        None
    ShardConfig* = ref object
        token*: string
        shard_id*: int
        shard_count*: int
    Shard* = ref object
        config: ShardConfig
        ratelimiter: RateLimiter
        apiclient: ApiClient
        gwclient: GatewayClient
        cache: Cache
        handlers: Table[EventKind, seq[pointer]]
    GatewayClient = ref object
        shard: Shard
        sequence: int
        interval: int
        gateway: string
        session_id: string
        conn: AsyncWebSocket
    ApiClient = ref object
        shard: Shard
        rateLimiter: RateLimiter
        headers: HttpHeaders
    
proc newApiClient*(token: string, shard: Shard): ApiClient {.inline.} =
    new(result)
    result.shard = shard
    result.rateLimiter = newRateLimiter()
    result.headers = newHttpHeaders({"User-Agent": "DiscordBot (https://github.com/Krognol/discordnim v1) Nim/0.20.2"})
    if token.len() > 0: result.headers.add("Authorization", "Bot " & token)
