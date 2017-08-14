## Has to be compiled with 
## '-d:ssl' flag

import asyncdispatch, discord, strutils

proc messageCreate(s: Session, m: MessageCreate) =
    if s.cache.me.id == m.author.id: return
    if m.content == "ping":
        asyncCheck s.channelMessageSend(m.channel_id, "pong")
    elif m.content == "add handler":
        # Closures work too!
        let clos = proc(s2: Session, m: MessageDelete) =
            asyncCheck s2.channelMessageSend(m.channel_id, "message $1 deleted!" % [m.id])
        s.addHandler(EventType.message_delete, clos)

let s = newSession("Bot <your bot token>")

proc endSession() {.noconv.} =
    waitFor s.disconnect()

setControlCHook(endSession)

s.addHandler(EventType.message_create, messageCreate)
waitFor s.startSession()