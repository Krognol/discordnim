include discordobjects, endpoints
import httpclient, asyncnet, strutils, json, marshal, net, re, ospaths, mimetypes, cgi, sequtils
 
method request(s: Shard,
                bucketid, meth, url, contenttype, b: string = "",
                sequence: int = 0,
                mp: MultipartData = nil,
                xheaders: HttpHeaders = nil): Future[AsyncResponse] {.base, gcsafe, async.} =
    var id: string
    if bucketid == "" or url.contains('?'):
        id = split(url, "?", 2)[0]
    else:
        id = bucketid
    await s.limiter.preCheck(id)

    let client = newAsyncHttpClient("DiscordBot (https://github.com/Krognol/discordnim, v" & VERSION & ")")
    await s.globalRL.preCheck(bucketid)

    client.headers["Authorization"] = s.token
    client.headers["Content-Type"] = contenttype 
    client.headers["Content-Length"] = $(b.len)
    if mp == nil: 
        result = await client.request(url, meth, b)
    else:
        if meth == "POST":
            result = await client.post(url, b, mp)
    client.close()

    if (await s.globalRL.postCheck(url, result)) and sequence < 5:
        result = await s.request(bucketid, meth, url, contenttype, b, sequence+1)

    if (await s.limiter.postCheck(url, result)):
        echo "You got ratelimited"

type
    CacheError* = object of Exception

proc join(g1: var Guild, g2: Guild) =
    ## Joins g1(regular guild) and g2(Ready event guild)
    ## with g2's Ready event only fields
    g1.joined_at = g2.joined_at
    g1.large = g2.large
    g1.unavailable = g2.unavailable
    g1.member_count = g2.member_count
    g1.voice_states = g2.voice_states
    g1.members = g2.members
    g1.channels = g2.channels
    g1.presences = g2.presences

# Caching stuff
method getGuild*(c: Cache, id: string): tuple[guild: Guild, exists: bool] {.base, gcsafe.} =
    ## Gets a guild from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    initLock(c.lock)
    defer: deinitLock(c.lock)
    result = (Guild(), false)
    
    if c.guilds.hasKey(id):
        result.guild = c.guilds[id]
        for g in c.ready.guilds:
            if g.id == result.guild.id:
                result.guild.join(g)
                result.exists = true
                break

method removeGuild*(c: Cache, guildid: string) {.raises: CacheError, base, gcsafe.}  =
    ## Removes a guild from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")

    if not c.guilds.hasKey(guildid): return
    
    initLock(c.lock)
    c.guilds.del(guildid)
    deinitLock(c.lock)

method updateGuild*(c: Cache, guild: Guild) {.raises: CacheError, inline, base, gcsafe.} =
    ## Updates a guild in the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    
    initLock(c.lock)
    c.guilds[guild.id.val] = guild
    deinitLock(c.lock)

method getUser*(c: Cache, id: string): tuple[user: User, exists: bool] {.base, gcsafe.}  =
    ## Gets a user from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    initLock(c.lock)
    defer: deinitLock(c.lock)
    result = (User(), false)
    
    if c.users.hasKey(id):
       result = (c.users[id], true)

method removeUser*(c: Cache, id: string) {.raises: CacheError, inline, base, gcsafe.}  =
    ## Removes a user from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    initLock(c.lock)
    defer: deinitLock(c.lock)
    if not c.users.hasKey(id): return

    c.users.del(id)

method updateUser*(c: Cache, user: User) {.inline, base, gcsafe.}  =
    ## Updates a user in the cache
    if c == nil: raise newException(CacheError, "The cache is nil")

    initLock(c.lock)
    c.users[user.id.val] = user
    deinitLock(c.lock)

method getChannel*(c: Cache, id: string): tuple[channel: Channel, exists: bool] {.base, gcsafe.} =
    ## Gets a channel from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    initLock(c.lock)
    defer: deinitLock(c.lock)
    result = (Channel(), false)

    if c.channels.hasKey(id):
        result = (c.channels[id], true)


method updateChannel*(c: Cache, chan: Channel) {.inline, base, gcsafe.}  =
    ## Updates a channel in the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    initLock(c.lock)
    c.channels[chan.id.val] = chan
    deinitLock(c.lock)

method removeChannel*(c: Cache, chan: string) {.raises: CacheError, inline, base, gcsafe.}  =
    ## Removes a channel from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    initLock(c.lock)
    defer: deinitLock(c.lock)
    if not c.channels.hasKey(chan): return

    c.channels.del(chan)

method getGuildMember*(c: Cache, guild, memberid: string): tuple[member: GuildMember, exists: bool] {. base, gcsafe.} =
    ## Gets a guild member from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    
    result = (GuildMember(), false)
    var (guild, exists) = c.getGuild(guild)

    if not exists:
        return
    
    initLock(c.lock)
    defer: deinitLock(c.lock)
    for member in guild.members: 
        if member.user.id == memberid:
            result = (member, true)
            break

method addGuildMember*(c: Cache, member: GuildMember) {.inline, base, gcsafe.} =
    ## Adds a guild member to the cache
    if c == nil: raise newException(CacheError, "The cache is nil")

    initLock(c.lock)
    c.members.add(member.user.id.val, member)
    deinitLock(c.lock)

method updateGuildMember*(c: Cache, m: GuildMember) {.inline, base, gcsafe.} =
    ## Updates a guild member in the cache
    if c == nil: raise newException(CacheError, "The cache is nil")

    initLock(c.lock)
    c.members[m.user.id.val] = m
    deinitLock(c.lock)

method removeGuildMember*(c: Cache, gmember: GuildMember) {.inline, base, gcsafe.} =
    ## Removes a guild member from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    initLock(c.lock)
    c.members.del(gmember.user.id.val)
    deinitLock(c.lock)

method getRole*(c: Cache, guildid, roleid: string): tuple[role: Role, exists: bool] {.base, gcsafe.} =
    ## Gets a role from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    
    result = (Role(), false)
    var (guild, exists) = c.getGuild(guildid)

    if not exists:
        return
    
    initLock(c.lock)
    defer: deinitLock(c.lock)
    for role in guild.roles:
        if role.id == roleid:
            result = (role, true)
            return

method updateRole*(c: Cache, role: Role) {.raises: CacheError, base, gcsafe.} =
    ## Updates a role in the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    initLock(c.lock)
    defer: deinitLock(c.lock)

    c.roles[role.id.val] = role

method removeRole*(c: Cache, role: string) {.raises: CacheError, base, gcsafe.} =
    ## Removes a role from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    initLock(c.lock)
    defer: deinitLock(c.lock)

    if not c.roles.hasKey(role): return

    c.roles.del(role)

method clear*(c: Cache) {.base, gcsafe.} =
    ## Clears a cache of all cached objects
    c.channels.clear()
    c.guilds.clear()
    c.members.clear()
    c.roles.clear()
    c.users.clear()

proc doreq(s: Shard, meth, endpoint, payload: string = "", xheaders: HttpHeaders = nil, mpd: MultipartData = nil): Future[JsonNode] =
    result = newFuture[JsonNode]("shard.request")
    let resnw = s.request(endpoint, meth, endpoint, "application/json", payload, 0, xheaders = xheaders)
    if resnw.failed():
        result.fail(resnw.error)
        return
    
    let res = waitFor resnw
    let body = waitFor res.body
    result.complete(body.parseJson)

method channel*(s: Shard, channel_id: string): Future[Channel] {.base, gcsafe, async.} =
    let (chan, exists) = s.cache.getChannel(channel_id)
    if exists:
        result = chan
        return
    let res = await doreq(s, endpointChannels(channel_id))
    result = newChannel(res)
    if s.cache.cacheChannels:
        s.cache.channels[result.id.val] = result

method channelEdit*(s: Shard, channelid: string, params: ChannelParams, reason: string = ""): Future[Guild] {.base, gcsafe, async.} =
    ## Edits a channel with the ChannelParams
    var xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    result = (await doreq(s, "POST", endpointChannels(channelid), $$params, xh)).newGuild
    if s.cache.cacheGuilds:
        s.cache.updateGuild(result)

method deleteChannel*(s: Shard, channelid: string, reason: string = ""): Future[Channel] {.base, gcsafe, async.} =
    ## Deletes a channel
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    result = (await doreq(s, "DELETE", endpointChannels(channelid), xheaders = xh)).newChannel
    if s.cache.cacheChannels:
        s.cache.removeChannel(result.id.val)

method channelMessages*(s: Shard, channelid: string, before, after, around: string, limit: int): Future[seq[Message]] {.base, gcsafe, async.} =
    ## Returns a channels messages
    ## Maximum of 100 messages
    var url = endpointChannelMessages(channelid) & "?"
    
    if before != "":
        url = url & "before=" & before & "&"
    if after != "":
        url = url & "after=" & after & "&"
    if around != "":
        url = url & "around=" & around & "&"
    if limit > 0 and limit <= 100:
        url = url & "limit=" & $limit
    
    result = (await doreq(s, "GET", url)).newMessageSeq

method channelMessage*(s: Shard, channelid, messageid: string): Future[Message] {.base, gcsafe, async, inline.} =
    ## Returns a message from a channel
    result = (await doreq(s, "GET", endpointChannelMessage(channelid, messageid))).newMessage

method channelMessageSend*(s: Shard, channelid, message: string): Future[Message] {.base, gcsafe, async.} =
    ## Sends a regular text message to a channel
    let payload = %*{"content": message}
    result = (await doreq(s, "POST", endpointChannelMessages(channelid), $payload)).newMessage

method channelMessageSendEmbed*(s: Shard, channelid: string, embed: Embed): Future[Message] {.base, gcsafe, async, inline.} =
    ## Sends an Embed message to a channel
    result = (await doreq(s, "POST", endpointChannelMessages(channelid),
        $(%*{
            "content": "",
            "embed": embed
        }))).newMessage


method channelMessageSendTTS*(s: Shard, channelid, message: string): Future[Message] {.base, gcsafe, async, inline.} =
    ## Sends a TTS message to a channel
    result = (await doreq(s, "POST", endpointChannelMessages(channelid), 
        $(%*{
            "content": message,
            "tts": true
        }))).newMessage

method channelFileSendWithMessage*(s: Shard, channelid, name, message: string): Future[Message] {.base, gcsafe, async.} =
    ## Sends a file to a channel along with a message
    let payload = %*{"content": message}
    var data = newMultipartData()
    data = data.addFiles({"file": name})
    data.add("payload_json", $payload, contentType = "application/json")
    result = (await doreq(s, "POST", endpointChannelMessages(channelid), mpd = data)).newMessage

method channelFileSendWithMessage*(s: Shard, channelid, name, fbody, message: string): Future[Message] {.base, gcsafe, async.} =
    ## Sends the contents of a file as a file to a channel.
    var data = newMultipartData()
    if name == "":
        raise newException(Exception, "Parameter `name` of `channelFileSendWithMessage` can't be empty and has to have an extension")
    let payload = %*{"content": message}
    var contenttype: string 
    let (_, fname, ext) = splitFile(name)
    if ext.len > 0: contenttype = newMimetypes().getMimetype(ext[1..high(ext)], nil)
    
    data.add(name, fbody, fname & ext, contenttype)
    data.add("payload_json", $payload, contentType = "application/json")
    result = (await doreq(s, "POST", endpointChannelMessages(channelid), mpd = data)).newMessage

method channelFileSend*(s: Shard, channelid, fname: string): Future[Message] {.base, gcsafe, inline, async.} =
    ## Sends a file to a channel
    result = await s.channelFileSendWithMessage(channelid, fname, "")

method channelFileSend*(s: Shard, channelid, fname, fbody: string): Future[Message] {.base, gcsafe, inline, async.} =
    ## Sends the contents of a file as a file to a channel.
    result = await s.channelFileSendWithMessage(channelid, fname, fbody, "")

method channelMessageReactionAdd*(s: Shard, channelid, messageid, emojiid: string): Future[void] {.base, gcsafe, inline, async.} = 
    ## Adds a reaction to a message
    asyncCheck doreq(s, "PUT", endpointMessageReactions(channelid, messageid, emojiid))

method messageDeleteOwnReaction*(s: Shard, channelid, messageid, emojiid: string): Future[void] {.base, gcsafe, inline, async.} =
    ## Deletes your own reaction to a message
    asyncCheck doreq(s, "DELETE", endpointOwnReactions(channelid, messageid, emojiid))

method messageDeleteReaction*(s: Shard, channelid, messageid, emojiid, userid: string): Future[void] {.base, gcsafe, inline, async.} =
    ## Deletes a reaction from a user from a message
    asyncCheck doreq(s, "DELETE", endpointMessageUserReaction(channelid, messageid, emojiid, userid))

method messageGetReactions*(s: Shard, channelid, messageid, emojiid: string): Future[seq[User]] {.base, gcsafe, inline, async.} =
    ## Gets a message's reactions
    result = (await doreq(s, "GET", endpointMessageReactions(channelid, messageid, emojiid))).newUserSeq

method messageDeleteAllReactions*(s: Shard, channelid, messageid: string): Future[void] {.base, gcsafe, inline, async.} =
    ## Deletes all reactions on a message
    asyncCheck doreq(s, "DELETE", endpointReactions(channelid, messageid))

method channelMessageEdit*(s: Shard, channelid, messageid, content: string): Future[Message] {.base, gcsafe, inline, async.} =
    ## Edits a message's contents
    result = (await doreq(s, "PATCH", endpointChannelMessage(channelid, messageid), $(%*{"content": content}))).newMessage
    
method channelMessageDelete*(s: Shard, channelid, messageid: string, reason: string = ""): Future[void] {.base, gcsafe, async.} =
    ## Deletes a message
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    asyncCheck doreq(s, "DELETE", endpointChannelMessage(channelid, messageid), xheaders = xh)

method channelMessagesDeleteBulk*(s: Shard, channelid: string, messages: seq[string]): Future[void] {.base, gcsafe, async, inline.} =
    ## Deletes messages in bulk.
    ## Will not delete messages older than 2 weeks
    asyncCheck doreq(s, "DELETE", endpointBulkDelete(channelid), $(%*{"messages": messages}))

method channelEditPermissions*(s: Shard, channelid: string, overwrite: Overwrite, reason: string = ""): Future[void] {.base, gcsafe, async.} =
    ## Edits a channel's permissions
    let payload = %*{
        "type": overwrite.`type`, 
        "allow": overwrite.allow, 
        "deny": overwrite.deny
    }
    let xh: HttpHeaders = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    asyncCheck doreq(s, "PUT", endpointChannelPermissions(channelid, overwrite.id.val), $payload, xh)

method channelInvites*(s: Shard, channel: string): Future[seq[Invite]] {.base, gcsafe, inline, async.} =
    ## Returns all invites to a channel
    result = (await doreq(s, "GET", endpointChannelInvites(channel))).newInviteSeq

method channelCreateInvite*(
                s: Shard, 
                channel: string, 
                max_age, max_uses: int, 
                temp, unique: bool, 
                reason: string = ""): Future[Invite] 
                {.base, gcsafe, async.} =
    ## Creates an invite to a channel
    let payload = %*{"max_age": max_age, "max_uses": max_uses, "temp": temp, "unique": unique}
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    result = (await doreq(s, "POST", endpointChannelInvites(channel), $payload, xh)).newInvite

method channelDeletePermission*(s: Shard, channel, target: string, reason: string = ""): Future[void] {.base, gcsafe, async.} =
    ## Deletes a channel permission
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    asyncCheck doreq(s, "DELETE", endpointCHannelPermissions(channel, target), xheaders = xh)

method typingIndicatorTrigger*(s: Shard, channel: string): Future[void] {.base, gcsafe, async, inline.} =
    ## Triggers the "X is typing" indicator
    asyncCheck doreq(s, "POST", endpointTriggerTypingIndicator(channel))

method channelPinnedMessages*(s: Shard, channel: string): Future[seq[Message]] {.base, gcsafe, inline, async.} =
    ## Returns all pinned messages in a channel
    result = (await doreq(s, "GET", endpointCHannelPinnedMessages(channel))).newMessageSeq
    
method channelPinMessage*(s: Shard, channel, message: string): Future[void] {.base, gcsafe, inline, async.} =
    ## Pins a message in a channel
    asyncCheck doreq(s, "PUT", endpointPinnedChannelMessage(channel, message))

method channelDeletePinnedMessage*(s: Shard, channel, message: string): Future[void] {.base, gcsafe, inline, async.} =
    asyncCheck doreq(s, "DELETE", endpointPinnedChannelMessage(channel, message))

# This might work?
type AddGroupDMUser* = object
    id: string
    nick: string

# This might work?
method groupDMCreate*(s: Shard, accesstokens: seq[string], nicks: seq[AddGroupDMUser]): Future[Channel] {.base, gcsafe, async, inline.} =
    ## Creates a group DM channel
    result = (await doreq(s, "POST", endpointDM(), $(
         %*{
            "access_tokens": accesstokens, 
            "nicks": nicks
        }
    ))).newChannel

method groupDMAddUser*(s: Shard, channelid, userid, access_token, nick: string): Future[void] {.base, gcsafe, async, inline.} =
    ## Adds a user to a group dm.
    ## Requires the 'gdm.join' scope.
    asyncCheck doreq(s, "PUT", endpointGroupDMRecipient(channelid, userid), $(
        %*{
            "access_token": access_token, 
            "nick": nick
        }
    ))
    
method groupdDMRemoveUser*(s: Shard, channelid, userid: string): Future[void] {.base, gcsafe, inline, async.} =
    ## Removes a user from a group dm.
    asyncCheck doreq(s, "DELETE", endpointGroupDMRecipient(channelid, userid))

type
    PartialChannel* = object
        name*: string
        `type`*: int

proc newPartialChannel*(name: string, typ: int = 0): PartialChannel {.inline.} = PartialChannel(name: name, `type`: typ)

method createGuild*(s: Shard, 
        name, region, icon: string, 
        roles: seq[Role] = @[], channels: seq[PartialChannel] = @[], 
        verlvl, defmsgnot: int): Future[Guild] {.base, gcsafe, async, inline.} =
    ## Creates a guild.
    ## This endpoint is limited to 10 active guilds
    result = (await doreq(s, "POST", endpointGuilds(), $(
        %*{
            "name": name,
            "region": region,
            "icon": icon,
            "verification_level": verlvl,
            "default_message_notifications": defmsgnot,
            "roles": roles,
            "channels": channels
        }
    ))).newGuild
    if s.cache.cacheGuilds:
        s.cache.updateGuild(result)
    
method guild*(s: Shard, id: string): Future[Guild] {.base, gcsafe, async.} =
    ## Gets a guild
    if s.cache.cacheGuilds:
        let (guild, exists) = s.cache.getGuild(id)
        if exists:
            return guild
    result = (await doreq(s, "GET", endpointGuild(id))).newGuild
    if s.cache.cacheGuilds:
        s.cache.updateGuild(result)

method guildEdit*(s: Shard, guild: string, settings: GuildParams, reason: string = ""): Future[Guild] {.base, gcsafe, async.} =
    ## Edits a guild with the GuildParams
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    result = (await doreq(s, "PATCH", endpointGuild(guild), $$settings, xh)).newGuild

method deleteGuild*(s: Shard, guild: string): Future[Guild] {.base, gcsafe, inline, async.} =
    ## Deletes a guild
    asyncCheck doreq(s, "DELETE", endpointGuild(guild))
    
method guildChannels*(s: Shard, guild: string): Future[seq[Channel]] {.base, gcsafe, async.} =
    ## Returns all guild channels
    if s.cache.cacheGuilds and s.cache.cacheChannels:
        let (guild, exists) = s.cache.getGuild(guild)
        if exists:
            return guild.channels
            
    result = (await doreq(s, "GET", endpointGuildChannels(guild))).newChannelSeq
    if s.cache.cacheChannels:
        for chan in result:
            s.cache.updateChannel(chan)

method guildChannelCreate*(s: Shard, guild, channelname: string, voice: bool, reason: string = ""): Future[Channel] {.base, gcsafe, async.} =
    ## Creates a new channel in a guild
    let payload = %*{"name": channelname, "voice": voice}
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    result = (await doreq(s, "POST", endpointGuildChannels(guild), $payload, xh)).newChannel
    if s.cache.cacheChannels:
        s.cache.updateChannel(result)

method guildChannelPositionEdit*(s: Shard, guild, channel: string, position: int, reason: string = ""): Future[seq[Channel]] {.base, gcsafe, async.} =
    ## Reorders the position of a channel and returns the new order
    let payload = %*{"id": channel, "position": position}
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    result = (await doreq(s, "PATCH", endpointGuildChannels(guild), $payload, xh)).newChannelSeq

method guildMembers*(s: Shard, guild: string, limit, after: int): Future[seq[GuildMember]] {.base, gcsafe, async.} =
    ## Returns up to 1000 guild members
    var url = endpointGuildMembers(guild) & "?"
    if limit > 1:
        url &= "limit=" & $limit & "&"
    if after > 0:
        url &= "after=" & $after & "&"

    result = (await doreq(s, "GET", url)).newGuildMemberSeq

    if s.cache.cacheGuildMembers: 
        for member in result:
            s.cache.updateGuildMember(member)

method guildMember*(s: Shard, guild, userid: string): Future[GuildMember] {.base, gcsafe, async.} =
    ## Returns a guild member with the userid
    if s.cache.cacheGuildMembers:
        let (member, exists) = s.cache.getGuildMember(guild, userid)
        if exists:
            return member
    result = (await doreq(s, "GET", endpointGuildMember(guild, userid))).newGuildMember

    if s.cache.cacheGuildMembers:
        s.cache.updateGuildMember(result)

method guildAddMember*(s: Shard, guild, userid, accesstoken: string): Future[GuildMember] {.base, gcsafe, async.} =
    ## Adds a guild member to the guild
    result = (await doreq(s, "PUT", endpointGuildMember(guild, userid), $(
        %*{
            "access_token": accesstoken
        }
    ))).newGuildMember
    if s.cache.cacheGuildMembers:
        s.cache.updateGuildMember(result)


method guildMemberRolesEdit*(s: Shard, guild, userid: string, roles: seq[string]): Future[void] {.base, gcsafe, async.} =
    ## Edits a guild member's roles
    asyncCheck doreq(s, "PATCH", endpointGuildMember(guild, userid), $(%*{"roles": roles}))

method guildMemberSetNickname*(s: Shard, guild, userid, nick: string, reason: string = ""): Future[void] {.base, gcsafe, async.} =
    ## Sets the nickname of a member
    asyncCheck doreq(s, "PATCH", endpointGuildMember(guild, userid), $(%*{"nick": nick}))

method guildMemberMute*(s: Shard, guild, userid: string, mute: bool, reason: string = ""): Future[void] {.base, gcsafe, async.} =
    ## Mutes a guild member
    let payload = %*{"mute": mute}
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    asyncCheck doreq(s, "PATCH", endpointGuildMember(guild, userid), $payload, xh)

method guildMemberDeafen*(s: Shard, guild, userid: string, deafen: bool, reason: string = ""): Future[void] {.base, gcsafe, async.} =
    ## Deafens a guild member
    let payload = %*{"deaf": deafen}
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    asyncCheck doreq(s, "PATCH", endpointGuildMember(guild, userid), $payload, xh)
 
method guildMemberMove*(s: Shard, guild, userid, channel: string, reason: string = ""): Future[void] {.base, gcsafe, async.} =
    ## Moves a guild member from one channel to another
    ## only works if they are connected to a voice channel
    let payload = %*{"channel_id": channel}
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    asyncCheck doreq(s, "PATCH", endpointGuildMember(guild, userid), $payload, xh)

method setNickname*(s: Shard, guild, nick: string, reason: string = ""): Future[void] {.base, gcsafe, async.} =
    ## Sets the nick for the current user
    let payload = %*{"nick": nick}
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    asyncCheck doreq(s, "PATCH", endpointEditNick(guild), $payload, xh)

method guildMemberAddRole*(s: Shard, guild, userid, roleid: string, reason: string = ""): Future[void] {.base, gcsafe, async.} =
    ## Adds a role to a guild member
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    asyncCheck doreq(s, "PUT", endpointGuildMemberRoles(guild, userid, roleid), xheaders = xh)

method guildMemberRemoveRole*(s: Shard, guild, userid, roleid: string, reason: string = ""): Future[void] {.base, gcsafe, async.} =
    ## Removes a role from a guild member
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    asyncCheck doreq(s, "DELETE", endpointGuildMemberRoles(guild, userid, roleid), xheaders = xh)

method guildRemoveMemberWithReason*(s: Shard, guild, userid, reason: string): Future[void] {.base, gcsafe, async.} =
    var url = endpointGuildMember(guild, userid)
    if reason != "": url &= "?reason=" & encodeUrl(reason)
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    asyncCheck doreq(s, "DELETE", url, xheaders = xh)

method guildRemoveMember*(s: Shard, guild, userid: string, reason: string = ""): Future[void] {.base, gcsafe, inline, async.} =
    ## Removes a guild membe from the guild
    asyncCheck s.guildRemoveMemberWithReason(guild, userid, "")

method guildBans*(s: Shard, guild: string): Future[seq[User]] {.base, gcsafe, inline, async.} =
    ## Returns all users who have been banned from the guild
    result = (await doreq(s, "GET", endpointGuildBans(guild))).newUserSeq

method guildUserBan*(s: Shard, guild, userid: string, reason: string = ""): Future[void] {.base, gcsafe, async.} =
    ## Bans a user from the guild
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    asyncCheck doreq(s, "PUT", endpointGuildBan(guild, userid), xheaders = xh)

method guildRemoveBan*(s: Shard, guild, userid: string, reason: string = ""): Future[void] {.base, gcsafe, async.} =
    ## Removes a ban from the guild
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    asyncCheck doreq(s, "DELETE", endpointGuildBan(guild, userid), xheaders = xh)

method guildRoles*(s: Shard, guild: string): Future[seq[Role]] {.base, gcsafe, async.} =
    ## Returns all guild roles
    if s.cache.cacheGuilds and s.cache.cacheRoles:
        let (guild, exists) = s.cache.getGuild(guild)
        if exists:
            return guild.roles
    result = (await doreq(s, "GET", endpointGuildRoles(guild))).newRoleSeq

    if s.cache.cacheRoles:
        for role in result:
            s.cache.updateRole(role)
    
method guildRole*(s: Shard, guild, roleid: string): Future[Role] {.base, gcsafe, async.} =
    ## Returns a role with the given id.
    let roles = await s.guildRoles(guild)
    for role in roles:
        if role.id == roleid:
            return role

method guildCreateRole*(s: Shard, guild: string, reason: string = ""): Future[Role] {.base, gcsafe, async.} =
    ## Creates a new role in the guild
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    result = (await doreq(s, "POST", endpointGuildRoles(guild), xheaders = xh)).newRole
    
method guildEditRolePosition*(s: Shard, guild: string, roles: seq[Role], reason: string = ""): Future[seq[Role]] {.base, gcsafe, async.} =
    ## Edits the positions of a guilds roles roles
    ## and returns the new roles order
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    result = (await doreq(s, "PATCH", endpointGuildRoles(guild), $$roles, xh)).newRoleSeq

method guildEditRole*(
            s: Shard, 
            guild, roleid, name: string, 
            permissions, color: int, 
            hoist, mentionable: bool,
            reason: string = ""): Future[Role] 
            {.base, gcsafe, async.} =
    ## Edits a role
    let payload = %*{"name": name, "permissions": permissions, "color": color, "hoist": hoist, "mentionable": mentionable}
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    result = (await doreq(s, "PATCH", endpointGuildRole(guild, roleid), $payload, xh)).newRole
   
method guildDeleteRole*(s: Shard, guild, roleid: string, reason: string = ""): Future[void] {.base, gcsafe, async.} =
    ## Deletes a role
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    asyncCheck doreq(s, "DELETE", endpointGuildRole(guild, roleid), xheaders = xh)

method guildPruneCount*(s: Shard, guild: string, days: int): Future[int] {.base, gcsafe, async.} =
    ## Returns the number of members who would get kicked
    ## during a prune operation
    var url = endpointGuildPruneCount(guild) & "?days=" & $days
    result = (await doreq(s, "GET", url))["pruned"].num.int

method guildPruneBegin*(s: Shard, guild: string, days: int, reason: string = ""): Future[int] {.base, gcsafe, async.} =
    ## Begins a prune operation and
    ## kicks all members who haven't been active
    ## for N days
    var url = endpointGuildPruneCount(guild) & "?days=" & $days
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    result = (await doreq(s, "POST", url, xheaders = xh))["pruned"].num.int

method guildVoiceRegions*(s: Shard, guild: string): Future[seq[VoiceRegion]] {.base, gcsafe, inline, async.} =
    ## Lists all voice regions in a guild
    result = (await doreq(s, "GET", endpointGuildVoiceRegions(guild))).newVoiceRegionSeq
    
method guildInvites*(s: Shard, guild: string): Future[seq[Invite]] {.base, gcsafe, inline, async.} =
    ## Lists all guild invites
    result = (await doreq(s, "GET", endpointGuildInvites(guild))).newInviteSeq

method guildIntegrations*(s: Shard, guild: string): Future[seq[Integration]] {.base, gcsafe, inline, async.} =
    ## Lists all guild integrations
    result = (await doreq(s, "GET", endpointGuildIntegrations(guild))).newIntegrationSeq

method guildIntegrationCreate*(s: Shard, guild, typ, id: string): Future[void] {.base, gcsafe, async.} =
    ## Creates a new guild integration
    let payload = %*{"type": typ, "id": id}
    asyncCheck doreq(s, "POST", endpointGuildIntegrations(guild), $payload)

method guildIntegrationEdit*(s: Shard, guild, integrationid: string, behaviour, grace: int, emotes: bool): Future[void] {.base, gcsafe, async.} =
    ## Edits a guild integration
    let payload = %*{"expire_behavior": behaviour, "expire_grace_period": grace, "enable_emoticons": emotes}
    asyncCheck doreq(s, "PATCH", endpointGuildIntegration(guild, integrationid), $payload)

method guildIntegrationDelete*(s: Shard, guild, integration: string): Future[void] {.base, gcsafe, inline, async.} =
    ## Deletes a guild Integration
    asyncCheck doreq(s, "DELETE", endpointGuildIntegration(guild, integration))

method guildIntegrationSync*(s: Shard, guild, integration: string): Future[void] {.base, gcsafe, inline, async.} =
    ## Syncs an existing guild integration
    asyncCheck doreq(s, "POST", endpointSyncGuildIntegration(guild, integration))

method guildEmbed*(s: Shard, guild: string): Future[GuildEmbed] {.base, gcsafe, inline, async.} =
    ## Gets a GuildEmbed
    result = (await doreq(s, "GET", endpointGuildEmbed(guild))).newGuildEmbed
    
method guildEmbedEdit*(s: Shard, guild: string, enabled: bool, channel: string): Future[GuildEmbed] {.base, gcsafe, async.} =
    ## Edits a GuildEmbed
    let embed = GuildEmbed(enabled: enabled, channel_id: channel)
    result = (await doreq(s, "PATCH", endpointGuildEmbed(guild), $$embed)).newGuildEmbed

method guildEmojiCreate*(s: Shard, guild, name, image: string, roles: seq[string] = @[]): Future[Emoji] {.base, gcsafe, async.} =
    let payload = %*{
        "name": name,
        "image": image,
        "roles": roles
    }
    result = (await doreq(s, "POST", endpointGuildEmojis(guild), $payload)).newEmoji

method guildEmojiUpdate*(s: Shard, guild, emoji, name: string, roles: seq[string] = @[]): Future[Emoji] {.base, gcsafe, async.} =
    ## Updates a guild emoji
    let payload = %*{
        "name": name,
        "roles": roles
    }
    result = (await doreq(s, "PATCH", endpointGuildEmoji(guild, emoji), $payload)).newEmoji

method guildEmojiDelete*(s: Shard, guild, emoji: string): Future[void] {.base, gcsafe, async.} =
    asyncCheck doreq(s, "DELETE", endpointGuildEmoji(guild, emoji))

method guildAuditLog*(s: Shard, guild: string, 
                        user_id: string = "", action_type: int = -1, 
                        before: string = "", limit: int = 50): Future[AuditLog]
                        {.gcsafe, base, async.} =
    
    var url = endpointGuildAuditLog(guild) & "?"
    if user_id != "": url &= "user_id=" & user_id & "&"
    if action_type >= 1: url &= "action_type" & $action_type & "&"
    if before != "": url &= "before=" & before & "&"
    url &= "limit=" & $limit
    result = (await doreq(s, "GET", url)).newAuditLog

method invite*(s: Shard, code: string): Future[Invite] {.base, gcsafe, inline, async.} =
    ## Gets an invite with code
    result = (await doreq(s, "GET", endpointInvite(code))).newInvite
   
method inviteDelete*(s: Shard, code: string, reason: string = ""): Future[Invite] {.base, gcsafe, async.} =
    ## Deletes an invite
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    result = (await doreq(s, "DELETE", endpointInvite(code), xheaders = xh)).newInvite
    
method me*(s: Shard): User {.base, gcsafe, inline.} =
    ## Returns the current user
    result = s.cache.me 

method user*(s: Shard, userid: string): Future[User] {.base, gcsafe, async.} =
    ## Gets a user
    if userid == s.cache.me.id: return s.cache.me
    if s.cache.cacheUsers:
        let (user, exists) = s.cache.getUser(userid)
        if exists: return user
    result = (await doreq(s, "GET", endpointUser(userid))).newUser
    if s.cache.cacheUsers:
        s.cache.updateUser(result)
        
method usernameEdit*(s: Shard, name: string): Future[User] {.base, gcsafe, inline, async.} =
    ## Edits the current users username
    result = (await doreq(s, "PATCH", endpointCurrentUser(), $(%*{"username": name}))).newUser

method avatarEdit*(s: Shard, avatar: string): Future[User] {.base, gcsafe, inline, async.} =
    ## Changes the current users avatar
    result = (await doreq(s, "PATCH", endpointCurrentUser(), $(%*{"avatar": avatar}))).newUser

method currentUserGuilds*(s: Shard): Future[seq[UserGuild]] {.base, gcsafe, inline, async.} =
    ## Lists the current users guilds
    result = (await doreq(s, "GET", endpointCurrentUserGuilds())).newUserGuildSeq 

method leaveGuild*(s: Shard, guild: string): Future[void] {.base, gcsafe, inline, async.} =
    ## Makes the current user leave the specified guild
    asyncCheck doreq(s, "DELETE", endpointLeaveGuild(guild))

method activePrivateChannels*(s: Shard): Future[seq[Channel]] {.base, gcsafe, inline, async.} =
    ## Lists all active DM channels
    result = (await doreq(s, "GET", endpointUserDMs())).newChannelSeq

method privateChannelCreate*(s: Shard, recipient: string): Future[Channel] {.base, gcsafe, inline, async.} =
    ## Creates a new DM channel
    result = (await doreq(s, "POST", endpointDM(), $(%*{"recipient_id": recipient}))).newChannel
    
method voiceRegions*(s: Shard): Future[seq[VoiceRegion]] {.base, gcsafe, inline, async.} =
    ## Lists all voice regions
    result = (await doreq(s, "GET", endpointListVoiceRegions())).newVoiceRegionSeq

method webhookCreate*(s: Shard, channel, name, avatar: string, reason: string = ""): Future[Webhook] {.base, gcsafe, async.} =
    ## Creates a webhook
    let payload = %*{"name": name, "avatar": avatar}
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    result = (await doreq(s, "POST", endpointWebhooks(channel), $payload, xh)).newWebhook

method channelWebhooks*(s: Shard, channel: string): Future[seq[Webhook]] {.base, gcsafe, inline, async.} =
    ## Lists all webhooks in a channel
    result = (await doreq(s, "GET", endpointWebhooks(channel))).newWebhookSeq 

method guildWebhooks*(s: Shard, guild: string): Future[seq[Webhook]] {.base, gcsafe, inline, async.} =
    ## Lists all webhooks in a guild
    result = (await doreq(s, "GET", endpointGuildWebhooks(guild))).newWebhookSeq

method getWebhookWithToken*(s: Shard, webhook, token: string): Future[Webhook] {.base, gcsafe, inline, async.} =
    ## Gets a webhook with a token
    result = (await doreq(s, "GET", endpointWebhookWithToken(webhook, token))).newWebhook

method webhookEdit*(s: Shard, webhook, name, avatar: string, reason: string = ""): Future[Webhook] {.base, gcsafe, async.} =
    ## Edits a webhook
    let payload = %*{"name": name, "avatar": avatar}
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    result = (await doreq(s, "PATCH", endpointWebhook(webhook), $payload, xh)).newWebhook
    
method webhookEditWithToken*(s: Shard, webhook, token, name, avatar: string, reason: string = ""): Future[Webhook] {.base, gcsafe, async.} =
    ## Edits a webhook with a token
    let payload = %*{"name": name, "avatar": avatar}
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    result = (await doreq(s, "PATCH", endpointWebhookWithToken(webhook, token), $payload, xh)).newWebhook

method webhookDelete*(s: Shard, webhook: string, reason: string = ""): Future[Webhook] {.base, gcsafe, async.} =
    ## Deletes a webhook
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    result = (await doreq(s, "DELETE", endpointWebhook(webhook), xheaders = xh)).newWebhook

method webhookDeleteWithToken*(s: Shard, webhook, token: string, reason: string = ""): Future[Webhook] {.base, gcsafe, async.} =
    ## Deltes a webhook with a token
    let xh = if reason != "": newHttpHeaders({"X-Audit-Log-Reason": reason}) else: nil
    result = (await doreq(s, "DELETE", endpointWebhookWithToken(webhook, token), xheaders = xh)).newWebhook

method executeWebhook*(s: Shard, webhook, token: string, payload: WebhookParams): Future[void] {.base, gcsafe, inline, async.} =
    ## Executes a webhook
    asyncCheck doreq(s, "POST", endpointWebhookWithToken(webhook, token), $$payload)

proc `$`*(u: User): string {.gcsafe, inline.} =
    ## Stringifies a user.
    ##
    ## e.g: Username#1234
    result = u.username & "#" & u.discriminator

proc `$`*(c: Channel): string {.gcsafe, inline.} =
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

proc `@`*(c: Channel): string {.gcsafe, inline.} = 
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

proc defaultAvatar*(u: User): string =
    ## Returns the avatar url of the user.
    ##
    ## If the user doesn't have an avatar it returns the users default avatar.
    if u.avatar.isNilOrEmpty():
        result = "https://cdn.discordapp.com/embed/avatars/$1.png" % [$(u.discriminator.parseInt mod 5)]
    else: 
        if u.avatar.startsWith("a_"):
            result = endpointAvatarAnimated(u.id.val, u.avatar)
        else:
            result = endpointAvatar(u.id.val, u.avatar)
            
proc timestamp*(i: int64): DateTime  =
    ## Takes an ID and converts it into a timestamp
    let it = ((i shr 22) + 1420070400000) div 1000
    result = it.fromUnix.utc

proc stripMentions*(msg: Message): string {.gcsafe.} =  
    ## Strips all user mentions from a message
    ## and replaces them with plaintext
    ##
    ## e.g: <@1901092738173> -> @Username#1234
    if msg.mentions == nil or msg.mentions.len == 0: return msg.content

    result = msg.content

    for user in msg.mentions:
        let regex = re("(<@!?" & user.id & ">)")
        result = result.replace(regex, "@" & $user)

proc stripEveryoneMention*(msg: Message): string {.gcsafe.} =
    ## Strips a message of any @everyone and @here mention
    if not msg.mention_everyone: return msg.content
    result = msg.content.replace(re"(@everyone)", "").replace(re"(@here)", "")

proc newChannelParams*(name, topic: string = "",
                       position: int = 0,
                       bitrate: int = 48,
                       userlimit: int = 0): ChannelParams {.gcsafe, inline.} =
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
                     splash: string = ""): GuildParams {.gcsafe, inline.} =
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
                          deaf: bool = false): GuildMemberParams {.gcsafe, inline.} =
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
                       tts: bool = false, embeds: seq[Embed] = nil): WebhookParams {.gcsafe, inline.} =
    ## Initialises a new WebhookParams object
    ## for altering webhooks.
    result = WebhookParams( 
        content: content, 
        username: username,
        avatar_url: avatarurl,
        tts: tts,
        embeds: embeds
    )

proc messageGuild*(s: Shard, m: Message): string =
    ## Returns the guild id of the guild
    ## the message was sent in.
    ##
    ## Returns an empty string if it can't find the guild in the cache
    ## or by requesting it from the API.
    result = ""
    if s.cache.cacheChannels:
        var (chan, exists) = s.cache.getChannel(m.channel_id)
        if exists:
            return chan.guild_id
    var chan = waitFor s.channel(m.channel_id)
    if chan != Channel():
        result = chan.guild_id