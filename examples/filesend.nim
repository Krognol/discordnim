## Has to be compiled with 
## '-d:ssl' and '--threads:on' flags

import asyncdispatch, discord, logging

proc messageCreate(s: Session, m: MessageCreate) =
    if s.cache.me.id == m.author.id: return
    if m.content == "img":
        # will not work without editing the httpclient library
        # refer to https://github.com/nim-lang/Nim/commit/5cf31417a6fcbe5a40bce792652fc05fc6a1cff9
        discard s.SendFileWithMessage(m.channel_id, "ZWn5Eqt.png", "asdasd")

let s = NewSession("Bot <token>")
s.messageCreate = messageCreate

waitFor s.SessionStart()