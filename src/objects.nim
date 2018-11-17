#import tables, times, asyncdispatch, httpclient, strutils, options, websocket, macros, json
import options, tables, times, asyncdispatch, httpclient, json, strutils, websocket
{.hint[XDeclaredButNotUsed]: off.} 
type 
    RateLimit = ref object
        reset: int64
        limit: int64
        remaining: int64
    RateLimits = ref object of RootObj
        global: RateLimit
        endpoints: Table[string, RateLimit]

proc preCheck*(r: RateLimit) {.async, gcsafe.} =
    if r.limit == 0: return
    
    let diff = r.reset - getTime().utc.toTime.toUnix
    if diff < 0:
        r.reset += 3
        r.remaining = r.limit
        return
    
    if r.remaining <= 0:
        let delay = diff * 1000+900
        await sleepAsync delay.int
        return
    
    r.remaining.dec

proc postCheck*(r: RateLimit, url: string, response: AsyncResponse): Future[bool] {.async, gcsafe.} =
    if response.headers.hasKey("X-RateLimit-Reset"): r.reset = response.headers["X-RateLimit-Reset"].parseInt
    if response.headers.hasKey("X-RateLimit-Limit"): r.limit = response.headers["X-RateLimit-Limit"].parseInt
    if response.headers.hasKey("X-RateLimit-Remaining"): r.remaining = response.headers["X-RateLimit-Remaining"].parseInt

    if response.code == Http429:
        let delay = if response.headers.hasKey("Retry-After"): response.headers["Retry-After"].parseInt else: -1
        if delay == -1: return false

        await sleepAsync delay+100
        result = true

proc postCheck*(r: RateLimits, url: string, response: AsyncResponse): Future[bool] {.async, gcsafe.} =
    if response.headers.hasKey("X-RateLimit-Global"):
        result = await r.global.postCheck(url, response)
    else:
        let rl = if r.endpoints.hasKey(url): r.endpoints[url] else: new(RateLimit)
        result = await rl.postCheck(url, response)

proc preCheck*(r: RateLimits, url: string) {.async, gcsafe.} =
    await r.global.preCheck()

    if r.endpoints.hasKey(url):
        let rl = r.endpoints[url]
        await rl.preCheck()

proc newRateLimiter*(): RateLimits {.inline.} =
    result = RateLimits(
        global: new(RateLimit),
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
    ChannelType* = enum
        CTGuildText = 0
        CTDM = 1
        CTGuildVoice = 2
        CTGroupDM = 3
        CTGuildCategory = 4
    Channel* = object
        id*: string
        `type`*: int
        guild_id*: Option[string]
        position*: Option[int]
        permission_overwrites*: Option[seq[Overwrite]]
        name*: Option[string]
        topic*: Option[string]
        nsfw*: Option[bool]
        last_message_id*: Option[string]
        bitrate*: Option[int]
        user_limit*: Option[int]
        rate_limit_per_user*: Option[int]
        recipients*: Option[seq[User]]
        icon*: Option[string]
        owner_id*: Option[string]
        application_id*: Option[string]
        parent_id*: Option[string]
        last_pin_timestamp*: Option[string]
    MessageType* = enum
        MTDefault
        MTRecipientAdd
        MTRecipientRemove
        MTCall
        MTChannelNameChange
        MTChannelIconChange
        MTChannelPinnedMessage
        MTGuildMemberJoin
    MessageActivityType* = enum
        MATJoin
        MATSpectate
        MATListen
        MATJoinRequest
    MessageActivity* = object
        `type`*: MessageActivityType
        party_id*: Option[string]
    MessageApplication* = object
        id*: string
        cover_image*: string
        description*: string
        icon*: string
        name*: string
    Message* = object
        id*: string
        channel_id*: string
        guild_id*: Option[string]
        author*: User
        member*: Option[GuildMember]
        content*: string
        timestamp*: string
        edited_timestamp*: Option[string]
        tts*: bool
        mention_everyone*: bool
        mentions*: seq[User]
        mention_roles*: seq[string]
        attachments*: seq[Attachment]
        embeds*: seq[Embed]
        reactions*: Option[seq[Reaction]]
        nonce*: Option[string]
        pinned*: bool
        webhook_id*: Option[string]
        `type`*: int
        activity*: Option[MessageActivity]
        application*: Option[MessageApplication]
    Reaction* = object
        count*: int
        me*: bool
        emoji*: Emoji
    Emoji* = object
        id*: Option[string]
        name*: string
        roles*: Option[seq[string]]
        user*: Option[User]
        require_colons*: Option[bool]
        managed*: Option[bool]
        animated*: Option[bool]
    Embed* = object
        title*: Option[string]
        `type`*: Option[string]
        description*: Option[string]
        url*: Option[string]
        timestamp*: Option[string]
        color*: Option[int]
        footer*: Option[EmbedFooter]
        image*: Option[EmbedImage]
        thumbnail*: Option[EmbedThumbnail]
        video*: Option[EmbedVideo]
        provider*: Option[EmbedProvider]
        author*: Option[EmbedAuthor]
        fields*: Option[seq[EmbedField]]
    EmbedThumbnail* = object
        url*: Option[string]
        proxy_url*: Option[string]
        height*: Option[int]
        width*: Option[int]
    EmbedVideo* = object
        url*: Option[string]
        height*: Option[int]
        width*: Option[int]
    EmbedImage* = object
        url*: Option[string]
        proxy_url*: Option[string]
        height*: Option[int]
        width*: Option[int]
    EmbedProvider* = object
        name*: Option[string]
        url*: Option[string]
    EmbedAuthor* = object
        name*: Option[string]
        url*: Option[string]
        icon_url*: Option[string]
        proxy_icon_url*: Option[string]
    EmbedFooter* = object
        text*: string
        icon_url*: Option[string]
        proxy_icon_url*: Option[string]
    EmbedField* = object
        name*: string
        value*: string
        inline*: Option[bool]
    Attachment* = object
        id*: string
        filename*: string
        size*: int
        url*: string
        proxy_url*: string
        height*: Option[int]
        width*: Option[int]
    Presence* = object
        since*: Option[int]
        afk*: Option[bool]
        game*: Option[Game]
        status*: Option[string]
    Guild* = object
        id*: string
        name*: Option[string]
        icon*: Option[string]
        splash*: Option[string]
        owner*: Option[bool]
        owner_id*: Option[string]
        permissions*: Option[int]
        region*: Option[string]
        afk_channel_id*: Option[string]
        afk_timeout*: Option[int]
        embed_enabled*: Option[bool]
        embed_channel_id*: Option[string]
        verification_level*: Option[int]
        default_message_notifications*: Option[int]
        explicit_content_filter*: Option[int]
        roles*: Option[seq[Role]]
        emojis*: Option[seq[Emoji]]
        features*: Option[seq[string]]
        mfa_level*: Option[int]
        application_id*: Option[string]
        widget_enabled*: Option[bool]
        widget_channel_id*: Option[string]
        system_channel_id*: Option[string]
        joined_at*: Option[string]
        large*: Option[bool]
        unavailable*: Option[bool]
        member_count*: Option[int]
        voice_states*: Option[seq[VoiceState]]
        members*: Option[seq[GuildMember]]
        channels*: Option[seq[Channel]]
        presences*: Option[seq[Presence]]
    GuildMember* = object
        guild_id*: Option[string]
        user*: Option[User]
        nick*: Option[string]
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
        account*: IntegrationAccount
        synced_at*: string
    IntegrationAccount* = object
        id*: string
        name*: string
    Invite* = object
        code*: string
        guild*: Option[InviteGuild]
        channel*: Option[InviteChannel]
        approximate_presence_count*: Option[int]
        approximate_member_count*: Option[int]
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
    User* = object
        id*: string
        username*: string
        discriminator*: string
        avatar*: Option[string]
        bot*: Option[bool]
        mfa_enabled*: Option[bool]
        locale*: Option[string]
        verified*: Option[bool]
        email*: Option[string]
    UserGuild* = object
        id*: string
        name*: string
        icon*: string
        owner*: bool
        permissions*: int
    Connection* = object
        id*: string
        name*: string
        `type`*: string
        revoked*: bool
        integrations*: seq[Integration]
    VoiceState* = object
        guild_id*: Option[string]
        channel_id*: Option[string]
        user_id*: string
        member*: Option[GuildMember]
        session_id*: string
        deaf*: bool
        mute*: bool
        self_deaf*: bool
        self_mute*: bool
        suppress*: bool
    VoiceRegion* = object
        id*: string
        name*: string
        vip*: bool
        optimal*: bool
        deprecated*: bool
        custom*: bool
    Webhook* = object
        id*: string
        guild_id*: Option[string]
        channel_id*: string
        user*: Option[User]
        name*: Option[string]
        avatar*: Option[string]
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
    ChannelParams* = object
        name*: string
        position*: int
        topic*: string
        nsfw*: bool
        rate_limit_per_user*: int
        bitrate*: int
        user_limit*: int
        permission_overwrites*: seq[Overwrite]
        parent_id*: string
    GuildParams* = object
        name*: string
        region*: string
        verification_level*: int
        default_message_notifications*: int
        afk_channel_id*: string
        afk_timeout*: int
        icon*: string
        owner_id*: string
        splash*: string
    GuildMemberParams* = object
        nick*: string
        roles*: seq[string]
        mute*: bool
        deaf*: bool
        channel_id*: string
    GuildEmbed* = object
        enabled*: bool
        channel_id*: Option[string]
    GuildBan* = object
        reason*: Option[string]
        user*: User
    WebhookParams* = object
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
    AuditLogChangeValue* = ref object
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
        reason*: string
    AuditLog* = object
        webhooks*: seq[Webhook]
        users*: seq[User]
        audit_log_entries*: seq[AuditLogEntry]
    MessageDeleteBulk* = object
        ids*: seq[string]
        channel_id*: string
        guild_id*: string
    Game* = object
        name*: string
        `type`*: int
        url*: Option[string]
        # session_id: string # Should appear at some point in the payload
    PresenceUpdate* = object
        user*: User
        nick: string
        roles*: seq[string]
        game*: Game
        guild_id*: string
        status*: string
    TypingStart* = object
        guild_id*: string
        channel_id*: string
        user_id*: string
        timestamp*: int
    VoiceServerUpdate* = object
        token: string
        guild_id: string
        endpoint: string
    VoiceConnection* = object
        
    Resumed* = object
        trace*: seq[string]
    Cache* = ref object
        version*: int
        me*: User
        cacheChannels*: bool
        cacheGuilds*: bool
        cacheGuildMembers*: bool
        cacheUsers*: bool
        cacheRoles*: bool
        channels*: Table[string, Channel]
        guilds*: Table[string, Guild]
        users*: Table[string, User]
        members*: Table[string, GuildMember]
        roles*: Table[string, Role]
        ready*: Ready
    Ready* = object
        v*: int
        user*: User
        private_channels*: seq[Channel]
        session_id*: string
        guilds*: seq[Guild]
        trace*: Option[seq[string]]
    Pin* = object
        last_pin_timestamp*: string
        channel_id*: string
    MessageCreate* = Message
    MessageUpdate* = Message
    MessageDelete* = Message
    GuildMemberAdd* = GuildMember
    GuildMemberUpdate* = GuildMember
    GuildMemberRemove* = GuildMember
    GuildMembersChunk* = object
        guild_id*: string
        members*: seq[GuildMember]
    GuildCreate* = Guild
    GuildUpdate* = Guild
    GuildDelete* = object
        id*: string
        unavailable*: bool
    GuildBanAdd* = User
    GuildBanRemove* = User
    ChannelCreate* = Channel
    ChannelUpdate* = Channel
    ChannelDelete* = Channel
    ChannelPinsUpdate* = Pin
    UserUpdate* = User
    VoiceStateUpdate* = VoiceState
    MessageReactionAdd* = object
        user_id*: string
        message_id*: string
        channel_id*: string
        guild_id*: string
        emoji*: Emoji
    MessageReactionRemove* = MessageReactionAdd
    MessageReactionRemoveAll* = object
        message_id*: string
        channel_id*: string
        guild_id*: string
    WebhooksUpdate* = Webhook
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
        on_disconnect
    Shard* = ref ShardImpl
    ShardImpl = object
        shouldResume*: bool
        suspended*: bool
        invalidated*: bool
        stop*: bool
        compress*: bool
        sequence*: int
        interval*: int
        shardID*: int 
        token*: string
        gateway*: string
        session_id*: string
        cache*: Cache
        limiter*: RateLimits
        connection*: AsyncWebSocket
        voiceConnections: Table[string, VoiceConnection] # voice connection tied to guild
        globalRL*: RateLimits
        handlers*: Table[EventType, seq[pointer]]
        shardCount*: int
    
const DISCORD_EPOCH = int64(1420070400000)

proc timestamp*(s: string): DateTime =
    ## Makes a timestamp from the Snowflake
    var i = (s.parseBiggestInt.int64)
    i = ((i shr 22) + DISCORD_EPOCH) div 1000
    i.fromUnix.utc
 
proc addHandler*(d: Shard, t: EventType, p: pointer): (proc()) {.gcsafe, inline.} =
    ## Adds a handler tied to a websocket event.
    ##
    ## Returns a proc that removes the event handler.
    if not d.handlers.hasKey(t): 
        d.handlers.add(t, newSeq[pointer]())

    d.handlers[t].add(p)
    let i = d.handlers[t].high

    result = proc()=
        d.handlers[t].del(i) 

proc `%`*[T](o: Option[T]): JsonNode = 
    new(result)
    let default = when T is SomeInteger:
        0
    elif T is bool:
        false
    elif T is string:
        ""
    else:
        new(T)[]
    result = %(o.get(default))

{.hint[Pattern]: off.}
when defined(generateCtors):
    import macros
    macro genCtor(t: untyped): untyped =
        let 
            id = ident("new" & $t)
            res = ident("result")
        result = quote do:
            proc `id`*(node: JsonNode): `t` {.inline.} = 
                `res` = node.to(`t`)
        
        echo result.repr

    genCtor(User)
    genCtor(Overwrite)
    genCtor(Channel)
    genCtor(EmbedFooter)
    genCtor(EmbedImage)
    genCtor(EmbedThumbnail)
    genCtor(EmbedVideo)
    genCtor(EmbedProvider)
    genCtor(EmbedAuthor)
    genCtor(EmbedField)
    genCtor(Embed)
    genCtor(Attachment)
    genCtor(MessageActivity)
    genCtor(MessageApplication)
    genCtor(Emoji)
    genCtor(Reaction)
    genCtor(Message)
    genCtor(Game)
    genCtor(Presence)
    genCtor(Role)
    genCtor(GuildMember)
    genCtor(VoiceState)
    genCtor(VoiceRegion)
    genCtor(Guild)
    genCtor(IntegrationAccount)
    genCtor(InviteGuild)
    genCtor(InviteChannel)
    genCtor(Invite)
    genCtor(InviteMetadata)
    genCtor(UserGuild)
    genCtor(Integration)
    genCtor(Connection)
    genCtor(Webhook)
    genCtor(ChannelParams)
    genCtor(GuildParams)
    genCtor(GuildMemberParams)
    genCtor(GuildEmbed)
    genCtor(WebhookParams)
    genCtor(GuildEmojisUpdate)
    genCtor(GuildIntegrationsUpdate)
    genCtor(GuildRoleCreate)
    genCtor(GuildRoleUpdate)
    genCtor(GuildRoleDelete)
    genCtor(AuditLogOptions)
    genCtor(MessageDeleteBulk)
    genCtor(PresenceUpdate)
    genCtor(TypingStart)
    genCtor(VoiceServerUpdate)
    genCtor(Resumed)
    genCtor(MessageCreate)
    genCtor(MessageUpdate)
    genCtor(MessageDelete)
    genCtor(GuildMemberAdd)
    genCtor(GuildMemberUpdate)
    genCtor(GuildMemberRemove)
    genCtor(GuildMembersChunk)
    genCtor(GuildCreate)
    genCtor(GuildUpdate)
    genCtor(GuildDelete)
    genCtor(GuildBanAdd)
    genCtor(GuildBanRemove)
    genCtor(ChannelCreate)
    genCtor(ChannelUpdate)
    genCtor(ChannelDelete)
    genCtor(Pin)
    genCtor(ChannelPinsUpdate)
    genCtor(UserUpdate)
    genCtor(VoiceStateUpdate)
    genCtor(MessageReactionRemove)
    genCtor(WebhooksUpdate)
    genCtor(MessageReactionAdd)
    genCtor(MessageReactionRemoveAll)
    genCtor(Ready)
    
include ctors

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

proc newAuditLogChange(change: JsonNode): AuditLogChange =
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

proc newAuditLogEntry*(node: JsonNode): AuditLogEntry {.inline.} =
    result = AuditLogEntry(
        target_id: node["target_id"].str,
        changes: newSeq[AuditLogChange](node["changes"].elems.len),
        user_id: node["user_id"].str,
        id: node["id"].str,
        action_type: node["action_type"].getInt(),
        options: node["options"].to(AuditLogOptions),
        reason: node["reason"].str,
    )

    for i, n in node["changes"].elems:
        result.changes[i] = newAuditLogChange(n)

proc newAuditLog*(node: JsonNode): AuditLog {.inline.} =
    result = AuditLog(
        webhooks: node["webhooks"].to(seq[Webhook]),
        users: node["users"].to(seq[User]),
        audit_log_entries: newSeq[AuditLogEntry](node["audit_log_entries"].elems.len)
    )

    for i, n in node["audit_log_entires"].elems:
        result.audit_log_entries[i] = newAuditLogEntry(n)


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

type CacheError = object of Exception

# Caching stuff
proc getGuild*(c: Cache, id: string): tuple[guild: Guild, exists: bool] {.gcsafe.} =
    ## Gets a guild from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    result = (Guild(), false)
    
    if c.guilds.hasKey(id):
        result.guild = c.guilds[id]
        for g in c.ready.guilds:
            if g.id == result.guild.id:
                result.guild.join(g)
                result.exists = true
                break

proc removeGuild*(c: Cache, guildid: string) {.raises: CacheError, gcsafe.}  =
    ## Removes a guild from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")

    if not c.guilds.hasKey(guildid): return
    
    c.guilds.del(guildid)

proc updateGuild*(c: Cache, guild: Guild) {.raises: CacheError, inline, gcsafe.} =
    ## Updates a guild in the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    
    c.guilds[guild.id] = guild

proc getUser*(c: Cache, id: string): tuple[user: User, exists: bool] {.gcsafe.}  =
    ## Gets a user from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    result = (User(), false)
    
    if c.users.hasKey(id):
       result = (c.users[id], true)

proc removeUser*(c: Cache, id: string) {.raises: CacheError, inline, gcsafe.}  =
    ## Removes a user from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    if not c.users.hasKey(id): return

    c.users.del(id)

proc updateUser*(c: Cache, user: User) {.inline, gcsafe.}  =
    ## Updates a user in the cache
    if c == nil: raise newException(CacheError, "The cache is nil")

    c.users[user.id] = user

proc getChannel*(c: Cache, id: string): tuple[channel: Channel, exists: bool] {.gcsafe.} =
    ## Gets a channel from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    result = (Channel(), false)

    if c.channels.hasKey(id):
        result = (c.channels[id], true)


proc updateChannel*(c: Cache, chan: Channel) {.inline, gcsafe.}  =
    ## Updates a channel in the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    c.channels[chan.id] = chan

proc removeChannel*(c: Cache, chan: string) {.raises: CacheError, inline, gcsafe.}  =
    ## Removes a channel from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    if not c.channels.hasKey(chan): return

    c.channels.del(chan)

proc getGuildMember*(c: Cache, guild, memberid: string): tuple[member: GuildMember, exists: bool] {.gcsafe.} =
    ## Gets a guild member from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    
    result = (GuildMember(), false)
    var (guild, exists) = c.getGuild(guild)

    if not exists:
        return
    
    for member in guild.members.get: 
        if member.user.get().id == memberid:
            result = (member, true)
            break

proc addGuildMember*(c: Cache, member: GuildMember) {.inline, gcsafe.} =
    ## Adds a guild member to the cache
    if c == nil: raise newException(CacheError, "The cache is nil")

    c.members.add(member.user.get().id, member)

proc updateGuildMember*(c: Cache, m: GuildMember) {.inline, gcsafe.} =
    ## Updates a guild member in the cache
    if c == nil: raise newException(CacheError, "The cache is nil")

    c.members[m.user.get().id] = m

proc removeGuildMember*(c: Cache, gmember: GuildMember) {.inline, gcsafe.} =
    ## Removes a guild member from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    c.members.del(gmember.user.get().id)

proc getRole*(c: Cache, guildid, roleid: string): tuple[role: Role, exists: bool] {.gcsafe.} =
    ## Gets a role from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    
    result = (Role(), false)
    var (guild, exists) = c.getGuild(guildid)

    if not exists:
        return
    
    for role in guild.roles.get():
        if role.id == roleid:
            result = (role, true)
            return

proc updateRole*(c: Cache, role: Role) {.raises: CacheError, gcsafe.} =
    ## Updates a role in the cache
    if c == nil: raise newException(CacheError, "The cache is nil")
    c.roles[role.id] = role

proc removeRole*(c: Cache, role: string) {.raises: CacheError, gcsafe.} =
    ## Removes a role from the cache
    if c == nil: raise newException(CacheError, "The cache is nil")

    if not c.roles.hasKey(role): return

    c.roles.del(role)

proc clear*(c: Cache) {.gcsafe.} =
    ## Clears a cache of all cached objects
    c.channels.clear()
    c.guilds.clear()
    c.members.clear()
    c.roles.clear()
    c.users.clear()
