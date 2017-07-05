## Has to be compiled with 
## '-d:ssl' flag

import asyncdispatch, discord, tables 

var cachedMessages: Table[string, string]
cachedMessages = initTable[string, string]()

let messageCreateProc = proc(s: Session, m: MessageCreate) =
    echo "Message was created!"
    if m.author.id != s.cache.me.id:
        cachedMessages[m.id] = m.content
 
let messageDeleteProc = proc(s: Session, m: MessageDelete) =
    echo "Message was deleted"
    if cachedMessages.hasKey(m.id):
        asyncCheck s.channelMessageSend(m.channel_id, "Message removed: " & cachedMessages[m.id])
        cachedMessages.del(m.id)


let s = newSession("Bot <your bot token>")
s.addHandler(EventType.message_create, messageCreateProc)
s.addHandler(EventType.message_delete, messageDeleteProc)

waitFor s.startSession()