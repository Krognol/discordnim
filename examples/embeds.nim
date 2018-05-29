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
  if m.content == "embed":  
    # This is just a helper function
    # to set the default values.
    # You can always make your own constructor
    # but if you're not using some object fields
    # e.g Author, Footer, etc.
    # they should always be set to nil
    # Your bot will crash if they're not set to nil
    let embed = Embed(
      title: "Embed title", 
      description: "Embed description",
      url: "https://github.com/Krognol/discordnim",
      color: 0xFF3245,
      fields: @[] # Has to be initialized, even if it's empty
    )
    asyncCheck s.channelmessageSendEmbed(m.channel_id, embed)


let client = newDiscordClient("Bot " & DISCORD_TOKEN)
client.addHandler(EventType.message_create, messageCreate)

let shard = client.addShard()
shard.compress = true

proc endSession() {.noconv.} =
  waitFor client.disconnect()

setControlCHook(endSession)
asyncCheck shard.startSession()