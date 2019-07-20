# Discordnim

A Discord library for Nim. 

Websockets from [niv/websocket.nim](https://github.com/niv/websocket.nim)

# Installing

This assumes that you have your Nim environment (including [Nimble](https://github.com/nim-lang/nimble)) already set up, and that your Nim version is `0.19.4` or greater.
You can check your version with `nim --version`

```
nim -v
Nim Compiler Version 0.19.4 [Windows: amd64]
Copyright (c) 2006-2018 by Andreas Rumpf

git hash: 5ee9e86c87d831d32441db658046fc989a197ac9
active boot switches: -d:release
```

`nimble install discordnim`

# Usage

There are some examples in the `examples` folder.


Initialising a `Shard`:

```nim
when isMainModule:
    import asyncdispatch, discordnim, ospaths

    proc messageCreate(s: Shard, m: MessageCreate) =
        if s.cache.me.id == m.author.id: return
        if m.content == "ping":
            asyncCheck s.channelMessageSend(m.channel_id, "pong")

    let d = newShard("Bot " & getEnv("token")) // get token in environment variables 

    proc endSession() {.noconv.} =
        waitFor d.disconnect()

    setControlCHook(endSession)
    d.compress = true
    let removeProc = d.addHandler(EventType.message_create, messageCreate)
    waitFor d.startSession()
    removeProc()
```

All programs have to be compiled with the `-d:ssl` flag.

Example : 

```
nimble build -d:ssl
```
OR
```
nim compile -d:ssl --run youfile.nim
```

When compression is enabled you need a `zlib1.dll` present. Somewhere. I don't know where it should be placed.

[Documentation](https://krognol.github.io/discordnim/)

# Contributing

1. Fork it ( https://github.com/Krognol/discordnim/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request
