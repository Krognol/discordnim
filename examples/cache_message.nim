## Has to be compiled with 
## '-d:ssl' flag

import asyncdispatch, discordnim, tables 

var cachedMessages: Table[string, string]
cachedMessages = initTable[string, string]()

let messageCreateProc = proc(s: Shard, m: MessageCreate) =
    echo "Message was created!"
    if m.author.id != s.cache.me.id:
        cachedMessages[$m.id] = m.content
 
let messageDeleteProc = proc(s: Shard, m: MessageDelete) =
    echo "Message was deleted" 
    if cachedMessages.hasKey($m.id):
        asyncCheck s.channelMessageSend(m.channel_id, "Message removed: " & cachedMessages[$m.id])
        cachedMessages.del($m.id)


let shard = newShard("<your bot token>")

proc endSession() {.noconv.} =
    waitFor shard.disconnect()

setControlCHook(endSession)

discard shard.addHandler(EventType.message_create, messageCreateProc)
discard shard.addHandler(EventType.message_delete, messageDeleteProc)

waitFor shard.startSession()