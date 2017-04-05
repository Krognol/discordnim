## Has to be compiled with 
## '-d:ssl' and '--threads:on' flags

import asyncdispatch, discord

proc messageCreate(s: Session, m: Message) =
    echo "Message was created!"
    if m.content == "ping":
        discard s.SendMessage(m.channel_id, "pong")

proc messageUpdate(s: Session, m: Message) =
    echo "Message was update"
    if m.content == "pong":
        discard s.SendMessage(m.channel_id, "ping")

let s = NewSession("Bot <your bot token>")
s.messageCreate = messageCreate
s.messageUpdate = messageUpdate

asyncCheck s.SessionStart()
runForever()