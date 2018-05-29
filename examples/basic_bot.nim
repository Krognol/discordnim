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

proc someMessageCreateProc(s: Shard, m: MessageCreate) {.cdecl.} =
  if m.content == "ping!":
    asyncCheck s.channelMessageSend(m.channel_id, "pong!")

let client = newDiscordClient("Bot " & DISCORD_TOKEN)
client.addHandler(EventType.message_create, someMessageCreateProc)

let shard = client.addShard()
shard.compress = true

proc endSession() {.noconv.} =
  waitFor client.disconnect()

setControlCHook(endSession)
waitFor shard.startSession()