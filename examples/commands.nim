## Has to be compiled with 
## '-d:ssl' flag

import asyncdispatch, discordnim, times
 
const PREFIX = "!"

proc messageCreate(s: Shard, m: MessageCreate) =
    if m.author.id != s.cache.me.id:
        let command = m.content

        case command:
            of PREFIX & "help":
                asyncCheck s.channelMessageSend(m.channel_id, "This is supposed to be some help command!")
            of PREFIX & "date":
                asyncCheck s.channelMessageSend(m.channel_id, $utc(getTime()))
            else: discard

let shard = newShard("Bot <token>")

proc endSession() {.noconv.} =
    waitFor shard.disconnect()

setControlCHook(endSession)

discard shard.addHandler(EventType.message_create, messageCreate)

waitFor shard.startSession()