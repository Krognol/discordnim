import json, tables, locks, websocket/shared, times, httpclient, strutils, asyncdispatch, marshal, sequtils, macros, typetraits
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

method postCheck(r: RateLimit, url: string, response: AsyncResponse): Future[bool] {.async, gcsafe, base.} =
    if response.headers.hasKey("X-RateLimit-Reset"): r.reset = response.headers["X-RateLimit-Reset"].parseInt
    if response.headers.hasKey("X-RateLimit-Limit"): r.limit = response.headers["X-RateLimit-Limit"].parseInt
    if response.headers.hasKey("X-RateLimit-Remaining"): r.remaining = response.headers["X-RateLimit-Remaining"].parseInt

    if response.code == Http429:
        let delay = if response.headers.hasKey("Retry-After"): response.headers["Retry-After"].parseInt else: -1
        if delay == -1: return false

        await sleepAsync delay+100
        result = true

method postCheck(r: RateLimits, url: string, response: AsyncResponse): Future[bool] {.async, gcsafe, base.} =
    if response.headers.hasKey("X-RateLimit-Global"):
        initLock(r.global.lock)
        result = await r.global.postCheck(url, response)
        deinitLock(r.global.lock)
    else:
        let rl = if r.endpoints.hasKey(url): r.endpoints[url] else: RateLimit(lock: Lock(), reset: 0, limit: 0, remaining: 0)
        initLock(rl.lock)
        result = await rl.postCheck(url, response)
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
    Snowflake* = object
        ## Snowlake is a unique id for most Discord objects
        val*: string
    Overwrite* = object
        id*: Snowflake
        `type`*: string
        allow*: int
        deny*: int
    ChannelType* = enum
        CTGuildText
        CTDM
        CTGuildVoice
        CTGroupDM
        CTGuildCategory
    Channel* = object
        id*: Snowflake
        `type`*: ChannelType
        guild_id*: string
        position*: int
        permission_overwrites*: seq[Overwrite]
        name*: string
        topic*: string
        nsfw*: bool
        last_message_id*: string
        bitrate*: int
        user_limit*: int
        recipients*: seq[User]
        icon*: string
        owner_id*: string
        application_id*: string
        parent_id*: string
        last_pin_timestamp*: string
        rate_limit_per_user*: int
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
        party_id*: string
    MessageApplication* = object
        id*: Snowflake
        cover_image*: string
        description*: string
        icon*: string
        name*: string
    Message* = object
        id*: Snowflake
        channel_id*: string
        author*: User
        content*: string
        timestamp*: string
        edited_timestamp*: string
        tts*: bool
        mention_everyone*: bool
        mentions*: seq[User]
        mention_roles*: seq[string]
        attachments*: seq[Attachment]
        embeds*: seq[Embed]
        reactions*: seq[Reaction]
        nonce*: string
        pinned*: bool
        webhook_id*: string
        `type`*: MessageType
        activity*: MessageActivity
        application*: MessageApplication
        guild_id*: string
    Reaction* = object
        count*: int
        me*: bool
        emoji*: Emoji
    Emoji* = object
        id*: Snowflake
        name*: string
        roles*: seq[string]
        user*: User
        require_colons*: bool
        managed*: bool
        animated*: bool
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
        fields*: seq[EmbedField]
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
        id*: Snowflake
        filename*: string
        size*: int
        url*: string
        proxy_url*: string
        height*: int
        width*: int
    Presence* = object
        since*: int
        afk*: bool
        game*: Game
        status*: string
    Guild* = object
        id*: Snowflake
        name*: string
        icon*: string
        splash*: string
        owner*: bool
        owner_id*: string
        permissions*: int
        region*: string
        afk_channel_id*: string
        afk_timeout*: int
        embed_enabled*: bool
        embed_channel_id*: string
        verification_level*: int
        default_message_notifications*: int
        explicit_content_filter*: int
        roles*: seq[Role]
        emojis*: seq[Emoji]
        features*: seq[string]
        mfa_level*: int
        application_id*: string
        widget_enabled*: bool
        widget_channel_id*: string
        system_channel_id*: string
        joined_at*: string
        large*: bool
        unavailable*: bool
        member_count*: int
        voice_states*: seq[VoiceState]
        members*: seq[GuildMember]
        channels*: seq[Channel]
        presences*: seq[Presence]
    GuildMember* = object
        guild_id*: string
        user*: User
        nick*: string
        roles*: seq[string]
        joined_at*: string
        deaf*: bool
        mute*: bool
    Integration* = object
        id*: Snowflake
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
        id*: Snowflake
        name*: string
    Invite* = object
        code*: string
        guild*: InviteGuild
        channel*: InviteChannel
        approximate_presence_count*: int
        approximate_member_count*: int
    InviteMetadata* = object
        inviter*: User
        uses*: int
        max_uses*: int
        max_age*: int
        temporary*: bool
        created_at*: string
        revoked*: bool
    InviteGuild* = object
        id*: Snowflake
        name*: string
        splash*: string
        icon*: string
    InviteChannel* = object
        id*: Snowflake
        name*: string
        `type`*: int
    User* = object
        id*: Snowflake
        username*: string
        discriminator*: string
        avatar*: string
        bot*: bool
        mfa_enabled*: bool
        locale*: string
        verified*: bool
        email*: string
    UserGuild* = object
        id*: Snowflake
        name*: string
        icon*: string
        owner*: bool
        permissions*: int
    Connection* = object
        id*: Snowflake
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
        id*: Snowflake
        name*: string
        vip*: bool
        optimal*: bool
        deprecated*: bool
        custom*: bool
    Webhook* = object
        id*: Snowflake
        guild_id*: string
        channel_id*: string
        user*: User
        name*: string
        avatar*: string
        token*: string
    Role* = object
        id*: Snowflake
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
        channel_id*: string
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
        id*: Snowflake
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
        id*: Snowflake
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
        lock: Lock
        version*: int
        me*: User
        cacheChannels*: bool
        cacheGuilds*: bool
        cacheGuildMembers*: bool
        cacheUsers*: bool
        cacheRoles*: bool
        channels: Table[string, Channel]
        guilds: Table[string, Guild]
        users: Table[string, User]
        members: Table[string, GuildMember]
        roles: Table[string, Role]
        ready: Ready
    Ready* = object
        v*: int
        user*: User
        private_channels*: seq[Channel]
        session_id*: string
        guilds*: seq[Guild]
        trace*: seq[string]
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
        id*: Snowflake
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
        shouldResume: bool
        suspended: bool
        invalidated: bool
        stop: bool
        compress*: bool
        sequence: int
        interval: int
        shardID*: int 
        token*: string
        gateway*: string
        session_id: string
        cache*: Cache
        limiter: RateLimits
        connection*: AsyncWebSocket
        voiceConnections: Table[string, VoiceConnection] # voice connection tied to guild
        mut: Lock
        globalRL: RateLimits
        handlers: Table[EventType, seq[pointer]]
        shardCount*: int
    
const DISCORD_EPOCH = int64(1420070400000)

method timestamp*(s: Snowflake): DateTime {.base.} =
    ## Makes a timestamp from the Snowflake
    var i = (s.val.parseBiggestInt.int64)
    i = ((i shr 22) + DISCORD_EPOCH) div 1000
    i.fromUnix.utc

proc toSnowflake*(id: string): Snowflake {.inline.}  = Snowflake(val: id)
proc toSnowflake*(id: int64): Snowflake {.inline.}  = Snowflake(val: $id)
proc newSnowflake*(node: JsonNode): Snowflake {.inline.} =
    case node.kind
    of JInt: result = toSnowflake(node.num)
    of JString: result = toSnowflake(node.str)
    else: result = Snowflake(val: "")
proc `==`*(a, b: Snowflake): bool {.inline.}  = a.val == b.val
proc `==`*(a: Snowflake, b: string): bool {.inline.}  = a.val == b
proc `==`*(a: string, b: Snowflake): bool {.inline.}  = a == b.val

# This is a hack because 
# seq is nil check broke for some reason.
proc `==`*(a: seq[pointer], b: type(nil)): bool {.inline.} = a == b

proc `&`*(a: string, b: Snowflake): string {.inline.}  = a & b.val
proc `$`*(a: Snowflake): string {.inline.} = a.val

method addHandler*(d: Shard, t: EventType, p: pointer): (proc()) {.gcsafe, base, inline.} =
    ## Adds a handler tied to a websocket event.
    ##
    ## Returns a proc that removes the event handler.
    initLock(d.mut)
    if not d.handlers.hasKey(t): 
        d.handlers.add(t, newSeq[pointer]())
    else: 
        if d.handlers[t] == nil: d.handlers[t] = newSeq[pointer]()

    d.handlers[t].add(p)
    let i = d.handlers[t].high
    deinitLock(d.mut)

    result = proc()=
        initLock(d.mut)
        d.handlers[t].del(i) 
        deinitLock(d.mut)

proc getRecList(node: NimNode): NimNode {.compileTime.} =
    expectKind(node, nnkObjectTy)
    result = node[2]

template genHasKeyCheck(key, kind, default: NimNode): NimNode =
    newTree(
        nnkIfExpr,
        newTree(
            nnkElifExpr,
            newTree(
                nnkInfix,
                newIdentNode("and"),
                newCall(
                    newDotExpr(
                        newIdentNode("node"),
                        newIdentNode("hasKey"),
                    ),
                    key,
                ),
                newTree(
                    nnkInfix,
                    newIdentNode("!="),
                    newDotExpr(
                        newTree(
                            nnkBracketExpr,
                            newIdentNode("node"),
                            key
                        ),
                        newIdentNode("kind")
                    ),
                    newIdentNode("JNull")
                )
            ),
            newDotExpr(
                newTree(
                    nnkBracketExpr,
                    newIdentNode("node"),
                    key,
                ),
                kind
            )
        ),
        newTree(
            nnkElseExpr,
            newStmtList(
                default,
            )
        )
    )

macro genCtor(T: typedesc): untyped =
    let 
        realType = T.getTypeInst[1]
        tname = $realType
    
    let recList = getRecList(realType.getTypeImpl)

    result = newTree(
        nnkProcDef,
        newIdentNode("new" & tname),
        newEmptyNode(),
        newEmptyNode(),
        newTree(
            nnkFormalParams,
            newIdentNode(tname),
            newIdentDefs(
                newIdentNode("node"),
                newIdentNode("JsonNode")
            ),
        ),
        newTree(
            nnkPragma,
            newIdentNode("inline"),
        ),
        newEmptyNode(),
    )

    let 
        ctor = newTree(nnkObjConstr, newIdentNode(tname))
    var postCtorStmt = newSeq[NimNode]()

    for field in recList:
        let
            fieldName = field[0]
            fieldKind = field[1]
            fieldNameStr = newStrLitNode($fieldName)
        
        let ece = newTree(
            nnkExprColonExpr,
            newIdentNode($fieldName)
        )
        
        case fieldKind.kind
        of nnkBracketExpr:
            postCtorStmt.add(
                newStmtList(
                    newTree(
                        nnkIfExpr,
                        newTree(
                            nnkElifBranch,
                            newTree(
                                nnkInfix,
                                newIdentNode("and"),
                                newCall(
                                    newDotExpr(
                                        newIdentNode("node"),
                                        newIdentNode("hasKey")
                                    ),
                                    fieldNameStr,
                                ),
                                newTree(
                                    nnkInfix,
                                    newIdentNode(">"),
                                    newDotExpr(
                                        newDotExpr(
                                            newTree(
                                                nnkBracketExpr,
                                                newIdentNode("node"),
                                                fieldNameStr,
                                            ),
                                            newIdentNode("elems")
                                        ),
                                        newIdentNode("len")
                                    ),
                                    newIntLitNode(0),
                                )
                            ),
                            newStmtList(
                                newAssignment(
                                    newDotExpr(
                                        newIdentNode("result"),
                                        fieldName,
                                    ),
                                    newCall(
                                        newTree(
                                            nnkBracketExpr,
                                            newIdentNode("newSeq"),
                                            fieldKind[1],
                                        ),
                                        newDotExpr(
                                            newDotExpr(
                                                newTree(
                                                    nnkBracketExpr,
                                                    newIdentNode("node"),
                                                    fieldNameStr,
                                                ),
                                                newIdentNode("elems")
                                            ),
                                            newIdentNode("len")
                                        )
                                    )
                                ),
                                newTree(
                                    nnkForStmt,
                                    newIdentNode("i"),
                                    newIdentNode("n"),
                                    newDotExpr(
                                        newTree(
                                            nnkBracketExpr,
                                            newIdentNode("node"),
                                            fieldNameStr,
                                        ),
                                        newIdentNode("elems")
                                    ),
                                )
                            )
                        )
                    )
                )
            )

            let seqAsgnStmt = newStmtList(
                newTree(
                    nnkAsgn,
                    newTree(
                        nnkBracketExpr,
                        newDotExpr(
                            newIdentNode("result"),
                            fieldName,
                        ),
                        newIdentNode("i")
                    )
                )
            )

            case $fieldKind[1]
            of "int": 
                seqAsgnStmt[0].add(newCall(newIdentNode("int"), newDotExpr(newIdentNode("n"), newIdentNode("num"))))
            of "int64": seqAsgnStmt[0].add(newDotExpr(newIdentNode("n"), newIdentNode("num")))
            of "float": seqAsgnStmt[0].add(newDotExpr(newIdentNode("n"), newIdentNode("fnum")))
            of "string": seqAsgnStmt[0].add(newDotExpr(newIdentNode("n"), newIdentNode("str")))
            else: seqAsgnStmt[0].add(newCall(newIdentNode("new" & $fieldKind[1]), newIdentNode("n")))
            postCtorStmt[postCtorStmt.high][0][0][1][1].add(seqAsgnStmt)
        else:
            case $fieldKind
            of "int": 
                let tree = genHasKeyCheck(fieldNameStr, newIdentNode("num"), newIntLitNode(0))
                tree[0][1] = newDotExpr(tree[0][1], newIdentNode("int"))
                ece.add(tree)
            of "int64": ece.add(genHasKeyCheck(fieldNameStr, newIdentNode("num"), newIntLitNode(0)))
            of "float": ece.add(genHasKeyCheck(fieldNameStr, newIdentNode("fnum"), newFloatLitNode(0.0)))
            of "string": ece.add(genHasKeyCheck(fieldNameStr, newIdentNode("str"), newStrLitNode("")))
            of "bool": ece.add(genHasKeyCheck(fieldNameStr, newIdentNode("bval"), newLit(false)))
            else: 
                if fieldKind.getType.kind == nnkEnumTy:
                    let tree = genHasKeyCheck(fieldNameStr, newIdentNode("num"), newCall(newIdentNode($fieldKind), newIntLitNode(0)))
                    tree[0][1] = newCall(newIdentNode($fieldKind), newDotExpr(newTree(nnkBracketExpr, newIdentNode("node"), fieldNameStr), newIdentNode("num")))
                    ece.add(tree)
                else:
                    let tree = genHasKeyCheck(fieldNameStr, newEmptyNode(), newCall(newIdentNode($fieldKind)))
                    tree[0][1][1] = newIdentNode("new" & $fieldKind)
                    ece.add(tree)
            ctor.add(ece)
    result.add(
        newStmtList(
            newAssignment(
                newIdentNode("result"),
                ctor
            ),
        )
    )

    if len(postCtorStmt) > 0:
        result[result.len-1].add(postCtorStmt)

    # echo result.repr

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
proc newMessageCreate(node: JsonNode): MessageUpdate {.inline.} =
    result = newMessage(node)
proc newMessageUpdate(node: JsonNode): MessageUpdate {.inline.} =
    result = newMessage(node)
proc newMessageDelete(node: JsonNode): MessageUpdate {.inline.} =
    result = newMessage(node)
proc newGuildMemberAdd(node: JsonNode): GuildMemberAdd {.inline.} =
    result = newGuildMember(node)
proc newGuildMemberUpdate(node: JsonNode): GuildMemberUpdate {.inline.} =
    result = newGuildMember(node)
proc newGuildMemberRemove(node: JsonNode): GuildMemberRemove {.inline.} =
    result = newGuildMember(node)
genCtor(GuildMembersChunk)
proc newGuildCreate(node: JsonNode): GuildCreate {.inline.} =
    result = newGuild(node)
proc newGuildUpdate(node: JsonNode): GuildUpdate {.inline.} =
    result = newGuild(node)
genCtor(GuildDelete)
proc newGuildBanAdd(node: JsonNode): GuildBanAdd {.inline.} =
    result = newUser(node)
proc newGuildBanRemove(node: JsonNode): GuildBanRemove {.inline.} =
    result = newUser(node)
proc newChannelCreate(node: JsonNode): ChannelCreate {.inline.} =
    result = newChannel(node)
proc newChannelUpdate(node: JsonNode): ChannelUpdate {.inline.} =
    result = newChannel(node)
proc newChannelDelete(node: JsonNode): ChannelDelete {.inline.} =
    result = newChannel(node)
genCtor(Pin)
proc newChannelPinsUpdate(node: JsonNode): ChannelPinsUpdate {.inline.} =
    result = newPin(node)
proc newUserUpdate(node: JsonNode): UserUpdate {.inline.} =
    result = newUser(node)
proc newVoiceStateUpdate(node: JsonNode): VoiceStateUpdate {.inline.} =
    result = newVoiceState(node)
genCtor(MessageReactionAdd)
proc newMessageReactionRemove(node: JsonNode): MessageReactionRemove {.inline.} =
    result = newMessageReactionAdd(node)
genCtor(MessageReactionRemoveAll)
proc newWebhooksUpdate(node: JsonNode): WebhooksUpdate {.inline.} =
    result = newWebhook(node)
genCtor(Ready)

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

genCtor(AuditLogEntry)
genCtor(AuditLog)

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
