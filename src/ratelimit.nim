import httpclient, strutils, asyncdispatch, tables, times

type 
    Bucket = ref object
        reset: int
        limit: int
        remaining: int
    RateLimiter* = ref object of RootObj
        global: Bucket
        endpoints: Table[string, Bucket]

proc nextWillRatelimit(b: Bucket): bool = (b.remaining - 1 < 0 and getTime().utc.toTime.toUnix <= b.reset)

proc preCheck*(b: Bucket) {.async, gcsafe.} =
    if b.limit == 0: return
    
    let diff = b.reset - getTime().utc.toTime.toUnix
    if diff < 0:
        b.reset += 3
        b.remaining = b.limit
        return
    
    if b.remaining <= 0:
        let delay = diff * 1000+900
        await sleepAsync delay.int
        return
    
    b.remaining.dec

proc postCheck*(b: Bucket, url: string, response: AsyncResponse): Future[bool] {.async, gcsafe.} =
    if response.headers.hasKey("X-Bucket-Reset"): b.reset = response.headers["X-Bucket-Reset"].parseInt
    if response.headers.hasKey("X-Bucket-Limit"): b.limit = response.headers["X-Bucket-Limit"].parseInt
    if response.headers.hasKey("X-Bucket-Remaining"): b.remaining = response.headers["X-Bucket-Remaining"].parseInt

    if response.code == Http429:
        let delay = if response.headers.hasKey("Retry-After"): response.headers["Retry-After"].parseInt else: -1
        if delay == -1: return false

        await sleepAsync delay+100
        result = true

proc cooldown(b: Bucket) {.async.} =
    let time = getTime().utc.toTime.toUnix
    if b.reset -  time < 0: return
    await sleepAsync ((b.reset - time) + 500).int


proc postCheck*(r: RateLimiter, url: string, response: AsyncResponse): Future[bool] {.async, gcsafe.} =
    if response.headers.hasKey("X-Bucket-Global"):
        result = await r.global.postCheck(url, response)
    else:
        let rl = if r.endpoints.hasKey(url): r.endpoints[url] else: new(Bucket)
        result = await rl.postCheck(url, response)

proc preCheck*(r: RateLimiter, url: string) {.async, gcsafe.} =
    await r.global.preCheck()

    if r.endpoints.hasKey(url):
        let rl = r.endpoints[url]
        await rl.preCheck()
        if rl.nextWillRatelimit():
            await rl.cooldown()

proc newRateLimiter*(): RateLimiter {.inline.} =
    result = RateLimiter(
        global: new(Bucket),
        endpoints: initTable[string, Bucket]()
    )