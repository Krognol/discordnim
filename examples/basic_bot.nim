## Has to be compiled with 
## '-d:ssl' flag

import asyncdispatch, discord

proc messageCreate(s: Session, m: MessageCreate) =
    if s.cache.me.id == m.author.id: return
    if m.content == "ping":
        asyncCheck s.channelMessageSend(m.channel_id, "pong")

let s = newSession("Bot <your bot token>")

proc endSession() {.noconv.} =
    waitFor s.disconnect()

setControlCHook(endSession)

s.addHandler(EventType.message_create, messageCreate)
waitFor s.startSession()