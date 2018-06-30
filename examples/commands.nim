## 
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import asyncdispatch, ospaths, times, ../src/discord

const DISCORD_TOKEN = getEnv("DISCORD_TOKEN")

if DISCORD_TOKEN == "":
  raise newException(Exception, "no DISCORD_TOKEN env variable found")

const PREFIX = "!"

proc messageCreate(s: Shard, m: MessageCreate) {.cdecl.} =
  if m.author.id != s.cache.me.id:
    let command = m.content

    case command:
      of PREFIX & "help":
        asyncCheck s.channelMessageSend(m.channel_id, "This is supposed to be some help command!")
      of PREFIX & "date":
        asyncCheck s.channelMessageSend(m.channel_id, $getLocalTime(getTime()))
      else: discard

let client = newDiscordClient("Bot " & DISCORD_TOKEN)
client.addHandler(EventType.message_create, messageCreate)

let shard = client.addShard()
shard.compress = true

proc endSession() {.noconv.} =
  waitFor client.disconnect()

setControlCHook(endSession)
waitFor shard.startSession()