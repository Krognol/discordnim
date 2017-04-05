## Has to be compiled with 
## '-d:ssl' and '--threads:on' flags

import asyncdispatch, discord, tables

var cachedMessages: Table[string, string]
cachedMessages = initTable[string, string]()

proc messageCreate(s: Session, m: Message) =
    echo "Message was created!"
    if m.author.id != s.State.me.id:
        cachedMessages[m.id] = m.content

proc messageDelete(s: Session, m: MessageDelete) =
    echo "Message was deleted"
    if cachedMessages.hasKey(m.id):
        discard s.SendMessage(m.channel_id, "Message removed: " & cachedMessages[m.id])
        cachedMessages.del(m.id)



let s = NewSession("Bot <lol token>")
s.messageCreate = messageCreate
s.messageDelete = messageDelete

asyncCheck s.SessionStart()
runForever()