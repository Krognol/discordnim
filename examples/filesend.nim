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

let shard = newShard("Bot <token>")

proc endSession() {.noconv.} =
    waitFor shard.disconnect()

setControlCHook(endSession)

discard shard.addHandler(EventType.message_create, messageCreate)

waitFor shard.startSession()