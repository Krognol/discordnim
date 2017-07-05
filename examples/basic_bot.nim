## Has to be compiled with 
## '-d:ssl' flag

import asyncdispatch, discord

proc messageCreate(s: Session, m: MessageCreate) =
    if s.cache.me.id == m.author.id: return
    if m.content == "ping":
        asyncCheck s.channelMessageSend(m.channel_id, "pong")
    elif m.content == "you're stupid!":
        asyncCheck s.channelmessageDelete(m.channel_id, m.id)

proc messageUpdate(s: Session, m: MessageUpdate) =
    if s.cache.me.id == m.author.id: return
    if m.content == "pong":
        asyncCheck s.channelMessageSend(m.channel_id, "ping")
        


let s = newSession("Bot <your bot token>")
s.addHandler(EventType.message_create, messageCreate)
s.addHandler(EventType.message_update, messageUpdate)

waitFor s.startSession()