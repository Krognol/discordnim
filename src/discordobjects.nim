import json, tables, locks, websocket/client, times, httpclient, strutils, asyncdispatch, marshal, sequtils
{.hint[XDeclaredButNotUsed]: off.}

type 
    RateLimit = ref object
        lock: Lock
        reset: int64
        limit: int64
        remaining: int64
    RateLimits = ref object of RootObj
        lock: Lock
        global: RateLimit
        endpoints: Table[string, RateLimit]

method preCheck(r: RateLimit) {.async, gcsafe, base.} =
    if r.limit == 0: return
    
    let diff = r.reset - getTime().toSeconds.int64
    if diff < 0:
        r.reset += 3
        r.remaining = r.limit
        return
    
    if r.remaining <= 0:
        let delay = diff * 1000+900
        await sleepAsync delay.int
        return
    
    r.remaining.dec

method postUpdate(r: RateLimit, url: string, response: AsyncResponse): Future[bool] {.async, gcsafe, base.} =
    if response.headers.hasKey("X-RateLimit-Reset"): r.reset = response.headers["X-RateLimit-Reset"].parseInt
    if response.headers.hasKey("X-RateLimit-Limit"): r.limit = response.headers["X-RateLimit-Limit"].parseInt
    if response.headers.hasKey("X-RateLimit-Remaining"): r.remaining = response.headers["X-RateLimit-Remaining"].parseInt

    if response.code == Http429:
        let delay = if response.headers.hasKey("Retry-After"): response.headers["Retry-After"].parseInt else: -1
        if delay == -1: return false

        await sleepAsync delay+100
        result = true

method postUpdate(r: RateLimits, url: string, response: AsyncResponse): Future[bool] {.async, gcsafe, base.} =
    if response.headers.hasKey("X-RateLimit-Global"):
        initLock(r.global.lock)
        result = await r.global.postUpdate(url, response)
        deinitLock(r.global.lock)
    else:
        let rl = if r.endpoints.hasKey(url): r.endpoints[url] else: RateLimit(lock: Lock(), reset: 0, limit: 0, remaining: 0)
        initLock(rl.lock)
        result = await rl.postUpdate(url, response)
        deinitLock(rl.lock)

method preCheck(r: RateLimits, url: string) {.async, gcsafe, base.} =
    initLock(r.global.lock)
    await r.global.preCheck()
    deinitLock(r.global.lock)

    if r.endpoints.hasKey(url):
        let rl = r.endpoints[url]
        initLock(rl.lock)
        await rl.preCheck()
        deinitLock(rl.lock)

proc newRateLimiter(): RateLimits {.inline.} =
    result = RateLimits(
        lock: Lock(),
        global: RateLimit(
            lock: Lock(),
            reset: 0, 
            limit: 0,
            remaining: 0
        ),
        endpoints: initTable[string, RateLimit]()
    )
    
const
    auditGuildUpdate* = 1
    auditChannelCreate* = 10
    auditChannelUpdate* = 11
    auditChannelDelete* = 12
    auditChannelOverwriteCreate* = 13
    auditChannelOverwriteUpdate* = 14
    auditChannelOverwriteDelete* = 15
    auditMemberKick* = 20
    auditMemberPrune* = 21
    auditMemberBanAdd* = 22
    auditMemberBanRemove* = 23
    auditMemberUpdate* = 24
    auditMemberRoleUpdate* = 25
    auditRoleCreate* = 30
    auditRoleUpdate* = 31
    auditRoleDelete* = 32
    auditInviteCreate* = 40
    auditInviteUpdate* = 41
    auditInviteDelete* = 42
    auditWebhookCreate* = 50
    auditWebhookUpdate* = 51
    auditWebhookDelete* = 52
    auditEmojiCreate* = 60
    auditEmojiUpdate* = 61
    auditEmojiDelete* = 62
    auditMessageDelete* = 72

type 
    Overwrite* = object
        id*: string
        `type`*: string
        allow*: int
        deny*: int
    DChannel* = object of RootObj
        id*: string
        guild_id*: string
        name*: string
        `type`*: int
        position*: int
        permission_overwrites*: seq[Overwrite]
        topic*: string
        last_message_id*: string
        last_pin_timestamp*: string
        bitrate*: int
        user_limit*: int
        recipients*: seq[User]
        nsfw*: bool
        parent_id*: string
        icon: string
        owner_id: string
        application_id: string
    Message* = object of RootObj
        `type`: int
        tts*: bool
        timestamp*: string
        pinned*: bool
        nonce*: string
        mention_roles*: seq[string]
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
        roles*: seq[string]
        require_colons*: bool
        managed*: bool
    Embed* = object
        title*: string
        `type`*: string
        description*: string
        url*: string
        timestamp*: string
        color*: int
        footer*: EmbedFooter
        image*: EmbedImage
        thumbnail*: EmbedThumbnail
        video*: EmbedVideo
        provider*: EmbedProvider
        author*: EmbedAuthor
        fields*: seq[EmbedField] not nil
    EmbedThumbnail* = object
        url*: string
        proxy_url*: string
        height*: int
        width*: int
    EmbedVideo* = object
        url*: string
        height*: int
        width*: int
    EmbedImage* = object
        url*: string
        proxy_url*: string
        height*: int
        width*: int
    EmbedProvider* = object
        name*: string
        url*: string
    EmbedAuthor* = object
        name*: string
        url*: string
        icon_url*: string
        proxy_icon_url*: string
    EmbedFooter* = object
        text*: string
        icon_url*: string
        proxy_icon_url*: string
    EmbedField* = object
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
        since: int
        afk: bool
        game: Game
        status: string
    Guild* = object of RootObj
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
        features: seq[string]
        explicit_content_filter*: int
        member_count*: int
        voice_states*: seq[VoiceState]
        members*: seq[GuildMember]
        channels*: seq[DChannel]
        presences*: seq[Presence]
        application_id*: string
        widget_channel_id*: string
        widget_enabled*: bool
    GuildMember* = object of RootObj
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
        user*: User
        account*: Account
        synced_at*: string
    Account* = object
        id*: string
        name*: string
    Invite* = object
        code*: string
        guild*: InviteGuild
        channel*: InviteChannel
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
        `type`*: int
    User* = object of RootObj
        id*: string
        guild_id: string
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
    VoiceState* = object of RootObj
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
        embeds*: seq[Embed]
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
    AuditLogOptions* = object
        delete_members_days*: string
        members_removed*: string
        channel_id*: string
        count*: string
        id*: string
        `type`*: string
        role_name*: string
    AuditLogChangeKind* = enum
        ALCString,
        ALCInt,
        ALCBool,
        ALCRoles,
        ALCOverwrites,
        ALCNil
    AuditLogChangeValue* = ref AuditLogChangeValueObj
    AuditLogChangeValueObj* = object
        case kind*: AuditLogChangeKind
        of ALCString:
            str*: string
        of ALCInt:
            ival*: int64
        of ALCBool:
            bval*: bool
        of ALCRoles:
            roles*: seq[Role]
        of ALCOverwrites:
            overwrites*: seq[Overwrite]
        of ALCNil:
            nil
    AuditLogChange* = object
        new_value*: AuditLogChangeValue
        old_value*: AuditLogChangeValue 
        key*: string
    AuditLogEntry* = object
        target_id*: string
        changes*: seq[AuditLogChange]
        user_id*: string
        id*: string
        action_type*: int
        options*: AuditLogOptions
    AuditLog* = object
        webhooks*: seq[Webhook]
        users: seq[User]
        audit_log_entries: seq[AuditLogEntry]
    MessageDeleteBulk* = object
        ids*: seq[string]
        channel_id*: string
    Game* = object of RootObj
        name*: string
        `type`*: int
        url*: string
        # session_id: string # Should appear at some point in the payload
    PresenceUpdate* = object
        user*: User
        nick: string
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
    VoiceConnection* = object
        sampleRate: uint
        frameSize: uint16
        channels: uint8
        volume: float
    Resumed* = object
        trace*: seq[string]
    Cache* = ref object
        lock: Lock
        version*: int
        me*: User
        cacheChannels*: bool
        cacheGuilds*: bool
        cacheGuildMembers*: bool
        cacheUsers*: bool
        cacheRoles*: bool
        channels: Table[string, DChannel]
        guilds: Table[string, Guild]
        users: Table[string, User]
        members: Table[string, GuildMember]
        roles: Table[string, Role]
        ready: Ready
    Ready* = object
        v*: int
        user*: User
        private_channels*: seq[DChannel]
        session_id*: string
        guilds*: seq[Guild]
        trace*: seq[string] 
        presences: seq[Presence]
    Pin* = object of RootObj
        last_pin_timestamp*: string
        channel_id*: string
    MessageCreate* = Message
    MessageUpdate* = Message
    MessageDelete* = Message
    GuildMemberAdd* = object of GuildMember
    GuildMemberUpdate* = object of GuildMember
    GuildMemberRemove* = object of GuildMember
    GuildMembersChunk* = object
        guild_id*: string
        members*: seq[GuildMember]
    GuildCreate* = Guild
    GuildUpdate* = Guild
    GuildDelete* = object
        id: string
        unavailable: bool
    GuildBanAdd* = User
    GuildBanRemove* = User
    ChannelCreate* = DChannel
    ChannelUpdate* = DChannel
    ChannelDelete* = DChannel
    ChannelPinsUpdate* = object of Pin
    UserUpdate* = User
    VoiceStateUpdate* = VoiceState
    MessageReactionAdd* = object of RootObj
        user_id: string
        message_id: string
        channel_id: string
        emoji: Emoji
    MessageReactionRemove* = MessageReactionAdd
    MessageReactionRemoveAll* = object
        message_id: string
        channel_id: string
    WebhooksUpdate = Webhook
    EventType* = enum
        channel_create
        channel_update
        channel_delete
        channel_pins_update
        webhooks_update
        guild_create
        guild_update
        guild_delete
        guild_ban_add
        guild_ban_remove
        guild_emojis_update
        guild_integrations_update
        guild_member_add
        guild_member_update
        guild_member_remove
        guild_members_chunk
        guild_role_create
        guild_role_update
        guild_role_delete
        message_create
        message_update
        message_delete
        message_delete_bulk
        message_reaction_add
        message_reaction_remove
        message_reaction_remove_all
        presence_update
        typing_start
        user_update
        voice_state_update
        voice_server_update
        on_resume
        on_ready
    Session* = ref SessionImpl
    SessionImpl = object
        mut: Lock
        token*: string
        compress*: bool
        shardID*: int 
        shardCount*: int
        gateway*: string
        session_id: string
        limiter: RateLimits
        connection*: AsyncWebSocket
        voiceConnections: seq[VoiceConnection]
        cache*: Cache
        shouldResume: bool
        suspended: bool
        invalidated: bool
        stop: bool
        sequence: int
        interval: int
        handlers: Table[EventType, pointer]
    

method addHandler*(s: Session, t: EventType, p: pointer) {.gcsafe, base, inline.} =
    ## Adds a handler tied to a websocket event
    initLock(s.mut)
    s.handlers[t] = p
    deinitLock(s.mut)

method removeHandler*(s: Session, t: EventType) {.gcsafe, base, inline.} =
    ## Removes a websocket event handler
    initLock(s.mut)
    s.handlers.del(t)
    deinitLock(s.mut)


# This isn't very pretty, but it is significantly faster than `json.to(T)`, and also faster than marshal.to[T].
# should also be "safer" to use than either of them.
# Might move to another file in the future
proc newUser(payload: JsonNode): User {.inline.} =
    result = User(
            guild_id: if payload.hasKey("guild_id"): payload["guild_id"].str else: "",
            id: payload["id"].str,
            username: if payload.hasKey("username"): payload["username"].str else: "",
            discriminator: if payload.hasKey("discriminator"): payload["discriminator"].str else: "0000",
            avatar: if payload.hasKey("avatar") and payload["avatar"].kind != JNull: payload["avatar"].str else: "",
            bot: if payload.hasKey("bot"): payload["bot"].bval else: false,
            mfa_enabled: if payload.hasKey("mfa_enabled"): payload["mfa_enabled"].bval else: false,
            verified: if payload.hasKey("verified"): payload["verified"].bval else: false,
            email: if payload.hasKey("email") and payload["email"].kind != JNull: payload["email"].str else: ""
    )

proc newUnavailableGuild(payload: JsonNode): Guild {.inline.} =
    result = Guild(
        id: payload["id"].str,
        unavailable: payload["unavailable"].bval
    )

proc newResumed(payload: JsonNode): Resumed {.inline.} =
    result = Resumed(
        trace: marshal.to[seq[string]]($payload["trace"])
    )

proc newChannel(payload: JsonNode): DChannel {.inline.} =
    result = DChannel(
        id: payload["id"].str,
        guild_id: if payload.hasKey("guild_id") and payload["guild_id"].kind != JNull: payload["guild_id"].str else: "",
        name: if payload.hasKey("name") and payload["name"].kind != JNull: payload["name"].str else: "",
        `type`: payload["type"].num.int,
        position: if payload.hasKey("position") and payload["position"].kind != JNull: payload["position"].num.int else: 0,
        permission_overwrites: if payload.hasKey("permission_overwrites"): marshal.to[seq[Overwrite]]($payload["permission_overwrites"]) else: @[],
        topic: if payload.hasKey("topic") and payload["topic"].kind != JNull: payload["topic"].str else: "",
        last_message_id: if payload.hasKey("last_message_id") and payload["last_message_id"].kind != JNull: payload["last_message_id"].str else: "",
        bitrate: if payload.hasKey("bitrate"): payload["bitrate"].num.int else: 0,
        user_limit: if payload.hasKey("user_limit"): payload["user_limit"].num.int else: 0,
        icon: if payload.hasKey("avatar") and payload["avatar"].kind != JNull: payload["avatar"].str else: "",
        owner_id: if payload.hasKey("owner_id"): payload["owner_id"].str else: "",
        application_id: if payload.hasKey("application_id"): payload["application_id"].str else: ""
    )

    if payload.hasKey("recipients"):
        for user in payload["recipents"].elems:
            result.recipients.add(newUser(user))

proc newChannelCreate(payload: JsonNode): ChannelCreate {.inline.} =
    result = newChannel(payload)

proc newChannelUpdate(payload: JsonNode): ChannelUpdate {.inline.} =
    result = newChannel(payload)

proc newChannelDelete(payload: JsonNode): ChannelDelete {.inline.} =
    result = newChannel(payload)

proc newRole(payload: JsonNode): Role {.inline.} =
    result = Role(
        id: payload["id"].str,
        name: payload["name"].str,
        color: payload["color"].num.int,
        hoist: payload["hoist"].bval,
        position: payload["position"].num.int,
        managed: payload["managed"].bval,
        mentionable: payload["mentionable"].bval
    )

proc newEmoji(payload: JsonNode): Emoji {.inline.} =
    result = Emoji(
        id: if payload.hasKey("id") and payload["id"].kind != JNull: payload["id"].str else: "",
        name: if payload.hasKey("name") and payload["name"].kind != JNull: payload["name"].str else: "",
        roles: if payload.hasKey("roles"): marshal.to[seq[string]]($payload["roles"]) else: @[],
        require_colons: if payload.hasKey("require_colons"): payload["require_colons"].bval else: false,
        managed: if payload.hasKey("managed"): payload["managed"].bval else: false,
    )

proc newGuild(payload: JsonNode): Guild  =
    result = Guild(
        id: payload["id"].str,
        name: payload["name"].str,
        icon: if payload["icon"].kind != JNull: payload["icon"].str else: "",
        splash: if payload.hasKey("splash") and payload["splash"].kind != JNull: payload["splash"].str else: "",
        owner_id: payload["owner_id"].str,
        region: payload["region"].str,
        afk_channel_id: if payload.hasKey("afk_channel_id") and payload["afk_channel_id"].kind != JNull: payload["afk_channel_id"].str else: "",
        afk_timeout: payload["afk_timeout"].num.int,
        embed_enabled: if payload.hasKey("embed_enabled"): payload["embed_enabled"].bval else: false,
        embed_channel_id: if payload.hasKey("embed_channel_id") and payload["embed_channel_id"].kind != JNull: payload["embed_channel_id"].str else: "",
        verification_level: payload["verification_level"].num.int,
        default_message_notifications: payload["default_message_notifications"].num.int,
        explicit_content_filter: payload["explicit_content_filter"].num.int,
        features: marshal.to[seq[string]]($payload["features"]),
        mfa_level: payload["mfa_level"].num.int,
        application_id: if payload["application_id"].kind != JNull: payload["application_id"].str else: "",
        widget_enabled: if payload.hasKey("widget_enabled"): payload["widget_enabled"].bval else: false,
        widget_channel_id: if payload.hasKey("widget_channel_id") and payload["widget_channel_id"].kind != JNull: payload["widget_channel_id"].str else: "",
        roles: @[],
        emojis: @[]
    )

    for role in payload["roles"].elems:
        result.roles.add(newRole(role))

    for emoji in payload["emojis"].elems:
        result.emojis.add(newEmoji(emoji))

proc newVoiceState(payload: JsonNode): VoiceState {.inline.} =
    result = VoiceState(
        guild_id: if payload.hasKey("guild_id") and payload["guild_id"].kind != JNull: payload["guild_id"].str else: "",
        channel_id: if payload["channel_id"].kind != JNull: payload["channel_id"].str else: "",
        user_id: payload["user_id"].str,
        session_id: payload["session_id"].str,
        deaf: payload["deaf"].bval,
        mute: payload["mute"].bval,
        self_deaf: payload["self_deaf"].bval,
        self_mute: payload["self_mute"].bval,
        suppress: payload["suppress"].bval
    )

proc newGuildMember(payload: JsonNode): GuildMember {.inline.} =
    result = GuildMember(
        guild_id: if payload.hasKey("guild_id"): payload["guild_id"].str else: "",
        user: newUser(payload["user"]),
        nick: if payload.hasKey("nick") and payload["nick"].kind != JNull: payload["nick"].str else: "",
        roles: marshal.to[seq[string]]($payload["roles"]),
        joined_at: payload["joined_at"].str,
        deaf: payload["deaf"].bval,
        mute: payload["mute"].bval,
    )

proc newGame(payload: JsonNode): Game {.inline.} =
    result = Game(
        name: if payload.hasKey("name") and payload["name"].kind != JNull: payload["name"].str else: "",
        `type`: if payload.hasKey("type"): payload["type"].num.int else: 0,
        url: if payload.hasKey("url") and payload["url"].kind != JNull: payload["url"].str else: ""
    )

proc newPresence(payload: JsonNode): Presence {.inline.} =
    result = Presence(
        since: if payload.hasKey("since") and payload["since"].kind != JNull: payload["since"].num.int else: 0,
        game: if payload.hasKey("game") and payload["game"].kind != JNull: newGame(payload["game"]) else: Game(),
        status: payload["status"].str,
        afk: payload["afk"].bval
    )

proc newPresenceUpdate(payload: JsonNode): PresenceUpdate {.inline.} =
    result = PresenceUpdate(
        user: newUser(payload["user"]),
        status: payload["status"].str,
        guild_id: payload["guild_id"].str,
        roles: if payload.hasKey("roles"): marshal.to[seq[string]]($payload["roles"]) else: @[],
        game: if payload.hasKey("game") and payload["game"].kind != JNull: newGame(payload["game"]) else: Game(),
    )

proc newGuildWithCreateFields(payload: JsonNode): Guild =
    result = Guild(
        joined_at: payload["joined_at"].str,
        large: payload["large"].bval,
        unavailable: payload["unavailable"].bval,
        member_count: payload["member_count"].num.int,
    )

    for vstate in payload["voice_states"].elems:
        result.voice_states.add(newVoiceState(vstate))

    for member in payload["members"].elems:
        result.members.add(newGuildMember(member))

    for channel in payload["channels"].elems:
        result.channels.add(newChannel(channel))

    for presence in payload["presences"].elems:
        result.presences.add(newPresence(presence))

proc newGuildCreate(payload: JsonNode): GuildCreate {.inline.} =
    result = newGuild(payload)

proc newGuildUpdate(payload: JsonNode): GuildUpdate {.inline.} =
    result = newGuild(payload)

proc newGuildDelete(payload: JsonNode): GuildDelete {.inline.} =
    result = GuildDelete(
        id: payload["id"].str,
        unavailable: payload["unavailable"].bval,
    )

proc newReady(payload: JsonNode): Ready =
    result = Ready(
        v: payload["v"].num.int,
        user: newUser(payload["user"]),
        private_channels: marshal.to[seq[DChannel]]($payload["private_channels"]),
        session_id: payload["session_id"].str,
        trace: marshal.to[seq[string]]($payload["_trace"]),
        presences: marshal.to[seq[Presence]]($payload["presences"]),
        guilds: @[]
    )

    if payload.hasKey("guilds"):
        for guild in payload["guilds"].elems:
            result.guilds.add(newUnavailableGuild(guild))

proc newChannelPinsUpdate(payload: JsonNode): ChannelPinsUpdate {.inline.} =
    result = ChannelPinsUpdate(
        channel_id: payload["channel_id"].str,
        last_pin_timestamp: if payload.hasKey("last_pin_timestamp"): payload["last_pin_timestamp"].str else: ""
    )

proc newGuildBanAdd(payload: JsonNode): GuildBanAdd {.inline.} =
    result = newUser(payload)

proc newGuildBanRemove(payload: JsonNode): GuildBanRemove {.inline.} =
    result = newUser(payload)

proc newGuildEmojisUpdate(payload: JsonNode): GuildEmojisUpdate =
    result = GuildEmojisUpdate(
        guild_id: payload["guild_id"].str,
        emojis: @[]
    )

    for emoji in payload["emojis"].elems:
        result.emojis.add(newEmoji(emoji))

proc newGuildIntegrationsUpdate(payload: JsonNode): GuildIntegrationsUpdate {.inline.} =
    result = GuildIntegrationsUpdate(
        guild_id: payload["guild_id"].str
    )

proc newGuildMemberAdd(payload: JsonNode): GuildMemberAdd {.inline.} =
    result = newGuildMember(payload).GuildMemberAdd

proc newGuildMemberRemove(payload: JsonNode): GuildMemberRemove {.inline.} =
    result = GuildMemberRemove(
        guild_id: payload["guild_id"].str,
        user: newUser(payload["user"])
    )

proc newGuildMemberUpdate(payload: JsonNode): GuildMemberUpdate {.inline.} =
    result = GuildMemberUpdate(
        guild_id: payload["guild_id"].str,
        roles: marshal.to[seq[string]]($payload["roles"]),
        user: newUser(payload["user"]),
        nick: if payload["nick"].kind != JNull: payload["nick"].str else: ""
    )

proc newGuildMembersChunk(payload: JsonNode): GuildMembersChunk {.inline.} =
    result = GuildMembersChunk(
        guild_id: payload["guild_id"].str
    )

    for member in payload["members"].elems:
        result.members.add(newGuildMember(member))

proc newGuildRoleCreate(payload: JsonNode): GuildRoleCreate {.inline.} =
    result = GuildRoleCreate(
        guild_id: payload["guild_id"].str,
        role: newRole(payload["role"])
    )

proc newGuildRoleUpdate(payload: JsonNode): GuildRoleUpdate {.inline.} =
    result = GuildRoleUpdate(
        guild_id: payload["guild_id"].str,
        role: newRole(payload["role"])
    )

proc newGuildRoleDelete(payload: JsonNode): GuildRoleDelete {.inline.} =
    result = GuildRoleDelete(
        guild_id: payload["guild_id"].str,
        role_id: payload["role_id"].str
    )

proc newAttachment(payload: JsonNode): Attachment {.inline.} =
    result = Attachment(
        id: payload["id"].str,
        filename: payload["filename"].str,
        size: payload["size"].num.int,
        url: payload["url"].str,
        proxy_url: payload["proxy_url"].str,
        height: if payload.hasKey("height") and payload["height"].kind != JNull: payload["height"].num.int else: 0,
        width: if payload.hasKey("width") and payload["width"].kind != JNull: payload["width"].num.int else: 0,
    )

proc newEmbedFooter(payload: JsonNode): EmbedFooter {.inline.} =
    result = EmbedFooter(
        text: payload["text"].str,
        icon_url: if payload.hasKey("icon_url"): payload["icon_url"].str else: "",
        proxy_icon_url: if payload.hasKey("proxy_icon_url"): payload["proxy_icon_url"].str else: ""
    )

proc newEmbedImage(payload: JsonNode): EmbedImage{.inline.} =
    result = EmbedImage(
        url: payload["url"].str,
        proxy_url: payload["proxy_url"].str,
        height: payload["height"].num.int,
        width: payload["width"].num.int
    )

proc newEmbedThumbnail(payload: JsonNode): EmbedThumbnail {.inline.} =
    result = EmbedThumbnail(
        url: payload["url"].str,
        proxy_url: payload["proxy_url"].str,
        height: payload["height"].num.int,
        width: payload["width"].num.int
    )

proc newEmbedVideo(payload: JsonNode): EmbedVideo {.inline.} =
    result = EmbedVideo(
        url: payload["url"].str,
        height: payload["height"].num.int,
        width: payload["width"].num.int
    )

proc newEmbedProvider(payload: JsonNode): EmbedProvider {.inline.} =
    result = EmbedProvider(
        url: if payload["url"].kind != JNull: payload["url"].str else: "",
        name: if payload["name"].kind != JNull: payload["name"].str else: ""
    )

proc newEmbedAuthor(payload: JsonNode): EmbedAuthor {.inline.} =
    result = EmbedAuthor(
        name: payload["name"].str,
        url: if payload.hasKey("url"): payload["url"].str else: "",
        icon_url: if payload.hasKey("icon_url"): payload["icon_url"].str else: "",
        proxy_icon_url: if payload.hasKey("proxy_icon_url"): payload["proxy_icon_url"].str else: ""
    )

proc newEmbedField(payload: JsonNode): EmbedField {.inline.} =
    result = EmbedField(
        name: payload["name"].str,
        value: payload["value"].str,
        inline: payload["inline"].bval
    )

proc newEmbed(payload: JsonNode): Embed {.inline.} =
    result = Embed(
        title: if payload.hasKey("title"): payload["title"].str else: "",
        `type`: if payload.hasKey("type"): payload["type"].str else: "rich",
        description: if payload.hasKey("description"): payload["description"].str else: "",
        url: if payload.hasKey("url"): payload["url"].str else: "",
        timestamp: if payload.hasKey("timestamp"): payload["timestamp"].str else: "",
        color: if payload.hasKey("color"): payload["color"].num.int else: 0x4f545c,
        footer: if payload.hasKey("footer"): newEmbedFooter(payload["footer"]) else: EmbedFooter(),
        image: if payload.hasKey("image"): newEmbedImage(payload["image"]) else: EmbedImage(),
        thumbnail: if payload.hasKey("thumbnail"): newEmbedThumbnail(payload["thumbnail"]) else: EmbedThumbnail(),
        video: if payload.hasKey("video"): newEmbedVideo(payload["video"]) else: EmbedVideo(),
        provider: if payload.hasKey("provider"): newEmbedProvider(payload["provider"]) else: EmbedProvider(),
        author: if payload.hasKey("author"): newEmbedAuthor(payload["author"]) else: EmbedAuthor(),
        fields: @[]
    )

    if payload.hasKey("fields"):
        for field in payload["fields"].elems:
            result.fields.add(newEmbedField(field))

proc newReaction(payload: JsonNode): Reaction {.inline.} =
    result = Reaction(
        count: payload["count"].num.int,
        me: payload["me"].bval,
        emoji: newEmoji(payload["emoji"])
    )

proc newMessage(payload: JsonNode): Message =
    result = Message(
        id: payload["id"].str,
        channel_id: payload["channel_id"].str,
        author: if payload.hasKey("author"): marshal.to[User]($payload["author"]) else: User(),
        content: if payload.hasKey("content"): payload["content"].str else: "",
        timestamp: if payload.hasKey("timestamp"): payload["timestamp"].str else: $getLocalTime(getTime()),
        edited_timestamp: if payload.hasKey("edited_timestamp") and payload["edited_timestamp"].kind != JNull: payload["edited_timestamp"].str else: "",
        tts: if payload.hasKey("tts"): payload["tts"].bval else: false,
        mention_everyone: if payload.hasKey("mention_everyone"): payload["mention_everyone"].bval else: false,
        mention_roles: if payload.hasKey("mention_roles"): marshal.to[seq[string]]($payload["mention_roles"]) else: @[],
        nonce: if payload.hasKey("nonce") and payload["nonce"].kind != JNull: payload["nonce"].str else: "",
        pinned: if payload.hasKey("pinned"): payload["pinned"].bval else: false,
        webhook_id: if payload.hasKey("webhook_id"): payload["webhook_id"].str else: "",
        `type`: if payload.hasKey("type"): payload["type"].num.int else: 0,
        reactions: @[],
        mentions: @[],
        attachments: @[],
        embeds: @[],
    )

    if payload.hasKey("mentions"):
        for mention in payload["mentions"].elems:
            result.mentions.add(newUser(mention))

    if payload.hasKey("attachments"):
        for attachment in payload["attachments"].elems:
            result.attachments.add(newAttachment(attachment))

    if payload.hasKey("embeds"):
        for embed in payload["embeds"].elems:
            result.embeds.add(newEmbed(embed))

    if payload.hasKey("reactions"):
        for reaction in payload["reactions"]:
            result.reactions.add(newReaction(reaction))

proc newMessageCreate(payload: JsonNode): MessageCreate {.inline.} =
    result = newmessage(payload)

proc newMessageUpdate(payload: JsonNode): MessageUpdate {.inline.} =
    result = newmessage(payload)

proc newMessageDelete(payload: JsonNode): MessageDelete {.inline.} =
    result = MessageDelete(
        id: payload["id"].str,
        channel_id: payload["channel_id"].str
    )

proc newMessageDeleteBulk(payload: JsonNode): MessageDeleteBulk {.inline.} =
    result = MessageDeleteBulk(
        ids: marshal.to[seq[string]]($payload["ids"]),
        channel_id: payload["channel_id"].str
    )

proc newMessageReactionAdd(payload: JsonNode): MessageReactionAdd {.inline.} =
    result = MessageReactionAdd(
        user_id: payload["user_id"].str,
        channel_id: payload["channel_id"].str,
        message_id: payload["message_id"].str,
        emoji: newEmoji(payload["emoji"])
    )

proc newMessageReactionRemove(payload: JsonNode): MessageReactionRemove {.inline.} =
    result = newMessageReactionAdd(payload)

proc newMessageReactionRemoveAll(payload: JsonNode): MessageReactionRemoveAll {.inline.} =
    result = MessageReactionRemoveAll(
        channel_id: payload["channel_id"].str,
        message_id: payload["message_id"].str
    )

proc newWebhooksUpdate(payload: JsonNode): WebhooksUpdate {.inline.} =
    result = WebhooksUpdate(
        guild_id: payload["guild_id"].str,
        channel_id: payload["channel_id"].str,
    )

proc newTypingStart(payload: JsonNode): TypingStart {.inline.} =
    result = TypingStart(
        channel_id: payload["channel_id"].str,
        user_id: payload["user_id"].str,
        timestamp: payload["timestamp"].num.int
    )

proc newUserUpdate(payload: JsonNode): UserUpdate {.inline.} =
    result = newUser(payload)

proc newVoiceStateUpdate(payload: JsonNode): VoiceStateUpdate {.inline.} =
    result = newVoiceState(payload)

proc newVoiceServerUpdate(payload: JsonNode): VoiceServerUpdate {.inline.} =
    result = VoiceServerUpdate(
        token: payload["token"].str,
        guild_id: payload["guild_id"].str,
        endpoint: payload["endpoint"].str
    )

proc newInviteGuild(payload: JsonNode): InviteGuild {.inline.} =
    result = InviteGuild(
        id: payload["id"].str,
        name: payload["name"].str,
        splash: if payload.hasKey("splash") and payload["splash"].kind != JNull: payload["splash"].str else: "",
        icon: if payload.hasKey("icon") and payload["icon"].kind != JNull: payload["icon"].str else: ""
    )

proc newInviteChannel(payload: JsonNode): InviteChannel {.inline.} =
    result = InviteChannel(
        id: payload["id"].str,
        name: payload["name"].str,
        `type`: if payload.hasKey("type"): payload["type"].num.int else: 0,
    )

proc newInvite(payload: JsonNode): Invite {.inline.} =
    result = Invite(
        code: payload["code"].str,
        guild: if payload.hasKey("guild"): newInviteGuild(payload["guild"]) else: InviteGuild(),
        channel: if payload.hasKey("channel"): newInviteChannel(payload["channel"]) else: InviteChannel()
    )

proc newVoiceRegion(payload: JsonNode): VoiceRegion {.inline.} =
    result = VoiceRegion(
        name: payload["name"].str,
        deprecated: payload["deprecated"].bval,
        custom: payload["custom"].bval,
        vip: payload["vip"].bval,
        optimal: payload["optimal"].bval,
        id: payload["id"].str,
        sample_hostname: if payload.hasKey("sample_hostname"): payload["sample_hostname"].str else: "",
        sample_port: if payload.hasKey("sample_port"): payload["sample_port"].num.int else: 0,
    )

proc newIntegrationAccount(payload: JsonNode): Account {.inline.} =
    result = Account(
        id: payload["id"].str,
        name: payload["name"].str
    )

proc newIntegration(payload: JsonNode): Integration {.inline.} =
    result = Integration(
        id: payload["id"].str,
        name: payload["name"].str,
        `type`: payload["type"].str,
        enabled: payload["enabled"].bval,
        syncing: payload["syncing"].bval,
        role_id: payload["role_id"].str,
        expire_behavior: payload["expire_behavior"].num.int,
        expire_grace_period: payload["expire_grace_period"].num.int,
        user: newUser(payload["user"]),
        account: newIntegrationAccount(payload["account"]),
        synced_at: payload["synced_at"].str,
    )

proc newWebhook(payload: JsonNode): Webhook {.inline.} =
    result = Webhook(
        id: payload["id"].str,
        guild_id: if payload.hasKey("guild_id"): payload["guild_id"].str else: "",
        channel_id: payload["channel_id"].str,
        user: if payload.hasKey("user") and payload["user"].kind != JNull: newUser(payload["user"]) else: User(),
        name: if payload["name"].kind != JNull: payload["name"].str else: "",
        avatar: if payload["avatar"].kind != JNull: payload["avatar"].str else: "",
        token: payload["token"].str
    )

proc newGuildEmbed(payload: JsonNode): GuildEmbed {.inline.} =
    result = GuildEmbed(
        enabled: payload["enabled"].bval,
        channel_id: payload["channel_id"].str
    )

proc newAuditLogChangeValue(s: string): AuditLogChangeValue =
    new(result)
    result.kind = ALCString
    result.str = s

proc newAuditLogChangeValue(i: int64): AuditLogChangeValue =
    new(result)
    result.kind = ALCInt
    result.ival = i

proc newAuditLogChangeValue(b: bool): AuditLogChangeValue =
    new(result)
    result.kind = ALCBool
    result.bval = b

proc newAuditLogChangeValue(r: seq[Role]): AuditLogChangeValue =
    new(result)
    result.kind = ALCRoles
    result.roles = r

proc newAuditLogChangeValue(o: seq[Overwrite]): AuditLogChangeValue =
    new(result)
    result.kind = ALCOverwrites
    result.overwrites = o

proc newOverwrite(payload: JsonNode): Overwrite {.inline.} =
    result = Overwrite(
        id: payload["id"].str,
        `type`: payload["type"].str,
        allow: payload["allow"].num.int,
        deny: payload["deny"].num.int
    )

proc newAuditLogChange(payload: seq[JsonNode]): AuditLogChange =
    for change in payload:
        case change["key"].str:
        of "name", "icon_hash", "splash_hash",
            "owner_id", "region", "afk_channel_id",
            "vanity_url_code", "topic", "application_id",
            "code", "nick", "avatar_hash", "id":
                if change.hasKey("new_value"): 
                    result.new_value = newAuditLogChangeValue(change["new_value"].str)
                if change.hasKey("old_value"):
                    result.old_value = newAuditLogChangeValue(change["old_value"].str)
        of "afk_timeout", "mfa_level", "verification_level",
            "explicit_content_filter", "default_message_notifications",
            "prune_delete_days", "position", "bitrate", "permissions",
            "color", "allow", "deny", "max_uses", "uses", "max_age":
                if change.hasKey("new_value"):
                    result.new_value = newAuditLogChangeValue(change["new_value"].num)
                if change.hasKey("old_value"):
                    result.old_value = newAuditLogChangeValue(change["old_value"].num)
        of "widget_enabled", "nsfw", "hoist", "mentionable",
            "temporary", "deaf", "mute":
                if change.hasKey("new_value"):
                    result.new_value = newAuditLogChangeValue(change["new_value"].bval)
                if change.hasKey("old_value"):
                    result.old_value = newAuditLogChangeValue(change["old_value"].bval)
        of "$add", "$remove":
            if change.hasKey("new_value"):
                var roles: seq[Role] = @[]
                for role in change["new_value"]:
                    roles.add(newRole(role))
                result.new_value = newAuditLogChangeValue(roles)
            if change.hasKey("old_value"):
                var roles: seq[Role] = @[]
                for role in change["old_value"]:
                    roles.add(newRole(role))
                result.old_value = newAuditLogChangeValue(roles)
        of "permission_overwrites":
            if change.hasKey("new_value"):
                var overwrites: seq[Overwrite] = @[]
                for overwrite in change["new_value"]:
                    overwrites.add(newOverwrite(overwrite))
                result.new_value = newAuditLogChangeValue(overwrites)
            if change.hasKey("old_value"):
                var overwrites: seq[Overwrite] = @[]
                for overwrite in change["old_value"]:
                    overwrites.add(newOverwrite(overwrite))
                result.old_value = newAuditLogChangeValue(overwrites)
        of "type":
            if change.hasKey("new_value"):
                case change["new_value"].kind:
                of JString:
                    result.new_value = newAuditLogChangeValue(change["new_value"].str)
                of JInt:
                    result.new_value = newAuditLogChangeValue(change["new_value"].num)
                else: discard
            if change.hasKey("old_value"):
                case change["old_value"].kind:
                of JString:
                    result.old_value = newAuditLogChangeValue(change["old_value"].str) 
                of JInt:
                    result.old_value = newAuditLogChangeValue(change["old_value"].num)
                else: discard

proc newAuditLogOptions(payload: JsonNode): AuditLogOptions {.inline.} =
    result = AuditLogOptions(
        delete_members_days: if payload.hasKey("delete_members_days"): payload["delete_members_days"].str else: "",
        members_removed: if payload.hasKey("members_removed"): payload["members_removed"].str else: "",
        channel_id: if payload.hasKey("channel_id"): payload["channel_id"].str else: "",
        count: if payload.hasKey("count"): payload["count"].str else: "0",
        id: if payload.hasKey("id"): payload["id"].str else: "",
        `type`: if payload.hasKey("type"): payload["type"].str else: "",
        role_name: if payload.hasKey("role_name"): payload["role_name"].str else: ""
    )

proc newAuditLogEntry(payload: JsonNode): AuditLogEntry = 
    result = AuditLogEntry(
        target_id: payload["target_id"].str,
        user_id: payload["user_id"].str,
        id: payload["id"].str,
        action_type: payload["action_type"].num.int,
        changes: @[]
    )
    
    if payload.hasKey("options"):
        result.options = newAuditLogOptions(payload["options"])

    if payload.hasKey("changes"):
        result.changes.add(newAuditLogChange(payload["changes"].elems))

proc newAuditLog(payload: JsonNode): AuditLog =
    result = AuditLog(
        webhooks: @[],
        users: @[],
        audit_log_entries: @[]
    )

    for webhook in payload["webhooks"].elems:
        result.webhooks.add(newWebhook(webhook))

    for user in payload["users"].elems:
        result.users.add(newUser(user))

    for entry in payload["audit_log_entries"].elems:
        result.audit_log_entries.add(newAuditLogEntry(entry))

proc newUserGuild(payload: JsonNode): UserGuild {.inline.} =
    result = UserGuild(
        id: payload["id"].str,
        name: payload["name"].str,
        icon: if payload.hasKey("icon") and payload["icon"].kind != JNull: payload["icon"].str else: "",
        owner: payload["owner"].bval,
        permissions: payload["permissions"].num.int
    )