include endpoints
import httpclient, marshal, json, 
       locks, tables, times, strutils,
       os, typetraits, websocket/shared, asyncdispatch, asyncnet, threadpool
type
    Overwrite* = object
        id*: string
        `type`*: string
        allow*: int
        deny*: int
    DiscordChannel* = object
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
        recipient*: User
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
    Thumbnail* = object
        url*: string
        proxy_url*: string
        height*: int
        width*: int
    Video* = object
        url*: string
        height*: int
        width*: int
    Image* = object
        url*: string
        proxy_url*: string
        height*: int
        width*: int
    Provider* = object
        name*: string
        url*: string
    Author* = object
        name*: string
        url*: string
        icon_url*: string
        proxy_icon_url*: string
    Footer* = object
        text*: string
        icon_url*: string
        proxy_icon_url*: string
    Field* = object
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
        channels*: seq[DiscordChannel]
        presences*: seq[Presence]
        application_id*: string
    GuildMember* = object
        guild_id*: string
        user*: User
        nick*: string
        roles*: seq[Role]
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
    Session* = ref object
        Mut*: Lock
        Token*: string
        Compress*: bool
        ShardID*: int
        ShardCount*: int
        Sequence*: int
        Gateway*: string
        Session_ID*: string
        Limiter*: ref RateLimiter   
        Connection*: AsyncWebSocket
        Closed*: bool
        CurrentMsg*: string
        # Temporary until better solution is found
        channelCreate*:           proc(s: Session, p: DiscordChannel)
        channelUpdate*:           proc(s: Session, p: DiscordChannel)
        channelDelete*:           proc(s: Session, p: DiscordChannel)
        guildCreate*:             proc(s: Session, p: Guild)
        guildUpdate*:             proc(s: Session, p: Guild)
        guildDelete*:             proc(s: Session, p: GuildDelete)
        guildBanAdd*:             proc(s: Session, p: User)
        guildBanRemove*:          proc(s: Session, p: User)
        guildEmojisUpdate*:       proc(s: Session, p: GuildEmojisUpdate)
        guildIntegrationsUpdate*: proc(s: Session, p: GuildIntegrationsUpdate)
        guildMemberAdd*:          proc(s: Session, p: GuildMember)
        guildMemberUpdate*:       proc(s: Session, p: GuildMember)
        guildMemberRemove*:       proc(s: Session, p: GuildMember)
        guildRoleCreate*:         proc(s: Session, p: GuildRoleCreate)
        guildRoleUpdate*:         proc(s: Session, p: GuildRoleUpdate)
        guildRoleDelete*:         proc(s: Session, p: GuildRoleDelete)
        messageCreate*:           proc(s: Session, p: Message)
        messageUpdate*:           proc(s: Session, p: Message)
        messageDelete*:           proc(s: Session, p: MessageDelete)
        messageDeleteBulk*:       proc(s: Session, p: MessageDeleteBulk)
        presenceUpdate*:          proc(s: Session, p: PresenceUpdate)
        typingStart*:             proc(s: Session, p: TypingStart)
        userUpdate*:              proc(s: Session, p: User)
        voiceStateUpdate*:        proc(s: Session, p: VoiceState)
        voiceServerUpdate*:       proc(s: Session, p: VoiceServerUpdate)
    RateLimiter* = object
        Mut: Lock
        Global: ref Bucket
        Buckets: Table[string, ref Bucket]
        GlobalRateLimit: TimeInterval#TimeInterval
    Bucket* = object
        Mut: Lock
        Key: string
        Remaining: int
        Limit: int
        Reset: TimeInfo
        Global: ref Bucket
    
    





# Gateway payloads

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

type 
    DiscordError* = enum
        ERR_UNKNOWN = (4000, "We're not sure what went wrong. Try reconnecting?")
        ERR_UNKNOWN_OPCODE = (4001, "You sent and invalid Gateway OP Code. Don't do that!")
        ERR_DECODE_ERROR = (4002, "You send an invalid payload to us. Don't do that!")
        ERR_NOT_AUTHENTICATED = (4003, "You send us a payload prior to identifying.")
        ERR_AUTHENTICATION_FAILED = (4004, "The acoount token sent with your identify payload is incorrect.")
        ERR_ALREAD_AUTHENTICATED = (4005, "You send more than one identify payload. Don't do that!")
        ERR_INVALID_SEQ = (4007, "The sequence sent when resuming the session was invalid. Reconnect and start a new session.")
        ERR_RATE_LIMITED = (4008, "Woah nelly! You're sending payloads to us too quickly. Slow it down!")
        ERR_SESSION_TIMEOUT = (4009, "Your session timed out. Reconnect and start a new one.")
        ERR_INVALID_SHARD = (4010, "You sent us an invalid shard when identifying.")
        ERR_SHARDING_REQUIRED = (4011, "The session would have handled too many guilds - you are required to shard your connection in order to connect.")

type
    WSIdentify* = ref object
        Token*: string
        Properties*: JsonNode
        Compress*: bool
        Large_threshold*: int
        Shard*: seq[int]
    WSRequestGuildMembers* = ref object
        Guild_id*: string
        Query*: string
        Limit*: int
    WSResume* = ref object
        Token*: string
        Session_id*: string
        Seq*: int
    WSStatusUpdate* = ref object
        Idle_since*: int
        Game*: Game
    
    WSVoiceStateUpdate* = ref object
        Guild_id*: string
        Channel_id*: string
        Self_mute*: bool
        Self_deaf*: bool



# Permissions

const
    CREATE_INSTANT_INVITE = 0x00000001
    KICK_MEMBERS = 0x00000002
    BAN_MEMBERS = 0x00000004
    ADMINISTRATOR = 0x00000008
    MANAGE_CHANNELS = 0x00000010
    MANAGE_GUILD = 0x00000020
    ADD_REACTIONS = 0x00000040
    READ_MESSAGES = 0x00000400
    SEND_MESSAGES = 0x00000800
    SEND_TTS_MESSAGES = 0x00001000
    MANAGE_MESSAGES = 0x00002000
    EMBED_LINKS = 0x00004000
    ATTACH_FILES = 0x00008000
    READ_MESSAGE_HISTORY = 0x00010000
    MENTION_EVERYONE = 0x00020000
    USE_EXTERNAL_EMOJIS = 0x00040000
    CONNECT = 0x00100000
    SPEAK = 0x00200000
    MUTE_MEMBERS = 0x00400000
    DEAFEN_MEMBERS = 0x00800000
    MOVE_MEMBERS = 0x01000000
    USE_VAD = 0x02000000
    CHANGE_NICKNAME = 0x04000000
    MANAGE_NICKNAMES = 0x08000000
    MANAGE_ROLES = 0x10000000
    MANAGE_WEBHOOKS = 0x20000000
    MANAGE_EMOJIS = 0x40000000

proc newRateLimiter*(): ref RateLimiter =
    let b = new(Bucket)
    b[] = Bucket(Mut: Lock(), Key: "global", Reset: getLocalTime(fromSeconds(epochTime())))
    var rl = new(RateLimiter)
    rl[]= RateLimiter(Mut: Lock(), Buckets: initTable[string, ref Bucket](), Global: b)
    return rl

method getBucket*(r: ref RateLimiter, key: string): ref Bucket {.base.} =
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

method lockBucket*(r : ref RateLimiter, bid : string): ref Bucket {.base.} =
    var b = r.getBucket(bid)

    initLock(b.Mut)

    if b.Remaining < 1 and toTime(b.Reset) - getTime() > 0:
        sleep int32(toTime(b.Reset) - getTime())

    initLock(r.Global.Mut)
    deinitLock(r.Global.Mut)
    return b

proc sleepUntil*(pa : int32, b : ref Bucket) =
    var sleepTo = getTime() + pa.seconds
    initLock(b.Global.Mut)

    var sleepdur = sleepTo - getTime()

    if sleepdur > 0:
        sleep(int32(sleepdur))

    deinitLock(b.Global.Mut)
    return

method Release*(b : ref Bucket, headers : HttpHeaders) {.base.} =
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

method Request(s : Session, bucketid: var string, meth, url, contenttype, b : string, sequence : int): Response {.base.} =
    var client = newHttpClient("DiscordBot(https://github.com/Krognol/discord-nim, v0.0.1)")
    
    if bucketid == "":
        bucketid = split(url, "?", 2)[0]

    var bucket = s.Limiter.lockBucket(bucketid)

    if s.Token != "" and s.Token != nil:
        client.headers["Authorization"] = s.Token

    client.headers["Content-Type"] = contenttype
    var res: Response = cast[Response](client.request(url, meth, b))

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

method Login*(s : Session, email, password : string) {.base.} =
    var payload = %*{"email": email, "password": password}
    var id = EndpointLogin()
    let res = s.Request(id, "POST", id, "application/json", $payload, 0)
    type Temp = object
        Token: string

    var t = to[Temp](res.body)
    s.Token = t.Token
    return 

method initEvents(s: Session) {.base.} =
    s.channelCreate =           proc(s: Session, p: DiscordChannel) = return
    s.channelUpdate =           proc(s: Session, p: DiscordChannel) = return
    s.channelDelete =           proc(s: Session, p: DiscordChannel) = return
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


proc NewSession*(args: varargs[string, `$`]): Session =
    var 
        s = Session(Mut: Lock(), Compress: false, Limiter: newRateLimiter())
        auth: string = ""
        pass: string = ""
    
    for arg in args:
        case arg.type.name:
            of "string":
                if auth == "":
                    auth = arg
                elif pass == "":
                    pass = arg
                elif s.Token == "":
                    s.Token = arg
            else: 
                echo "Invalid type"
                return

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

method Channel*(s: Session, chan: string): DiscordChannel {.base.} =
    var url = EndpointGetChannel(chan)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let chan = to[DiscordChannel](res.body)
    return chan

method ModifyChannel*(s: Session, channelid: string, channel: ChannelParams): Guild {.base.} =
    var url = EndpointModifyChannel(channelid)
    let res = s.Request(url, "PATCH", url, "application/json", $$channel, 0)
    let guild = to[Guild](res.body)
    return guild

method DeleteChannel*(s: Session, channel: string): DiscordChannel {.base.} =
    var url = EndpointDeleteChannel(channel)
    let res = s.Request(url, "DELETE", url, "application/json", "", 0)
    let chan = to[DiscordChannel](res.body)
    return chan

method ChannelMessages*(s: Session, channel: string): seq[Message] {.base.} =
    var url = EndpointGetChannelMessages(channel)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let msgs = to[seq[Message]](res.body)
    return msgs

method ChannelMessage*(s: Session, channel, message: string): Message {.base.} =
    var url = EndpointGetChannelMessage(channel, message)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let msg = to[Message](res.body)
    return msg

method SendMessage*(s: Session, channel, message: string): Message {.base.} =
    var url = EndpointCreateMessage(channel)
    let payload = %*{"content": message}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    let msg = to[Message](res.body)
    return msg

method SendMessageEmbed*(s: Session, channel: string, embed: var Embed): Message {.base.} =
    var url = EndpointCreateMessage(channel)
    let empty = Embed()
    if embed == empty:
        echo "Can't send an empty embed"
        return
    
    if embed.type != "rich":
        embed.type = "rich"

    let payload = %*{"embed": embed}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    let msg = to[Message](res.body)
    return msg

method SendMessageTTS*(s: Session, channel, message: string): Message {.base.} =
    var url = EndpointCreateMessage(channel)
    let payload = %*{"content": message, "tts": true}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    let msg = to[Message](res.body)
    return msg

# TODO
#method SendFile()

method MessageAddReaction*(s: Session, channelid, messageid, emojiid: string) {.base.} =
    var url = EndpointCreateReaction(channelid, messageid, emojiid)
    discard s.Request(url, "PUT", url, "application/json", "", 0)

method MessageDeleteOwnReaction*(s: Session, channelid, messageid, emojiid: string) {.base.} =
    var url = EndpointDeleteOwnReaction(channelid, messageid, emojiid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method MessageDeleteReaction*(s: Session, channelid, messageid, emojiid, userid: string) {.base.} =
    var url = EndpointDeleteUserReaction(channelid, messageid, emojiid, userid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method MessageGetReactions*(s: Session, channelid, messageid, emojiid: string): seq[User] {.base.} =
    var url = EndpointGetMessageReactions(channelid, messageid, emojiid)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let users = to[seq[User]](res.body)
    return users

method MessageDeleteAllReactions*(s: Session, channelid, messageid: string) {.base.} =
    var url = EndpointDeleteAllReactions(channelid, messageid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method EditMessage*(s: Session, channelid, messageid, content: string): Message {.base.} =
    var url = EndpointEditMessage(channelid, messageid)
    let payload = %*{"content": content}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    let msg = to[Message](res.body)
    return msg

method DeleteMessage*(s: Session, channelid, messageid: string) {.base.} =
    var url = EndpointDeleteMessage(channelid, messageid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method BulkDeleteMessages*(s: Session, channelid: string, messages: seq[string]) {.base.} =
    var url = EndpointBulkDelete(channelid)
    let payload = %*{"messages": $messages}
    discard s.Request(url, "DELETE", url, "application/json", $payload, 0)

method EditChannelPermissions*(s: Session, channelid: string, overwrite: Overwrite) {.base.} =
    var url = EndpointEditChannelPermissions(channelid, overwrite.id)
    discard s.Request(url, "PUT", url, "application/json", $$overwrite, 0)

method ChannelInvites*(s: Session, channel: string): seq[Invite] {.base.} =
    var url = EndpointGetChannelInvites(channel)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let invites = to[seq[Invite]](res.body)
    return invites

method CreateChannelInvite*(s: Session, channel: string, max_age, max_uses: int, temp, unique: bool): Invite {.base.} =
    var url = EndpointCreateChannelInvite(channel)
    let payload = %*{"max_age": max_age, "max_uses": max_uses, "temp": temp, "unique": unique}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    let invite = to[Invite](res.body)
    return invite

method DeleteChannelPermission*(s: Session, channel, target: string) {.base.} =
    var url = EndpointDeleteChannelPermission(channel, target)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method TriggerTypingIndicator*(s: Session, channel: string) {.base.} =
    var url = EndpointTriggerTypingIndicator(channel)
    discard s.Request(url, "POST", url, "application/json", "", 0)

method ChannelPinnedMessages*(s: Session, channel: string): seq[Message] {.base.} =
    var url = EndpointGetPinnedMessages(channel)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let msgs = to[seq[Message]](res.body)
    return msgs

method ChannelPinMessage*(s: Session, channel, message: string) {.base.} =
    var url = EndpointAddPinnedChannelMessage(channel, message)
    discard s.Request(url, "PUT", url, "application/json", "", 0)

method ChannelDeletePinnedMessage*(s: Session, channel, message: string) {.base.} =
    var url = EndpointDeletePinnedChannelMessage(channel, message)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

#TODO
#method GroupDMAddUser()

#TODO
#method GroupdDMRemoveUser()

method CreateGuild*(s: Session, name: string): Guild {.base.} =
    var url = EndpointCreateGuild()
    let payload = %*{"name": name}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    let guild = to[Guild](res.body)
    return guild

method GetGuild*(s: Session, id: string): Guild {.base.} =
    var url = EndpointGetGuild(id)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let guild = to[Guild](res.body)
    return guild

method ModifyGuild*(s: Session, guild: string, settings: GuildParams): Guild {.base.} =
    var url = EndpointModifyGuild(guild)
    let res = s.Request(url, "PATCH", url, "application/json", $$settings, 0)
    let guild = to[Guild](res.body)
    return guild

method DeleteGuild*(s: Session, guild: string): Guild {.base.} =
    var url = EndpointDeleteGuild(guild)
    let res = s.Request(url, "DELETE", url, "application/json", "", 0)
    let guild = to[Guild](res.body)
    return guild

method GuildChannels*(s: Session, guild: string): seq[DiscordChannel] {.base.} =
    var url = EndpointGetGuildChannels(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let channels = to[seq[DiscordChannel]](res.body)
    return channels

method GuildChannelCreate*(s: Session, guild, channelname: string, voice: bool): DiscordChannel {.base.} =
    var url = EndpointCreateGuildChannel(guild)
    let payload = %*{"name": channelname, "voice": voice}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    let channel = to[DiscordChannel](res.body)
    return channel

method ModifyGuildChannelPosition*(s: Session, guild, channel: string, position: int): seq[DiscordChannel] {.base.} =
    var url = EndpointModifyGuildChannelPositions(guild)
    let payload = %*{"id": channel, "position": position}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    let channels = to[seq[DiscordChannel]](res.body)
    return channels

method GuildMembers*(s: Session, guild: string, limit, after: int): seq[GuildMember] {.base.} =
    var url = EndpointListGuildMembers(guild) & "?"

    if limit > 1:
        url = url & "limit=" & $limit & "&"
    if after > 0:
        url = url & "after=" & $after & "&"

    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let members = to[seq[GuildMember]](res.body)
    return members

method GetGuildMember*(s: Session, guild, userid: string): GuildMember {.base.} =
    var url = EndpointGetGuildMember(guild, userid)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let member = to[GuildMember](res.body)
    return member

method GuildMemberAdd*(s: Session, guild, userid, accesstoken: string): GuildMember {.base.} =
    var url = EndpointAddGuildMember(guild, userid)
    let payload = %*{"access_token": accesstoken}
    let res = s.Request(url, "PUT", url, "application/json", $payload, 0)
    let member = to[GuildMember](res.body)
    return member

method GuildMemberRoles*(s: Session, guild, userid: string, roles: seq[string]) {.base.} =
    var url = EndpointModifyGuildMember(guild, userid)
    let payload = %*{"roles": $roles}
    discard s.Request(url, "PATCH", url, "application/json", $payload, 0)

method GuildMemberNick*(s: Session, guild, userid, nick: string) {.base.} =
    var url = EndpointModifyGuildMember(guild, userid)
    let payload = %*{"nick": nick}
    discard s.Request(url, "PATCH", url, "application/json", $payload, 0)

method GuildMemberMute*(s: Session, guild, userid: string, mute: bool) {.base.} =
    var url = EndpointModifyGuildMember(guild, userid)
    let payload = %*{"mute": mute}
    discard s.Request(url, "PATCH", url, "application/json", $payload, 0)

method GuildMemberDeafen*(s: Session, guild, userid: string, deafen: bool) {.base.} =
    var url = EndpointModifyGuildMember(guild, userid)
    let payload = %*{"deaf": deafen}
    discard s.Request(url, "PATCH", url, "application/json", $payload, 0)

method GuildMemberMove*(s: Session, guild, userid, channel: string) {.base.} =
    var url = EndpointModifyGuildMember(guild, userid)
    let payload = %*{"channel_id": channel}
    discard s.Request(url, "PATCH", url, "application/json", $payload, 0)

method Nick*(s: Session, guild, nick: string) {.base.} =
    var url = EndpointModifyNick(guild)
    let payload = %*{"nick": nick}
    discard s.Request(url, "PATCH", url, "application/json", $payload, 0)

method GuildMemberAddRole*(s: Session, guild, userid, roleid: string) {.base.} =
    var url = EndpointAddGuildMemberRole(guild, userid, roleid)
    discard s.Request(url, "PUT", url, "application/json", "", 0)

method GuildMemberRemoveRole*(s: Session, guild, userid, roleid: string) {.base.} =
    var url = EndpointRemoveGuildMemberRole(guild, userid, roleid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method GuildMemberRemove*(s: Session, guild, userid: string) {.base.} =
    var url = EndpointRemoveGuildMember(guild, userid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method GuildBans*(s: Session, guild: string): seq[User] {.base.} =
    var url = EndpointGetGuildBans(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let users = to[seq[User]](res.body)
    return users

method GuildBanUser*(s: Session, guild, userid: string) {.base.} =
    var url = EndpointCreateGuildBan(guild, userid)
    discard s.Request(url, "PUT", url, "application/json", "", 0)

method GuildBanRemove*(s: Session, guild, userid: string) {.base.} =
    var url = EndpointRemoveGuildBan(guild, userid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method GuildRoles*(s: Session, guild: string): seq[Role] {.base.} =
    var url = EndpointGetGuildRoles(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let roles = to[seq[Role]](res.body)
    return roles

method GuildRoleCreateP*(s: Session, guild: string): Role {.base.} =
    var url = EndpointCreateGuildRole(guild)
    let res = s.Request(url, "POST", url, "application/json", "", 0)
    let role = to[Role](res.body)
    return role

method GuildRoleEditPosition*(s: Session, guild: string, roles: seq[Role]): seq[Role] {.base.} =
    var url = EndpointModifyGuildRolePositions(guild)
    let res = s.Request(url, "PATCH", url, "application/json", $$roles, 0)
    let nroles = to[seq[Role]](res.body)
    return nroles

method GuildRoleEdit*(s: Session, guild, roleid, name: string, permissions, color: int, hoist, mentionable: bool): Role {.base.} =
    var url = EndpointModifyGuildRole(guild, roleid)
    let payload = %*{"name": name, "permissions": permissions, "color": color, "hoist": hoist, "mentionable": mentionable}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    let role = to[Role](res.body)
    return role

method GuildRoleDeleteP*(s: Session, guild, roleid: string) {.base.} =
    var url = EndpointDeleteGuildRole(guild, roleid)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method GuildPruneCount*(s: Session, guild: string, days: int): int {.base.} =
    var url = EndpointGetGuildPruneCount(guild) & "?days=" & $days
    let res = s.Request(url, "GET", "", "application/json", "", 0)

    type temp = ref object
        pruned: int

    let t = to[temp](res.body)
    return t.pruned

method GuildPruneBegin*(s: Session, guild: string, days: int): int {.base.} =
    var url = EndpointBeginGuildPruneCount(guild) & "?days=" & $days
    let res = s.Request(url, "POST", "", "application/json", "", 0)

    type temp = ref object
        pruned: int

    let t = to[temp](res.body)
    return t.pruned

method GuildVoiceRegions*(s: Session, guild: string): seq[VoiceRegion] {.base.} =
    var url = EndpointGetGuildVoiceRegions(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let regions = to[seq[VoiceRegion]](res.body)
    return regions

method GuildInvites*(s: Session, guild: string): seq[Invite] {.base.} =
    var url = EndpointGetGuildInvites(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let invites = to[seq[Invite]](res.body)
    return invites

method GuildIntegrations*(s: Session, guild: string): seq[Integration] {.base.} =
    var url = EndpointGetGuildIntegrations(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let intgr = to[seq[Integration]](res.body)
    return intgr

method GuildIntegrationCreate*(s: Session, guild, typ, id: string) {.base.} =
    var url = EndpointGetGuildIntegrations(guild)
    let payload = %*{"type": typ, "id": id}
    discard s.Request(url, "POST", url, "application/json", $payload, 0)

method GuildIntegrationEdit*(s: Session, guild, integrationid: string, behaviour, grace: int, emotes: bool) {.base.} =
    var url = EndpointModifyGuildIntegration(guild, integrationid)
    let payload = %*{"expire_behavior": behaviour, "expire_grace_period": grace, "enable_emoticons": emotes}
    discard s.Request(url, "PATCH", url, "application/json", $payload, 0)

method GuildIntegrationDelete*(s: Session, guild, integration: string) {.base.} =
    var url = EndpointDeleteGuildIntegration(guild, integration)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method GuildIntegrationSync*(s: Session, guild, integration: string) {.base.} =
    var url = EndpointSyncGuildIntegration(guild, integration)
    discard s.Request(url, "POST", url, "application/json", "", 0)

method GetGuildEmbed*(s: Session, guild: string): GuildEmbed {.base.} =
    var url = EndpointGetGuildEmbed(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let embed = to[GuildEmbed](res.body)
    return embed

method GuildEmbedEdit*(s: Session, guild: string, enabled: bool, channel: string): GuildEmbed {.base.} =
    var url = EndpointModifyGuildEmbed(guild)
    let embed = GuildEmbed(enabled: enabled, channel_id: channel)
    let res = s.Request(url, "PATCH", url, "application/json", $$embed, 0)
    let nembed = to[GuildEmbed](res.body)
    return nembed

method GetInvite*(s: Session, code: string): Invite {.base.} =
    var url = EndpointGetInvite(code)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let invite = to[Invite](res.body)
    return invite

method InviteDelete*(s: Session, code: string): Invite {.base.} =
    var url = EndpointDeleteInvite(code)
    let res = s.Request(url, "DELETE", url, "application/json", "", 0)
    let invite = to[Invite](res.body)
    return invite

method Me*(s: Session): User {.base.} =
    var url = EndpointGetCurrentUser()
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let user = to[User](res.body)
    return user

method GetUser*(s: Session, userid: string): User {.base.} =
    var url = EndpointGetUser(userid)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let user = to[User](res.body)
    return user

method EditUsername*(s: Session, name: string): User {.base.} =
    var url = EndpointGetCurrentUser()
    let payload = %*{"username": name}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    let user = to[User](res.body)
    return user

method EditAvatar*(s: Session, avatar: string): User {.base.} =
    var url = EndpointGetCurrentUser()
    let payload = %*{"avatar": avatar}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    let user = to[User](res.body)
    return user

method Guilds*(s: Session): seq[UserGuild] {.base.} =
    var url = EndpointGetCurrentUserGuilds()
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let guilds = to[seq[UserGuild]](res.body)
    return guilds

method LeaveGuild*(s: Session, guild: string) {.base.} =
    var url = EndpointLeaveGuild(guild)
    discard s.Request(url, "DELETE", url, "application/json", "", 0)

method DMs*(s: Session): seq[DiscordChannel] {.base.} =
    var url = EndpointGetUserDMs()
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let channels = to[seq[DiscordChannel]](res.body)
    return channels

method DMCreate*(s: Session, recipient: string): DiscordChannel {.base.} =
    var url = EndpointCreateDM()
    let payload = %*{"recipient_id": recipient}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    let channel = to[DiscordChannel](res.body)
    return channel

method VoiceRegions*(s: Session): seq[VoiceRegion] {.base.} =
    var url = EndpointListVoiceRegions()
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let regions = to[seq[VoiceRegion]](res.body)
    return regions

method WebhookCreate*(s: Session, channel, name, avatar: string): Webhook {.base.} =
    var url = EndpointCreateWebhook(channel)
    let payload = %*{"name": name, "avatar": avatar}
    let res = s.Request(url, "POST", url, "application/json", $payload, 0)
    let webhook = to[Webhook](res.body)
    return webhook

method ChannelWebhooks*(s: Session, channel: string): seq[Webhook] {.base.} =
    var url = EndpointGetChannelWebhooks(channel)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let hooks = to[seq[Webhook]](res.body)
    return hooks

method GuildWebhooks*(s: Session, guild: string): seq[Webhook] {.base.} =
    var url = EndpointGetGuildWebhook(guild)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let hooks = to[seq[Webhook]](res.body)
    return hooks

method GetWebhookWithToken*(s: Session, webhook, token: string): Webhook {.base.} =
    var url = EndpointGetWebhookWithToken(webhook, token)
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    let hook = to[Webhook](res.body)
    return hook

method WebhookEdit*(s: Session, webhook, name, avatar: string): Webhook {.base.} =
    var url = EndpointModifyWebhook(webhook)
    let payload = %*{"name": name, "avatar": avatar}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    let hook = to[Webhook](res.body)
    return hook

method WebhookEditWithToken*(s: Session, webhook, token, name, avatar: string): Webhook {.base.} =
    var url = EndpointModifyWebhookWithToken(webhook, token)
    let payload = %*{"name": name, "avatar": avatar}
    let res = s.Request(url, "PATCH", url, "application/json", $payload, 0)
    let hook = to[Webhook](res.body)
    return hook

method WebhookDelete*(s: Session, webhook: string): Webhook {.base.} =
    var url = EndpointDeleteWebhook(webhook)
    let res = s.Request(url, "DELETE", url, "application/json", "", 0)
    let hook = to[Webhook](res.body)
    return hook

method WebhookDeleteWithToken*(s: Session, webhook, token: string): Webhook {.base.} =
    var url = EndpointDeleteWebhookWithToken(webhook, token)
    let res = s.Request(url, "DELETE", url, "application/json", "", 0)
    let hook = to[Webhook](res.body)
    return hook

method ExecuteWebhook*(s: Session, webhook, token: string, wait: bool, payload: WebhookParams) {.base.} =
    var url = EndpointExecuteWebhook(webhook, token)
    discard s.Request(url, "POST", url, "application/json", $$payload, 0)

#TODO
# method ExecuteSlackCompatibleWebhook()

#TODO
# method ExecuteGithubCompatibleWebhook()


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
        return
    return

proc startHeartbeats(t: tuple[s: Session, i: int]) {.thread, gcsafe.} =
    var hb: JsonNode
    while true:
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
        of "CHANNEL_CREATE":
            let payload = to[DiscordChannel]($data)
            s.channelCreate(s, payload)
        of "CHANNEL_UPDATE":
            let payload = to[DiscordChannel]($data)
            s.channelUpdate(s, payload)
        of "CHANNEL_DELETE":
            let payload = to[DiscordChannel]($data)
            s.channelDelete(s, payload)
        of "GUILD_CREATE":
            let payload = to[Guild]($data)
            s.guildCreate(s, payload)
        of "GUILD_UPDATE":
            let payload = to[Guild]($data)
            s.guildUpdate(s, payload)
        of "GUILD_DELETE":
            let payload = to[GuildDelete]($data)
            s.guildDelete(s, payload)
        of "GUILD_BAN_ADD":
            let payload = to[User]($data)
            s.guildBanAdd(s, payload)
        of "GUILD_BAN_REMOVE":
            let payload = to[User]($data)
            s.guildBanRemove(s, payload)
        of "GUILD_EMOJIS_UPDATE":
            let payload = to[GuildEmojisUpdate]($data)
            s.guildEmojisUpdate(s, payload)
        of "GUILD_INTEGRATIONS_UPDATE":
            let payload = to[GuildIntegrationsUpdate]($data)
            s.guildIntegrationsUpdate(s, payload)
        of "GUILD_MEMBER_ADD":
            let payload = to[GuildMember]($data)
            s.guildMemberAdd(s, payload)
        of "GUILD_MEMBER_UPDATE":
            let payload = to[GuildMember]($data)
            s.guildMemberUpdate(s, payload)
        of "GUILD_MEMBER_REMOVE":
            let payload = to[GuildMember]($data)
            s.guildMemberRemove(s, payload)
        of "GUILD_ROLE_CREATE":
            let payload = to[GuildRoleCreate]($data)
            s.guildRoleCreate(s, payload)
        of "GUILD_ROLE_UPDATE":
            let payload = to[GuildRoleUpdate]($data)
            s.guildRoleUpdate(s, payload)
        of "GUILD_ROLE_DELETE":
            let payload = to[GuildRoleDelete]($data)
            s.guildRoleDelete(s, payload)
        of "MESSAGE_CREATE":
            let payload = to[Message]($data)
            s.messageCreate(s, payload)
        of "MESSAGE_UPDATE":
            let payload = to[Message]($data)
            s.messageUpdate(s, payload)
        of "MESSAGE_DELETE":
            let payload = to[MessageDelete]($data)
            s.messageDelete(s, payload)
        of "MESSAGE_DELETE_BULK":
            let payload = to[MessageDeleteBulk]($data)
            s.messageDeleteBulk(s, payload)
        of "PRESENCE_UPDATE":
            let payload = to[PresenceUpdate]($data)
            s.presenceUpdate(s, payload)
        of "TYPING_START":
            let payload = to[TypingStart]($data)
            s.typingStart(s, payload)
        of "USER_UPDATE":
            let payload = to[User]($data)
            s.userUpdate(s, payload)
        of "VOICE_STATE_UPDATE":
            let payload = to[VoiceState]($data)
            s.voiceStateUpdate(s, payload)
        of "VOICE_SERVER_UPDATE":
            let payload = to[VoiceServerUpdate]($data)
            s.voiceServerUpdate(s, payload)
        else:
            discard

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
                let interval = data["d"].fields["heartbeat_interval"].num
                createThread(thread[0], startHeartbeats, (s, int(interval)))
            of OP_HEARTBEAT:
                let hb = %*{"op": OP_HEARTBEAT, "d": s.Sequence}
                waitFor s.Connection.sock.sendText($hb, true)
            of OP_INVALID_SESSION:
                s.Sequence = 0
                s.Session_ID = ""
                echo "session invalidated"
                if data["d"].bval == false:
                    await s.identify()
            of OP_DISPATCH:
                let event = data["t"].str
                handleDispatch(s, event, data["d"])
            else: 
                echo $data
    echo "connection closed\c\L" 
    return

proc SessionStart*(s: Session){.async, gcsafe.} =
    if s.Connection != nil:
        echo "Session is already connected"
        return
    
    try:
        let socket = await newAsyncWebsocket("gateway.discord.gg", Port 443, "/"&GATEWAYVERSION, ssl = true)
        echo "connected"
        s.Connection = socket
        s.Sequence = 0 
        asyncCheck sessionHandleSocketMessage(s)
    except:
        echo getCurrentExceptionMsg()
        return
