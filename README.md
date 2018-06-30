# Discordnim

A Discord library for Nim. 

Websockets from [niv/websocket.nim](https://github.com/niv/websocket.nim) -- Slightly altered.

# Installing

This assumes that you have your Nim environment (including [Nimble](https://github.com/nim-lang/nimble)) already set up, and that your Nim version is `0.17.0` or greater.
You can check your version with `nim --version`

```
nim --version
Nim Compiler Version 0.17.0 (2017-05-17) [Windows: amd64]
Copyright (c) 2006-2017 by Andreas Rumpf

git hash: bf0afaf3c4a7f901a525cbb035d6421a2f30bfe8
active boot switches: -d:release
```

`nimble install discordnim`

# Usage

There are some examples in the `examples` folder.


Initialising a `Shard`:

```nim
import discordnim, asyncdispatch

proc someMessageCreateProc(s: Shard, m: MessageCreate) {.cdecl.} =
  if m.content == "ping":
    asyncCheck s.channelMessageSend(m.channel_id, "pong!")

let client = newDiscordClient("Bot <your token>")
## Add your gateway event methods
client.addHandler(EventType.message_create, someMessageCreateProc)

let shard = client.addShard()
shard.compress = true

## Lastly you connect
waitFor shard.startSession()
# Alternatively you can do 
# `client.startSession()`, but only useful if you have more than one shard.
```

All programs have to be compiled with the `--d:ssl` flag.

When compression is enabled you need a `zlib1.dll` present. Somewhere. I don't know where it should be placed.

[Documentation](https://krognol.github.io/discordnim/)

# Disclaimer

This package hasn't been tested on any Mac systems and are thus not guaranteed to work on them. Although, I have a hard time believeing they wouldn't work.

# Contributing

1. Fork it ( https://github.com/Krognol/discordnim/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request