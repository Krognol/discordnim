## Has to be compiled with 
## '-d:ssl' flag

import asyncdispatch, discordnim

proc messageCreate(s: Shard, m: MessageCreate) =
    if s.cache.me.id == m.author.id: return
    if m.content == "ping":
        asyncCheck s.channelMessageSend(m.channel_id, "pong")
        
let d = newShard("Bot <Token>")

proc endSession() {.noconv.} = 
    waitFor d.disconnect()

setControlCHook(endSession)
d.compress = true
d.addHandler(EventType.message_create, messageCreate)
waitFor d.startSession()