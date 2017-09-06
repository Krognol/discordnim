## Has to be compiled with 
## '-d:ssl' flag

import asyncdispatch, discordnim, strutils

proc messageCreate(s: Shard, m: MessageCreate) =
    if s.cache.me.id == m.author.id: return
    if m.content == "ping":
        asyncCheck s.channelMessageSend(m.channel_id, "pong")
        
let d = newDiscordClient("Bot <your bot token>")
let s = d.addShard()
proc endSession() {.noconv.} =
    waitFor d.disconnect()

setControlCHook(endSession)

d.addHandler(EventType.message_create, messageCreate)
waitfor s.startSession()