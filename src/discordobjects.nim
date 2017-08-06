import json, tables, locks, websocket/client, times, httpclient, strutils, asyncdispatch
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
        is_private*: bool
        permission_overwrites*: seq[Overwrite]
        topic*: string
        last_message_id*: string
        last_pin_timestamp*: string
        bitrate*: int
        user_limit*: int
        recipients*: seq[User]
        nsfw*: bool
        parent_id*: string
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
        user: User
        roles: seq[string]
        game: Game
        guild_id: string
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
        features: seq[JsonNode]
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
    AuditLogOptions* = object
        delete_member_days*: string
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
    MessageCreate* = object of Message
    MessageUpdate* = object of Message
    MessageDelete* = object of Message
    GuildMemberAdd* = object of GuildMember
    GuildMemberUpdate* = object of GuildMember
    GuildMemberRemove* = object of GuildMember
    GuildMembersChunk* = object
        guild_id: string
        query: string
        limit: int
    GuildCreate* = object of Guild
    GuildUpdate* = object of Guild
    GuildBanAdd* = object of User
    GuildBanRemove* = object of User
    ChannelCreate* = object of DChannel
    ChannelUpdate* = object of DChannel
    ChannelDelete* = object of DChannel
    ChannelPinsUpdate* = object of Pin
    UserUpdate* = object of User
    VoiceStateUpdate* = object of VoiceState
    MessageReactionAdd* = object of RootObj
        user_id: string
        message_id: string
        channel_id: string
        emoji: Emoji
    MessageReactionRemove* = object of MessageReactionAdd
    MessageReactionRemoveAll* = object
        message_id: string
        channel_id: string
    EventType* = enum
        channel_create
        channel_update
        channel_delete
        channel_pins_update
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