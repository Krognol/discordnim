## Has to be compiled with 
## '-d:ssl' and '--threads:on' flags

import asyncdispatch, discord

proc messageCreate(s: Session, m: MessageCreate) =
    if s.cache.me.id == m.author.id: return
    if m.content == "ping":
        discard s.SendMessage(m.channel_id, "pong")
    elif m.content == "you're stupid!":
        s.DeleteMessage(m.channel_id, m.id)

proc messageUpdate(s: Session, m: MessageUpdate) =
    if s.cache.me.id == m.author.id: return
    if m.content == "pong":
        discard s.SendMessage(m.channel_id, "ping")



let s = NewSession("Bot <your bot token>")
s.messageCreate = messageCreate
s.messageUpdate = messageUpdate

waitFor s.SessionStart()