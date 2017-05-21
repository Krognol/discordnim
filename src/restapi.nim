include discordobjects, endpoints
import httpclient, asyncnet, strutils, json, marshal, net, re

method Request(s: Session, bucketid: var string, meth, url, contenttype, b : string, sequence : int, mp: MultipartData = nil): Response {.base, gcsafe.} =
    var client = newHttpClient(sslContext = newContext(verifyMode = CVerifyNone))
    client.headers["User-Agent"] = "DiscordBot (https://github.com/Krognol/discordnim, v" & VERSION & ")"

    if bucketid == "":
        bucketid = split(url, "?", 2)[0]

    var bucket = s.limiter.lockBucket(bucketid)

    if s.token != "" and s.token != nil:
        client.headers["Authorization"] = s.token

    client.headers["Content-Type"] = contenttype
    var res: Response
    if mp == nil:
        res = client.request(url, meth, b)
    elif mp != nil and meth == "POST":
        res = client.post(url, b, mp)
    bucket.Release(res.headers)

    case res.status:
    of "502":
        if sequence < 5:
            res = s.Request(bucketid, meth, url, contenttype, b, sequence+1)
    of "429":
        var rl = parseJson(res.body)
        sleep int(rl["retry_after"].num)
        res = s.Request(bucketid, meth, url, contenttype, b, sequence)
    else: discard

    result = res
    client.close()


type
    CacheError* = object of Exception

# Caching stuff

proc getGuild*(c: Cache, id: string): tuple[guild: Guild, exists: bool]  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    if c.guilds.hasKey(id):
        return (c.guilds[id], true)

    result = (Guild(), false)

proc removeGuild*(c: Cache, guildid: string) {.raises: CacheError.}  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    if not c.guilds.hasKey(guildid):
        raise newException(CacheError, "Guild not in cache")

    c.guilds.del(guildid)


proc updateGuild*(c: Cache, guild: Guild) {.raises: CacheError.}  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    c.guilds[guild.id] = guild

proc getUser*(c: Cache, id: string): tuple[user: User, exists: bool]  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    if c.users.hasKey(id):
        return (c.users[id], true)

    result = (User(), false)

proc removeUser*(c: Cache, id: string) {.raises: CacheError.}  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    if not c.users.hasKey(id):
        raise newException(CacheError, "User not in cache")

    c.users.del(id)

proc updateUser*(c: Cache, user: User) {.raises: CacheError.}  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    c.users[user.id] = user

proc getChannel*(c: Cache, id: string): tuple[channel: DChannel, exists: bool]  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    if c.channels.hasKey(id):
        return (c.channels[id], true)

    result = (DChannel(), false)

proc updateChannel*(c: Cache, chan: DChannel) {.raises: CacheError.}  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    if not c.channels.hasKey(chan.id):
        raise newException(CacheError, "Channel not in cache")

    c.channels[chan.id] = chan

proc removeChannel*(c: Cache, chan: string) {.raises: CacheError.}  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    if not c.channels.hasKey(chan):
        raise newException(CacheError, "Channel not in cache")

    c.channels.del(chan)

proc getGuildMember*(c: Cache, guild, memberid: string): tuple[member: GuildMember, exists: bool]  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    var (guild, exists) = c.getGuild(guild)

    if not exists:
        return (GuildMember(), false)

    for member in guild.members:
        if member.user.id == memberid:
            return (member, true)

    return (GuildMember(), false)

proc addGuildMember*(c: Cache, member: GuildMember)  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    var (guild, exists) = c.getGuild(member.guild_id)

    if not exists:
        raise newException(CacheError, "Guild not in cache")

    guild.members.add(member)

proc updateGuildMember*(c: Cache, m: GuildMember)  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    var (guild, exists) = c.getGuild(m.guild_id)

    if not exists:
        raise newException(CacheError, "Guild not in cache")

    for i, member in guild.members:
        if member.user.id == m.user.id:
            guild.members[i] = m
            return

proc removeGuildMember*(c: Cache, gmember: GuildMember)  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    var (guild, exists) = c.getGuild(gmember.guild_id)

    if not exists:
        raise newException(CacheError, "Guild not in cache")

    for i, member in guild.members:
        if member.user.id == gmember.user.id:
            guild.members.del(i)
            return 

proc getRole*(c: Cache, guildid, roleid: string): tuple[role: Role, exists: bool]  =
    if c == nil: raise newException(CacheError, "The cache is nil")

    var (guild, exists) = c.getGuild(guildid)

    if not exists:
        return (Role(), false)

    for role in guild.roles:
        if role.id == roleid:
            return (role, true)

    return (Role(), false)

proc updateRole*(c: Cache, role: Role) {.raises: CacheError.} =
    if c == nil: raise newException(CacheError, "The cache is nil")

    if not c.roles.hasKey(role.id):
        raise newException(CacheError, "Role not in cache")

    c.roles[role.id] = role

proc removeRole*(c: Cache, role: string) {.raises: CacheError.} =
    if c == nil: raise newException(CacheError, "The cache is nil")

    if not c.roles.hasKey(role):
        raise newException(CacheError, "Role not in cache")

    c.roles.del(role)

method GetChannel*(s: Session, channel_id: string): DChannel {.base, gcsafe.} =
    ## Returns the channel with the given ID
    if s.cache.cacheChannels:
        var (chan, exists) = s.cache.getChannel(channel_id)

        if exists:
            return chan

    var url = EndpointGetChannel(channel_id)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[DChannel](res.body)

    if s.cache.cacheChannels:
        s.cache.channels[result.id] = result

method ModifyChannel*(s: Session, channelid: string, params: ChannelParams): Guild {.base, gcsafe.} =
    ## Modifies a channel with the ChannelParams
    var url = EndpointModifyChannel(channelid)
    let res = s.Request(url, "PATCH", url, "application/json", $$params, 0)
    result = marshal.to[Guild](res.body) 

method DeleteChannel*(s: Session, channelid: string): DChannel {.base, gcsafe.} =
    ## Deletes a channel
    var url = EndpointDeleteChannel(channelid)
    let res = s.Request(url, "DELETE", url, "application/json", "", 0)
    result = marshal.to[DChannel](res.body)

method ChannelMessages*(s: Session, channelid: string, before, after, around: string, limit: int): seq[Message] {.base, gcsafe.} =
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

    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[seq[Message]](res.body)

method ChannelMessage*(s: Session, channelid, messageid: string): Message {.base, gcsafe.} =
    ## Returns a message from a channel
    var url = EndpointGetChannelMessage(channelid, messageid)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[Message](res.body)


method SendMessage*(s: Session, channelid, message: string): Message {.base, gcsafe.} =
    ## Sends a regular text message to a channel
    var url = EndpointCreateMessage(channelid)
    let payload = %*{"content": message}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    result = marshal.to[Message](res.body)
    

method SendMessageEmbed*(s: Session, channelid: string, embed: Embed): Message {.base, gcsafe.} =
    ## Sends an Embed message to a channel
    var url = EndpointCreateMessage(channelid)

    let payload = %*{
        "content": "",
        "embed": embed
    }

    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    result = marshal.to[Message](res.body)

method SendMessageTTS*(s: Session, channelid, message: string): Message {.base, gcsafe.} =
    ## Sends a TTS message to a channel
    var url = EndpointCreateMessage(channelid)
    let payload = %*{"content": message, "tts": true}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    result = marshal.to[Message](res.body)

# SendFileWithMessage and SendFile won't work
# without editing the httpclient lib
method SendFileWithMessage*(s: Session, channelid, name, message: string): Message {.base, gcsafe.} =
    ## Sends a file to a channel along with a message
    var data = newMultipartData()
    var url = EndpointCreateMessage(channelid)

    let payload = %*{"content": message}
    data = data.addFiles({"file": name})
    data.add("payload_json", $payload, contentType = "application/json")
    let res = s.Request(url, "POST", url, "multipart/form-data", "", 0, data)
    result = marshal.to[Message](res.body)

method SendFile*(s: Session, channelid, name: string): Message {.base, gcsafe.} =
    ## Sends a file to a channel
    result = s.SendFileWithMessage(channelid, name, "")

method MessageAddReaction*(s: Session, channelid, messageid, emojiid: string) {.base, gcsafe.} =
    ## Adds a reaction to a message
    var url = EndpointCreateReaction(channelid, messageid, emojiid)
    discard s.Request(url, "PUT", url, "application/json", "", 0)

method MessageDeleteOwnReaction*(s: Session, channelid, messageid, emojiid: string) {.base, gcsafe.} =
    ## Deletes your own reaction to a message
    var url = EndpointDeleteOwnReaction(channelid, messageid, emojiid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method MessageDeleteReaction*(s: Session, channelid, messageid, emojiid, userid: string) {.base, gcsafe.} =
    ## Deletes a reaction from a user from a message
    var url = EndpointDeleteUserReaction(channelid, messageid, emojiid, userid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method MessageGetReactions*(s: Session, channelid, messageid, emojiid: string): seq[User] {.base, gcsafe.} =
    ## Gets a message's reactions
    var url = EndpointGetMessageReactions(channelid, messageid, emojiid)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[seq[User]](res.body)
   

method MessageDeleteAllReactions*(s: Session, channelid, messageid: string) {.base, gcsafe.} =
    ## Deletes all reactions on a message
    var url = EndpointDeleteAllReactions(channelid, messageid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method EditMessage*(s: Session, channelid, messageid, content: string): Message {.base, gcsafe.} =
    ## Edits a message's contents
    var url = EndpointEditMessage(channelid, messageid)
    let payload = %*{"content": content}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    result = marshal.to[Message](res.body)
    

method DeleteMessage*(s: Session, channelid, messageid: string) {.base, gcsafe.} =
    ## Deletes a message
    var url = EndpointDeleteMessage(channelid, messageid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method BulkDeleteMessages*(s: Session, channelid: string, messages: seq[string]) {.base, gcsafe.} =
    ## Deletes messages in bulk
    ## Will not delete messages older than 2 weeks
    var url = EndpointBulkDelete(channelid)
    let payload = %*{"messages": $messages}
    discard s.Request(url, "DELETE", url, "application/json", $payload, 0)

method EditChannelPermissions*(s: Session, channelid: string, overwrite: Overwrite) {.base, gcsafe.} =
    ## Edits a channel's permissions
    var url = EndpointEditChannelPermissions(channelid, overwrite.id)
    discard s.Request(url, "PUT", url, "application/json", $$overwrite, 0)

method ChannelInvites*(s: Session, channel: string): seq[Invite] {.base, gcsafe.} =
    ## Returns all invites to a channel
    var url = EndpointGetChannelInvites(channel)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[seq[Invite]](res.body)
   

method CreateChannelInvite*(s: Session, channel: string, max_age, max_uses: int, temp, unique: bool): Invite {.base, gcsafe.} =
    ## Creates an invite to a channel
    var url = EndpointCreateChannelInvite(channel)
    let payload = %*{"max_age": max_age, "max_uses": max_uses, "temp": temp, "unique": unique}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    result = marshal.to[Invite](res.body)
    

method DeleteChannelPermission*(s: Session, channel, target: string) {.base, gcsafe.} =
    ## Deletes a channel permission
    var url = EndpointDeleteChannelPermission(channel, target)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method TriggerTypingIndicator*(s: Session, channel: string) {.base, gcsafe.} =
    ## Triggers the "X is typing" indicator
    var url = EndpointTriggerTypingIndicator(channel)
    discard s.Request(url, "POST", url, "application/json", "", 0)

method ChannelPinnedMessages*(s: Session, channel: string): seq[Message] {.base, gcsafe.} =
    ## Returns all pinned messages in a channel
    var url = EndpointGetPinnedMessages(channel)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[seq[Message]](res.body)
    

method ChannelPinMessage*(s: Session, channel, message: string) {.base, gcsafe.} =
    ## Pins a message in a channel
    var url = EndpointAddPinnedChannelMessage(channel, message)
    discard s.Request(url, "PUT", url, "application/json", "", 0)

method ChannelDeletePinnedMessage*(s: Session, channel, message: string) {.base, gcsafe.} =
    var url = EndpointDeletePinnedChannelMessage(channel, message)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

# This might work?
type AddGroupDMUser* = object
    id: string
    nick: string

# This might work?
method CreateGroupDM*(s: Session, accesstokens: seq[string], nicks: seq[AddGroupDMUser]): DChannel {.base, gcsafe.} =
    ## Creates a group DM channel
    var url = EndpointCreateGroupDM()
    let payload = %*{"access_tokens": accesstokens, "nicks": nicks}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    result = marshal.to[DChannel](res.body)

method GroupDMAddUser*(s: Session, channelid, userid, access_token, nick: string) {.base, gcsafe.} =
    ## Adds a user to a group dm.
    ## Requires the 'gdm.join' scope.
    var url = EndpointGroupDMAddRecipient(channelid, userid)
    let payload = %*{"access_token": access_token, "nick": nick}
    discard s.Request(url, "PUT", url, "application/json", $payload, 0)
    

method GroupdDMRemoveUser*(s: Session, channelid, userid: string) {.base, gcsafe.} =
    ## Removes a user from a group dm.
    var url = EndpointGroupDMRemoveRecipient(channelid, userid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method CreateGuild*(s: Session, name: string): Guild {.base, gcsafe.} =
    ## Creates a guild
    ## This endpoint is limited to 10 active guilds
    var url = EndpointCreateGuild()
    let payload = %*{"name": name}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    result = marshal.to[Guild](res.body)
    

method GetGuild*(s: Session, id: string): Guild {.base, gcsafe.} =
    ## Gets a guild
    if s.cache.cacheGuilds:
        var (guild, exists) = s.cache.getGuild(id)

        if exists:
            return guild

    var url = EndpointGetGuild(id)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[Guild](res.body)
   
    if s.cache.cacheGuilds:
        s.cache.guilds[result.id] = result

        if s.cache.cacheRoles:
            for role in result.roles:
                s.cache.roles[role.id] = role

method ModifyGuild*(s: Session, guild: string, settings: GuildParams): Guild {.base, gcsafe.} =
    ## Modifies a guild with the GuildParams
    var url = EndpointModifyGuild(guild)
    let res = s.Request(url, "PATCH", url, "application/json", $$settings, 0)
    result = marshal.to[Guild](res.body)
    

method DeleteGuild*(s: Session, guild: string): Guild {.base, gcsafe.} =
    ## Deletes a guild
    var url = EndpointDeleteGuild(guild)
    let res = s.Request(url, "DELETE", url, "application/json", "", 0)
    result = marshal.to[Guild](res.body)
    

method GuildChannels*(s: Session, guild: string): seq[DChannel] {.base, gcsafe.} =
    ## Returns all guild channels
    var url = EndpointGetGuildChannels(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[seq[DChannel]](res.body)
   

method GuildChannelCreate*(s: Session, guild, channelname: string, voice: bool): DChannel {.base, gcsafe.} =
    ## Creates a new channel in a guild
    var url = EndpointCreateGuildChannel(guild)
    let payload = %*{"name": channelname, "voice": voice}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    result = marshal.to[DChannel](res.body)
    

method ModifyGuildChannelPosition*(s: Session, guild, channel: string, position: int): seq[DChannel] {.base, gcsafe.} =
    ## Reorders the position of a channel and returns the new order
    var url = EndpointModifyGuildChannelPositions(guild)
    let payload = %*{"id": channel, "position": position}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    result = marshal.to[seq[DChannel]](res.body)
   

method GuildMembers*(s: Session, guild: string, limit, after: int): seq[GuildMember] {.base, gcsafe.} =
    ## Returns up to 1000 guild members
    var url = EndpointListGuildMembers(guild) & "?"

    if limit > 1:
        url = url & "limit=" & $limit & "&"
    if after > 0:
        url = url & "after=" & $after & "&"

    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[seq[GuildMember]](res.body)
    

method GetGuildMember*(s: Session, guild, userid: string): GuildMember {.base, gcsafe.} =
    ## Returns a guild member with the userid

    if s.cache.cacheGuildMembers:
        var (member, exists) = s.cache.getGuildMember(guild, userid)

        if exists:
            return member

    var url = EndpointGetGuildMember(guild, userid)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[GuildMember](res.body)
    
    if s.cache.cacheGuildMembers:
        s.cache.addGuildMember(result)

method GuildAddMember*(s: Session, guild, userid, accesstoken: string): GuildMember {.base, gcsafe.} =
    ## Adds a guild member to the guild
    var url = EndpointAddGuildMember(guild, userid)
    let payload = %*{"access_token": accesstoken}
    let res = s.Request(url, "PUT", url, "application/json", $payload, 0)
    result = marshal.to[GuildMember](res.body)
    

method GuildMemberRoles*(s: Session, guild, userid: string, roles: seq[string]) {.base, gcsafe.} =
    ## Modifies a guild member's roles
    var url = EndpointModifyGuildMember(guild, userid)
    let payload = %*{"roles": $roles}
    discard s.Request(url, "PATCH", url, "application/json", $payload, 0)

method GuildMemberNick*(s: Session, guild, userid, nick: string) {.base, gcsafe.} =
    ## Sets the nickname of a member
    var url = EndpointModifyGuildMember(guild, userid)
    let payload = %*{"nick": nick}
    discard s.Request(url, "PATCH", url, "application/json", $payload, 0)

method GuildMemberMute*(s: Session, guild, userid: string, mute: bool) {.base, gcsafe.} =
    ## Mutes a guild member
    var url = EndpointModifyGuildMember(guild, userid)
    let payload = %*{"mute": mute}
    discard s.Request(url, "PATCH", url, "application/json", $payload, 0)

method GuildMemberDeafen*(s: Session, guild, userid: string, deafen: bool) {.base, gcsafe.} =
    ## Deafens a guild member
    var url = EndpointModifyGuildMember(guild, userid)
    let payload = %*{"deaf": deafen}
    discard s.Request(url, "PATCH", url, "application/json", $payload, 0)

method GuildMemberMove*(s: Session, guild, userid, channel: string) {.base, gcsafe.} =
    ## Moves a guild member from one channel to another
    ## only works if they are connected to a voice channel
    var url = EndpointModifyGuildMember(guild, userid)
    let payload = %*{"channel_id": channel}
    discard s.Request(url, "PATCH", url, "application/json", $payload, 0)

method Nick*(s: Session, guild, nick: string) {.base, gcsafe.} =
    ## Sets the nick for the current user
    var url = EndpointModifyNick(guild)
    let payload = %*{"nick": nick}
    discard s.Request(url, "PATCH", url, "application/json", $payload, 0)

method GuildMemberAddRole*(s: Session, guild, userid, roleid: string) {.base, gcsafe.} =
    ## Adds a role to a guild member
    var url = EndpointAddGuildMemberRole(guild, userid, roleid)
    discard s.Request(url, "PUT", url, "application/json", "", 0)

method GuildMemberRemoveRole*(s: Session, guild, userid, roleid: string) {.base, gcsafe.} =
    ## Removes a role from a guild member
    var url = EndpointRemoveGuildMemberRole(guild, userid, roleid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method GuildRemoveMember*(s: Session, guild, userid: string) {.base, gcsafe.} =
    ## Removes a guild membe from the guild
    var url = EndpointRemoveGuildMember(guild, userid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method GuildBans*(s: Session, guild: string): seq[User] {.base, gcsafe.} =
    ## Returns all users who have been banned from the guild
    var url = EndpointGetGuildBans(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[seq[User]](res.body)
   

method GuildBanUser*(s: Session, guild, userid: string) {.base, gcsafe.} =
    ## Bans a user from the guild
    var url = EndpointCreateGuildBan(guild, userid)
    discard s.Request(url, "PUT", url, "application/json", "", 0)

method GuildRemoveBan*(s: Session, guild, userid: string) {.base, gcsafe.} =
    ## Removes a ban from the guild
    var url = EndpointRemoveGuildBan(guild, userid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method GuildRoles*(s: Session, guild: string): seq[Role] {.base, gcsafe.} =
    ## Returns all guild roles
    var url = EndpointGetGuildRoles(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[seq[Role]](res.body)
    
method GuildRole*(s: Session, guild, roleid: string): Role {.base, gcsafe.} =
    ## Returns a role with the given id.
    if s.cache.cacheRoles:
        var (rolea, exists) = s.cache.getRole(guild, roleid)

        if exists:
            return rolea

    let roles = s.GuildRoles(guild)

    for role in roles:
        if role.id == roleid:
            s.cache.roles[role.id] = role
            result = role
            break
    
    if s.cache.cacheRoles:
        s.cache.roles[result.id] = result


method GuildCreateRole*(s: Session, guild: string): Role {.base, gcsafe.} =
    ## Creates a new role in the guild
    var url = EndpointCreateGuildRole(guild)
    let res = s.Request(url, "POST", url, "application/json", "", 0)
    result = marshal.to[Role](res.body)
    

method GuildEditRolePosition*(s: Session, guild: string, roles: seq[Role]): seq[Role] {.base, gcsafe.} =
    ## Edits the positions of a guilds roles roles
    ## and returns the new roles order
    var url = EndpointModifyGuildRolePositions(guild)
    let res = s.Request(url, "PATCH", url, "application/json", $$roles, 0)
    result = marshal.to[seq[Role]](res.body)
    

method GuildEditRole*(s: Session, guild, roleid, name: string, permissions, color: int, hoist, mentionable: bool): Role {.base, gcsafe.} =
    ## Edits a role
    var url = EndpointModifyGuildRole(guild, roleid)
    let payload = %*{"name": name, "permissions": permissions, "color": color, "hoist": hoist, "mentionable": mentionable}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    result = marshal.to[Role](res.body)
   

method GuildDeleteRole*(s: Session, guild, roleid: string) {.base, gcsafe.} =
    ## Deletes a role
    var url = EndpointDeleteGuildRole(guild, roleid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method GuildPruneCount*(s: Session, guild: string, days: int): int {.base, gcsafe.} =
    ## Returns the number of members who would get kicked
    ## during a prune operation
    var url = EndpointGetGuildPruneCount(guild) & "?days=" & $days
    let res = s.Request(url, "GET", "", "application/json", "", 0)

    type Temp = object
        pruned: int

    let t = marshal.to[Temp](res.body)
    return t.pruned

method GuildPruneBegin*(s: Session, guild: string, days: int): int {.base, gcsafe.} =
    ## Begins a prune operation and
    ## kicks all members who haven't been active
    ## for N days
    var url = EndpointBeginGuildPruneCount(guild) & "?days=" & $days
    let res = s.Request(url, "POST", "", "application/json", "", 0)

    type Temp = object
        pruned: int

    let t = marshal.to[Temp](res.body)
    return t.pruned

method GuildVoiceRegions*(s: Session, guild: string): seq[VoiceRegion] {.base, gcsafe.} =
    ## Lists all voice regions in a guild
    var url = EndpointGetGuildVoiceRegions(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[seq[VoiceRegion]](res.body)
    

method GuildInvites*(s: Session, guild: string): seq[Invite] {.base, gcsafe.} =
    ## Lists all guild invites
    var url = EndpointGetGuildInvites(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[seq[Invite]](res.body)
    

method GuildIntegrations*(s: Session, guild: string): seq[Integration] {.base, gcsafe.} =
    ## Lists all guild integrations
    var url = EndpointGetGuildIntegrations(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[seq[Integration]](res.body)
    

method GuildIntegrationCreate*(s: Session, guild, typ, id: string) {.base, gcsafe.} =
    ## Creates a new guild integration
    var url = EndpointGetGuildIntegrations(guild)
    let payload = %*{"type": typ, "id": id}
    discard s.Request(url, "POST", url, "application/json", $payload, 0)

method GuildIntegrationEdit*(s: Session, guild, integrationid: string, behaviour, grace: int, emotes: bool) {.base, gcsafe.} =
    ## Edits a guild integration
    var url = EndpointModifyGuildIntegration(guild, integrationid)
    let payload = %*{"expire_behavior": behaviour, "expire_grace_period": grace, "enable_emoticons": emotes}
    discard s.Request(url, "PATCH", url, "application/json", $payload, 0)

method GuildIntegrationDelete*(s: Session, guild, integration: string) {.base, gcsafe.} =
    ## Deletes a guild Integration
    var url = EndpointDeleteGuildIntegration(guild, integration)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method GuildIntegrationSync*(s: Session, guild, integration: string) {.base, gcsafe.} =
    ## Syncs an existing guild integration
    var url = EndpointSyncGuildIntegration(guild, integration)
    discard s.Request(url, "POST", url, "application/json", "", 0)

method GetGuildEmbed*(s: Session, guild: string): GuildEmbed {.base, gcsafe.} =
    ## Gets a GuildEmbed
    var url = EndpointGetGuildEmbed(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[GuildEmbed](res.body)
    

method GuildEmbedEdit*(s: Session, guild: string, enabled: bool, channel: string): GuildEmbed {.base, gcsafe.} =
    ## Edits a GuildEmbed
    var url = EndpointModifyGuildEmbed(guild)
    let embed = GuildEmbed(enabled: enabled, channel_id: channel)
    let res = s.Request(url, "PATCH", url, "application/json", $$embed, 0)
    result = marshal.to[GuildEmbed](res.body)
   

method GetInvite*(s: Session, code: string): Invite {.base, gcsafe.} =
    ## Gets an invite with code
    var url = EndpointGetInvite(code)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[Invite](res.body)
   

method InviteDelete*(s: Session, code: string): Invite {.base, gcsafe.} =
    ## Deletes an invite
    var url = EndpointDeleteInvite(code)
    let res = s.Request(url, "DELETE", url, "application/json", "", 0)
    result = marshal.to[Invite](res.body)
    

method Me*(s: Session): User {.base, gcsafe.} =
    ## Returns the current user
    var url = EndpointGetCurrentUser()
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[User](res.body)
   

method GetUser*(s: Session, userid: string): User {.base, gcsafe.} =
    ## Gets a user
    if s.cache.cacheUsers:
        var (user, exists) = s.cache.getUser(userid)

        if exists:
            return user

    var url = EndpointGetUser(userid)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[User](res.body)

    if s.cache.cacheUsers:
        s.cache.users[result.id] = result
        
method EditUsername*(s: Session, name: string): User {.base, gcsafe.} =
    ## Edits the current users username
    var url = EndpointGetCurrentUser()
    let payload = %*{"username": name}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    result = marshal.to[User](res.body)
    

method EditAvatar*(s: Session, avatar: string): User {.base, gcsafe.} =
    ## Changes the current users avatar
    var url = EndpointGetCurrentUser()
    let payload = %*{"avatar": avatar}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    result = marshal.to[User](res.body)
    

method Guilds*(s: Session): seq[UserGuild] {.base, gcsafe.} =
    ## Lists the current users guilds
    var url = EndpointGetCurrentUserGuilds()
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[seq[UserGuild]](res.body)
    

method LeaveGuild*(s: Session, guild: string) {.base, gcsafe.} =
    ## Makes the current user leave the specified guild
    var url = EndpointLeaveGuild(guild)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method ActivePrivateChannels*(s: Session): seq[DChannel] {.base, gcsafe.} =
    ## Lists all active DM channels
    var url = EndpointGetUserDMs()
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[seq[DChannel]](res.body)
    

method PrivateChannelCreate*(s: Session, recipient: string): DChannel {.base, gcsafe.} =
    ## Creates a new DM channel
    var url = EndpointCreateDM()
    let payload = %*{"recipient_id": recipient}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    result = marshal.to[DChannel](res.body) 
    

method VoiceRegions*(s: Session): seq[VoiceRegion] {.base, gcsafe.} =
    ## Lists all voice regions
    var url = EndpointListVoiceRegions()
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[seq[VoiceRegion]](res.body)
    

method WebhookCreate*(s: Session, channel, name, avatar: string): Webhook {.base, gcsafe.} =
    ## Creates a webhook
    var url = EndpointCreateWebhook(channel)
    let payload = %*{"name": name, "avatar": avatar}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    result = marshal.to[Webhook](res.body)
   

method ChannelWebhooks*(s: Session, channel: string): seq[Webhook] {.base, gcsafe.} =
    ## Lists all webhooks in a channel
    var url = EndpointGetChannelWebhooks(channel)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[seq[Webhook]](res.body)
   

method GuildWebhooks*(s: Session, guild: string): seq[Webhook] {.base, gcsafe.} =
    ## Lists all webhooks in a guild
    var url = EndpointGetGuildWebhook(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[seq[Webhook]](res.body)
    

method GetWebhookWithToken*(s: Session, webhook, token: string): Webhook {.base, gcsafe.} =
    ## Gets a webhook with a token
    var url = EndpointGetWebhookWithToken(webhook, token)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = marshal.to[Webhook](res.body)
    

method WebhookEdit*(s: Session, webhook, name, avatar: string): Webhook {.base, gcsafe.} =
    ## Edits a webhook
    var url = EndpointModifyWebhook(webhook)
    let payload = %*{"name": name, "avatar": avatar}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    result = marshal.to[Webhook](res.body)
    

method WebhookEditWithToken*(s: Session, webhook, token, name, avatar: string): Webhook {.base, gcsafe.} =
    ## Edits a webhook with a token
    var url = EndpointModifyWebhookWithToken(webhook, token)
    let payload = %*{"name": name, "avatar": avatar}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    result = marshal.to[Webhook](res.body)
    

method WebhookDelete*(s: Session, webhook: string): Webhook {.base, gcsafe.} =
    ## Deletes a webhook
    var url = EndpointDeleteWebhook(webhook)
    let res = s.Request(url, "DELETE", url, "application/json", "", 0)
    result = marshal.to[Webhook](res.body)
    

method WebhookDeleteWithToken*(s: Session, webhook, token: string): Webhook {.base, gcsafe.} =
    ## Deltes a webhook with a token
    var url = EndpointDeleteWebhookWithToken(webhook, token)
    let res = s.Request(url, "DELETE", url, "application/json", "", 0)
    result = marshal.to[Webhook](res.body)
    

method ExecuteWebhook*(s: Session, webhook, token: string, wait: bool, payload: WebhookParams) {.base, gcsafe.} =
    ## Executes a webhook
    var url = EndpointExecuteWebhook(webhook, token)
    discard s.Request(url, "POST", url, "application/json", $$payload, 0) 


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
    var chan = s.GetChannel(m.channel_id)
    if chan != DChannel():
        return chan.guild_id
    result = ""