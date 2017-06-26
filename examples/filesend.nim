## Has to be compiled with 
## '-d:ssl' flag

import asyncdispatch, discord, logging

proc messageCreate(s: Session, m: MessageCreate) =
    if s.cache.me.id == m.author.id: return
    if m.content == "img":
        discard s.SendFileWithMessage(m.channel_id, "asdasd.png", "asdasd")

let s = NewSession("Bot <token>")
s.messageCreate = messageCreate

waitFor s.SessionStart()