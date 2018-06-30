## 
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import asyncdispatch, ospaths, ../src/discord

const DISCORD_TOKEN = getEnv("DISCORD_TOKEN")

if DISCORD_TOKEN == "":
  raise newException(Exception, "no DISCORD_TOKEN env variable found")

proc messageCreate(s: Shard, m: MessageCreate) {.cdecl.} =
  echo "Message was created!"
  if s.cache.me.id == m.author.id: return
  if m.content == "ping":
    asyncCheck s.channelMessageSend(m.channel_id, "pong")
  elif m.content == "you're stupid!":
    asyncCheck s.channelMessageDelete(m.channel_id, m.id)

proc messageUpdate(s: Shard, m: MessageUpdate) {.cdecl.} =
  echo "Message was updated"
  if m.content == "pong":
    asyncCheck s.channelMessageSend(m.channel_id, "ping")

var client = newDiscordClient("Bot " & DISCORD_TOKEN)
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