## Has to be compiled with 
## '-d:ssl' flag

import asyncdispatch, discord

proc messageCreate(s: Session, m: MessageCreate) =
    echo "Message was created!"
    if s.cache.me.id == m.author.id: return
    if m.content == "ping":
        asyncCheck s.channelMessageSend(m.channel_id, "pong")
    elif m.content == "you're stupid!":
        asyncCheck s.channelMessageDelete(m.channel_id, m.id)

proc messageUpdate(s: Session, m: MessageUpdate) =
    echo "Message was updated"
    if m.content == "pong":
        asyncCheck s.channelMessageSend(m.channel_id, "ping")

var sessions: seq[Session] = @[]
let shards = 1

for i in 0..shards:
    let s = newSession("Bot <Token>")
    s.shardID = i
    s.addHandler(EventType.message_create, messageCreate)
    s.addHandler(EventType.message_update, messageUpdate)
    sessions.add(s)

for session in sessions:
    asyncCheck session.startSession()

proc endSession() {.noconv.} =
    for session in sessions:
        asyncCheck session.disconnect()

setControlCHook(endSession)