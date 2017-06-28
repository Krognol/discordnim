## Has to be compiled with 
## '-d:ssl' flag

import asyncdispatch, discord

proc messageCreateProc(s: Session, m: MessageCreate) =
    if s.cache.me.id == m.author.id: return
    if m.content == "my-roles":
        var roles: seq[Role] = @[]
        
        # Check the cache for the guild first
        var (guild, exists) = s.cache.getGuild("214858616140857355")

        if not exists:
            # If it doesn't exist in the cache 
            # we'll request the guild and cache it at the same time.
            # I'd recommend only using the session functions
            # since they check the cache first before
            # making a request to the api.
            guild = waitFor s.GetGuild("214858616140857355")

        # This should be getting it from the cache since
        # we have cacheGuild(Members) set to true.
        var member = waitFor s.GetGuildMember("214858616140857355", m.author.id)
        
        for role in member.roles:
            let r = waitFor s.GuildRole("214858616140857355", role)
            roles.add(r)
        
        asyncCheck s.SendMessage(m.channel_id, $roles)
        # Sends "@[(id: 299604263133380629, name: nano, color: 2067276, hoist: false, position: 1, permissions: 2146958463, managed: false, mentionable: true)]"

let s = NewSession("Bot <Token>")
s.addHandler(message_create, messageCreateProc)

s.cache.cacheChannels = true
s.cache.cacheGuilds = true
s.cache.cacheRoles = true
s.cache.cacheGuildMembers = true
s.cache.cacheUsers = true

asyncCheck s.SessionStart()