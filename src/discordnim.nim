include endpoints
import httpclient, marshal, json, re,
       locks, tables, times, strutils, net, macros,
       os, typetraits, websocket/shared, asyncdispatch, asyncnet, threadpool
type
    Overwrite* = object
        id*: string
        `type`*: string
        allow*: int
        deny*: int
    Channel* = object
        id*: string
        guild_id*: string
        name*: string
        `type`*: int
        position*: int
        is_private*: bool
        permission_overwrites*: seq[Overwrite]
        topic*: string
        last_message_id*: string
        bitrate*: int
        user_limit*: int
        recipients*: seq[User]
    Message* = object
        `type`: int
        tts*: bool
        timestamp*: string
        pinned*: bool
        nonce*: string
        mention_roles*: seq[Role]
        mentions*: seq[User]
        mention_everyone*: bool
        id*: string
        embeds*: seq[Embed]
        edited_timestamp*: string
        content*: string
        channel_id*: string
        author*: User
        attachments*: seq[Attachment]
        reactions*: seq[Reaction]
        webhook_id*: string
    Reaction* = object
        count*: int
        me*: bool
        emoji*: Emoji
    Emoji* = object
        id*: string
        name*: string
        roles*: seq[Role]
        require_colons*: bool
        managed*: bool
    Embed* = object
        title*: string
        `type`*: string
        description*: string
        url*: string
        timestamp*: string
        color*: int
        footer*: Footer
        image*: Image
        thumbnail*: Thumbnail
        video*: Video
        provider*: Provider
        author*: Author
        fields*: seq[Field]
    Thumbnail* = ref object
        url*: string
        proxy_url*: string
        height*: int
        width*: int
    Video* = ref object
        url*: string
        height*: int
        width*: int
    Image* = ref object
        url*: string
        proxy_url*: string
        height*: int
        width*: int
    Provider* = ref object
        name*: string
        url*: string
    Author* = ref object
        name*: string
        url*: string
        icon_url*: string
        proxy_icon_url*: string
    Footer* = ref object
        text*: string
        icon_url*: string
        proxy_icon_url*: string
    Field* = ref object
        name*: string
        value*: string
        inline*: bool
    Attachment* = object
        id*: string
        filename*: string
        size*: int
        url*: string
        proxy_url*: string
        height*: int
        width*: int
    Presence* = object
        user: User
        status: string
        game: Game
        nick: string
        roles: seq[string]
    Guild* = object
        id*: string
        name*: string
        icon*: string
        splash*: string
        owner_id*: string
        region*: string
        afk_channel_id*: string
        afk_timeout*: int
        embed_enabled*: bool
        embed_channel_id*: string
        verification_level*: int
        default_message_notifications*: int
        roles*: seq[Role]
        emojis*: seq[Emoji]
        mfa_level*: int
        joined_at*: string
        large*: bool
        unavailable*: bool
        features: seq[JsonNode]
        explicit_content_filter*: int
        member_count*: int
        voice_states*: seq[VoiceState]
        members*: seq[GuildMember]
        channels*: seq[Channel]
        presences*: seq[Presence]
        application_id*: string
    GuildMember* = object
        guild_id*: string
        user*: User
        nick*: string
        roles*: seq[string]
        joined_at*: string
        deaf*: bool
        mute*: bool
    Integration* = object
        id*: string
        name*: string
        `type`*: string
        enabled*: bool
        syncing*: bool
        role_id*: string
        expire_behavior*: int
        expire_grace_period*: int
        iUser*: User
        iAccount*: Account
        synced_at*: string
    Account* = object
        id*: string
        name*: string
    Invite* = object
        code*: string
        guild*: InviteGuild
        iChannel*: InviteChannel
    InviteMetadata* = object
        inviter*: User
        uses*: int
        max_uses*: int
        max_age*: int
        temporary*: bool
        created_at*: string
        revoked*: bool
    InviteGuild* = object
        id*: string
        name*: string
        splash*: string
        icon*: string
    InviteChannel* = object
        id*: string
        name*: string
        `type`*: string
    User* = object
        id*: string
        username*: string
        discriminator*: string
        avatar*: string
        bot*: bool
        mfa_enabled*: bool
        verified*: bool
        email*: string
    UserGuild* = object
        id: string
        name: string
        icon: string
        owner: bool
        permissions: int
    Connection* = object
        id*: string
        name*: string
        `type`*: string
        revoked*: bool
        integrations*: seq[Integration]
    VoiceState* = object
        guild_id*: string
        channel_id*: string
        user_id*: string
        session_id*: string
        deaf*: bool
        mute*: bool
        self_deaf*: bool
        self_mute*: bool
        suppress*: bool
    VoiceRegion* = object
        id*: string
        name*: string
        sample_hostname*: string
        sample_port*: int
        vip*: bool
        optimal*: bool
        deprecated*: bool
        custom*: bool
    Webhook* = object
        id*: string
        guild_id*: string
        channel_id*: string
        user*: User
        name*: string
        avatar*: string
        token*: string
    Role* = object
        id*: string
        name*: string
        color*: int
        hoist*: bool
        position*: int
        permissions*: int
        managed*: bool
        mentionable*: bool
    ChannelParams* = ref object
        name*: string
        position*: int
        topic*: string
        bitrate*: int
        user_limit*: int
    GuildParams* = ref object
        name*: string
        region*: string
        verification_level*: int
        default_message_notifications*: int
        afk_channel_id*: string
        afk_timeout*: int
        icon*: string
        owner_id*: string
        splash*: string
    GuildMemberParams* = ref object
        nick*: string
        roles*: seq[string]
        mute*: bool
        deaf*: bool
        channel_id*: string
    GuildEmbed* = object
        enabled*: bool
        channel_id*: string
    WebhookParams* = ref object
        content*: string
        username*: string
        avatar_url*: string
        tts*: bool
        embeds*: Embed
    GuildDelete* = object
        id*: string
        unavailable*: bool
    GuildEmojisUpdate* = object
        guild_id*: string
        emojis*: seq[Emoji]
    GuildIntegrationsUpdate* = object
        guild_id*: string
    GuildRoleCreate* = object
        guild_id*: string
        role*: Role
    GuildRoleUpdate* = object
        guild_id*: string
        role*: Role
    GuildRoleDelete* = object
        guild_id*: string
        role_id*: string
    MessageDelete* = object
        id*: string
        channel_id*: string
    MessageDeleteBulk* = object
        ids*: seq[string]
        channel_id*: string
    Game* = ref object
        name*: string
        `type`*: int
        url*: string
    PresenceUpdate* = object
        user*: User
        roles*: seq[string]
        game*: Game
        guild_id*: string
        status*: string
    TypingStart* = object
        channel_id*: string
        user_id*: string
        timestamp*: int
    VoiceServerUpdate* = object
        token: string
        guild_id: string
        endpoint: string
    Resumed* = object
        trace*: seq[string]
    State* = ref object
        version*: int
        me*: User
        private_channels*: seq[Channel]
        guilds*: seq[Guild]
    Session* = ref object
        Mut: Lock
        Token*: string
        Compress*: bool
        ShardID*: int
        ShardCount*: int
        Sequence: int
        Gateway*: string
        Session_ID: string
        Limiter: ref RateLimiter   
        Connection*: AsyncWebSocket
        State*: State
        shouldResume: bool
        suspended: bool
        invalidated: bool
        # Temporary until better solution is found
        channelCreate*:           proc(s: Session, p: Channel) {.gcsafe.}
        channelUpdate*:           proc(s: Session, p: Channel) {.gcsafe.}
        channelDelete*:           proc(s: Session, p: Channel) {.gcsafe.}
        guildCreate*:             proc(s: Session, p: Guild) {.gcsafe.}
        guildUpdate*:             proc(s: Session, p: Guild) {.gcsafe.}
        guildDelete*:             proc(s: Session, p: GuildDelete) {.gcsafe.}
        guildBanAdd*:             proc(s: Session, p: User) {.gcsafe.}
        guildBanRemove*:          proc(s: Session, p: User) {.gcsafe.}
        guildEmojisUpdate*:       proc(s: Session, p: GuildEmojisUpdate) {.gcsafe.}
        guildIntegrationsUpdate*: proc(s: Session, p: GuildIntegrationsUpdate) {.gcsafe.}
        guildMemberAdd*:          proc(s: Session, p: GuildMember) {.gcsafe.}
        guildMemberUpdate*:       proc(s: Session, p: GuildMember) {.gcsafe.}
        guildMemberRemove*:       proc(s: Session, p: GuildMember) {.gcsafe.}
        guildRoleCreate*:         proc(s: Session, p: GuildRoleCreate) {.gcsafe.}
        guildRoleUpdate*:         proc(s: Session, p: GuildRoleUpdate) {.gcsafe.}
        guildRoleDelete*:         proc(s: Session, p: GuildRoleDelete) {.gcsafe.}
        messageCreate*:           proc(s: Session, p: Message) {.gcsafe.}
        messageUpdate*:           proc(s: Session, p: Message) {.gcsafe.}
        messageDelete*:           proc(s: Session, p: MessageDelete) {.gcsafe.}
        messageDeleteBulk*:       proc(s: Session, p: MessageDeleteBulk) {.gcsafe.}
        presenceUpdate*:          proc(s: Session, p: PresenceUpdate) {.gcsafe.}
        typingStart*:             proc(s: Session, p: TypingStart) {.gcsafe.}
        userUpdate*:              proc(s: Session, p: User) {.gcsafe.}
        voiceStateUpdate*:        proc(s: Session, p: VoiceState) {.gcsafe.}
        voiceServerUpdate*:       proc(s: Session, p: VoiceServerUpdate) {.gcsafe.}
        onResume*:                proc(s: Session, p: Resumed) {.gcsafe.}
    RateLimiter = object
        Mut: Lock
        Global: ref Bucket
        Buckets: Table[string, ref Bucket]
        GlobalRateLimit: TimeInterval
    Bucket = object
        Mut: Lock
        Key: string
        Remaining: int
        Limit: int
        Reset: TimeInfo
        Global: ref Bucket
    

# Gateway op codes

const
    OP_DISPATCH* = 0
    OP_HEARTBEAT* = 1
    OP_IDENTIFY* = 2
    OP_STATUS_UPDATE* = 3
    OP_VOICE_STATE_UPDATE* = 4
    OP_VOICE_SERVER_PING* = 5
    OP_RESUME* = 6
    OP_RECONNECT* = 7
    OP_REQUEST_GUILD_MEMBERS* = 8
    OP_INVALID_SESSION* = 9
    OP_HELLO* = 10
    OP_HEARTBEAT_ACK* = 11


# Permissions
const
    CREATE_INSTANT_INVITE* = 0x00000001
    KICK_MEMBERS* = 0x00000002
    BAN_MEMBERS* = 0x00000004
    ADMINISTRATOR* = 0x00000008
    MANAGE_CHANNELS* = 0x00000010
    MANAGE_GUILD* = 0x00000020
    ADD_REACTIONS* = 0x00000040
    READ_MESSAGES* = 0x00000400
    SEND_MESSAGES* = 0x00000800
    SEND_TTS_MESSAGES* = 0x00001000
    MANAGE_MESSAGES* = 0x00002000
    EMBED_LINKS* = 0x00004000
    ATTACH_FILES* = 0x00008000
    READ_MESSAGE_HISTORY* = 0x00010000
    MENTION_EVERYONE* = 0x00020000
    USE_EXTERNAL_EMOJIS* = 0x00040000
    CONNECT* = 0x00100000
    SPEAK* = 0x00200000
    MUTE_MEMBERS* = 0x00400000
    DEAFEN_MEMBERS* = 0x00800000
    MOVE_MEMBERS* = 0x01000000
    USE_VAD* = 0x02000000
    CHANGE_NICKNAME* = 0x04000000
    MANAGE_NICKNAMES* = 0x08000000
    MANAGE_ROLES* = 0x10000000
    MANAGE_WEBHOOKS* = 0x20000000
    MANAGE_EMOJIS* = 0x40000000

proc newRateLimiter(): ref RateLimiter =
    let b = new(Bucket)
    b[] = Bucket(Mut: Lock(), Key: "global", Reset: getLocalTime(fromSeconds(epochTime())))
    var rl = new(RateLimiter)
    rl[]= RateLimiter(Mut: Lock(), Buckets: initTable[string, ref Bucket](), Global: b)
    return rl

method getBucket(r: ref RateLimiter, key: string): ref Bucket {.base.} =
    initLock(r.Mut)
    defer: deinitLock(r.Mut)

    if hasKey(r.Buckets, key):
        return r.Buckets[key]

    var b = new Bucket

    b.Remaining = 1
    b.Key = key
    b.Global = r.Global
    r.Buckets[key] = b
    return b

method lockBucket(r : ref RateLimiter, bid : string): ref Bucket {.base.} =
    var b = r.getBucket(bid)

    initLock(b.Mut)

    if b.Remaining < 1 and toTime(b.Reset) - getTime() > 0:
        sleep int32(toTime(b.Reset) - getTime())

    initLock(r.Global.Mut)
    deinitLock(r.Global.Mut)
    return b

proc sleepUntil(pa : int32, b : ref Bucket) =
    var sleepTo = getTime() + pa.seconds
    initLock(b.Global.Mut)

    var sleepdur = sleepTo - getTime()

    if sleepdur > 0:
        sleep(int32(sleepdur))

    deinitLock(b.Global.Mut)
    return

method Release(b : ref Bucket, headers : HttpHeaders) {.base.} =
    defer: deinitLock(b.Mut)

    if headers == nil:
        return

    var
        remaining: string
        reset: string
        global: string
        retryAfter: string

    if hasKey(headers, "X-RateLimit-Remaining"):
        remaining = $headers["X-RateLimit-Remaining"]
    if hasKey(headers, "X-RateLimit-Reset"):
        reset = $headers["X-RateLimit-Reset"]
    if hasKey(headers, "X-RateLimit-Global"):
        global = $headers["X-RateLimit-Global"]
    if hasKey(headers, "Retry-After"):
        retryAfter = $headers["Retry-After"]

    if global != "" and global != nil:
        var parsedAfter = parseInt(retryAfter)

        sleepUntil(int32(parsedAfter), b)
        return

    if retryAfter != "" and retryAfter != nil:
        var pa = parseInt(retryAfter)
        b.Reset = (getTime() + pa.milliseconds).getLocalTime
    elif reset != "" and reset != nil:
        var dt = parse($headers["Date"], "ddd, dd MMM yyyy HH:mm:ss")
        var delta = parseInt(reset)
        var retry_after = int64(dt.toTime().toSeconds())-delta
        let t = retry_after.fromSeconds()
        b.Reset = t.getGMTime

    if remaining != "" and remaining != nil:
        var pr = remaining.parseInt
        b.Remaining = pr

    return


# REST API json objects

method Request(s : Session, bucketid: var string, meth, url, contenttype, b : string, sequence : int, mp: MultipartData = nil): Response {.base, gcsafe.} =
    var client = newHttpClient("DiscordBot(https://github.com/Krognol/discordnim, v0.1.0)", sslContext = newContext(verifyMode = CVerifyNone))
    
    if bucketid == "":
        bucketid = split(url, "?", 2)[0]

    var bucket = s.Limiter.lockBucket(bucketid)

    if s.Token != "" and s.Token != nil:
        client.headers["Authorization"] = s.Token

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
    of "409":
        var rl = parseJson(res.body)
        sleep int(rl["retry_after"].num)
        res = s.Request(bucketid, meth, url, contenttype, b, sequence)
    else: discard

    client.close()
    return res



method GetGateway(s: Session): string {.base.} =
    var url = Gateway()
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    type Temp = object
        url: string
    let t = to[Temp](res.body)
    return t.url

method Login(s : Session, email, password : string) {.base.} =
    var payload = %*{"email": email, "password": password}
    var id = EndpointLogin()
    let res = s.Request(id, "POST", id, "application/json", $payload, 0)
    type Temp = object
        Token: string

    var t = to[Temp](res.body)
    s.Token = t.Token
    return 

# Temporary until a better solution is found
method initEvents(s: Session) {.base.} =
    s.channelCreate =           proc(s: Session, p: Channel) = return
    s.channelUpdate =           proc(s: Session, p: Channel) = return
    s.channelDelete =           proc(s: Session, p: Channel) = return
    s.guildCreate =             proc(s: Session, p: Guild) = return
    s.guildUpdate =             proc(s: Session, p: Guild) = return
    s.guildDelete =             proc(s: Session, p: GuildDelete) = return
    s.guildBanAdd =             proc(s: Session, p: User) = return
    s.guildBanRemove =          proc(s: Session, p: User) = return
    s.guildEmojisUpdate =       proc(s: Session, p: GuildEmojisUpdate) = return
    s.guildIntegrationsUpdate = proc(s: Session, p: GuildIntegrationsUpdate) = return
    s.guildMemberAdd =          proc(s: Session, p: GuildMember) = return
    s.guildMemberUpdate =       proc(s: Session, p: GuildMember) = return
    s.guildMemberRemove =       proc(s: Session, p: GuildMember) = return
    s.guildRoleCreate =         proc(s: Session, p: GuildRoleCreate) = return
    s.guildRoleUpdate =         proc(s: Session, p: GuildRoleUpdate) = return
    s.guildRoleDelete =         proc(s: Session, p: GuildRoleDelete) = return
    s.messageCreate =           proc(s: Session, p: Message) = return
    s.messageUpdate =           proc(s: Session, p: Message) = return
    s.messageDelete =           proc(s: Session, p: MessageDelete) = return
    s.messageDeleteBulk =       proc(s: Session, p: MessageDeleteBulk) = return
    s.presenceUpdate =          proc(s: Session, p: PresenceUpdate) = return
    s.typingStart =             proc(s: Session, p: TypingStart) = return
    s.userUpdate =              proc(s: Session, p: User) = return
    s.voiceStateUpdate =        proc(s: Session, p: VoiceState) = return
    s.voiceServerUpdate =       proc(s: Session, p: VoiceServerUpdate) = return
    s.onResume =                proc(s: Session, p: Resumed) = return


proc NewSession*(args: varargs[string, `$`]): Session =
    ## Creates a new Session
    
    var 
        s = Session(Mut: Lock(), Compress: false, Limiter: newRateLimiter(), State: State())
        auth: string = ""
        pass: string = ""
    
    for arg in args:
        if auth == "":
            auth = arg
        elif pass == "":
            pass = arg
        elif s.Token == "":
            s.Token = arg
            

    if pass == "":
        s.Token = auth
    else:
        s.Login(auth, pass)
        if s.Token == "":
            echo "Failed to get auth token"
            return nil
    s.Gateway = s.GetGateway().strip&"/"&GATEWAYVERSION
    s.initEvents()
    return s

method GetChannel*(s: Session, channel_id: string): Channel {.base, gcsafe.} =
    ## Returns the channel with the given ID
    var url = EndpointGetChannel(channel_id)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[Channel](res.body)

method ModifyChannel*(s: Session, channelid: string, params: ChannelParams): Guild {.base, gcsafe.} =
    ## Modifies a channel with the ChannelParams
    var url = EndpointModifyChannel(channelid)
    let res = s.Request(url, "PATCH", url, "application/json", $$params, 0)
    result = to[Guild](res.body)

method DeleteChannel*(s: Session, channelid: string): Channel {.base, gcsafe.} =
    ## Deletes a channel
    var url = EndpointDeleteChannel(channelid)
    let res = s.Request(url, "DELETE", url, "application/json", "", 0)
    result = to[Channel](res.body)

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
    result = to[seq[Message]](res.body)

method ChannelMessage*(s: Session, channelid, messageid: string): Message {.base, gcsafe.} =
    ## Returns a message from a channel
    var url = EndpointGetChannelMessage(channelid, messageid)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[Message](res.body)


method SendMessage*(s: Session, channelid, message: string): Message {.base, gcsafe.} =
    ## Sends a regular text message to a channel
    var url = EndpointCreateMessage(channelid)
    let payload = %*{"content": message}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    result = to[Message](res.body)
    

method SendMessageEmbed*(s: Session, channelid: string, embed: Embed): Message {.base, gcsafe.} =
    ## Sends an Embed message to a channel
    var url = EndpointCreateMessage(channelid)

    let payload = %*{
        "content": "",
        "embed": embed
    }

    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    result = to[Message](res.body)

method SendMessageTTS*(s: Session, channelid, message: string): Message {.base, gcsafe.} =
    ## Sends a TTS message to a channel
    var url = EndpointCreateMessage(channelid)
    let payload = %*{"content": message, "tts": true}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    result = to[Message](res.body)

#[
    ## TODO
    ## On hold; returns 401
method SendFileWithMessage*(s: Session, channelid, name, message: string): Message {.base, gcsafe.} =
    var data = newMultipartData()
    var url = EndpointCreateMessage(channelid)
    
    let payload = %*{"content": message}
    data.add("payload_json", encodeUrl($payload), contentType = "application/json")
    data = data.addFiles({"file": name})

    let res = s.Request(url, "POST", url, "multipart/form-data", "", 0, data)
    echo res.body
    let msg = to[Message](res.body)
    return msg

method SendFile*(s: Session, channelid, name: string): Message {.base, gcsafe.} =
    return s.SendFileWithMessage(channelid, name, "")
]#
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
    result = to[seq[User]](res.body)
   

method MessageDeleteAllReactions*(s: Session, channelid, messageid: string) {.base, gcsafe.} =
    ## Deletes all reactions on a message
    var url = EndpointDeleteAllReactions(channelid, messageid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method EditMessage*(s: Session, channelid, messageid, content: string): Message {.base, gcsafe.} =
    ## Edits a message's contents
    var url = EndpointEditMessage(channelid, messageid)
    let payload = %*{"content": content}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    result = to[Message](res.body)
    

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
    result = to[seq[Invite]](res.body)
   

method CreateChannelInvite*(s: Session, channel: string, max_age, max_uses: int, temp, unique: bool): Invite {.base, gcsafe.} =
    ## Creates an invite to a channel
    var url = EndpointCreateChannelInvite(channel)
    let payload = %*{"max_age": max_age, "max_uses": max_uses, "temp": temp, "unique": unique}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    result = to[Invite](res.body)
    

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
    result = to[seq[Message]](res.body)
    

method ChannelPinMessage*(s: Session, channel, message: string) {.base, gcsafe.} =
    ## Pins a message in a channel
    var url = EndpointAddPinnedChannelMessage(channel, message)
    discard s.Request(url, "PUT", url, "application/json", "", 0)

method ChannelDeletePinnedMessage*(s: Session, channel, message: string) {.base, gcsafe.} =
    var url = EndpointDeletePinnedChannelMessage(channel, message)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

#TODO
#method GroupDMAddUser()

#TODO
#method GroupdDMRemoveUser()

method CreateGuild*(s: Session, name: string): Guild {.base, gcsafe.} =
    ## Creates a guild
    ## This endpoint is limited to 10 active guilds
    var url = EndpointCreateGuild()
    let payload = %*{"name": name}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    result = to[Guild](res.body)
    

method GetGuild*(s: Session, id: string): Guild {.base, gcsafe.} =
    ## Gets a guild
    var url = EndpointGetGuild(id)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[Guild](res.body)
   

method ModifyGuild*(s: Session, guild: string, settings: GuildParams): Guild {.base, gcsafe.} =
    ## Modifies a guild with the GuildParams
    var url = EndpointModifyGuild(guild)
    let res = s.Request(url, "PATCH", url, "application/json", $$settings, 0)
    result = to[Guild](res.body)
    

method DeleteGuild*(s: Session, guild: string): Guild {.base, gcsafe.} =
    ## Deletes a guild
    var url = EndpointDeleteGuild(guild)
    let res = s.Request(url, "DELETE", url, "application/json", "", 0)
    result = to[Guild](res.body)
    

method GuildChannels*(s: Session, guild: string): seq[Channel] {.base, gcsafe.} =
    ## Returns all guild channels
    var url = EndpointGetGuildChannels(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[seq[Channel]](res.body)
   

method GuildChannelCreate*(s: Session, guild, channelname: string, voice: bool): Channel {.base, gcsafe.} =
    ## Creates a new channel in a guild
    var url = EndpointCreateGuildChannel(guild)
    let payload = %*{"name": channelname, "voice": voice}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    result = to[Channel](res.body)
    

method ModifyGuildChannelPosition*(s: Session, guild, channel: string, position: int): seq[Channel] {.base, gcsafe.} =
    ## Reorders the position of a channel and returns the new order
    var url = EndpointModifyGuildChannelPositions(guild)
    let payload = %*{"id": channel, "position": position}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    result = to[seq[Channel]](res.body)
   

method GuildMembers*(s: Session, guild: string, limit, after: int): seq[GuildMember] {.base, gcsafe.} =
    ## Returns up to 1000 guild members
    var url = EndpointListGuildMembers(guild) & "?"

    if limit > 1:
        url = url & "limit=" & $limit & "&"
    if after > 0:
        url = url & "after=" & $after & "&"

    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[seq[GuildMember]](res.body)
    

method GetGuildMember*(s: Session, guild, userid: string): GuildMember {.base, gcsafe.} =
    ## Returns a guild member with the userid
    var url = EndpointGetGuildMember(guild, userid)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[GuildMember](res.body)
    

method GuildMemberAdd*(s: Session, guild, userid, accesstoken: string): GuildMember {.base, gcsafe.} =
    ## Adds a guild member to the guild
    var url = EndpointAddGuildMember(guild, userid)
    let payload = %*{"access_token": accesstoken}
    let res = s.Request(url, "PUT", url, "application/json", $payload, 0)
    result = to[GuildMember](res.body)
    

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

method GuildMemberRemove*(s: Session, guild, userid: string) {.base, gcsafe.} =
    ## Removes a guild membe from the guild
    var url = EndpointRemoveGuildMember(guild, userid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method GuildBans*(s: Session, guild: string): seq[User] {.base, gcsafe.} =
    ## Returns all users who have been banned from the guild
    var url = EndpointGetGuildBans(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[seq[User]](res.body)
   

method GuildBanUser*(s: Session, guild, userid: string) {.base, gcsafe.} =
    ## Bans a user from the guild
    var url = EndpointCreateGuildBan(guild, userid)
    discard s.Request(url, "PUT", url, "application/json", "", 0)

method GuildBanRemove*(s: Session, guild, userid: string) {.base, gcsafe.} =
    ## Removes a ban from the guild
    var url = EndpointRemoveGuildBan(guild, userid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method GuildRoles*(s: Session, guild: string): seq[Role] {.base, gcsafe.} =
    ## Returns all guild roles
    var url = EndpointGetGuildRoles(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[seq[Role]](res.body)
    

method GuildRoleCreateP*(s: Session, guild: string): Role {.base, gcsafe.} =
    ## Creates a new role in the guild
    ## Excuse the P in the name, the name conflicts with another declaration
    var url = EndpointCreateGuildRole(guild)
    let res = s.Request(url, "POST", url, "application/json", "", 0)
    result = to[Role](res.body)
    

method GuildRoleEditPosition*(s: Session, guild: string, roles: seq[Role]): seq[Role] {.base, gcsafe.} =
    ## Edits the positions of a guilds roles roles
    ## and returns the new roles order
    var url = EndpointModifyGuildRolePositions(guild)
    let res = s.Request(url, "PATCH", url, "application/json", $$roles, 0)
    result = to[seq[Role]](res.body)
    

method GuildRoleEdit*(s: Session, guild, roleid, name: string, permissions, color: int, hoist, mentionable: bool): Role {.base, gcsafe.} =
    ## Edits a role
    var url = EndpointModifyGuildRole(guild, roleid)
    let payload = %*{"name": name, "permissions": permissions, "color": color, "hoist": hoist, "mentionable": mentionable}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    result = to[Role](res.body)
   

method GuildRoleDeleteP*(s: Session, guild, roleid: string) {.base, gcsafe.} =
    ## Deletes a role
    ## Excuse the P in the name, the name conflicts with another declaration
    var url = EndpointDeleteGuildRole(guild, roleid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method GuildPruneCount*(s: Session, guild: string, days: int): int {.base, gcsafe.} =
    ## Returns the number of members who would get kicked
    ## during a prune operation
    var url = EndpointGetGuildPruneCount(guild) & "?days=" & $days
    let res = s.Request(url, "GET", "", "application/json", "", 0)

    type temp = ref object
        pruned: int

    let t = to[temp](res.body)
    return t.pruned

method GuildPruneBegin*(s: Session, guild: string, days: int): int {.base, gcsafe.} =
    ## Begins a prune operation and
    ## kicks all members who haven't been active
    ## for N days
    var url = EndpointBeginGuildPruneCount(guild) & "?days=" & $days
    let res = s.Request(url, "POST", "", "application/json", "", 0)

    type temp = ref object
        pruned: int

    let t = to[temp](res.body)
    return t.pruned

method GuildVoiceRegions*(s: Session, guild: string): seq[VoiceRegion] {.base, gcsafe.} =
    ## Lists all voice regions in a guild
    var url = EndpointGetGuildVoiceRegions(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[seq[VoiceRegion]](res.body)
    

method GuildInvites*(s: Session, guild: string): seq[Invite] {.base, gcsafe.} =
    ## Lists all guild invites
    var url = EndpointGetGuildInvites(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[seq[Invite]](res.body)
    

method GuildIntegrations*(s: Session, guild: string): seq[Integration] {.base, gcsafe.} =
    ## Lists all guild integrations
    var url = EndpointGetGuildIntegrations(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[seq[Integration]](res.body)
    

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
    result = to[GuildEmbed](res.body)
    

method GuildEmbedEdit*(s: Session, guild: string, enabled: bool, channel: string): GuildEmbed {.base, gcsafe.} =
    ## Edits a GuildEmbed
    var url = EndpointModifyGuildEmbed(guild)
    let embed = GuildEmbed(enabled: enabled, channel_id: channel)
    let res = s.Request(url, "PATCH", url, "application/json", $$embed, 0)
    result = to[GuildEmbed](res.body)
   

method GetInvite*(s: Session, code: string): Invite {.base, gcsafe.} =
    ## Gets an invite with code
    var url = EndpointGetInvite(code)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[Invite](res.body)
   

method InviteDelete*(s: Session, code: string): Invite {.base, gcsafe.} =
    ## Deletes an invite
    var url = EndpointDeleteInvite(code)
    let res = s.Request(url, "DELETE", url, "application/json", "", 0)
    result = to[Invite](res.body)
    

method Me*(s: Session): User {.base, gcsafe.} =
    ## Returns the current user
    var url = EndpointGetCurrentUser()
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[User](res.body)
   

method GetUser*(s: Session, userid: string): User {.base, gcsafe.} =
    ## Gets a user
    var url = EndpointGetUser(userid)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[User](res.body)
    

method EditUsername*(s: Session, name: string): User {.base, gcsafe.} =
    ## Edits the current users username
    var url = EndpointGetCurrentUser()
    let payload = %*{"username": name}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    result = to[User](res.body)
    

method EditAvatar*(s: Session, avatar: string): User {.base, gcsafe.} =
    ## Changes the current users avatar
    var url = EndpointGetCurrentUser()
    let payload = %*{"avatar": avatar}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    result = to[User](res.body)
    

method Guilds*(s: Session): seq[UserGuild] {.base, gcsafe.} =
    ## Lists the current users guilds
    var url = EndpointGetCurrentUserGuilds()
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[seq[UserGuild]](res.body)
    

method LeaveGuild*(s: Session, guild: string) {.base, gcsafe.} =
    ## Makes the current user leave the specified guild
    var url = EndpointLeaveGuild(guild)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method DMs*(s: Session): seq[Channel] {.base, gcsafe.} =
    ## Lists all active DM channels
    var url = EndpointGetUserDMs()
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[seq[Channel]](res.body)
    

method DMCreate*(s: Session, recipient: string): Channel {.base, gcsafe.} =
    ## Creates a new DM channel
    var url = EndpointCreateDM()
    let payload = %*{"recipient_id": recipient}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    result = to[Channel](res.body)
    

method VoiceRegions*(s: Session): seq[VoiceRegion] {.base, gcsafe.} =
    ## Lists all voice regions
    var url = EndpointListVoiceRegions()
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[seq[VoiceRegion]](res.body)
    

method WebhookCreate*(s: Session, channel, name, avatar: string): Webhook {.base, gcsafe.} =
    ## Creates a webhook
    var url = EndpointCreateWebhook(channel)
    let payload = %*{"name": name, "avatar": avatar}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    result = to[Webhook](res.body)
   

method ChannelWebhooks*(s: Session, channel: string): seq[Webhook] {.base, gcsafe.} =
    ## Lists all webhooks in a channel
    var url = EndpointGetChannelWebhooks(channel)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[seq[Webhook]](res.body)
   

method GuildWebhooks*(s: Session, guild: string): seq[Webhook] {.base, gcsafe.} =
    ## Lists all webhooks in a guild
    var url = EndpointGetGuildWebhook(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[seq[Webhook]](res.body)
    

method GetWebhookWithToken*(s: Session, webhook, token: string): Webhook {.base, gcsafe.} =
    ## Gets a webhook with a token
    var url = EndpointGetWebhookWithToken(webhook, token)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    result = to[Webhook](res.body)
    

method WebhookEdit*(s: Session, webhook, name, avatar: string): Webhook {.base, gcsafe.} =
    ## Edits a webhook
    var url = EndpointModifyWebhook(webhook)
    let payload = %*{"name": name, "avatar": avatar}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    result = to[Webhook](res.body)
    

method WebhookEditWithToken*(s: Session, webhook, token, name, avatar: string): Webhook {.base, gcsafe.} =
    ## Edits a webhook with a token
    var url = EndpointModifyWebhookWithToken(webhook, token)
    let payload = %*{"name": name, "avatar": avatar}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    result = to[Webhook](res.body)
    

method WebhookDelete*(s: Session, webhook: string): Webhook {.base, gcsafe.} =
    ## Deletes a webhook
    var url = EndpointDeleteWebhook(webhook)
    let res = s.Request(url, "DELETE", url, "application/json", "", 0)
    result = to[Webhook](res.body)
    

method WebhookDeleteWithToken*(s: Session, webhook, token: string): Webhook {.base, gcsafe.} =
    ## Deltes a webhook with a token
    var url = EndpointDeleteWebhookWithToken(webhook, token)
    let res = s.Request(url, "DELETE", url, "application/json", "", 0)
    result = to[Webhook](res.body)
    

method ExecuteWebhook*(s: Session, webhook, token: string, wait: bool, payload: WebhookParams) {.base, gcsafe.} =
    ## Executes a webhook
    var url = EndpointExecuteWebhook(webhook, token)
    discard s.Request(url, "POST", url, "application/json", $$payload, 0)

proc identify(s: Session) {.async, base.} =
    var properties = %*{
        "$os": system.hostOS,
        "$browser": "Discordnim v"&VERSION,
        "$device": "Discordnim v"&VERSION,
        "$referrer": "",
        "$referring_domain": ""
    }

    var payload = %*{
        "op": OP_IDENTIFY,
        "d": %*{
            "token": s.Token,
            "properties": properties,
        }
    }

    try:
        await s.Connection.sock.sendText($payload, true)
    except:
        echo "Error sending identify packet\c\L" & getCurrentExceptionMsg() 

proc startHeartbeats(t: tuple[s: Session, i: int]) {.thread, gcsafe.} =
    var hb: JsonNode
    while not t.s.suspended:
        if t.s.Sequence == 0:
            hb = %*{"op": OP_HEARTBEAT, "d": nil}
        else:
            hb = %*{"op": OP_HEARTBEAT, "d": t.s.Sequence}
        try:
            echo "sending heartbeat"
            waitFor t.s.Connection.sock.sendText($hb, true)
        except:
            echo "error sending heartbeat, returning"
            return
        sleep t.i

proc handleDispatch(s: Session, event: string, data: JsonNode) =
    case event:
        of "READY":
            s.Session_id = data["session_id"].str
            s.State.version = int(data["v"].num)
            s.State.me = to[User]($data["user"])
            s.State.private_channels = to[seq[Channel]]($data["private_channels"])
            s.State.guilds = to[seq[Guild]]($data["guilds"])
        of "RESUMED":
            let payload = to[Resumed]($data)
            spawn s.onResume(s, payload)
        of "CHANNEL_CREATE":
            let payload = to[Channel]($data)
            spawn s.channelCreate(s, payload)
        of "CHANNEL_UPDATE":
            let payload = to[Channel]($data)
            spawn s.channelUpdate(s, payload)
        of "CHANNEL_DELETE":
            let payload = to[Channel]($data)
            spawn s.channelDelete(s, payload)
        of "GUILD_CREATE":
            let payload = to[Guild]($data)
            spawn s.guildCreate(s, payload)
        of "GUILD_UPDATE":
            let payload = to[Guild]($data)
            spawn s.guildUpdate(s, payload)
        of "GUILD_DELETE":
            let payload = to[GuildDelete]($data)
            spawn s.guildDelete(s, payload)
        of "GUILD_BAN_ADD":
            let payload = to[User]($data)
            spawn s.guildBanAdd(s, payload)
        of "GUILD_BAN_REMOVE":
            let payload = to[User]($data)
            spawn s.guildBanRemove(s, payload)
        of "GUILD_EMOJIS_UPDATE":
            let payload = to[GuildEmojisUpdate]($data)
            spawn s.guildEmojisUpdate(s, payload)
        of "GUILD_INTEGRATIONS_UPDATE":
            let payload = to[GuildIntegrationsUpdate]($data)
            spawn s.guildIntegrationsUpdate(s, payload)
        of "GUILD_MEMBER_ADD":
            let payload = to[GuildMember]($data)
            spawn s.guildMemberAdd(s, payload)
        of "GUILD_MEMBER_UPDATE":
            let payload = to[GuildMember]($data)
            spawn s.guildMemberUpdate(s, payload)
        of "GUILD_MEMBER_REMOVE":
            let payload = to[GuildMember]($data)
            spawn s.guildMemberRemove(s, payload)
        of "GUILD_ROLE_CREATE":
            let payload = to[GuildRoleCreate]($data)
            spawn s.guildRoleCreate(s, payload)
        of "GUILD_ROLE_UPDATE":
            let payload = to[GuildRoleUpdate]($data)
            spawn s.guildRoleUpdate(s, payload)
        of "GUILD_ROLE_DELETE":
            let payload = to[GuildRoleDelete]($data)
            spawn s.guildRoleDelete(s, payload)
        of "MESSAGE_CREATE":
            let payload = to[Message]($data)
            spawn s.messageCreate(s, payload)
        of "MESSAGE_UPDATE":
            let payload = to[Message]($data)
            spawn s.messageUpdate(s, payload)
        of "MESSAGE_DELETE":
            let payload = to[MessageDelete]($data)
            spawn s.messageDelete(s, payload)
        of "MESSAGE_DELETE_BULK":
            let payload = to[MessageDeleteBulk]($data)
            spawn s.messageDeleteBulk(s, payload)
        of "PRESENCE_UPDATE":
            let payload = to[PresenceUpdate]($data)
            spawn s.presenceUpdate(s, payload)
        of "TYPING_START":
            let payload = to[TypingStart]($data)
            spawn s.typingStart(s, payload)
        of "USER_UPDATE":
            let payload = to[User]($data)
            spawn s.userUpdate(s, payload)
        of "VOICE_STATE_UPDATE":
            let payload = to[VoiceState]($data)
            spawn s.voiceStateUpdate(s, payload)
        of "VOICE_SERVER_UPDATE":
            let payload = to[VoiceServerUpdate]($data)
            spawn s.voiceServerUpdate(s, payload)
        else:
            discard
    sync()

proc resume(s: Session) {.async, gcsafe.} =
    let payload = %*{
        "token": s.Token,
        "session_id": s.Session_ID,
        "seq": s.Sequence
    }

    await s.Connection.sock.sendText($payload, true)

proc reconnect(s: Session) {.async, gcsafe.} =
    await s.Connection.close()
    discard s.Connection
    s.Connection = await newAsyncWebsocket("gateway.discord.gg", Port 443, "/"&GATEWAYVERSION, ssl = true)
    s.Sequence = 0
    s.Session_ID = ""
    await s.identify()

method shouldResumeSession(s: Session): bool {.base.} =
    return (not s.invalidated) and (not s.suspended)

proc sessionHandleSocketMessage(s: Session) {.gcsafe, async, thread.}  = 
    await s.identify()
    var thread: array[0..1, Thread[(Session, int)]]
    while not isClosed(s.Connection.sock):
        let res = await s.Connection.readData(true)
            
        let data = parseJson(res.data)
 
        if data["s"].kind != JNull:
            s.Sequence = int(data["s"].num)
            
        case data["op"].num:
            of OP_HELLO:
                if s.shouldResumeSession():
                    await s.resume()
                else:
                    let interval = data["d"].fields["heartbeat_interval"].num
                    createThread(thread[0], startHeartbeats, (s, int(interval)))
                    joinThreads(thread)
            of OP_HEARTBEAT:
                let hb = %*{"op": OP_HEARTBEAT, "d": s.Sequence}
                waitFor s.Connection.sock.sendText($hb, true)
            of OP_INVALID_SESSION:
                s.Sequence = 0
                s.Session_ID = ""
                s.invalidated = true
                echo "session invalidated"
                if data["d"].bval == false:
                    await s.identify()
            of OP_RECONNECT:
                s.suspended = true
                await s.reconnect()
            of OP_DISPATCH:
                let event = data["t"].str
                handleDispatch(s, event, data["d"])
            else:
                echo $data
    echo "connection closed\c\L" 
    s.suspended = true
    return

proc SessionStart*(s: Session){.async, gcsafe.} =
    ## Starts a Session
    if s.Connection != nil:
        echo "Session is already connected"
        return
    s.suspended = true
    try:
        let socket = await newAsyncWebsocket("gateway.discord.gg", Port 443, "/"&GATEWAYVERSION, ssl = true)
        echo "connected"
        s.Connection = socket
        s.Sequence = 0 
        asyncCheck sessionHandleSocketMessage(s)
    except:
        echo getCurrentExceptionMsg()
        return


# Helper functions

proc newMessageEmbed*(title, description: string = "", 
                      color: int = 0, footer: Footer = nil,
                      image: Image = nil, thumb: Thumbnail = nil,
                      video: Video = nil,
                      provider: Provider = nil,
                      author: Author = nil, fields: seq[Field] = @[]): Embed {.gcsafe.} =
    ## Initialises a new Embed object
    result = Embed(
        title: title,
        description: description,
        color: color,
        footer: footer,
        image: image,
        thumbnail: thumb,
        video: video,
        provider: provider,
        author: author,
        fields: fields
    )

proc `$`*(u: User): string {.gcsafe, inline.} =
    ## Stringifies a user 
    ## e.g: Username#1234
    result = u.username & "#" & u.discriminator

proc StripMentions*(msg: Message): string {.gcsafe.} =  
    ## Strips all user mentions from a message
    ## and replaces them with plaintext
    ## e.g: <@1901092738173> -> @Username#1234
    if msg.mentions == nil: return msg.content

    var content = msg.content

    for user in msg.mentions:
        let regex = r"<@!?(" & user.id & ")>"
        content = content.replace(regex, "@" & $user)
    result = content

proc StripEveryoneMention*(msg: Message): string {.gcsafe.} =
    ## Strips a message of any @everyone and @here mention
    if not msg.mention_everyone: return msg.content
    result = msg.content.replace("(@everyone)").replace("(@here)")