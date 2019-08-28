import jstin, options

type
    Snowflake* = distinct string
    AuditLog* = object
        webhooks*: seq[Webhook]
        users*: seq[User]
        audit_log_entries*: seq[AuditLogEntry]
    AuditLogEntry* = object
        target_id*: Option[string]
        changes* {.fieldTag(omit=WhenEmpty).}: seq[AuditLogChange]
        user_id*: Snowflake
        id*: Snowflake
        action_type*: AuditLogEvent
        options* {.fieldTag(omit=WhenEmpty).}: AuditEntryInfo
        reason* {.fieldTag(omit=WhenEmpty).}: string
    AuditLogEvent* = enum
        aleGuildUpdate = 1
        aleChannelCreate = 10
        aleChannelUpdate
        aleChannelDelete
        aleChannelOverwriteCreate
        aleChannelOverwriteUpdate
        aleChannelOverwriteDelete
        aleMemberKick = 20
        aleMemberPrune
        aleMemberBanAdd
        aleMemberBanRemove
        aleMemberUpdate
        aleMemberRoleUpdate
        aleRoleCreate = 30
        aleRoleUpdate
        aleRoleDelete
        aleInviteCreate = 40
        aleInviteUpdate
        aleInviteDelete
        aleWebhookCreate = 50
        aleWebhookUpdate
        aleWebhookDelete
        aleEmojiCreate = 60
        aleEmojiUpdate
        aleEmojiDelete
        aleMessageDelete = 72
    AuditEntryInfo* = object
        delete_member_days*: string
        members_removed*: string
        channel_id*: Snowflake
        count*: string
        id*: Snowflake
        `type`*: string
        role_name*: string
    AuditLogChangeValueKind* = enum
        alcString
        alcInt
        alcBool
        alcRoles
        alcOverwrites
    AuditLogChangeValue* = object
        case kind*: AuditLogChangeValueKind
        of alcString: str*: string
        of alcInt: ival*: int
        of alcBool: bval*: bool
        of alcRoles: roles*: seq[Role]
        of alcOverwrites: overwrites*: seq[Overwrite]
    AuditLogChange* = object
        new_value* {.fieldTag(omit=WhenEmpty).}: AuditLogChangeValue
        old_value* {.fieldTag(omit=WhenEmpty).}: AuditLogChangeValue 
        key*: string
    Channel* = object
        id*: Snowflake
        `type`*: ChannelType
        guild_id* {.fieldTag(omit=WhenEmpty).}: Snowflake
        position* {.fieldTag(omit=WhenEmpty).}: int
        permission_overwrites* {.fieldTag(omit=WhenEmpty).}: seq[Overwrite]
        name* {.fieldTag(omit=WhenEmpty).}: string
        topic* {.fieldTag(omit=WhenEmpty).}: Option[string]
        nsfw* {.fieldTag(omit=WhenEmpty).}: bool
        last_message_id* {.fieldTag(omit=WhenEmpty).}: Option[string]
        bitrate* {.fieldTag(omit=WhenEmpty).}: int
        user_limit* {.fieldTag(omit=WhenEmpty).}: int
        rate_limit_per_user* {.fieldTag(omit=WhenEmpty).}: int
        recipients* {.fieldTag(omit=WhenEmpty).}: seq[User]
        icon* {.fieldTag(omit=WhenEmpty).}: Option[string]
        owner_id* {.fieldTag(omit=WhenEmpty).}: Snowflake
        application_id* {.fieldTag(omit=WhenEmpty).}: Snowflake
        parent_id* {.fieldTag(omit=WhenEmpty).}: Option[Snowflake]
        last_pin_timestamp* {.fieldTag(omit=WhenEmpty).}: string
    ChannelType* = enum
        ctGuildText
        ctDM
        ctGuildVoid
        ctGroupDM
        ctGuildCategory
        ctGuildNews
        ctGuildStore
    Message* = object
        id*: Snowflake
        channel_id*: Snowflake
        guild_id* {.fieldTag(omit=WhenEmpty).}: Snowflake
        author*: User
        member* {.fieldTag(omit=WhenEmpty).}: GuildMember
        content*: string
        timestamp*: string
        edited_timestamp: Option[string]
        tts*: bool
        mention_everyone*: bool
        mentions*: seq[User]
        mention_roles*: seq[Role]
        mention_channels* {.fieldTag(omit=WhenEmpty).}: seq[ChannelMention]
        attachments*: seq[Attachment]
        embeds*: seq[Embed]
        reactions* {.fieldTag(omit=WhenEmpty).}: seq[Reaction]
        nonce* {.fieldTag(omit=WhenEmpty).}: Option[string]
        pinned*: bool
        webhook_id* {.fieldTag(omit=WhenEmpty).}: Snowflake
        `type`*: MessageType
        activity* {.fieldTag(omit=WhenEmpty).}: MessageActivityType
        application* {.fieldTag(omit=WhenEmpty).}: MessageApplication
        message_reference* {.fieldTag(omit=WhenEmpty).}: MessageReference
        flags* {.fieldTag(omit=WhenEmpty).}: int
    MessageType* = enum
        mtDefault
        mtRecipientAdd
        mtRecipientRemove
        mtCall
        mtChannelNameChange
        mtChannelIconChange
        mtChannelPinnedMessage
        mtGuildMemberJoin
        mtUserPremiumGuildSubscription
        mtUserPremiumGuildSubscriptionTier1
        mtUserPremiumGuildSubscriptionTier2
        mtUserPremiumGuildSubscriptionTier3
        mtChannelFollowAdd
    MessageActivityType* = enum
        matJoin
        matSpectate
        matListen
        matJoinRequest
    MessageActivity* = object
        `type`*: MessageActivityType
        party_id* {.fieldTag(omit=WhenEmpty).}: string
    MessageApplication* = object
        id*: Snowflake
        cover_image* {.fieldTag(omit=WhenEmpty).}: string
        description*: string
        icon*: Option[string]
        name*: string
    MessageReference* = object
        message_id* {.fieldTag(omit=WhenEmpty).}: Snowflake
        channel_id*: Snowflake
        guild_id* {.fieldTag(omit=WhenEmpty).}: Snowflake
    MessageFlags* = enum
        mfCrossposted = (1 shl 0)
        mfIsCrossposted = (1 shl 1)
        mfSuppressEmbeds = (1 shl 2)
    Reaction* = object
        count*: int
        me*: bool
        emoji*: Emoji
    Overwrite* = object
        id*: Snowflake
        `type`*: string
        allow*: int
        deny*: int
    Embed* = object
        title* {.fieldTag(omit=WhenEmpty).}: string
        `type`* {.fieldTag(omit=WhenEmpty).}: string
        descritpion* {.fieldTag(omit=WhenEmpty).}: string
        url* {.fieldTag(omit=WhenEmpty).}: string
        timestamp* {.fieldTag(omit=WhenEmpty).}: string
        color* {.fieldTag(omit=WhenEmpty).}: int
        footer* {.fieldTag(omit=WhenEmpty).}: EmbedFooter
        image* {.fieldTag(omit=WhenEmpty).}: EmbedImage
        thumbnail* {.fieldTag(omit=WhenEmpty).}: EmbedThumbnail
        video* {.fieldTag(omit=WhenEmpty).}: EmbedVideo
        provider* {.fieldTag(omit=WhenEmpty).}: EmbedProvider
        author* {.fieldTag(omit=WhenEmpty).}: EmbedAuthor
        fields* {.fieldTag(omit=WhenEmpty).}: seq[EmbedField]
    EmbedThumbnail* = object
        url* {.fieldTag(omit=WhenEmpty).}: string
        proxy_url* {.fieldTag(omit=WhenEmpty).}: string
        height* {.fieldTag(omit=WhenEmpty).}: int
        width* {.fieldTag(omit=WhenEmpty).}: int
    EmbedVideo* = object
        url* {.fieldTag(omit=WhenEmpty).}: string
        height* {.fieldTag(omit=WhenEmpty).}: int
        width* {.fieldTag(omit=WhenEmpty).}: int
    EmbedImage* = object
        url* {.fieldTag(omit=WhenEmpty).}: string
        proxy_url* {.fieldTag(omit=WhenEmpty).}: string
        height* {.fieldTag(omit=WhenEmpty).}: int
        width* {.fieldTag(omit=WhenEmpty).}: int
    EmbedProvider* = object
        name* {.fieldTag(omit=WhenEmpty).}: string
        url* {.fieldTag(omit=WhenEmpty).}: string
    EmbedAuthor* = object
        name* {.fieldTag(omit=WhenEmpty).}: string
        url* {.fieldTag(omit=WhenEmpty).}: string
        icon_url* {.fieldTag(omit=WhenEmpty).}: string
        proxy_icon_url* {.fieldTag(omit=WhenEmpty).}: string
    EmbedFooter* = object
        text*: string
        icon_url* {.fieldTag(omit=WhenEmpty).}: string
        proxy_icon_url* {.fieldTag(omit=WhenEmpty).}: string
    EmbedField* = object
        name*: string
        value*: string
        inline* {.fieldTag(omit=WhenEmpty).}: bool
    Attachment* = object
        id*: Snowflake
        filename*: string
        size*: int
        url*: string
        proxy_url*: string
        height*: Option[int]
        width*: Option[int]
    ChannelMention* = object
        id*: Snowflake
        guild_id*: Snowflake
        `type`*: ChannelType
        name*: string
    Emoji* = object
        id*: Option[Snowflake]
        name*: string
        roles* {.fieldTag(omit=WhenEmpty).}: seq[Snowflake]
        user* {.fieldTag(omit=WhenEmpty).}: User
        require_colons* {.fieldTag(omit=WhenEmpty).}: bool
        managed* {.fieldTag(omit=WhenEmpty).}: bool
        animated* {.fieldTag(omit=WhenEmpty).}: bool
    Guild* = object
        id*: Snowflake
        name*: string
        icon*: Option[string]
        splash*: Option[string]
        owner* {.fieldTag(omit=WhenEmpty).}: bool
        owner_id*: Snowflake
        permissions* {.fieldTag(omit=WhenEmpty).}: int
        region*: string
        afk_channel_id*: Option[Snowflake]
        afk_timeout*: int
        embed_enabled {.fieldTag(omit=WhenEmpty).}: bool
        embed_channel_id {.fieldTag(omit=WhenEmpty).}: Snowflake
        verification_level*: VerificationLevel
        default_message_notification*: MessageNotificationLevel
        explicit_content_filter*: ExplicitContentFilterLevel
        roles*: seq[Role]
        emojis*: seq[Emoji]
        features*: seq[string]
        mfa_level*: MFALevel
        application_id*: Option[Snowflake]
        widget_enabled* {.fieldTag(omit=WhenEmpty).}: bool
        widget_channel_id* {.fieldTag(omit=WhenEmpty).}: Snowflake
        system_channel_id*: Option[Snowflake]
        joined_at* {.fieldTag(omit=WhenEmpty).}: string
        large* {.fieldTag(omit=WhenEmpty).}: bool
        unavailable* {.fieldTag(omit=WhenEmpty).}: bool
        member_count* {.fieldTag(omit=WhenEmpty).}: int
        voice_states* {.fieldTag(omit=WhenEmpty).}: seq[VoiceState]
        members* {.fieldTag(omit=WhenEmpty).}: seq[GuildMember]
        channels* {.fieldTag(omit=WhenEmpty).}: seq[Channel]
        presences* {.fieldTag(omit=WhenEmpty).}: seq[string] # TODO FIX
        max_presences* {.fieldTag(omit=WhenEmpty).}: Option[int]
        max_members* {.fieldTag(omit=WhenEmpty).}: int
        vanity_url_code*: Option[string]
        description*: Option[string]
        banner*: Option[string]
        premium_tier*: PremiumTier
        premium_subscription_count* {.fieldTag(omit=WhenEmpty).}: int
        preferred_locale*: string
    MessageNotificationLevel* = enum
        mnlAllMessages
        mnlOnlyMentions
    ExplicitContentFilterLevel* = enum
        ecflDisabled
        ecflMembersWithoutRoles
        ecflAllMembers
    MFALevel* = enum
        mfalNone
        mfalElevated
    VerificationLevel* = enum
        vlNone
        vlLow
        vlMedium
        vlHigh
        vlVeryHigh
    PremiumTier* = enum
        ptNone
        ptTier1
        ptTier2
        ptTier3
    GuildEmbed* = object
        enabled*: bool
        channel_id*: Option[Snowflake]
    GuildMember* = object
        user*: User
        nick* {.fieldTag(omit=WhenEmpty).}: string
        roles*: seq[Role]
        joined_at*: string
        premium_since*: Option[string]
        deaf*: bool
        mute*: bool
    Integration* = object
        id*: Snowflake
        name*: string
        `type`*: string
        enabled*: bool
        syncing*: bool
        role_id*: Snowflake
        expire_behavior*: int
        expire_grace_period*: int
        user*: User
        account*: IntegrationAccount
        synced_at*: string
    IntegrationAccount* = object
        id*: string
        name*: string
    GuildBan* = object
        reason*: Option[string]
        user*: User
    Invite* = object
        code*: string
        guild* {.fieldTag(omit=WhenEmpty).}: Guild
        channel*: Channel
        target_user*: User
        target_user_type* {.fieldTag(omit=WhenEmpty).}: int
        approximate_presence_count* {.fieldTag(omit=WhenEmpty).}: int
        approximate_member_count* {.fieldTag(omit=WhenEmpty).}: int
    InviteMetadata* = object
        inviter*: User
        uses*: int
        max_uses*: int
        max_age*: int
        temporary*: bool
        created_at*: string
        revoked*: bool
    User* = object
        id*: Snowflake
        username*: string
        discriminator*: string
        avatar*: Option[string]
        bot* {.fieldTag(omit=WhenEmpty).}: bool
        mfa_enabled* {.fieldTag(omit=WhenEmpty).}: bool
        locale* {.fieldTag(omit=WhenEmpty).}: string
        verified* {.fieldTag(omit=WhenEmpty).}: bool
        email* {.fieldTag(omit=WhenEmpty).}: string
        flags* {.fieldTag(omit=WhenEmpty).}: int
        premium_type* {.fieldTag(omit=WhenEmpty).}: int
    Connection* = object
        id*: string
        name*: string
        `type`*: string
        revoked*: bool
        integrations*: seq[Integration]
        verified*: bool
        friend_sync*: bool
        show_activity*: bool
        visibility*: ConnectionVisibility
    ConnectionVisibility* = enum
        cvNone
        cvEveryone
    VoiceState* = object
        guild_id* {.fieldTag(omit=WhenEmpty).}: Snowflake
        channel_id*: Option[Snowflake]
        user_id*: Snowflake
        member* {.fieldTag(omit=WhenEmpty).}: GuildMember
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
        id*: Snowflake
        guild_id* {.fieldTag(omit=WhenEmpty).}: Snowflake
        channel_id*: Snowflake
        user* {.fieldTag(omit=WhenEmpty).}: User
        name*: Option[string]
        avatar*: Option[string]
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

        
