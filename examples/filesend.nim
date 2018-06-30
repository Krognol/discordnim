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
  if s.cache.me.id == m.author.id: return
  if m.content == "img":
    let f = readFile("somefile.png")
    asyncCheck s.channelFileSend(m.channel_id, "somefile.png", f)
  elif m.content == "img but with a message":
    let f = readFile("somefile.png")
    asyncCheck s.channelFileSendWithMessage(m.channel_id, "somefile.png", f, "here's a file but with a message")

let client = newDiscordClient("Bot " & DISCORD_TOKEN)
client.addHandler(EventType.message_create, messageCreate)

let shard = client.addShard()
shard.compress = true

proc endSession() {.noconv.} =
  waitFor client.disconnect()

setControlCHook(endSession)
waitFor shard.startSession()