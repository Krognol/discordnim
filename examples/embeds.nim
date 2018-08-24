## Has to be compiled with 
## '-d:ssl' flag

import asyncdispatch, discordnim


proc messageCreate(s: Shard, m: MessageCreate) =
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


let shard = newShard("Bot <your bot token>")

proc endSession() {.noconv.} =
    waitFor shard.disconnect()

setControlCHook(endSession)

shard.addHandler(EventType.message_create, messageCreate)

waitFor shard.startSession()