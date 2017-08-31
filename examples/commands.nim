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
                asyncCheck s.channelMessageSend(m.channel_id, $getLocalTime(getTime()))
            else: discard

let client = newDiscordClient("Bot <token>")
let s = client.addShard()

proc endSession() {.noconv.} =
    waitFor client.disconnect()

setControlCHook(endSession)

s.addHandler(EventType.message_create, messageCreate)

waitFor s.startSession()