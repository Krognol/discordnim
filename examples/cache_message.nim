## Has to be compiled with 
## '-d:ssl' flag

import asyncdispatch, discord, tables


proc main() =
    var cachedMessages: Table[string, string]
    cachedMessages = initTable[string, string]()
    
    proc messageCreate(s: Session, m: MessageCreate) =
        echo "Message was created!"
        if m.author.id != s.cache.me.id:
            cachedMessages[m.id] = m.content

    proc messageDelete(s: Session, m: MessageDelete) =
        echo "Message was deleted"
        if cachedMessages.hasKey(m.id):
            asyncCheck s.SendMessage(m.channel_id, "Message removed: " & cachedMessages[m.id])
            cachedMessages.del(m.id)

    let s = NewSession("Bot <your bot token>")
    s.messageCreate = messageCreate
    s.messageDelete = messageDelete

    waitFor s.SessionStart()

main()