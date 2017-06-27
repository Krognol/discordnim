include discordobjects, endpoints
import httpclient, asyncnet, strutils, json, marshal, net, re

method Request(s: Session, 
                bucketid, meth, url, contenttype, b : string, 
                sequence : int, 
                mp: MultipartData = nil): Future[AsyncResponse] {.base, gcsafe, async.} =

    var client = newAsyncHttpClient(sslContext = newContext(verifyMode = CVerifyNone))
    client.headers["User-Agent"] = "DiscordBot (https://github.com/Krognol/discordnim, v" & VERSION & ")"
    var id: string
    if bucketid == "":
        id = split(url, "?", 2)[0]

    var bucket = await s.limiter.lockBucket(id)

    if s.token != "" and s.token != nil:
        client.headers["Authorization"] = s.token

    client.headers["Content-Type"] = contenttype
    var res: AsyncResponse
    if mp == nil:
        res = await client.request(url, meth, b)
    elif mp != nil and meth == "POST":
        res = await client.post(url, b, mp)
    await bucket.Release(res.headers)

    case res.status:
    of "502":
        if sequence < 5:
            res = await s.Request(id, meth, url, contenttype, b, sequence+1)
    of "429":
        let resbody = await res.body()
        var rl = parseJson(resbody)
        await sleepAsync(int(rl["retry_after"].num))
        res = await s.Request(id, meth, url, contenttype, b, sequence)
    else: discard

    result = res
    client.close()


type
    CacheError* = object of Exception

# Caching stuff
proc getGuild*(c: Cache, id: string): tuple[guild: Guild, exists: bool]  =
    if c == nil: raise newException(CacheError, "The cache is nil")
    initLock(c.lock)
    defer: deinitLock(c.lock)

    if c.guilds.hasKey(id):
        return (c.guilds[id], true)

    result = (Guild(), false)

proc removeGuild*(c: Cache, guildid: string) {.raises: CacheError.}  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    if not c.guilds.hasKey(guildid):
        raise newException(CacheError, "Guild not in cache")
    
    initLock(c.lock)
    c.guilds.del(guildid)
    deinitLock(c.lock)

proc updateGuild*(c: Cache, guild: Guild) {.raises: CacheError.}  =
    if c == nil: raise newException(CacheError, "The cache is nil")
    
    initLock(c.lock)
    c.guilds[guild.id] = guild
    deinitLock(c.lock)

proc getUser*(c: Cache, id: string): tuple[user: User, exists: bool]  =
    if c == nil: raise newException(CacheError, "The cache is nil")
    initLock(c.lock)
    defer: deinitLock(c.lock)

    if c.users.hasKey(id):
        return (c.users[id], true)

    result = (User(), false)

proc removeUser*(c: Cache, id: string) {.raises: CacheError.}  =
    if c == nil: raise newException(CacheError, "The cache is nil")
    initLock(c.lock)
    defer: deinitLock(c.lock)
    if not c.users.hasKey(id):
        raise newException(CacheError, "User not in cache")

    c.users.del(id)

proc updateUser*(c: Cache, user: User) {.raises: CacheError.}  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    initLock(c.lock)
    c.users[user.id] = user
    deinitLock(c.lock)

proc getChannel*(c: Cache, id: string): tuple[channel: DChannel, exists: bool]  =
    if c == nil: raise newException(CacheError, "The cache is nil")
    initLock(c.lock)
    defer: deinitLock(c.lock)

    if c.channels.hasKey(id):
        return (c.channels[id], true)

    result = (DChannel(), false)

proc updateChannel*(c: Cache, chan: DChannel) {.raises: CacheError.}  =
    if c == nil: raise newException(CacheError, "The cache is nil")
    initLock(c.lock)
    defer: deinitLock(c.lock)

    if not c.channels.hasKey(chan.id):
        raise newException(CacheError, "Channel not in cache")

    c.channels[chan.id] = chan

proc removeChannel*(c: Cache, chan: string) {.raises: CacheError.}  =
    if c == nil: raise newException(CacheError, "The cache is nil")
    initLock(c.lock)
    defer: deinitLock(c.lock)
    if not c.channels.hasKey(chan):
        raise newException(CacheError, "Channel not in cache")

    c.channels.del(chan)

proc getGuildMember*(c: Cache, guild, memberid: string): tuple[member: GuildMember, exists: bool]  =
    if c == nil: raise newException(CacheError, "The cache is nil")
    
    var (guild, exists) = c.getGuild(guild)

    if not exists:
        return (GuildMember(), false)
    
    initLock(c.lock)
    defer: deinitLock(c.lock)
    for member in guild.members:
        if member.user.id == memberid:
            return (member, true)

    return (GuildMember(), false)

proc addGuildMember*(c: Cache, member: GuildMember)  =
    if c == nil: raise newException(CacheError, "The cache is nil")
    
    var (guild, exists) = c.getGuild(member.guild_id)

    if not exists:
        raise newException(CacheError, "Guild not in cache")

    initLock(c.lock)
    guild.members.add(member)
    deinitLock(c.lock)

proc updateGuildMember*(c: Cache, m: GuildMember)  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    var (guild, exists) = c.getGuild(m.guild_id)

    if not exists:
        raise newException(CacheError, "Guild not in cache")

    initLock(c.lock)
    defer: deinitLock(c.lock)
    for i, member in guild.members:
        if member.user.id == m.user.id:
            guild.members[i] = m
            return

proc removeGuildMember*(c: Cache, gmember: GuildMember)  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    var (guild, exists) = c.getGuild(gmember.guild_id)

    if not exists:
        raise newException(CacheError, "Guild not in cache")
    
    initLock(c.lock)
    defer: deinitLock(c.lock)
    for i, member in guild.members:
        if member.user.id == gmember.user.id:
            guild.members.del(i)
            return 

proc getRole*(c: Cache, guildid, roleid: string): tuple[role: Role, exists: bool]  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    var (guild, exists) = c.getGuild(guildid)

    if not exists:
        return (Role(), false)
    
    initLock(c.lock)
    defer: deinitLock(c.lock)
    for role in guild.roles:
        if role.id == roleid:
            return (role, true)

    return (Role(), false)

proc updateRole*(c: Cache, role: Role) {.raises: CacheError.} =
    if c == nil: raise newException(CacheError, "The cache is nil")
    initLock(c.lock)
    defer: deinitLock(c.lock)

    if not c.roles.hasKey(role.id):
        raise newException(CacheError, "Role not in cache")

    c.roles[role.id] = role

proc removeRole*(c: Cache, role: string) {.raises: CacheError.} =
    if c == nil: raise newException(CacheError, "The cache is nil")
    initLock(c.lock)
    defer: deinitLock(c.lock)

    if not c.roles.hasKey(role):
        raise newException(CacheError, "Role not in cache")

    c.roles.del(role)

method GetChannel*(s: Session, channel_id: string): Future[DChannel] {.base, gcsafe, async.} =
    ## Returns the channel with the given ID
    if s.cache.cacheChannels:
        var (chan, exists) = s.cache.getChannel(channel_id)

        if exists:
            return chan

    var url = EndpointGetChannel(channel_id)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[DChannel](body)

    if s.cache.cacheChannels:
        s.cache.channels[result.id] = result

method ModifyChannel*(s: Session, channelid: string, params: ChannelParams): Future[Guild] {.base, gcsafe, async.} =
    ## Modifies a channel with the ChannelParams
    var url = EndpointModifyChannel(channelid)
    let res = await s.Request(url, "PATCH", url, "application/json", $$params, 0)
    let body = await res.body()
    result = marshal.to[Guild](body) 

method DeleteChannel*(s: Session, channelid: string): Future[DChannel] {.base, gcsafe, async.} =
    ## Deletes a channel
    var url = EndpointDeleteChannel(channelid)
    let res = await s.Request(url, "DELETE", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[DChannel](body)

method ChannelMessages*(s: Session, channelid: string, before, after, around: string, limit: int): Future[seq[Message]] {.base, gcsafe, async.} =
    ## Returns a channels messages
    ## Maximum of 100 messages
    var url = EndpointGetChannelMessages(channelid) & "/?"
    
    if before != "":
        url = url & "before=" & before & "&"
    
    if after != "":
        url = url & "after=" & after & "&"

    if around != "":
        url = url & "around=" & around & "&"

    if limit > 0 and limit <= 100:
        url = url & "limit=" & $limit

    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[seq[Message]](body)

method ChannelMessage*(s: Session, channelid, messageid: string): Future[Message] {.base, gcsafe, async.} =
    ## Returns a message from a channel
    var url = EndpointGetChannelMessage(channelid, messageid)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[Message](body)


method SendMessage*(s: Session, channelid, message: string): Future[Message] {.base, gcsafe, async.} =
    ## Sends a regular text message to a channel
    var url = EndpointCreateMessage(channelid)
    let payload = %*{"content": message}
    let res = await s.Request(url, "POST", url, "application/json", $payload, 0)
    let body = await res.body()
    result = marshal.to[Message](body)
    

method SendMessageEmbed*(s: Session, channelid: string, embed: Embed): Future[Message] {.base, gcsafe, async.} =
    ## Sends an Embed message to a channel
    var url = EndpointCreateMessage(channelid)

    let payload = %*{
        "content": "",
        "embed": embed
    }

    let res = await s.Request(url, "POST", url, "application/json", $payload, 0)
    let body = await res.body()
    result = marshal.to[Message](body)

method SendMessageTTS*(s: Session, channelid, message: string): Future[Message] {.base, gcsafe, async.} =
    ## Sends a TTS message to a channel
    var url = EndpointCreateMessage(channelid)
    let payload = %*{"content": message, "tts": true}
    let res = await s.Request(url, "POST", url, "application/json", $payload, 0)
    let body = await res.body()
    result = marshal.to[Message](body)

# SendFileWithMessage and SendFile won't work
# without editing the httpclient lib
method SendFileWithMessage*(s: Session, channelid, name, message: string): Future[Message] {.base, gcsafe, async.} =
    ## Sends a file to a channel along with a message
    var data = newMultipartData()
    var url = EndpointCreateMessage(channelid)

    let payload = %*{"content": message}
    data = data.addFiles({"file": name})
    data.add("payload_json", $payload, contentType = "application/json")
    let res = await s.Request(url, "POST", url, "multipart/form-data", "", 0, data)
    let body = await res.body()
    result = marshal.to[Message](body)

method SendFile*(s: Session, channelid, name: string): Future[Message] {.base, gcsafe, async.} =
    ## Sends a file to a channel
    result = await s.SendFileWithMessage(channelid, name, "")

method MessageAddReaction*(s: Session, channelid, messageid, emojiid: string) {.base, gcsafe, async.} =
    ## Adds a reaction to a message
    var url = EndpointCreateReaction(channelid, messageid, emojiid)
    asyncCheck s.Request(url, "PUT", url, "application/json", "", 0)

method MessageDeleteOwnReaction*(s: Session, channelid, messageid, emojiid: string) {.base, gcsafe, async.} =
    ## Deletes your own reaction to a message
    var url = EndpointDeleteOwnReaction(channelid, messageid, emojiid)
    asyncCheck s.Request(url, "DELETE", url, "application/json", "", 0)

method MessageDeleteReaction*(s: Session, channelid, messageid, emojiid, userid: string) {.base, gcsafe, async.} =
    ## Deletes a reaction from a user from a message
    var url = EndpointDeleteUserReaction(channelid, messageid, emojiid, userid)
    asyncCheck s.Request(url, "DELETE", url, "application/json", "", 0)

method MessageGetReactions*(s: Session, channelid, messageid, emojiid: string): Future[seq[User]] {.base, gcsafe, async.} =
    ## Gets a message's reactions
    var url = EndpointGetMessageReactions(channelid, messageid, emojiid)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[seq[User]](body)
   

method MessageDeleteAllReactions*(s: Session, channelid, messageid: string) {.base, gcsafe, async.} =
    ## Deletes all reactions on a message
    var url = EndpointDeleteAllReactions(channelid, messageid)
    asyncCheck s.Request(url, "DELETE", url, "application/json", "", 0)

method EditMessage*(s: Session, channelid, messageid, content: string): Future[Message] {.base, gcsafe, async.} =
    ## Edits a message's contents
    var url = EndpointEditMessage(channelid, messageid)
    let payload = %*{"content": content}
    let res = await s.Request(url, "PATCH", url, "application/json", $payload, 0)
    let body = await res.body()
    result = marshal.to[Message](body)
    

method DeleteMessage*(s: Session, channelid, messageid: string) {.base, gcsafe, async.} =
    ## Deletes a message
    var url = EndpointDeleteMessage(channelid, messageid)
    asyncCheck s.Request(url, "DELETE", url, "application/json", "", 0)

method BulkDeleteMessages*(s: Session, channelid: string, messages: seq[string]) {.base, gcsafe, async.} =
    ## Deletes messages in bulk
    ## Will not delete messages older than 2 weeks
    var url = EndpointBulkDelete(channelid)
    let payload = %*{"messages": $messages}
    asyncCheck s.Request(url, "DELETE", url, "application/json", $payload, 0)

method EditChannelPermissions*(s: Session, channelid: string, overwrite: Overwrite) {.base, gcsafe, async.} =
    ## Edits a channel's permissions
    var url = EndpointEditChannelPermissions(channelid, overwrite.id)
    asyncCheck s.Request(url, "PUT", url, "application/json", $$overwrite, 0)

method ChannelInvites*(s: Session, channel: string): Future[seq[Invite]] {.base, gcsafe, async.} =
    ## Returns all invites to a channel
    var url = EndpointGetChannelInvites(channel)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[seq[Invite]](body)
   

method CreateChannelInvite*(s: Session, channel: string, max_age, max_uses: int, temp, unique: bool): Future[Invite] {.base, gcsafe, async.} =
    ## Creates an invite to a channel
    var url = EndpointCreateChannelInvite(channel)
    let payload = %*{"max_age": max_age, "max_uses": max_uses, "temp": temp, "unique": unique}
    let res = await s.Request(url, "POST", url, "application/json", $payload, 0)
    let body = await res.body()
    result = marshal.to[Invite](body)
    

method DeleteChannelPermission*(s: Session, channel, target: string) {.base, gcsafe, async.} =
    ## Deletes a channel permission
    var url = EndpointDeleteChannelPermission(channel, target)
    asyncCheck s.Request(url, "DELETE", url, "application/json", "", 0)

method TriggerTypingIndicator*(s: Session, channel: string) {.base, gcsafe, async.} =
    ## Triggers the "X is typing" indicator
    var url = EndpointTriggerTypingIndicator(channel)
    asyncCheck s.Request(url, "POST", url, "application/json", "", 0)

method ChannelPinnedMessages*(s: Session, channel: string): Future[seq[Message]] {.base, gcsafe, async.} =
    ## Returns all pinned messages in a channel
    var url = EndpointGetPinnedMessages(channel)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[seq[Message]](body)
    

method ChannelPinMessage*(s: Session, channel, message: string) {.base, gcsafe, async.} =
    ## Pins a message in a channel
    var url = EndpointAddPinnedChannelMessage(channel, message)
    asyncCheck s.Request(url, "PUT", url, "application/json", "", 0)

method ChannelDeletePinnedMessage*(s: Session, channel, message: string) {.base, gcsafe, async.} =
    var url = EndpointDeletePinnedChannelMessage(channel, message)
    asyncCheck s.Request(url, "DELETE", url, "application/json", "", 0)

# This might work?
type AddGroupDMUser* = object
    id: string
    nick: string

# This might work?
method CreateGroupDM*(s: Session, accesstokens: seq[string], nicks: seq[AddGroupDMUser]): Future[DChannel] {.base, gcsafe, async.} =
    ## Creates a group DM channel
    var url = EndpointCreateGroupDM()
    let payload = %*{"access_tokens": accesstokens, "nicks": nicks}
    let res = await s.Request(url, "POST", url, "application/json", $payload, 0)
    let body = await res.body()
    result = marshal.to[DChannel](body)

method GroupDMAddUser*(s: Session, channelid, userid, access_token, nick: string) {.base, gcsafe, async.} =
    ## Adds a user to a group dm.
    ## Requires the 'gdm.join' scope.
    var url = EndpointGroupDMAddRecipient(channelid, userid)
    let payload = %*{"access_token": access_token, "nick": nick}
    asyncCheck s.Request(url, "PUT", url, "application/json", $payload, 0)
    

method GroupdDMRemoveUser*(s: Session, channelid, userid: string) {.base, gcsafe, async.} =
    ## Removes a user from a group dm.
    var url = EndpointGroupDMRemoveRecipient(channelid, userid)
    asyncCheck s.Request(url, "DELETE", url, "application/json", "", 0)

method CreateGuild*(s: Session, name: string): Future[Guild] {.base, gcsafe, async.} =
    ## Creates a guild
    ## This endpoint is limited to 10 active guilds
    var url = EndpointCreateGuild()
    let payload = %*{"name": name}
    let res = await s.Request(url, "POST", url, "application/json", $payload, 0)
    let body = await res.body()
    result = marshal.to[Guild](body)
    

method GetGuild*(s: Session, id: string): Future[Guild] {.base, gcsafe, async.} =
    ## Gets a guild
    if s.cache.cacheGuilds:
        var (guild, exists) = s.cache.getGuild(id)

        if exists:
            return guild

    var url = EndpointGetGuild(id)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[Guild](body)
   
    if s.cache.cacheGuilds:
        s.cache.guilds[result.id] = result

        if s.cache.cacheRoles:
            for role in result.roles:
                s.cache.roles[role.id] = role

method ModifyGuild*(s: Session, guild: string, settings: GuildParams): Future[Guild] {.base, gcsafe, async.} =
    ## Modifies a guild with the GuildParams
    var url = EndpointModifyGuild(guild)
    let res = await s.Request(url, "PATCH", url, "application/json", $$settings, 0)
    let body = await res.body()
    result = marshal.to[Guild](body)
    

method DeleteGuild*(s: Session, guild: string): Future[Guild] {.base, gcsafe, async.} =
    ## Deletes a guild
    var url = EndpointDeleteGuild(guild)
    let res = await s.Request(url, "DELETE", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[Guild](body)
    

method GuildChannels*(s: Session, guild: string): Future[seq[DChannel]] {.base, gcsafe, async.} =
    ## Returns all guild channels
    var url = EndpointGetGuildChannels(guild)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[seq[DChannel]](body)
   

method GuildChannelCreate*(s: Session, guild, channelname: string, voice: bool): Future[DChannel] {.base, gcsafe, async.} =
    ## Creates a new channel in a guild
    var url = EndpointCreateGuildChannel(guild)
    let payload = %*{"name": channelname, "voice": voice}
    let res = await s.Request(url, "POST", url, "application/json", $payload, 0)
    let body = await res.body()
    result = marshal.to[DChannel](body)
    

method ModifyGuildChannelPosition*(s: Session, guild, channel: string, position: int): Future[seq[DChannel]] {.base, gcsafe, async.} =
    ## Reorders the position of a channel and returns the new order
    var url = EndpointModifyGuildChannelPositions(guild)
    let payload = %*{"id": channel, "position": position}
    let res = await s.Request(url, "PATCH", url, "application/json", $payload, 0)
    let body = await res.body()
    result = marshal.to[seq[DChannel]](body)
   

method ListGuildMembers*(s: Session, guild: string, limit, after: int): Future[seq[GuildMember]] {.base, gcsafe, async.} =
    ## Returns up to 1000 guild members
    var url = EndpointListGuildMembers(guild) & "?"

    if limit > 1:
        url &= "limit=" & $limit & "&"
    if after > 0:
        url &= "after=" & $after & "&"

    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[seq[GuildMember]](body)
    

method GetGuildMember*(s: Session, guild, userid: string): Future[GuildMember] {.base, gcsafe, async.} =
    ## Returns a guild member with the userid

    if s.cache.cacheGuildMembers:
        var (member, exists) = s.cache.getGuildMember(guild, userid)

        if exists:
            return member

    var url = EndpointGetGuildMember(guild, userid)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[GuildMember](body)
    
    if s.cache.cacheGuildMembers:
        s.cache.addGuildMember(result)

method GuildAddMember*(s: Session, guild, userid, accesstoken: string): Future[GuildMember] {.base, gcsafe, async.} =
    ## Adds a guild member to the guild
    var url = EndpointAddGuildMember(guild, userid)
    let payload = %*{"access_token": accesstoken}
    let res = await s.Request(url, "PUT", url, "application/json", $payload, 0)
    let body = await res.body()
    result = marshal.to[GuildMember](body)
    

method GuildMemberRoles*(s: Session, guild, userid: string, roles: seq[string]) {.base, gcsafe, async.} =
    ## Modifies a guild member's roles
    var url = EndpointModifyGuildMember(guild, userid)
    let payload = %*{"roles": $roles}
    asyncCheck s.Request(url, "PATCH", url, "application/json", $payload, 0)

method GuildMemberNick*(s: Session, guild, userid, nick: string) {.base, gcsafe, async.} =
    ## Sets the nickname of a member
    var url = EndpointModifyGuildMember(guild, userid)
    let payload = %*{"nick": nick}
    asyncCheck s.Request(url, "PATCH", url, "application/json", $payload, 0)

method GuildMemberMute*(s: Session, guild, userid: string, mute: bool) {.base, gcsafe, async.} =
    ## Mutes a guild member
    var url = EndpointModifyGuildMember(guild, userid)
    let payload = %*{"mute": mute}
    asyncCheck s.Request(url, "PATCH", url, "application/json", $payload, 0)

method GuildMemberDeafen*(s: Session, guild, userid: string, deafen: bool) {.base, gcsafe, async.} =
    ## Deafens a guild member
    var url = EndpointModifyGuildMember(guild, userid)
    let payload = %*{"deaf": deafen}
    asyncCheck s.Request(url, "PATCH", url, "application/json", $payload, 0)

method GuildMemberMove*(s: Session, guild, userid, channel: string) {.base, gcsafe, async.} =
    ## Moves a guild member from one channel to another
    ## only works if they are connected to a voice channel
    var url = EndpointModifyGuildMember(guild, userid)
    let payload = %*{"channel_id": channel}
    asyncCheck s.Request(url, "PATCH", url, "application/json", $payload, 0)

method Nick*(s: Session, guild, nick: string) {.base, gcsafe, async.} =
    ## Sets the nick for the current user
    var url = EndpointModifyNick(guild)
    let payload = %*{"nick": nick}
    asyncCheck s.Request(url, "PATCH", url, "application/json", $payload, 0)

method GuildMemberAddRole*(s: Session, guild, userid, roleid: string) {.base, gcsafe, async.} =
    ## Adds a role to a guild member
    var url = EndpointAddGuildMemberRole(guild, userid, roleid)
    asyncCheck s.Request(url, "PUT", url, "application/json", "", 0)

method GuildMemberRemoveRole*(s: Session, guild, userid, roleid: string) {.base, gcsafe, async.} =
    ## Removes a role from a guild member
    var url = EndpointRemoveGuildMemberRole(guild, userid, roleid)
    asyncCheck s.Request(url, "DELETE", url, "application/json", "", 0)

method GuildRemoveMember*(s: Session, guild, userid: string) {.base, gcsafe, async.} =
    ## Removes a guild membe from the guild
    var url = EndpointRemoveGuildMember(guild, userid)
    asyncCheck s.Request(url, "DELETE", url, "application/json", "", 0)

method GuildBans*(s: Session, guild: string): Future[seq[User]] {.base, gcsafe, async.} =
    ## Returns all users who have been banned from the guild
    var url = EndpointGetGuildBans(guild)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[seq[User]](body)
   

method GuildBanUser*(s: Session, guild, userid: string) {.base, gcsafe, async.} =
    ## Bans a user from the guild
    var url = EndpointCreateGuildBan(guild, userid)
    asyncCheck s.Request(url, "PUT", url, "application/json", "", 0)

method GuildRemoveBan*(s: Session, guild, userid: string) {.base, gcsafe, async.} =
    ## Removes a ban from the guild
    var url = EndpointRemoveGuildBan(guild, userid)
    asyncCheck s.Request(url, "DELETE", url, "application/json", "", 0)

method GuildRoles*(s: Session, guild: string): Future[seq[Role]] {.base, gcsafe, async.} =
    ## Returns all guild roles
    var url = EndpointGetGuildRoles(guild)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[seq[Role]](body)
    
method GuildRole*(s: Session, guild, roleid: string): Future[Role] {.base, gcsafe, async.} =
    ## Returns a role with the given id.
    if s.cache.cacheRoles:
        var (rolea, exists) = s.cache.getRole(guild, roleid)

        if exists:
            return rolea

    let roles = await s.GuildRoles(guild)

    for role in roles:
        if role.id == roleid:
            s.cache.roles[role.id] = role
            result = role
            break
    
    if s.cache.cacheRoles:
        s.cache.roles[result.id] = result


method GuildCreateRole*(s: Session, guild: string): Future[Role] {.base, gcsafe, async.} =
    ## Creates a new role in the guild
    var url = EndpointCreateGuildRole(guild)
    let res = await s.Request(url, "POST", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[Role](body)
    

method GuildEditRolePosition*(s: Session, guild: string, roles: seq[Role]): Future[seq[Role]] {.base, gcsafe, async.} =
    ## Edits the positions of a guilds roles roles
    ## and returns the new roles order
    var url = EndpointModifyGuildRolePositions(guild)
    let res = await s.Request(url, "PATCH", url, "application/json", $$roles, 0)
    let body = await res.body()
    result = marshal.to[seq[Role]](body)
    

method GuildEditRole*(s: Session, guild, roleid, name: string, permissions, color: int, hoist, mentionable: bool): Future[Role] {.base, gcsafe, async.} =
    ## Edits a role
    var url = EndpointModifyGuildRole(guild, roleid)
    let payload = %*{"name": name, "permissions": permissions, "color": color, "hoist": hoist, "mentionable": mentionable}
    let res = await s.Request(url, "PATCH", url, "application/json", $payload, 0)
    let body = await res.body()
    result = marshal.to[Role](body)
   

method GuildDeleteRole*(s: Session, guild, roleid: string) {.base, gcsafe, async.} =
    ## Deletes a role
    var url = EndpointDeleteGuildRole(guild, roleid)
    asyncCheck s.Request(url, "DELETE", url, "application/json", "", 0)

method GuildPruneCount*(s: Session, guild: string, days: int): Future[int] {.base, gcsafe, async.} =
    ## Returns the number of members who would get kicked
    ## during a prune operation
    var url = EndpointGetGuildPruneCount(guild) & "?days=" & $days
    let res = await s.Request(url, "GET", "", "application/json", "", 0)
    let body = await res.body()
    type Temp = object
        pruned: int

    let t = marshal.to[Temp](body)
    return t.pruned

method GuildPruneBegin*(s: Session, guild: string, days: int): Future[int] {.base, gcsafe, async.} =
    ## Begins a prune operation and
    ## kicks all members who haven't been active
    ## for N days
    var url = EndpointBeginGuildPruneCount(guild) & "?days=" & $days
    let res = await s.Request(url, "POST", "", "application/json", "", 0)
    let body = await res.body()
    type Temp = object
        pruned: int

    let t = marshal.to[Temp](body)
    return t.pruned

method GuildVoiceRegions*(s: Session, guild: string): Future[seq[VoiceRegion]] {.base, gcsafe, async.} =
    ## Lists all voice regions in a guild
    var url = EndpointGetGuildVoiceRegions(guild)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[seq[VoiceRegion]](body)
    

method GuildInvites*(s: Session, guild: string): Future[seq[Invite]] {.base, gcsafe, async.} =
    ## Lists all guild invites
    var url = EndpointGetGuildInvites(guild)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[seq[Invite]](body)
    

method GuildIntegrations*(s: Session, guild: string): Future[seq[Integration]] {.base, gcsafe, async.} =
    ## Lists all guild integrations
    var url = EndpointGetGuildIntegrations(guild)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[seq[Integration]](body)
    

method GuildIntegrationCreate*(s: Session, guild, typ, id: string) {.base, gcsafe, async.} =
    ## Creates a new guild integration
    var url = EndpointGetGuildIntegrations(guild)
    let payload = %*{"type": typ, "id": id}
    asyncCheck s.Request(url, "POST", url, "application/json", $payload, 0)

method GuildIntegrationEdit*(s: Session, guild, integrationid: string, behaviour, grace: int, emotes: bool) {.base, gcsafe, async.} =
    ## Edits a guild integration
    var url = EndpointModifyGuildIntegration(guild, integrationid)
    let payload = %*{"expire_behavior": behaviour, "expire_grace_period": grace, "enable_emoticons": emotes}
    asyncCheck s.Request(url, "PATCH", url, "application/json", $payload, 0)

method GuildIntegrationDelete*(s: Session, guild, integration: string) {.base, gcsafe, async.} =
    ## Deletes a guild Integration
    var url = EndpointDeleteGuildIntegration(guild, integration)
    asyncCheck s.Request(url, "DELETE", url, "application/json", "", 0)

method GuildIntegrationSync*(s: Session, guild, integration: string) {.base, gcsafe, async.} =
    ## Syncs an existing guild integration
    var url = EndpointSyncGuildIntegration(guild, integration)
    asyncCheck s.Request(url, "POST", url, "application/json", "", 0)

method GetGuildEmbed*(s: Session, guild: string): Future[GuildEmbed] {.base, gcsafe, async.} =
    ## Gets a GuildEmbed
    var url = EndpointGetGuildEmbed(guild)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[GuildEmbed](body)
    

method GuildEmbedEdit*(s: Session, guild: string, enabled: bool, channel: string): Future[GuildEmbed] {.base, gcsafe, async.} =
    ## Edits a GuildEmbed
    var url = EndpointModifyGuildEmbed(guild)
    let embed = GuildEmbed(enabled: enabled, channel_id: channel)
    let res = await s.Request(url, "PATCH", url, "application/json", $$embed, 0)
    let body = await res.body()
    result = marshal.to[GuildEmbed](body)
   

method GetInvite*(s: Session, code: string): Future[Invite] {.base, gcsafe, async.} =
    ## Gets an invite with code
    var url = EndpointGetInvite(code)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[Invite](body)
   

method InviteDelete*(s: Session, code: string): Future[Invite] {.base, gcsafe, async.} =
    ## Deletes an invite
    var url = EndpointDeleteInvite(code)
    let res = await s.Request(url, "DELETE", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[Invite](body)
    

method Me*(s: Session): Future[User] {.base, gcsafe, async.} =
    ## Returns the current user
    var url = EndpointGetCurrentUser()
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[User](body)
   

method GetUser*(s: Session, userid: string): Future[User] {.base, gcsafe, async.} =
    ## Gets a user
    if s.cache.cacheUsers:
        var (user, exists) = s.cache.getUser(userid)

        if exists:
            return user

    var url = EndpointGetUser(userid)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[User](body)

    if s.cache.cacheUsers:
        s.cache.users[result.id] = result
        
method EditUsername*(s: Session, name: string): Future[User] {.base, gcsafe, async.} =
    ## Edits the current users username
    var url = EndpointGetCurrentUser()
    let payload = %*{"username": name}
    let res = await s.Request(url, "PATCH", url, "application/json", $payload, 0)
    let body = await res.body()
    result = marshal.to[User](body)
    

method EditAvatar*(s: Session, avatar: string): Future[User] {.base, gcsafe, async.} =
    ## Changes the current users avatar
    var url = EndpointGetCurrentUser()
    let payload = %*{"avatar": avatar}
    let res = await s.Request(url, "PATCH", url, "application/json", $payload, 0)
    let body = await res.body()
    result = marshal.to[User](body)
    

method CurrentUserGuilds*(s: Session): Future[seq[UserGuild]] {.base, gcsafe, async.} =
    ## Lists the current users guilds
    var url = EndpointGetCurrentUserGuilds()
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[seq[UserGuild]](body)
    

method LeaveGuild*(s: Session, guild: string) {.base, gcsafe, async.} =
    ## Makes the current user leave the specified guild
    var url = EndpointLeaveGuild(guild)
    asyncCheck s.Request(url, "DELETE", url, "application/json", "", 0)

method ActivePrivateChannels*(s: Session): Future[seq[DChannel]] {.base, gcsafe, async.} =
    ## Lists all active DM channels
    var url = EndpointGetUserDMs()
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[seq[DChannel]](body)
    

method PrivateChannelCreate*(s: Session, recipient: string): Future[DChannel] {.base, gcsafe, async.} =
    ## Creates a new DM channel
    var url = EndpointCreateDM()
    let payload = %*{"recipient_id": recipient}
    let res = await s.Request(url, "POST", url, "application/json", $payload, 0)
    let body = await res.body()
    result = marshal.to[DChannel](body) 
    

method VoiceRegions*(s: Session): Future[seq[VoiceRegion]] {.base, gcsafe, async.} =
    ## Lists all voice regions
    var url = EndpointListVoiceRegions()
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[seq[VoiceRegion]](body)
    

method WebhookCreate*(s: Session, channel, name, avatar: string): Future[Webhook] {.base, gcsafe, async.} =
    ## Creates a webhook
    var url = EndpointCreateWebhook(channel)
    let payload = %*{"name": name, "avatar": avatar}
    let res = await s.Request(url, "POST", url, "application/json", $payload, 0)
    let body = await res.body()
    result = marshal.to[Webhook](body)
   

method ChannelWebhooks*(s: Session, channel: string): Future[seq[Webhook]] {.base, gcsafe, async.} =
    ## Lists all webhooks in a channel
    var url = EndpointGetChannelWebhooks(channel)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[seq[Webhook]](body)
   

method GuildWebhooks*(s: Session, guild: string): Future[seq[Webhook]] {.base, gcsafe, async.} =
    ## Lists all webhooks in a guild
    var url = EndpointGetGuildWebhook(guild)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[seq[Webhook]](body)
    

method GetWebhookWithToken*(s: Session, webhook, token: string): Future[Webhook] {.base, gcsafe, async.} =
    ## Gets a webhook with a token
    var url = EndpointGetWebhookWithToken(webhook, token)
    let res = await s.Request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[Webhook](body)
    

method WebhookEdit*(s: Session, webhook, name, avatar: string): Future[Webhook] {.base, gcsafe, async.} =
    ## Edits a webhook
    var url = EndpointModifyWebhook(webhook)
    let payload = %*{"name": name, "avatar": avatar}
    let res = await s.Request(url, "PATCH", url, "application/json", $payload, 0)
    let body = await res.body()
    result = marshal.to[Webhook](body)
    

method WebhookEditWithToken*(s: Session, webhook, token, name, avatar: string): Future[Webhook] {.base, gcsafe, async.} =
    ## Edits a webhook with a token
    var url = EndpointModifyWebhookWithToken(webhook, token)
    let payload = %*{"name": name, "avatar": avatar}
    let res = await s.Request(url, "PATCH", url, "application/json", $payload, 0)
    let body = await res.body()
    result = marshal.to[Webhook](body)
    

method WebhookDelete*(s: Session, webhook: string): Future[Webhook] {.base, gcsafe, async.} =
    ## Deletes a webhook
    var url = EndpointDeleteWebhook(webhook)
    let res = await s.Request(url, "DELETE", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[Webhook](body)
    

method WebhookDeleteWithToken*(s: Session, webhook, token: string): Future[Webhook] {.base, gcsafe, async.} =
    ## Deltes a webhook with a token
    var url = EndpointDeleteWebhookWithToken(webhook, token)
    let res = await s.Request(url, "DELETE", url, "application/json", "", 0)
    let body = await res.body()
    result = marshal.to[Webhook](body)
    

method ExecuteWebhook*(s: Session, webhook, token: string, wait: bool, payload: WebhookParams) {.base, gcsafe, async.} =
    ## Executes a webhook
    var url = EndpointExecuteWebhook(webhook, token)
    asyncCheck s.Request(url, "POST", url, "application/json", $$payload, 0) 


proc `$`*(u: User): string {.gcsafe, inline.} =
    ## Stringifies a user.
    ##
    ## e.g: Username#1234
    result = u.username & "#" & u.discriminator

proc `$`*(c: DChannel): string {.gcsafe, inline.} =
    ## Stringifies a channel.
    ##
    ## e.g: #channel-name
    result = "#" & c.name

proc `$`*(e: Emoji): string {.gcsafe, inline.} =
    ## Stringifies an emoji.
    ##
    ## e.g: :emojiName:129837192873
    result = ":" & e.name & ":" & e.id

proc `@`*(u: User): string {.gcsafe, inline.} =
    ## Returns a message formatted user mention.
    ##
    ## e.g: <@109283102983019283>
    result = "<@" & u.id & ">"

proc `@`*(c: DChannel): string {.gcsafe, inline.} = 
    ## Returns a message formatted channel mention.
    ##
    ## e.g: <#1239810283>
    result = "<#" & c.id & ">"

proc `@`*(r: Role): string {.gcsafe, inline.} =
    ## Returns a message formatted role mention
    ##
    ## e.g: <@&129837128937>
    result = "<@&" & r.id & ">"

proc `@`*(e: Emoji): string {.gcsafe, inline.} =
    ## Returns a message formated emoji.
    ##
    ## e.g: <:emojiName:1920381>
    result = "<" & $e & ">"

proc stripMentions*(msg: Message): string {.gcsafe.} =  
    ## Strips all user mentions from a message
    ## and replaces them with plaintext
    ##
    ## e.g: <@1901092738173> -> @Username#1234
    if msg.mentions == nil: return msg.content

    var content = msg.content

    for user in msg.mentions:
        let regex = r"<@!?(" & user.id & ")>"
        content = content.replace(regex, "@" & $user)
    result = content

proc stripEveryoneMention*(msg: Message): string {.gcsafe.} =
    ## Strips a message of any @everyone and @here mention
    if not msg.mention_everyone: return msg.content
    result = msg.content.replace(re"(@everyone)", "").replace(re"(@here)", "")

proc newMessageEmbed*(title, description, url: string = "", 
                      color: int = 0, footer: Footer = nil,
                      image: Image = nil, thumb: Thumbnail = nil,
                      video: Video = nil,
                      provider: Provider = nil,
                      author: Author = nil, fields: seq[Field] = nil): Embed {.gcsafe.} =
    ## Initialises a new Embed object
    result = Embed(
        title: title,
        description: description,
        url: url,
        color: color,
        footer: footer,
        image: image,
        thumbnail: thumb,
        video: video,
        provider: provider,
        author: author,
        fields: fields
    )

proc newChannelParams*(name, topic: string = "",
                       position: int = 0,
                       bitrate: int = 48,
                       userlimit: int = 0): ChannelParams {.gcsafe.} =
    ## Initialises a new ChannelParams object
    ## for altering channel settings.
    result = ChannelParams(
        name: name,
        position: position,
        topic: topic,
        bitrate: bitrate,
        user_limit: userlimit)

proc newGuildParams*(name, region, afkchan: string = "",
                     verlvl: int = 0,
                     defnotif: int = 0,
                     afktim: int = 0,
                     icon: string = "",
                     ownerid: string = "",
                     splash: string = ""): GuildParams {.gcsafe.} =
    ## Initialises a new GuildParams object
    ## for altering guild settings.
    result = GuildParams(
        name: name,
        region: region,
        verification_level: verlvl,
        default_message_notifications: defnotif,
        afk_channel_id: afkchan,
        afk_timeout: afktim,
        icon: icon,
        owner_id: ownerid,
        splash: splash
    )

proc newGuildMemberParams*(nick, channelid: string = "",
                          roles: seq[string] = @[],
                          mute: bool = false,
                          deaf: bool = false): GuildMemberParams {.gcsafe.} =
    ## Initialises a new GuildMemberParams object
    ## for altering guild members.
    result = GuildMemberParams(
        nick: nick,
        roles: roles,
        mute: mute,
        deaf: deaf,
        channel_id: channelid
    )

proc newWebhookParams*(content, username, avatarurl: string = "",
                       tts: bool = false, embeds: Embed = nil): WebhookParams {.gcsafe.} =
    ## Initialises a new WebhookParams object
    ## for altering webhooks.
    result = WebhookParams(
        content: content,
        username: username,
        avatar_url: avatarurl,
        tts: tts,
        embeds: embeds
    )

proc messageGuild*(s: Session, m: Message): string =
    ## Returns the guild id of the guild
    ## the message was sent in.
    ##
    ## Returns an empty string if it can't find the guild in the cache
    ## or by requesting it from the API.
    if s.cache.cacheChannels:
        var (chan, exists) = s.cache.getChannel(m.channel_id)
        if exists:
            return chan.guild_id
    var chan = waitFor s.GetChannel(m.channel_id)
    if chan != DChannel():
        return chan.guild_id
    result = ""