## Has to be compiled with 
## '-d:ssl' flag

import asyncdispatch, discord, times

const PREFIX = "!"

proc messageCreate(s: Session, m: MessageCreate) =
    if m.author.id != s.cache.me.id:
        let command = m.content

        case command:
            of PREFIX & "help":
                asyncCheck s.channelMessageSend(m.channel_id, "This is supposed to be some help command!")
            of PREFIX & "date":
                asyncCheck s.channelMessageSend(m.channel_id, $getLocalTime(getTime()))
            else: discard

let s = newSession("Bot <token>")
s.addHandler(EventType.message_create, messageCreate)

asyncCheck s.startSession()