## Has to be compiled with 
## '-d:ssl' flag

import asyncdispatch, discordnim

proc messageCreate(s: Shard, m: MessageCreate) =
    echo "Message was created!"
    if s.cache.me.id == m.author.id: return
    if m.content == "ping":
        asyncCheck s.channelMessageSend(m.channel_id, "pong")
    elif m.content == "you're stupid!":
        asyncCheck s.channelMessageDelete(m.channel_id, m.id)

proc messageUpdate(s: Shard, m: MessageUpdate) =
    echo "Message was updated"
    if m.content == "pong":
        asyncCheck s.channelMessageSend(m.channel_id, "ping")


var client = newDiscordClient("Bot <Token>")
client.addHandler(EventType.message_create, messageCreate)
client.addHandler(EventType.message_update, messageUpdate)

if client.shardCount > 2:
    for i in 1..client.shardCount:
        let s = client.addShard()
        s.shardID = i

proc endSession() {.noconv.} =
    waitFor client.disconnect()

setControlCHook(endSession)

waitFor client.startSession()