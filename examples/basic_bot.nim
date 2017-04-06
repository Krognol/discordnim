## Has to be compiled with 
## '-d:ssl' and '--threads:on' flags

import asyncdispatch, discord

proc messageCreate(s: Session, m: Message) =
    echo "Message was created!"
    if s.State.me.id == m.author.id: return
    if m.content == "ping":
        discard s.SendMessage(m.channel_id, "pong")
    elif m.content == "you're stupid!":
        s.DeleteMessage(m.channel_id, m.id)

proc messageUpdate(s: Session, m: Message) =
    echo "Message was updated"
    if m.content == "pong":
        discard s.SendMessage(m.channel_id, "ping")



let s = NewSession("Bot <your bot token>")
s.messageCreate = messageCreate
s.messageUpdate = messageUpdate

asyncCheck s.SessionStart()
runForever()