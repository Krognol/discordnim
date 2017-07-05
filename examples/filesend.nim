## Has to be compiled with 
## '-d:ssl' flag

import asyncdispatch, discord, logging

proc messageCreate(s: Session, m: MessageCreate) =
    if s.cache.me.id == m.author.id: return
    if m.content == "img":
        let f = readFile("somefile.png")
        asyncCheck s.channelFileSend(m.channel_id, "somefile.png", f)
    elif m.content == "img but with a message":
        let f = readFile("somefile.png")
        asyncCheck s.channelFileSendWithMessage(m.channel_id, "somefile.png", f, "here's a file but with a message")

let s = newSession("Bot <token>")
s.addHandler(EventType.message_create, messageCreate)

waitFor s.startSession()