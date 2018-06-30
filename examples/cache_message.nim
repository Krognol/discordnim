## 
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import asyncdispatch, ospaths, tables, ../src/discord

const DISCORD_TOKEN = getEnv("DISCORD_TOKEN")

if DISCORD_TOKEN == "":
  raise newException(Exception, "no DISCORD_TOKEN env variable found")

var cachedMessages: Table[string, string]
cachedMessages = initTable[string, string]()

proc messageCreateProc(s: Shard, m: MessageCreate) {.cdecl.} =
  echo "Message was created!"
  if m.author.id != s.cache.me.id:
    cachedMessages[m.id] = m.content
 
proc messageDeleteProc(s: Shard, m: MessageDelete) {.cdecl.} =
  echo "Message was deleted"
  if cachedMessages.hasKey(m.id):
    asyncCheck s.channelMessageSend(m.channel_id, "Message removed: " & cachedMessages[m.id])
    cachedMessages.del(m.id)


let client = newDiscordClient("Bot " & DISCORD_TOKEN)
client.addHandler(EventType.message_create, messageCreateProc)
client.addHandler(EventType.message_delete, messageDeleteProc)

let shard = client.addShard()
shard.compress = true

proc endSession() {.noconv.} =
  waitFor client.disconnect()

setControlCHook(endSession)
waitFor shard.startSession()