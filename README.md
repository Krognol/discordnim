# Discordnim

A Discord library for Nim. 

Websockets from [niv/websocket.nim](https://github.com/niv/websocket.nim) -- Slightly altered to make functional for threads.

# Installing

`nimble install discordnim`

# Usage

There are some examples in the examples folder.

The `Session` object is the only one you should be concerned about.
It holds all REST API methods and gateway events.

Initialising a `Session`:

```nim
proc someMessageCreateProc(s: Session, m: MessageCreate) =
    if m.content == "ping":
        discard s.SendMessage(m.channel_id, "pong!")

let session = NewSession("Bot <your token>")
## Add your gateway event methods

session.messageCreate = someMessageCreateProc

## Lastly you connect 
waitFor s.StartSession()
runForever()
```

All programs have to be compiled with the `-d:ssl` and `--threads:on` flags

[Documentation](https://krognol.github.io/discordnim/)

# Contributing

1. Fork it ( https://github.com/Krognol/discordnim/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request