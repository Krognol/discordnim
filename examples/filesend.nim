## Has to be compiled with 
## '-d:ssl' flag

import asyncdispatch, discordnim

proc messageCreate(s: Shard, m: MessageCreate) =
    if s.cache.me.id == m.author.id: return
    if m.content == "img":
        let f = readFile("somefile.png")
        asyncCheck s.channelFileSend(m.channel_id, "somefile.png", f)
    elif m.content == "img but with a message":
        let f = readFile("somefile.png")
        asyncCheck s.channelFileSendWithMessage(m.channel_id, "somefile.png", f, "here's a file but with a message")

let client = newDiscordClient("Bot <token>")
let s = client.addShard()

proc endSession() {.noconv.} =
    waitFor client.disconnect()

setControlCHook(endSession)

s.addHandler(EventType.message_create, messageCreate)

waitFor s.startSession()