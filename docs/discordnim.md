<div class="document" id="documentId">

<div class="container">

# Module discordnim

<div class="row">

<div class="three columns">

<div>Search: <input type="text" id="searchInput" onkeyup="search()"></div>

<div>Group by: <select onchange="groupBy(this.value)"><option value="section">Section</option> <option value="type">Type</option></select></div>

*   [Imports](#6)
*   [Types](#7)
    *   [<wbr>Overwrite<span class="attachedType" style="visibility:hidden"></span>](#Overwrite "Overwrite* = object
          id*: string
          `type`*: string
          allow*: int
          deny*: int")
    *   [<wbr>Discord<wbr>Channel<span class="attachedType" style="visibility:hidden"></span>](#DiscordChannel "DiscordChannel* = object
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
          recipient*: User")
    *   [<wbr>Message<span class="attachedType" style="visibility:hidden"></span>](#Message "Message* = object
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
          webhook_id*: string")
    *   [<wbr>Reaction<span class="attachedType" style="visibility:hidden"></span>](#Reaction "Reaction* = object
          count*: int
          me*: bool
          emoji*: Emoji")
    *   [<wbr>Emoji<span class="attachedType" style="visibility:hidden"></span>](#Emoji "Emoji* = object
          id*: string
          name*: string
          roles*: seq[Role]
          require_colons*: bool
          managed*: bool")
    *   [<wbr>Embed<span class="attachedType" style="visibility:hidden"></span>](#Embed "Embed* = object
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
          fields*: seq[Field]")
    *   [<wbr>Thumbnail<span class="attachedType" style="visibility:hidden"></span>](#Thumbnail "Thumbnail* = object
          url*: string
          proxy_url*: string
          height*: int
          width*: int")
    *   [<wbr>Video<span class="attachedType" style="visibility:hidden"></span>](#Video "Video* = object
          url*: string
          height*: int
          width*: int")
    *   [<wbr>Image<span class="attachedType" style="visibility:hidden"></span>](#Image "Image* = object
          url*: string
          proxy_url*: string
          height*: int
          width*: int")
    *   [<wbr>Provider<span class="attachedType" style="visibility:hidden"></span>](#Provider "Provider* = object
          name*: string
          url*: string")
    *   [<wbr>Author<span class="attachedType" style="visibility:hidden"></span>](#Author "Author* = object
          name*: string
          url*: string
          icon_url*: string
          proxy_icon_url*: string")
    *   [<wbr>Footer<span class="attachedType" style="visibility:hidden"></span>](#Footer "Footer* = object
          text*: string
          icon_url*: string
          proxy_icon_url*: string")
    *   [<wbr>Field<span class="attachedType" style="visibility:hidden"></span>](#Field "Field* = object
          name*: string
          value*: string
          inline*: bool")
    *   [<wbr>Attachment<span class="attachedType" style="visibility:hidden"></span>](#Attachment "Attachment* = object
          id*: string
          filename*: string
          size*: int
          url*: string
          proxy_url*: string
          height*: int
          width*: int")
    *   [<wbr>Presence<span class="attachedType" style="visibility:hidden"></span>](#Presence "Presence* = object
          user: User
          status: string
          game: Game
          nick: string
          roles: seq[string]")
    *   [<wbr>Guild<span class="attachedType" style="visibility:hidden"></span>](#Guild "Guild* = object
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
          application_id*: string")
    *   [<wbr>Guild<wbr>Member<span class="attachedType" style="visibility:hidden"></span>](#GuildMember "GuildMember* = object
          guild_id*: string
          user*: User
          nick*: string
          roles*: seq[Role]
          joined_at*: string
          deaf*: bool
          mute*: bool")
    *   [<wbr>Integration<span class="attachedType" style="visibility:hidden"></span>](#Integration "Integration* = object
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
          synced_at*: string")
    *   [<wbr>Account<span class="attachedType" style="visibility:hidden"></span>](#Account "Account* = object
          id*: string
          name*: string")
    *   [<wbr>Invite<span class="attachedType" style="visibility:hidden"></span>](#Invite "Invite* = object
          code*: string
          guild*: InviteGuild
          iChannel*: InviteChannel")
    *   [<wbr>Invite<wbr>Metadata<span class="attachedType" style="visibility:hidden"></span>](#InviteMetadata "InviteMetadata* = object
          inviter*: User
          uses*: int
          max_uses*: int
          max_age*: int
          temporary*: bool
          created_at*: string
          revoked*: bool")
    *   [<wbr>Invite<wbr>Guild<span class="attachedType" style="visibility:hidden"></span>](#InviteGuild "InviteGuild* = object
          id*: string
          name*: string
          splash*: string
          icon*: string")
    *   [<wbr>Invite<wbr>Channel<span class="attachedType" style="visibility:hidden"></span>](#InviteChannel "InviteChannel* = object
          id*: string
          name*: string
          `type`*: string")
    *   [<wbr>User<span class="attachedType" style="visibility:hidden"></span>](#User "User* = object
          id*: string
          username*: string
          discriminator*: string
          avatar*: string
          bot*: bool
          mfa_enabled*: bool
          verified*: bool
          email*: string")
    *   [<wbr>User<wbr>Guild<span class="attachedType" style="visibility:hidden"></span>](#UserGuild "UserGuild* = object
          id: string
          name: string
          icon: string
          owner: bool
          permissions: int")
    *   [<wbr>Connection<span class="attachedType" style="visibility:hidden"></span>](#Connection "Connection* = object
          id*: string
          name*: string
          `type`*: string
          revoked*: bool
          integrations*: seq[Integration]")
    *   [<wbr>Voice<wbr>State<span class="attachedType" style="visibility:hidden"></span>](#VoiceState "VoiceState* = object
          guild_id*: string
          channel_id*: string
          user_id*: string
          session_id*: string
          deaf*: bool
          mute*: bool
          self_deaf*: bool
          self_mute*: bool
          suppress*: bool")
    *   [<wbr>Voice<wbr>Region<span class="attachedType" style="visibility:hidden"></span>](#VoiceRegion "VoiceRegion* = object
          id*: string
          name*: string
          sample_hostname*: string
          sample_port*: int
          vip*: bool
          optimal*: bool
          deprecated*: bool
          custom*: bool")
    *   [<wbr>Webhook<span class="attachedType" style="visibility:hidden"></span>](#Webhook "Webhook* = object
          id*: string
          guild_id*: string
          channel_id*: string
          user*: User
          name*: string
          avatar*: string
          token*: string")
    *   [<wbr>Role<span class="attachedType" style="visibility:hidden"></span>](#Role "Role* = object
          id*: string
          name*: string
          color*: int
          hoist*: bool
          position*: int
          permissions*: int
          managed*: bool
          mentionable*: bool")
    *   [<wbr>Channel<wbr>Params<span class="attachedType" style="visibility:hidden"></span>](#ChannelParams "ChannelParams* = ref object
          name*: string
          position*: int
          topic*: string
          bitrate*: int
          user_limit*: int")
    *   [<wbr>Guild<wbr>Params<span class="attachedType" style="visibility:hidden"></span>](#GuildParams "GuildParams* = ref object
          name*: string
          region*: string
          verification_level*: int
          default_message_notifications*: int
          afk_channel_id*: string
          afk_timeout*: int
          icon*: string
          owner_id*: string
          splash*: string")
    *   [<wbr>Guild<wbr>Member<wbr>Params<span class="attachedType" style="visibility:hidden"></span>](#GuildMemberParams "GuildMemberParams* = ref object
          nick*: string
          roles*: seq[string]
          mute*: bool
          deaf*: bool
          channel_id*: string")
    *   [<wbr>Guild<wbr>Embed<span class="attachedType" style="visibility:hidden"></span>](#GuildEmbed "GuildEmbed* = object
          enabled*: bool
          channel_id*: string")
    *   [<wbr>Webhook<wbr>Params<span class="attachedType" style="visibility:hidden"></span>](#WebhookParams "WebhookParams* = ref object
          content*: string
          username*: string
          avatar_url*: string
          tts*: bool
          embeds*: Embed")
    *   [<wbr>Guild<wbr>Delete<span class="attachedType" style="visibility:hidden"></span>](#GuildDelete "GuildDelete* = object
          id*: string
          unavailable*: bool")
    *   [<wbr>Guild<wbr>Emojis<wbr>Update<span class="attachedType" style="visibility:hidden"></span>](#GuildEmojisUpdate "GuildEmojisUpdate* = object
          guild_id*: string
          emojis*: seq[Emoji]")
    *   [<wbr>Guild<wbr>Integrations<wbr>Update<span class="attachedType" style="visibility:hidden"></span>](#GuildIntegrationsUpdate "GuildIntegrationsUpdate* = object
          guild_id*: string")
    *   [<wbr>Guild<wbr>Role<wbr>Create<span class="attachedType" style="visibility:hidden"></span>](#GuildRoleCreate "GuildRoleCreate* = object
          guild_id*: string
          role*: Role")
    *   [<wbr>Guild<wbr>Role<wbr>Update<span class="attachedType" style="visibility:hidden"></span>](#GuildRoleUpdate "GuildRoleUpdate* = object
          guild_id*: string
          role*: Role")
    *   [<wbr>Guild<wbr>Role<wbr>Delete<span class="attachedType" style="visibility:hidden"></span>](#GuildRoleDelete "GuildRoleDelete* = object
          guild_id*: string
          role_id*: string")
    *   [<wbr>Message<wbr>Delete<span class="attachedType" style="visibility:hidden"></span>](#MessageDelete "MessageDelete* = object
          id*: string
          channel_id*: string")
    *   [<wbr>Message<wbr>Delete<wbr>Bulk<span class="attachedType" style="visibility:hidden"></span>](#MessageDeleteBulk "MessageDeleteBulk* = object
          ids*: seq[string]
          channel_id*: string")
    *   [<wbr>Game<span class="attachedType" style="visibility:hidden"></span>](#Game "Game* = ref object
          name*: string
          `type`*: int
          url*: string")
    *   [<wbr>Presence<wbr>Update<span class="attachedType" style="visibility:hidden"></span>](#PresenceUpdate "PresenceUpdate* = object
          user*: User
          roles*: seq[string]
          game*: Game
          guild_id*: string
          status*: string")
    *   [<wbr>Typing<wbr>Start<span class="attachedType" style="visibility:hidden"></span>](#TypingStart "TypingStart* = object
          channel_id*: string
          user_id*: string
          timestamp*: int")
    *   [<wbr>Voice<wbr>Server<wbr>Update<span class="attachedType" style="visibility:hidden"></span>](#VoiceServerUpdate "VoiceServerUpdate* = object
          token: string
          guild_id: string
          endpoint: string")
    *   [<wbr>Resumed<span class="attachedType" style="visibility:hidden"></span>](#Resumed "Resumed* = object
          trace*: seq[string]")
    *   [<wbr>Session<span class="attachedType" style="visibility:hidden"></span>](#Session "Session* = ref object
          Mut: Lock
          Token*: string
          Compress*: bool
          ShardID*: int
          ShardCount*: int
          Sequence*: int
          Gateway*: string
          Session_ID*: string
          Limiter: ref RateLimiter
          Connection*: AsyncWebSocket
          shouldResume: bool
          suspended: bool
          invalidated: bool
          channelCreate*: proc (s: Session; p: DiscordChannel)
          channelUpdate*: proc (s: Session; p: DiscordChannel)
          channelDelete*: proc (s: Session; p: DiscordChannel)
          guildCreate*: proc (s: Session; p: Guild)
          guildUpdate*: proc (s: Session; p: Guild)
          guildDelete*: proc (s: Session; p: GuildDelete)
          guildBanAdd*: proc (s: Session; p: User)
          guildBanRemove*: proc (s: Session; p: User)
          guildEmojisUpdate*: proc (s: Session; p: GuildEmojisUpdate)
          guildIntegrationsUpdate*: proc (s: Session; p: GuildIntegrationsUpdate)
          guildMemberAdd*: proc (s: Session; p: GuildMember)
          guildMemberUpdate*: proc (s: Session; p: GuildMember)
          guildMemberRemove*: proc (s: Session; p: GuildMember)
          guildRoleCreate*: proc (s: Session; p: GuildRoleCreate)
          guildRoleUpdate*: proc (s: Session; p: GuildRoleUpdate)
          guildRoleDelete*: proc (s: Session; p: GuildRoleDelete)
          messageCreate*: proc (s: Session; p: Message)
          messageUpdate*: proc (s: Session; p: Message)
          messageDelete*: proc (s: Session; p: MessageDelete)
          messageDeleteBulk*: proc (s: Session; p: MessageDeleteBulk)
          presenceUpdate*: proc (s: Session; p: PresenceUpdate)
          typingStart*: proc (s: Session; p: TypingStart)
          userUpdate*: proc (s: Session; p: User)
          voiceStateUpdate*: proc (s: Session; p: VoiceState)
          voiceServerUpdate*: proc (s: Session; p: VoiceServerUpdate)
          onResume*: proc (s: Session; p: Resumed)")
    *   [<wbr>Discord<wbr>Error<span class="attachedType" style="visibility:hidden"></span>](#DiscordError "DiscordError* = enum
          ERR_UNKNOWN = (4000, "We\'re not sure what went wrong. Try reconnecting?"), ERR_UNKNOWN_OPCODE = (
              4001, "You sent and invalid Gateway OP Code. Don\'t do that!"), ERR_DECODE_ERROR = (
              4002, "You send an invalid payload to us. Don\'t do that!"), ERR_NOT_AUTHENTICATED = (
              4003, "You send us a payload prior to identifying."), ERR_AUTHENTICATION_FAILED = (
              4004, "The acoount token sent with your identify payload is incorrect."), ERR_ALREAD_AUTHENTICATED = (
              4005, "You send more than one identify payload. Don\'t do that!"), ERR_INVALID_SEQ = (
              4007, "The sequence sent when resuming the session was invalid. Reconnect and start a new session."), ERR_RATE_LIMITED = (
              4008,
              "Woah nelly! You\'re sending payloads to us too quickly. Slow it down!"), ERR_SESSION_TIMEOUT = (
              4009, "Your session timed out. Reconnect and start a new one."),
          ERR_INVALID_SHARD = (4010, "You sent us an invalid shard when identifying."), ERR_SHARDING_REQUIRED = (
              4011, "The session would have handled too many guilds - you are required to shard your connection in order to connect.")")
*   [Consts](#10)
    *   [<wbr>OP_<wbr>DISPATCH<span class="attachedType" style="visibility:hidden"></span>](#OP_DISPATCH "OP_DISPATCH* = 0")
    *   [<wbr>OP_<wbr>HEARTBEAT<span class="attachedType" style="visibility:hidden"></span>](#OP_HEARTBEAT "OP_HEARTBEAT* = 1")
    *   [<wbr>OP_<wbr>IDENTIFY<span class="attachedType" style="visibility:hidden"></span>](#OP_IDENTIFY "OP_IDENTIFY* = 2")
    *   [<wbr>OP_<wbr>STATUS_<wbr>UPDATE<span class="attachedType" style="visibility:hidden"></span>](#OP_STATUS_UPDATE "OP_STATUS_UPDATE* = 3")
    *   [<wbr>OP_<wbr>VOICE_<wbr>STATE_<wbr>UPDATE<span class="attachedType" style="visibility:hidden"></span>](#OP_VOICE_STATE_UPDATE "OP_VOICE_STATE_UPDATE* = 4")
    *   [<wbr>OP_<wbr>VOICE_<wbr>SERVER_<wbr>PING<span class="attachedType" style="visibility:hidden"></span>](#OP_VOICE_SERVER_PING "OP_VOICE_SERVER_PING* = 5")
    *   [<wbr>OP_<wbr>RESUME<span class="attachedType" style="visibility:hidden"></span>](#OP_RESUME "OP_RESUME* = 6")
    *   [<wbr>OP_<wbr>RECONNECT<span class="attachedType" style="visibility:hidden"></span>](#OP_RECONNECT "OP_RECONNECT* = 7")
    *   [<wbr>OP_<wbr>REQUEST_<wbr>GUILD_<wbr>MEMBERS<span class="attachedType" style="visibility:hidden"></span>](#OP_REQUEST_GUILD_MEMBERS "OP_REQUEST_GUILD_MEMBERS* = 8")
    *   [<wbr>OP_<wbr>INVALID_<wbr>SESSION<span class="attachedType" style="visibility:hidden"></span>](#OP_INVALID_SESSION "OP_INVALID_SESSION* = 9")
    *   [<wbr>OP_<wbr>HELLO<span class="attachedType" style="visibility:hidden"></span>](#OP_HELLO "OP_HELLO* = 10")
    *   [<wbr>OP_<wbr>HEARTBEAT_<wbr>ACK<span class="attachedType" style="visibility:hidden"></span>](#OP_HEARTBEAT_ACK "OP_HEARTBEAT_ACK* = 11")
    *   [<wbr>CREATE_<wbr>INSTANT_<wbr>INVITE<span class="attachedType" style="visibility:hidden"></span>](#CREATE_INSTANT_INVITE "CREATE_INSTANT_INVITE* = 0x00000001")
    *   [<wbr>KICK_<wbr>MEMBERS<span class="attachedType" style="visibility:hidden"></span>](#KICK_MEMBERS "KICK_MEMBERS* = 0x00000002")
    *   [<wbr>BAN_<wbr>MEMBERS<span class="attachedType" style="visibility:hidden"></span>](#BAN_MEMBERS "BAN_MEMBERS* = 0x00000004")
    *   [<wbr>ADMINISTRATOR<span class="attachedType" style="visibility:hidden"></span>](#ADMINISTRATOR "ADMINISTRATOR* = 0x00000008")
    *   [<wbr>MANAGE_<wbr>CHANNELS<span class="attachedType" style="visibility:hidden"></span>](#MANAGE_CHANNELS "MANAGE_CHANNELS* = 0x00000010")
    *   [<wbr>MANAGE_<wbr>GUILD<span class="attachedType" style="visibility:hidden"></span>](#MANAGE_GUILD "MANAGE_GUILD* = 0x00000020")
    *   [<wbr>ADD_<wbr>REACTIONS<span class="attachedType" style="visibility:hidden"></span>](#ADD_REACTIONS "ADD_REACTIONS* = 0x00000040")
    *   [<wbr>READ_<wbr>MESSAGES<span class="attachedType" style="visibility:hidden"></span>](#READ_MESSAGES "READ_MESSAGES* = 0x00000400")
    *   [<wbr>SEND_<wbr>MESSAGES<span class="attachedType" style="visibility:hidden"></span>](#SEND_MESSAGES "SEND_MESSAGES* = 0x00000800")
    *   [<wbr>SEND_<wbr>TTS_<wbr>MESSAGES<span class="attachedType" style="visibility:hidden"></span>](#SEND_TTS_MESSAGES "SEND_TTS_MESSAGES* = 0x00001000")
    *   [<wbr>MANAGE_<wbr>MESSAGES<span class="attachedType" style="visibility:hidden"></span>](#MANAGE_MESSAGES "MANAGE_MESSAGES* = 0x00002000")
    *   [<wbr>EMBED_<wbr>LINKS<span class="attachedType" style="visibility:hidden"></span>](#EMBED_LINKS "EMBED_LINKS* = 0x00004000")
    *   [<wbr>ATTACH_<wbr>FILES<span class="attachedType" style="visibility:hidden"></span>](#ATTACH_FILES "ATTACH_FILES* = 0x00008000")
    *   [<wbr>READ_<wbr>MESSAGE_<wbr>HISTORY<span class="attachedType" style="visibility:hidden"></span>](#READ_MESSAGE_HISTORY "READ_MESSAGE_HISTORY* = 0x00010000")
    *   [<wbr>MENTION_<wbr>EVERYONE<span class="attachedType" style="visibility:hidden"></span>](#MENTION_EVERYONE "MENTION_EVERYONE* = 0x00020000")
    *   [<wbr>USE_<wbr>EXTERNAL_<wbr>EMOJIS<span class="attachedType" style="visibility:hidden"></span>](#USE_EXTERNAL_EMOJIS "USE_EXTERNAL_EMOJIS* = 0x00040000")
    *   [<wbr>CONNECT<span class="attachedType" style="visibility:hidden"></span>](#CONNECT "CONNECT* = 0x00100000")
    *   [<wbr>SPEAK<span class="attachedType" style="visibility:hidden"></span>](#SPEAK "SPEAK* = 0x00200000")
    *   [<wbr>MUTE_<wbr>MEMBERS<span class="attachedType" style="visibility:hidden"></span>](#MUTE_MEMBERS "MUTE_MEMBERS* = 0x00400000")
    *   [<wbr>DEAFEN_<wbr>MEMBERS<span class="attachedType" style="visibility:hidden"></span>](#DEAFEN_MEMBERS "DEAFEN_MEMBERS* = 0x00800000")
    *   [<wbr>MOVE_<wbr>MEMBERS<span class="attachedType" style="visibility:hidden"></span>](#MOVE_MEMBERS "MOVE_MEMBERS* = 0x01000000")
    *   [<wbr>USE_<wbr>VAD<span class="attachedType" style="visibility:hidden"></span>](#USE_VAD "USE_VAD* = 0x02000000")
    *   [<wbr>CHANGE_<wbr>NICKNAME<span class="attachedType" style="visibility:hidden"></span>](#CHANGE_NICKNAME "CHANGE_NICKNAME* = 0x04000000")
    *   [<wbr>MANAGE_<wbr>NICKNAMES<span class="attachedType" style="visibility:hidden"></span>](#MANAGE_NICKNAMES "MANAGE_NICKNAMES* = 0x08000000")
    *   [<wbr>MANAGE_<wbr>ROLES<span class="attachedType" style="visibility:hidden"></span>](#MANAGE_ROLES "MANAGE_ROLES* = 0x10000000")
    *   [<wbr>MANAGE_<wbr>WEBHOOKS<span class="attachedType" style="visibility:hidden"></span>](#MANAGE_WEBHOOKS "MANAGE_WEBHOOKS* = 0x20000000")
    *   [<wbr>MANAGE_<wbr>EMOJIS<span class="attachedType" style="visibility:hidden"></span>](#MANAGE_EMOJIS "MANAGE_EMOJIS* = 0x40000000")
*   [Procs](#12)
    *   [<wbr>New<wbr>Session<span class="attachedType" style="visibility:hidden"></span>](#NewSession,varargs[string,] "NewSession*(args: varargs[string, `<div class="three columns"]): Session")
    *   [<wbr>Session<wbr>Start<span class="attachedType" style="visibility:hidden"></span>](#SessionStart,Session "SessionStart*(s: Session)")
*   [Methods](#13)
    *   [<wbr>Channel<span class="attachedType" style="visibility:hidden"></span>](#Channel.e,Session,string "Channel*(s: Session; channel_id: string): DiscordChannel")
    *   [<wbr>Modify<wbr>Channel<span class="attachedType" style="visibility:hidden"></span>](#ModifyChannel.e,Session,string,ChannelParams "ModifyChannel*(s: Session; channelid: string; params: ChannelParams): Guild")
    *   [<wbr>Delete<wbr>Channel<span class="attachedType" style="visibility:hidden"></span>](#DeleteChannel.e,Session,string "DeleteChannel*(s: Session; channelid: string): DiscordChannel")
    *   [<wbr>Channel<wbr>Messages<span class="attachedType" style="visibility:hidden"></span>](#ChannelMessages.e,Session,string,string,string,string,int "ChannelMessages*(s: Session; channelid: string; before, after, around: string;
                         limit: int): seq[Message]")
    *   [<wbr>Channel<wbr>Message<span class="attachedType" style="visibility:hidden"></span>](#ChannelMessage.e,Session,string,string "ChannelMessage*(s: Session; channelid, messageid: string): Message")
    *   [<wbr>Send<wbr>Message<span class="attachedType" style="visibility:hidden"></span>](#SendMessage.e,Session,string,string "SendMessage*(s: Session; channelid, message: string): Message")
    *   [<wbr>Send<wbr>Message<wbr>Embed<span class="attachedType" style="visibility:hidden"></span>](#SendMessageEmbed.e,Session,string,Embed "SendMessageEmbed*(s: Session; channelid: string; embed: var Embed): Message")
    *   [<wbr>Send<wbr>Message<wbr>TTS<span class="attachedType" style="visibility:hidden"></span>](#SendMessageTTS.e,Session,string,string "SendMessageTTS*(s: Session; channelid, message: string): Message")
    *   [<wbr>Message<wbr>Add<wbr>Reaction<span class="attachedType" style="visibility:hidden"></span>](#MessageAddReaction.e,Session,string,string,string "MessageAddReaction*(s: Session; channelid, messageid, emojiid: string)")
    *   [<wbr>Message<wbr>Delete<wbr>Own<wbr>Reaction<span class="attachedType" style="visibility:hidden"></span>](#MessageDeleteOwnReaction.e,Session,string,string,string "MessageDeleteOwnReaction*(s: Session; channelid, messageid, emojiid: string)")
    *   [<wbr>Message<wbr>Delete<wbr>Reaction<span class="attachedType" style="visibility:hidden"></span>](#MessageDeleteReaction.e,Session,string,string,string,string "MessageDeleteReaction*(s: Session; channelid, messageid, emojiid, userid: string)")
    *   [<wbr>Message<wbr>Get<wbr>Reactions<span class="attachedType" style="visibility:hidden"></span>](#MessageGetReactions.e,Session,string,string,string "MessageGetReactions*(s: Session; channelid, messageid, emojiid: string): seq[User]")
    *   [<wbr>Message<wbr>Delete<wbr>All<wbr>Reactions<span class="attachedType" style="visibility:hidden"></span>](#MessageDeleteAllReactions.e,Session,string,string "MessageDeleteAllReactions*(s: Session; channelid, messageid: string)")
    *   [<wbr>Edit<wbr>Message<span class="attachedType" style="visibility:hidden"></span>](#EditMessage.e,Session,string,string,string "EditMessage*(s: Session; channelid, messageid, content: string): Message")
    *   [<wbr>Delete<wbr>Message<span class="attachedType" style="visibility:hidden"></span>](#DeleteMessage.e,Session,string,string "DeleteMessage*(s: Session; channelid, messageid: string)")
    *   [<wbr>Bulk<wbr>Delete<wbr>Messages<span class="attachedType" style="visibility:hidden"></span>](#BulkDeleteMessages.e,Session,string,seq[string] "BulkDeleteMessages*(s: Session; channelid: string; messages: seq[string])")
    *   [<wbr>Edit<wbr>Channel<wbr>Permissions<span class="attachedType" style="visibility:hidden"></span>](#EditChannelPermissions.e,Session,string,Overwrite "EditChannelPermissions*(s: Session; channelid: string; overwrite: Overwrite)")
    *   [<wbr>Channel<wbr>Invites<span class="attachedType" style="visibility:hidden"></span>](#ChannelInvites.e,Session,string "ChannelInvites*(s: Session; channel: string): seq[Invite]")
    *   [<wbr>Create<wbr>Channel<wbr>Invite<span class="attachedType" style="visibility:hidden"></span>](#CreateChannelInvite.e,Session,string,int,int,bool,bool "CreateChannelInvite*(s: Session; channel: string; max_age, max_uses: int;
                             temp, unique: bool): Invite")
    *   [<wbr>Delete<wbr>Channel<wbr>Permission<span class="attachedType" style="visibility:hidden"></span>](#DeleteChannelPermission.e,Session,string,string "DeleteChannelPermission*(s: Session; channel, target: string)")
    *   [<wbr>Trigger<wbr>Typing<wbr>Indicator<span class="attachedType" style="visibility:hidden"></span>](#TriggerTypingIndicator.e,Session,string "TriggerTypingIndicator*(s: Session; channel: string)")
    *   [<wbr>Channel<wbr>Pinned<wbr>Messages<span class="attachedType" style="visibility:hidden"></span>](#ChannelPinnedMessages.e,Session,string "ChannelPinnedMessages*(s: Session; channel: string): seq[Message]")
    *   [<wbr>Channel<wbr>Pin<wbr>Message<span class="attachedType" style="visibility:hidden"></span>](#ChannelPinMessage.e,Session,string,string "ChannelPinMessage*(s: Session; channel, message: string)")
    *   [<wbr>Channel<wbr>Delete<wbr>Pinned<wbr>Message<span class="attachedType" style="visibility:hidden"></span>](#ChannelDeletePinnedMessage.e,Session,string,string "ChannelDeletePinnedMessage*(s: Session; channel, message: string)")
    *   [<wbr>Create<wbr>Guild<span class="attachedType" style="visibility:hidden"></span>](#CreateGuild.e,Session,string "CreateGuild*(s: Session; name: string): Guild")
    *   [<wbr>Get<wbr>Guild<span class="attachedType" style="visibility:hidden"></span>](#GetGuild.e,Session,string "GetGuild*(s: Session; id: string): Guild")
    *   [<wbr>Modify<wbr>Guild<span class="attachedType" style="visibility:hidden"></span>](#ModifyGuild.e,Session,string,GuildParams "ModifyGuild*(s: Session; guild: string; settings: GuildParams): Guild")
    *   [<wbr>Delete<wbr>Guild<span class="attachedType" style="visibility:hidden"></span>](#DeleteGuild.e,Session,string "DeleteGuild*(s: Session; guild: string): Guild")
    *   [<wbr>Guild<wbr>Channels<span class="attachedType" style="visibility:hidden"></span>](#GuildChannels.e,Session,string "GuildChannels*(s: Session; guild: string): seq[DiscordChannel]")
    *   [<wbr>Guild<wbr>Channel<wbr>Create<span class="attachedType" style="visibility:hidden"></span>](#GuildChannelCreate.e,Session,string,string,bool "GuildChannelCreate*(s: Session; guild, channelname: string; voice: bool): DiscordChannel")
    *   [<wbr>Modify<wbr>Guild<wbr>Channel<wbr>Position<span class="attachedType" style="visibility:hidden"></span>](#ModifyGuildChannelPosition.e,Session,string,string,int "ModifyGuildChannelPosition*(s: Session; guild, channel: string; position: int): seq[
            DiscordChannel]")
    *   [<wbr>Guild<wbr>Members<span class="attachedType" style="visibility:hidden"></span>](#GuildMembers.e,Session,string,int,int "GuildMembers*(s: Session; guild: string; limit, after: int): seq[GuildMember]")
    *   [<wbr>Get<wbr>Guild<wbr>Member<span class="attachedType" style="visibility:hidden"></span>](#GetGuildMember.e,Session,string,string "GetGuildMember*(s: Session; guild, userid: string): GuildMember")
    *   [<wbr>Guild<wbr>Member<wbr>Add<span class="attachedType" style="visibility:hidden"></span>](#GuildMemberAdd.e,Session,string,string,string "GuildMemberAdd*(s: Session; guild, userid, accesstoken: string): GuildMember")
    *   [<wbr>Guild<wbr>Member<wbr>Roles<span class="attachedType" style="visibility:hidden"></span>](#GuildMemberRoles.e,Session,string,string,seq[string] "GuildMemberRoles*(s: Session; guild, userid: string; roles: seq[string])")
    *   [<wbr>Guild<wbr>Member<wbr>Nick<span class="attachedType" style="visibility:hidden"></span>](#GuildMemberNick.e,Session,string,string,string "GuildMemberNick*(s: Session; guild, userid, nick: string)")
    *   [<wbr>Guild<wbr>Member<wbr>Mute<span class="attachedType" style="visibility:hidden"></span>](#GuildMemberMute.e,Session,string,string,bool "GuildMemberMute*(s: Session; guild, userid: string; mute: bool)")
    *   [<wbr>Guild<wbr>Member<wbr>Deafen<span class="attachedType" style="visibility:hidden"></span>](#GuildMemberDeafen.e,Session,string,string,bool "GuildMemberDeafen*(s: Session; guild, userid: string; deafen: bool)")
    *   [<wbr>Guild<wbr>Member<wbr>Move<span class="attachedType" style="visibility:hidden"></span>](#GuildMemberMove.e,Session,string,string,string "GuildMemberMove*(s: Session; guild, userid, channel: string)")
    *   [<wbr>Nick<span class="attachedType" style="visibility:hidden"></span>](#Nick.e,Session,string,string "Nick*(s: Session; guild, nick: string)")
    *   [<wbr>Guild<wbr>Member<wbr>Add<wbr>Role<span class="attachedType" style="visibility:hidden"></span>](#GuildMemberAddRole.e,Session,string,string,string "GuildMemberAddRole*(s: Session; guild, userid, roleid: string)")
    *   [<wbr>Guild<wbr>Member<wbr>Remove<wbr>Role<span class="attachedType" style="visibility:hidden"></span>](#GuildMemberRemoveRole.e,Session,string,string,string "GuildMemberRemoveRole*(s: Session; guild, userid, roleid: string)")
    *   [<wbr>Guild<wbr>Member<wbr>Remove<span class="attachedType" style="visibility:hidden"></span>](#GuildMemberRemove.e,Session,string,string "GuildMemberRemove*(s: Session; guild, userid: string)")
    *   [<wbr>Guild<wbr>Bans<span class="attachedType" style="visibility:hidden"></span>](#GuildBans.e,Session,string "GuildBans*(s: Session; guild: string): seq[User]")
    *   [<wbr>Guild<wbr>Ban<wbr>User<span class="attachedType" style="visibility:hidden"></span>](#GuildBanUser.e,Session,string,string "GuildBanUser*(s: Session; guild, userid: string)")
    *   [<wbr>Guild<wbr>Ban<wbr>Remove<span class="attachedType" style="visibility:hidden"></span>](#GuildBanRemove.e,Session,string,string "GuildBanRemove*(s: Session; guild, userid: string)")
    *   [<wbr>Guild<wbr>Roles<span class="attachedType" style="visibility:hidden"></span>](#GuildRoles.e,Session,string "GuildRoles*(s: Session; guild: string): seq[Role]")
    *   [<wbr>Guild<wbr>Role<wbr>Create<wbr>P<span class="attachedType" style="visibility:hidden"></span>](#GuildRoleCreateP.e,Session,string "GuildRoleCreateP*(s: Session; guild: string): Role")
    *   [<wbr>Guild<wbr>Role<wbr>Edit<wbr>Position<span class="attachedType" style="visibility:hidden"></span>](#GuildRoleEditPosition.e,Session,string,seq[Role] "GuildRoleEditPosition*(s: Session; guild: string; roles: seq[Role]): seq[Role]")
    *   [<wbr>Guild<wbr>Role<wbr>Edit<span class="attachedType" style="visibility:hidden"></span>](#GuildRoleEdit.e,Session,string,string,string,int,int,bool,bool "GuildRoleEdit*(s: Session; guild, roleid, name: string; permissions, color: int;
                       hoist, mentionable: bool): Role")
    *   [<wbr>Guild<wbr>Role<wbr>Delete<wbr>P<span class="attachedType" style="visibility:hidden"></span>](#GuildRoleDeleteP.e,Session,string,string "GuildRoleDeleteP*(s: Session; guild, roleid: string)")
    *   [<wbr>Guild<wbr>Prune<wbr>Count<span class="attachedType" style="visibility:hidden"></span>](#GuildPruneCount.e,Session,string,int "GuildPruneCount*(s: Session; guild: string; days: int): int")
    *   [<wbr>Guild<wbr>Prune<wbr>Begin<span class="attachedType" style="visibility:hidden"></span>](#GuildPruneBegin.e,Session,string,int "GuildPruneBegin*(s: Session; guild: string; days: int): int")
    *   [<wbr>Guild<wbr>Voice<wbr>Regions<span class="attachedType" style="visibility:hidden"></span>](#GuildVoiceRegions.e,Session,string "GuildVoiceRegions*(s: Session; guild: string): seq[VoiceRegion]")
    *   [<wbr>Guild<wbr>Invites<span class="attachedType" style="visibility:hidden"></span>](#GuildInvites.e,Session,string "GuildInvites*(s: Session; guild: string): seq[Invite]")
    *   [<wbr>Guild<wbr>Integrations<span class="attachedType" style="visibility:hidden"></span>](#GuildIntegrations.e,Session,string "GuildIntegrations*(s: Session; guild: string): seq[Integration]")
    *   [<wbr>Guild<wbr>Integration<wbr>Create<span class="attachedType" style="visibility:hidden"></span>](#GuildIntegrationCreate.e,Session,string,string,string "GuildIntegrationCreate*(s: Session; guild, typ, id: string)")
    *   [<wbr>Guild<wbr>Integration<wbr>Edit<span class="attachedType" style="visibility:hidden"></span>](#GuildIntegrationEdit.e,Session,string,string,int,int,bool "GuildIntegrationEdit*(s: Session; guild, integrationid: string;
                              behaviour, grace: int; emotes: bool)")
    *   [<wbr>Guild<wbr>Integration<wbr>Delete<span class="attachedType" style="visibility:hidden"></span>](#GuildIntegrationDelete.e,Session,string,string "GuildIntegrationDelete*(s: Session; guild, integration: string)")
    *   [<wbr>Guild<wbr>Integration<wbr>Sync<span class="attachedType" style="visibility:hidden"></span>](#GuildIntegrationSync.e,Session,string,string "GuildIntegrationSync*(s: Session; guild, integration: string)")
    *   [<wbr>Get<wbr>Guild<wbr>Embed<span class="attachedType" style="visibility:hidden"></span>](#GetGuildEmbed.e,Session,string "GetGuildEmbed*(s: Session; guild: string): GuildEmbed")
    *   [<wbr>Guild<wbr>Embed<wbr>Edit<span class="attachedType" style="visibility:hidden"></span>](#GuildEmbedEdit.e,Session,string,bool,string "GuildEmbedEdit*(s: Session; guild: string; enabled: bool; channel: string): GuildEmbed")
    *   [<wbr>Get<wbr>Invite<span class="attachedType" style="visibility:hidden"></span>](#GetInvite.e,Session,string "GetInvite*(s: Session; code: string): Invite")
    *   [<wbr>Invite<wbr>Delete<span class="attachedType" style="visibility:hidden"></span>](#InviteDelete.e,Session,string "InviteDelete*(s: Session; code: string): Invite")
    *   [<wbr>Me<span class="attachedType" style="visibility:hidden"></span>](#Me.e,Session "Me*(s: Session): User")
    *   [<wbr>Get<wbr>User<span class="attachedType" style="visibility:hidden"></span>](#GetUser.e,Session,string "GetUser*(s: Session; userid: string): User")
    *   [<wbr>Edit<wbr>Username<span class="attachedType" style="visibility:hidden"></span>](#EditUsername.e,Session,string "EditUsername*(s: Session; name: string): User")
    *   [<wbr>Edit<wbr>Avatar<span class="attachedType" style="visibility:hidden"></span>](#EditAvatar.e,Session,string "EditAvatar*(s: Session; avatar: string): User")
    *   [<wbr>Guilds<span class="attachedType" style="visibility:hidden"></span>](#Guilds.e,Session "Guilds*(s: Session): seq[UserGuild]")
    *   [<wbr>Leave<wbr>Guild<span class="attachedType" style="visibility:hidden"></span>](#LeaveGuild.e,Session,string "LeaveGuild*(s: Session; guild: string)")
    *   [<wbr>DMs<span class="attachedType" style="visibility:hidden"></span>](#DMs.e,Session "DMs*(s: Session): seq[DiscordChannel]")
    *   [<wbr>DMCreate<span class="attachedType" style="visibility:hidden"></span>](#DMCreate.e,Session,string "DMCreate*(s: Session; recipient: string): DiscordChannel")
    *   [<wbr>Voice<wbr>Regions<span class="attachedType" style="visibility:hidden"></span>](#VoiceRegions.e,Session "VoiceRegions*(s: Session): seq[VoiceRegion]")
    *   [<wbr>Webhook<wbr>Create<span class="attachedType" style="visibility:hidden"></span>](#WebhookCreate.e,Session,string,string,string "WebhookCreate*(s: Session; channel, name, avatar: string): Webhook")
    *   [<wbr>Channel<wbr>Webhooks<span class="attachedType" style="visibility:hidden"></span>](#ChannelWebhooks.e,Session,string "ChannelWebhooks*(s: Session; channel: string): seq[Webhook]")
    *   [<wbr>Guild<wbr>Webhooks<span class="attachedType" style="visibility:hidden"></span>](#GuildWebhooks.e,Session,string "GuildWebhooks*(s: Session; guild: string): seq[Webhook]")
    *   [<wbr>Get<wbr>Webhook<wbr>With<wbr>Token<span class="attachedType" style="visibility:hidden"></span>](#GetWebhookWithToken.e,Session,string,string "GetWebhookWithToken*(s: Session; webhook, token: string): Webhook")
    *   [<wbr>Webhook<wbr>Edit<span class="attachedType" style="visibility:hidden"></span>](#WebhookEdit.e,Session,string,string,string "WebhookEdit*(s: Session; webhook, name, avatar: string): Webhook")
    *   [<wbr>Webhook<wbr>Edit<wbr>With<wbr>Token<span class="attachedType" style="visibility:hidden"></span>](#WebhookEditWithToken.e,Session,string,string,string,string "WebhookEditWithToken*(s: Session; webhook, token, name, avatar: string): Webhook")
    *   [<wbr>Webhook<wbr>Delete<span class="attachedType" style="visibility:hidden"></span>](#WebhookDelete.e,Session,string "WebhookDelete*(s: Session; webhook: string): Webhook")
    *   [<wbr>Webhook<wbr>Delete<wbr>With<wbr>Token<span class="attachedType" style="visibility:hidden"></span>](#WebhookDeleteWithToken.e,Session,string,string "WebhookDeleteWithToken*(s: Session; webhook, token: string): Webhook")
    *   [<wbr>Execute<wbr>Webhook<span class="attachedType" style="visibility:hidden"></span>](#ExecuteWebhook.e,Session,string,string,bool,WebhookParams "ExecuteWebhook*(s: Session; webhook, token: string; wait: bool; payload: WebhookParams)")

</div>

<div class="nine columns" id="content">

<div class="section" id="6">

# [Imports](#6)

<dl class="item">[httpclient](httpclient.html), [marshal](marshal.html), [json](json.html), [locks](locks.html), [tables](tables.html), [times](times.html), [strutils](strutils.html), [os](os.html), [typetraits](typetraits.html), [websocket/shared](websocket/shared.html), [asyncdispatch](asyncdispatch.html), [asyncnet](asyncnet.html), [threadpool](threadpool.html)</dl>

</div>

<div class="section" id="7">

# [Types](#7)

<dl class="item">

<dt id="Overwrite"><a name="Overwrite"></a>

<pre><span class="Identifier">Overwrite</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Other">`</span><span class="Keyword">type</span><span class="Other">`</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">allow</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">deny</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L6) [Edit](/edit/devel/discordnim.nim#L6)</dd>

<dt id="DiscordChannel"><a name="DiscordChannel"></a>

<pre><span class="Identifier">DiscordChannel</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">guild_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">name</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Other">`</span><span class="Keyword">type</span><span class="Other">`</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">position</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">is_private</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">permission_overwrites</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Overwrite</span><span class="Other">]</span>
  <span class="Identifier">topic</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">last_message_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">bitrate</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">user_limit</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">recipient</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">User</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L11) [Edit](/edit/devel/discordnim.nim#L11)</dd>

<dt id="Message"><a name="Message"></a>

<pre><span class="Identifier">Message</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Other">`</span><span class="Keyword">type</span><span class="Other">`</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">tts</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">timestamp</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">pinned</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">nonce</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">mention_roles</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Role</span><span class="Other">]</span>
  <span class="Identifier">mentions</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">User</span><span class="Other">]</span>
  <span class="Identifier">mention_everyone</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">embeds</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Embed</span><span class="Other">]</span>
  <span class="Identifier">edited_timestamp</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">content</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">channel_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">author</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">User</span>
  <span class="Identifier">attachments</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Attachment</span><span class="Other">]</span>
  <span class="Identifier">reactions</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Reaction</span><span class="Other">]</span>
  <span class="Identifier">webhook_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L24) [Edit](/edit/devel/discordnim.nim#L24)</dd>

<dt id="Reaction"><a name="Reaction"></a>

<pre><span class="Identifier">Reaction</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">count</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">me</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">emoji</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">Emoji</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L42) [Edit](/edit/devel/discordnim.nim#L42)</dd>

<dt id="Emoji"><a name="Emoji"></a>

<pre><span class="Identifier">Emoji</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">name</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">roles</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Role</span><span class="Other">]</span>
  <span class="Identifier">require_colons</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">managed</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L46) [Edit](/edit/devel/discordnim.nim#L46)</dd>

<dt id="Embed"><a name="Embed"></a>

<pre><span class="Identifier">Embed</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">title</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Other">`</span><span class="Keyword">type</span><span class="Other">`</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">description</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">url</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">timestamp</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">color</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">footer</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">Footer</span>
  <span class="Identifier">image</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">Image</span>
  <span class="Identifier">thumbnail</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">Thumbnail</span>
  <span class="Identifier">video</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">Video</span>
  <span class="Identifier">provider</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">Provider</span>
  <span class="Identifier">author</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">Author</span>
  <span class="Identifier">fields</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Field</span><span class="Other">]</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L52) [Edit](/edit/devel/discordnim.nim#L52)</dd>

<dt id="Thumbnail"><a name="Thumbnail"></a>

<pre><span class="Identifier">Thumbnail</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">url</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">proxy_url</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">height</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">width</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L66) [Edit](/edit/devel/discordnim.nim#L66)</dd>

<dt id="Video"><a name="Video"></a>

<pre><span class="Identifier">Video</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">url</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">height</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">width</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L71) [Edit](/edit/devel/discordnim.nim#L71)</dd>

<dt id="Image"><a name="Image"></a>

<pre><span class="Identifier">Image</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">url</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">proxy_url</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">height</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">width</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L75) [Edit](/edit/devel/discordnim.nim#L75)</dd>

<dt id="Provider"><a name="Provider"></a>

<pre><span class="Identifier">Provider</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">name</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">url</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L80) [Edit](/edit/devel/discordnim.nim#L80)</dd>

<dt id="Author"><a name="Author"></a>

<pre><span class="Identifier">Author</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">name</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">url</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">icon_url</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">proxy_icon_url</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L83) [Edit](/edit/devel/discordnim.nim#L83)</dd>

<dt id="Footer"><a name="Footer"></a>

<pre><span class="Identifier">Footer</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">text</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">icon_url</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">proxy_icon_url</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L88) [Edit](/edit/devel/discordnim.nim#L88)</dd>

<dt id="Field"><a name="Field"></a>

<pre><span class="Identifier">Field</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">name</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">value</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">inline</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L92) [Edit](/edit/devel/discordnim.nim#L92)</dd>

<dt id="Attachment"><a name="Attachment"></a>

<pre><span class="Identifier">Attachment</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">filename</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">size</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">url</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">proxy_url</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">height</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">width</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L96) [Edit](/edit/devel/discordnim.nim#L96)</dd>

<dt id="Presence"><a name="Presence"></a>

<pre><span class="Identifier">Presence</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">user</span><span class="Other">:</span> <span class="Identifier">User</span>
  <span class="Identifier">status</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">game</span><span class="Other">:</span> <span class="Identifier">Game</span>
  <span class="Identifier">nick</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">roles</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">string</span><span class="Other">]</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L104) [Edit](/edit/devel/discordnim.nim#L104)</dd>

<dt id="Guild"><a name="Guild"></a>

<pre><span class="Identifier">Guild</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">name</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">icon</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">splash</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">owner_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">region</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">afk_channel_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">afk_timeout</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">embed_enabled</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">embed_channel_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">verification_level</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">default_message_notifications</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">roles</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Role</span><span class="Other">]</span>
  <span class="Identifier">emojis</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Emoji</span><span class="Other">]</span>
  <span class="Identifier">mfa_level</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">joined_at</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">large</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">unavailable</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">features</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">JsonNode</span><span class="Other">]</span>
  <span class="Identifier">explicit_content_filter</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">member_count</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">voice_states</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">VoiceState</span><span class="Other">]</span>
  <span class="Identifier">members</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">GuildMember</span><span class="Other">]</span>
  <span class="Identifier">channels</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">DiscordChannel</span><span class="Other">]</span>
  <span class="Identifier">presences</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Presence</span><span class="Other">]</span>
  <span class="Identifier">application_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L110) [Edit](/edit/devel/discordnim.nim#L110)</dd>

<dt id="GuildMember"><a name="GuildMember"></a>

<pre><span class="Identifier">GuildMember</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">guild_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">user</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">User</span>
  <span class="Identifier">nick</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">roles</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Role</span><span class="Other">]</span>
  <span class="Identifier">joined_at</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">deaf</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">mute</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L137) [Edit](/edit/devel/discordnim.nim#L137)</dd>

<dt id="Integration"><a name="Integration"></a>

<pre><span class="Identifier">Integration</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">name</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Other">`</span><span class="Keyword">type</span><span class="Other">`</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">enabled</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">syncing</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">role_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">expire_behavior</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">expire_grace_period</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">iUser</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">User</span>
  <span class="Identifier">iAccount</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">Account</span>
  <span class="Identifier">synced_at</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L145) [Edit](/edit/devel/discordnim.nim#L145)</dd>

<dt id="Account"><a name="Account"></a>

<pre><span class="Identifier">Account</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">name</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L157) [Edit](/edit/devel/discordnim.nim#L157)</dd>

<dt id="Invite"><a name="Invite"></a>

<pre><span class="Identifier">Invite</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">code</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">guild</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">InviteGuild</span>
  <span class="Identifier">iChannel</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">InviteChannel</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L160) [Edit](/edit/devel/discordnim.nim#L160)</dd>

<dt id="InviteMetadata"><a name="InviteMetadata"></a>

<pre><span class="Identifier">InviteMetadata</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">inviter</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">User</span>
  <span class="Identifier">uses</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">max_uses</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">max_age</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">temporary</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">created_at</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">revoked</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L164) [Edit](/edit/devel/discordnim.nim#L164)</dd>

<dt id="InviteGuild"><a name="InviteGuild"></a>

<pre><span class="Identifier">InviteGuild</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">name</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">splash</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">icon</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L172) [Edit](/edit/devel/discordnim.nim#L172)</dd>

<dt id="InviteChannel"><a name="InviteChannel"></a>

<pre><span class="Identifier">InviteChannel</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">name</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Other">`</span><span class="Keyword">type</span><span class="Other">`</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L177) [Edit](/edit/devel/discordnim.nim#L177)</dd>

<dt id="User"><a name="User"></a>

<pre><span class="Identifier">User</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">username</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">discriminator</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">avatar</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">bot</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">mfa_enabled</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">verified</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">email</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L181) [Edit](/edit/devel/discordnim.nim#L181)</dd>

<dt id="UserGuild"><a name="UserGuild"></a>

<pre><span class="Identifier">UserGuild</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">id</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">name</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">icon</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">owner</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">permissions</span><span class="Other">:</span> <span class="Identifier">int</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L190) [Edit](/edit/devel/discordnim.nim#L190)</dd>

<dt id="Connection"><a name="Connection"></a>

<pre><span class="Identifier">Connection</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">name</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Other">`</span><span class="Keyword">type</span><span class="Other">`</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">revoked</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">integrations</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Integration</span><span class="Other">]</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L196) [Edit](/edit/devel/discordnim.nim#L196)</dd>

<dt id="VoiceState"><a name="VoiceState"></a>

<pre><span class="Identifier">VoiceState</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">guild_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">channel_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">user_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">session_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">deaf</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">mute</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">self_deaf</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">self_mute</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">suppress</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L202) [Edit](/edit/devel/discordnim.nim#L202)</dd>

<dt id="VoiceRegion"><a name="VoiceRegion"></a>

<pre><span class="Identifier">VoiceRegion</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">name</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">sample_hostname</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">sample_port</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">vip</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">optimal</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">deprecated</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">custom</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L212) [Edit](/edit/devel/discordnim.nim#L212)</dd>

<dt id="Webhook"><a name="Webhook"></a>

<pre><span class="Identifier">Webhook</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">guild_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">channel_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">user</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">User</span>
  <span class="Identifier">name</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">avatar</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">token</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L221) [Edit](/edit/devel/discordnim.nim#L221)</dd>

<dt id="Role"><a name="Role"></a>

<pre><span class="Identifier">Role</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">name</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">color</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">hoist</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">position</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">permissions</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">managed</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">mentionable</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L229) [Edit](/edit/devel/discordnim.nim#L229)</dd>

<dt id="ChannelParams"><a name="ChannelParams"></a>

<pre><span class="Identifier">ChannelParams</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">ref</span> <span class="Keyword">object</span>
  <span class="Identifier">name</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">position</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">topic</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">bitrate</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">user_limit</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L238) [Edit](/edit/devel/discordnim.nim#L238)</dd>

<dt id="GuildParams"><a name="GuildParams"></a>

<pre><span class="Identifier">GuildParams</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">ref</span> <span class="Keyword">object</span>
  <span class="Identifier">name</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">region</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">verification_level</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">default_message_notifications</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">afk_channel_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">afk_timeout</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">icon</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">owner_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">splash</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L244) [Edit](/edit/devel/discordnim.nim#L244)</dd>

<dt id="GuildMemberParams"><a name="GuildMemberParams"></a>

<pre><span class="Identifier">GuildMemberParams</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">ref</span> <span class="Keyword">object</span>
  <span class="Identifier">nick</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">roles</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">string</span><span class="Other">]</span>
  <span class="Identifier">mute</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">deaf</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">channel_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L254) [Edit](/edit/devel/discordnim.nim#L254)</dd>

<dt id="GuildEmbed"><a name="GuildEmbed"></a>

<pre><span class="Identifier">GuildEmbed</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">enabled</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">channel_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L260) [Edit](/edit/devel/discordnim.nim#L260)</dd>

<dt id="WebhookParams"><a name="WebhookParams"></a>

<pre><span class="Identifier">WebhookParams</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">ref</span> <span class="Keyword">object</span>
  <span class="Identifier">content</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">username</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">avatar_url</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">tts</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">embeds</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">Embed</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L263) [Edit](/edit/devel/discordnim.nim#L263)</dd>

<dt id="GuildDelete"><a name="GuildDelete"></a>

<pre><span class="Identifier">GuildDelete</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">unavailable</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L269) [Edit](/edit/devel/discordnim.nim#L269)</dd>

<dt id="GuildEmojisUpdate"><a name="GuildEmojisUpdate"></a>

<pre><span class="Identifier">GuildEmojisUpdate</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">guild_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">emojis</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Emoji</span><span class="Other">]</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L272) [Edit](/edit/devel/discordnim.nim#L272)</dd>

<dt id="GuildIntegrationsUpdate"><a name="GuildIntegrationsUpdate"></a>

<pre><span class="Identifier">GuildIntegrationsUpdate</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">guild_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L275) [Edit](/edit/devel/discordnim.nim#L275)</dd>

<dt id="GuildRoleCreate"><a name="GuildRoleCreate"></a>

<pre><span class="Identifier">GuildRoleCreate</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">guild_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">role</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">Role</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L277) [Edit](/edit/devel/discordnim.nim#L277)</dd>

<dt id="GuildRoleUpdate"><a name="GuildRoleUpdate"></a>

<pre><span class="Identifier">GuildRoleUpdate</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">guild_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">role</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">Role</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L280) [Edit](/edit/devel/discordnim.nim#L280)</dd>

<dt id="GuildRoleDelete"><a name="GuildRoleDelete"></a>

<pre><span class="Identifier">GuildRoleDelete</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">guild_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">role_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L283) [Edit](/edit/devel/discordnim.nim#L283)</dd>

<dt id="MessageDelete"><a name="MessageDelete"></a>

<pre><span class="Identifier">MessageDelete</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">channel_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L286) [Edit](/edit/devel/discordnim.nim#L286)</dd>

<dt id="MessageDeleteBulk"><a name="MessageDeleteBulk"></a>

<pre><span class="Identifier">MessageDeleteBulk</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">ids</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">string</span><span class="Other">]</span>
  <span class="Identifier">channel_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L289) [Edit](/edit/devel/discordnim.nim#L289)</dd>

<dt id="Game"><a name="Game"></a>

<pre><span class="Identifier">Game</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">ref</span> <span class="Keyword">object</span>
  <span class="Identifier">name</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Other">`</span><span class="Keyword">type</span><span class="Other">`</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">url</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L292) [Edit](/edit/devel/discordnim.nim#L292)</dd>

<dt id="PresenceUpdate"><a name="PresenceUpdate"></a>

<pre><span class="Identifier">PresenceUpdate</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">user</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">User</span>
  <span class="Identifier">roles</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">string</span><span class="Other">]</span>
  <span class="Identifier">game</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">Game</span>
  <span class="Identifier">guild_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">status</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L296) [Edit](/edit/devel/discordnim.nim#L296)</dd>

<dt id="TypingStart"><a name="TypingStart"></a>

<pre><span class="Identifier">TypingStart</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">channel_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">user_id</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">timestamp</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L302) [Edit](/edit/devel/discordnim.nim#L302)</dd>

<dt id="VoiceServerUpdate"><a name="VoiceServerUpdate"></a>

<pre><span class="Identifier">VoiceServerUpdate</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">token</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">guild_id</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">endpoint</span><span class="Other">:</span> <span class="Identifier">string</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L306) [Edit](/edit/devel/discordnim.nim#L306)</dd>

<dt id="Resumed"><a name="Resumed"></a>

<pre><span class="Identifier">Resumed</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">object</span>
  <span class="Identifier">trace</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">string</span><span class="Other">]</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L310) [Edit](/edit/devel/discordnim.nim#L310)</dd>

<dt id="Session"><a name="Session"></a>

<pre><span class="Identifier">Session</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">ref</span> <span class="Keyword">object</span>
  <span class="Identifier">Mut</span><span class="Other">:</span> <span class="Identifier">Lock</span>
  <span class="Identifier">Token</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">Compress</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">ShardID</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">ShardCount</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">Sequence</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">int</span>
  <span class="Identifier">Gateway</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">Session_ID</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">string</span>
  <span class="Identifier">Limiter</span><span class="Other">:</span> <span class="Keyword">ref</span> <span class="Identifier">RateLimiter</span>
  <span class="Identifier">Connection</span><span class="Operator">*</span><span class="Other">:</span> <span class="Identifier">AsyncWebSocket</span>
  <span class="Identifier">shouldResume</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">suspended</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">invalidated</span><span class="Other">:</span> <span class="Identifier">bool</span>
  <span class="Identifier">channelCreate</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">DiscordChannel</span><span class="Other">)</span>
  <span class="Identifier">channelUpdate</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">DiscordChannel</span><span class="Other">)</span>
  <span class="Identifier">channelDelete</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">DiscordChannel</span><span class="Other">)</span>
  <span class="Identifier">guildCreate</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">Guild</span><span class="Other">)</span>
  <span class="Identifier">guildUpdate</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">Guild</span><span class="Other">)</span>
  <span class="Identifier">guildDelete</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">GuildDelete</span><span class="Other">)</span>
  <span class="Identifier">guildBanAdd</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">User</span><span class="Other">)</span>
  <span class="Identifier">guildBanRemove</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">User</span><span class="Other">)</span>
  <span class="Identifier">guildEmojisUpdate</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">GuildEmojisUpdate</span><span class="Other">)</span>
  <span class="Identifier">guildIntegrationsUpdate</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">GuildIntegrationsUpdate</span><span class="Other">)</span>
  <span class="Identifier">guildMemberAdd</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">GuildMember</span><span class="Other">)</span>
  <span class="Identifier">guildMemberUpdate</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">GuildMember</span><span class="Other">)</span>
  <span class="Identifier">guildMemberRemove</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">GuildMember</span><span class="Other">)</span>
  <span class="Identifier">guildRoleCreate</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">GuildRoleCreate</span><span class="Other">)</span>
  <span class="Identifier">guildRoleUpdate</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">GuildRoleUpdate</span><span class="Other">)</span>
  <span class="Identifier">guildRoleDelete</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">GuildRoleDelete</span><span class="Other">)</span>
  <span class="Identifier">messageCreate</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">Message</span><span class="Other">)</span>
  <span class="Identifier">messageUpdate</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">Message</span><span class="Other">)</span>
  <span class="Identifier">messageDelete</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">MessageDelete</span><span class="Other">)</span>
  <span class="Identifier">messageDeleteBulk</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">MessageDeleteBulk</span><span class="Other">)</span>
  <span class="Identifier">presenceUpdate</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">PresenceUpdate</span><span class="Other">)</span>
  <span class="Identifier">typingStart</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">TypingStart</span><span class="Other">)</span>
  <span class="Identifier">userUpdate</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">User</span><span class="Other">)</span>
  <span class="Identifier">voiceStateUpdate</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">VoiceState</span><span class="Other">)</span>
  <span class="Identifier">voiceServerUpdate</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">VoiceServerUpdate</span><span class="Other">)</span>
  <span class="Identifier">onResume</span><span class="Operator">*</span><span class="Other">:</span> <span class="Keyword">proc</span> <span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">p</span><span class="Other">:</span> <span class="Identifier">Resumed</span><span class="Other">)</span>
</pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L312) [Edit](/edit/devel/discordnim.nim#L312)</dd>

<dt id="DiscordError"><a name="DiscordError"></a>

<pre><span class="Identifier">DiscordError</span><span class="Operator">*</span> <span class="Other">=</span> <span class="Keyword">enum</span>
  <span class="Identifier">ERR_UNKNOWN</span> <span class="Other">=</span> <span class="Other">(</span><span class="DecNumber">4000</span><span class="Other">,</span> <span class="StringLit">"We\'re not sure what went wrong. Try reconnecting?"</span><span class="Other">)</span><span class="Other">,</span> <span class="Identifier">ERR_UNKNOWN_OPCODE</span> <span class="Other">=</span> <span class="Other">(</span>
      <span class="DecNumber">4001</span><span class="Other">,</span> <span class="StringLit">"You sent and invalid Gateway OP Code. Don\'t do that!"</span><span class="Other">)</span><span class="Other">,</span> <span class="Identifier">ERR_DECODE_ERROR</span> <span class="Other">=</span> <span class="Other">(</span>
      <span class="DecNumber">4002</span><span class="Other">,</span> <span class="StringLit">"You send an invalid payload to us. Don\'t do that!"</span><span class="Other">)</span><span class="Other">,</span> <span class="Identifier">ERR_NOT_AUTHENTICATED</span> <span class="Other">=</span> <span class="Other">(</span>
      <span class="DecNumber">4003</span><span class="Other">,</span> <span class="StringLit">"You send us a payload prior to identifying."</span><span class="Other">)</span><span class="Other">,</span> <span class="Identifier">ERR_AUTHENTICATION_FAILED</span> <span class="Other">=</span> <span class="Other">(</span>
      <span class="DecNumber">4004</span><span class="Other">,</span> <span class="StringLit">"The acoount token sent with your identify payload is incorrect."</span><span class="Other">)</span><span class="Other">,</span> <span class="Identifier">ERR_ALREAD_AUTHENTICATED</span> <span class="Other">=</span> <span class="Other">(</span>
      <span class="DecNumber">4005</span><span class="Other">,</span> <span class="StringLit">"You send more than one identify payload. Don\'t do that!"</span><span class="Other">)</span><span class="Other">,</span> <span class="Identifier">ERR_INVALID_SEQ</span> <span class="Other">=</span> <span class="Other">(</span>
      <span class="DecNumber">4007</span><span class="Other">,</span> <span class="StringLit">"The sequence sent when resuming the session was invalid. Reconnect and start a new session."</span><span class="Other">)</span><span class="Other">,</span> <span class="Identifier">ERR_RATE_LIMITED</span> <span class="Other">=</span> <span class="Other">(</span>
      <span class="DecNumber">4008</span><span class="Other">,</span>
      <span class="StringLit">"Woah nelly! You\'re sending payloads to us too quickly. Slow it down!"</span><span class="Other">)</span><span class="Other">,</span> <span class="Identifier">ERR_SESSION_TIMEOUT</span> <span class="Other">=</span> <span class="Other">(</span>
      <span class="DecNumber">4009</span><span class="Other">,</span> <span class="StringLit">"Your session timed out. Reconnect and start a new one."</span><span class="Other">)</span><span class="Other">,</span>
  <span class="Identifier">ERR_INVALID_SHARD</span> <span class="Other">=</span> <span class="Other">(</span><span class="DecNumber">4010</span><span class="Other">,</span> <span class="StringLit">"You sent us an invalid shard when identifying."</span><span class="Other">)</span><span class="Other">,</span> <span class="Identifier">ERR_SHARDING_REQUIRED</span> <span class="Other">=</span> <span class="Other">(</span>
      <span class="DecNumber">4011</span><span class="Other">,</span> <span class="StringLit">"The session would have handled too many guilds - you are required to shard your connection in order to connect."</span><span class="Other">)</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L385) [Edit](/edit/devel/discordnim.nim#L385)</dd>

</dl>

</div>

<div class="section" id="10">

# [Consts](#10)

<dl class="item">

<dt id="OP_DISPATCH"><a name="OP_DISPATCH"></a>

<pre><span class="Identifier">OP_DISPATCH</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L370) [Edit](/edit/devel/discordnim.nim#L370)</dd>

<dt id="OP_HEARTBEAT"><a name="OP_HEARTBEAT"></a>

<pre><span class="Identifier">OP_HEARTBEAT</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">1</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L371) [Edit](/edit/devel/discordnim.nim#L371)</dd>

<dt id="OP_IDENTIFY"><a name="OP_IDENTIFY"></a>

<pre><span class="Identifier">OP_IDENTIFY</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">2</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L372) [Edit](/edit/devel/discordnim.nim#L372)</dd>

<dt id="OP_STATUS_UPDATE"><a name="OP_STATUS_UPDATE"></a>

<pre><span class="Identifier">OP_STATUS_UPDATE</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">3</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L373) [Edit](/edit/devel/discordnim.nim#L373)</dd>

<dt id="OP_VOICE_STATE_UPDATE"><a name="OP_VOICE_STATE_UPDATE"></a>

<pre><span class="Identifier">OP_VOICE_STATE_UPDATE</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">4</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L374) [Edit](/edit/devel/discordnim.nim#L374)</dd>

<dt id="OP_VOICE_SERVER_PING"><a name="OP_VOICE_SERVER_PING"></a>

<pre><span class="Identifier">OP_VOICE_SERVER_PING</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">5</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L375) [Edit](/edit/devel/discordnim.nim#L375)</dd>

<dt id="OP_RESUME"><a name="OP_RESUME"></a>

<pre><span class="Identifier">OP_RESUME</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">6</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L376) [Edit](/edit/devel/discordnim.nim#L376)</dd>

<dt id="OP_RECONNECT"><a name="OP_RECONNECT"></a>

<pre><span class="Identifier">OP_RECONNECT</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">7</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L377) [Edit](/edit/devel/discordnim.nim#L377)</dd>

<dt id="OP_REQUEST_GUILD_MEMBERS"><a name="OP_REQUEST_GUILD_MEMBERS"></a>

<pre><span class="Identifier">OP_REQUEST_GUILD_MEMBERS</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">8</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L378) [Edit](/edit/devel/discordnim.nim#L378)</dd>

<dt id="OP_INVALID_SESSION"><a name="OP_INVALID_SESSION"></a>

<pre><span class="Identifier">OP_INVALID_SESSION</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">9</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L379) [Edit](/edit/devel/discordnim.nim#L379)</dd>

<dt id="OP_HELLO"><a name="OP_HELLO"></a>

<pre><span class="Identifier">OP_HELLO</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">10</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L380) [Edit](/edit/devel/discordnim.nim#L380)</dd>

<dt id="OP_HEARTBEAT_ACK"><a name="OP_HEARTBEAT_ACK"></a>

<pre><span class="Identifier">OP_HEARTBEAT_ACK</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">11</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L381) [Edit](/edit/devel/discordnim.nim#L381)</dd>

<dt id="CREATE_INSTANT_INVITE"><a name="CREATE_INSTANT_INVITE"></a>

<pre><span class="Identifier">CREATE_INSTANT_INVITE</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00000001</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L402) [Edit](/edit/devel/discordnim.nim#L402)</dd>

<dt id="KICK_MEMBERS"><a name="KICK_MEMBERS"></a>

<pre><span class="Identifier">KICK_MEMBERS</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00000002</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L403) [Edit](/edit/devel/discordnim.nim#L403)</dd>

<dt id="BAN_MEMBERS"><a name="BAN_MEMBERS"></a>

<pre><span class="Identifier">BAN_MEMBERS</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00000004</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L404) [Edit](/edit/devel/discordnim.nim#L404)</dd>

<dt id="ADMINISTRATOR"><a name="ADMINISTRATOR"></a>

<pre><span class="Identifier">ADMINISTRATOR</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00000008</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L405) [Edit](/edit/devel/discordnim.nim#L405)</dd>

<dt id="MANAGE_CHANNELS"><a name="MANAGE_CHANNELS"></a>

<pre><span class="Identifier">MANAGE_CHANNELS</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00000010</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L406) [Edit](/edit/devel/discordnim.nim#L406)</dd>

<dt id="MANAGE_GUILD"><a name="MANAGE_GUILD"></a>

<pre><span class="Identifier">MANAGE_GUILD</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00000020</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L407) [Edit](/edit/devel/discordnim.nim#L407)</dd>

<dt id="ADD_REACTIONS"><a name="ADD_REACTIONS"></a>

<pre><span class="Identifier">ADD_REACTIONS</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00000040</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L408) [Edit](/edit/devel/discordnim.nim#L408)</dd>

<dt id="READ_MESSAGES"><a name="READ_MESSAGES"></a>

<pre><span class="Identifier">READ_MESSAGES</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00000400</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L409) [Edit](/edit/devel/discordnim.nim#L409)</dd>

<dt id="SEND_MESSAGES"><a name="SEND_MESSAGES"></a>

<pre><span class="Identifier">SEND_MESSAGES</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00000800</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L410) [Edit](/edit/devel/discordnim.nim#L410)</dd>

<dt id="SEND_TTS_MESSAGES"><a name="SEND_TTS_MESSAGES"></a>

<pre><span class="Identifier">SEND_TTS_MESSAGES</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00001000</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L411) [Edit](/edit/devel/discordnim.nim#L411)</dd>

<dt id="MANAGE_MESSAGES"><a name="MANAGE_MESSAGES"></a>

<pre><span class="Identifier">MANAGE_MESSAGES</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00002000</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L412) [Edit](/edit/devel/discordnim.nim#L412)</dd>

<dt id="EMBED_LINKS"><a name="EMBED_LINKS"></a>

<pre><span class="Identifier">EMBED_LINKS</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00004000</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L413) [Edit](/edit/devel/discordnim.nim#L413)</dd>

<dt id="ATTACH_FILES"><a name="ATTACH_FILES"></a>

<pre><span class="Identifier">ATTACH_FILES</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00008000</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L414) [Edit](/edit/devel/discordnim.nim#L414)</dd>

<dt id="READ_MESSAGE_HISTORY"><a name="READ_MESSAGE_HISTORY"></a>

<pre><span class="Identifier">READ_MESSAGE_HISTORY</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00010000</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L415) [Edit](/edit/devel/discordnim.nim#L415)</dd>

<dt id="MENTION_EVERYONE"><a name="MENTION_EVERYONE"></a>

<pre><span class="Identifier">MENTION_EVERYONE</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00020000</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L416) [Edit](/edit/devel/discordnim.nim#L416)</dd>

<dt id="USE_EXTERNAL_EMOJIS"><a name="USE_EXTERNAL_EMOJIS"></a>

<pre><span class="Identifier">USE_EXTERNAL_EMOJIS</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00040000</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L417) [Edit](/edit/devel/discordnim.nim#L417)</dd>

<dt id="CONNECT"><a name="CONNECT"></a>

<pre><span class="Identifier">CONNECT</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00100000</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L418) [Edit](/edit/devel/discordnim.nim#L418)</dd>

<dt id="SPEAK"><a name="SPEAK"></a>

<pre><span class="Identifier">SPEAK</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00200000</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L419) [Edit](/edit/devel/discordnim.nim#L419)</dd>

<dt id="MUTE_MEMBERS"><a name="MUTE_MEMBERS"></a>

<pre><span class="Identifier">MUTE_MEMBERS</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00400000</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L420) [Edit](/edit/devel/discordnim.nim#L420)</dd>

<dt id="DEAFEN_MEMBERS"><a name="DEAFEN_MEMBERS"></a>

<pre><span class="Identifier">DEAFEN_MEMBERS</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x00800000</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L421) [Edit](/edit/devel/discordnim.nim#L421)</dd>

<dt id="MOVE_MEMBERS"><a name="MOVE_MEMBERS"></a>

<pre><span class="Identifier">MOVE_MEMBERS</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x01000000</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L422) [Edit](/edit/devel/discordnim.nim#L422)</dd>

<dt id="USE_VAD"><a name="USE_VAD"></a>

<pre><span class="Identifier">USE_VAD</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x02000000</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L423) [Edit](/edit/devel/discordnim.nim#L423)</dd>

<dt id="CHANGE_NICKNAME"><a name="CHANGE_NICKNAME"></a>

<pre><span class="Identifier">CHANGE_NICKNAME</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x04000000</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L424) [Edit](/edit/devel/discordnim.nim#L424)</dd>

<dt id="MANAGE_NICKNAMES"><a name="MANAGE_NICKNAMES"></a>

<pre><span class="Identifier">MANAGE_NICKNAMES</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x08000000</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L425) [Edit](/edit/devel/discordnim.nim#L425)</dd>

<dt id="MANAGE_ROLES"><a name="MANAGE_ROLES"></a>

<pre><span class="Identifier">MANAGE_ROLES</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x10000000</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L426) [Edit](/edit/devel/discordnim.nim#L426)</dd>

<dt id="MANAGE_WEBHOOKS"><a name="MANAGE_WEBHOOKS"></a>

<pre><span class="Identifier">MANAGE_WEBHOOKS</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x20000000</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L427) [Edit](/edit/devel/discordnim.nim#L427)</dd>

<dt id="MANAGE_EMOJIS"><a name="MANAGE_EMOJIS"></a>

<pre><span class="Identifier">MANAGE_EMOJIS</span><span class="Operator">*</span> <span class="Other">=</span> <span class="DecNumber">0x40000000</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L428) [Edit](/edit/devel/discordnim.nim#L428)</dd>

</dl>

</div>

<div class="section" id="12">

# [Procs](#12)

<dl class="item">

<dt id="NewSession"><a name="NewSession,varargs[string,]"></a>

<pre><span class="Keyword">proc</span> <span class="Identifier">NewSession</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">args</span><span class="Other">:</span> <span class="Identifier">varargs</span><span class="Other">[</span><span class="Identifier">string</span><span class="Other">,</span> <span class="Other">`</span><span class="Operator">$</span><span class="Other">`</span><span class="Other">]</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Session</span></pre>

</dt>

<dd>Creates a new Session   [Source](/tree/master/discordnim.nim#L602) [Edit](/edit/devel/discordnim.nim#L602)</dd>

<dt id="SessionStart"><a name="SessionStart,Session"></a>

<pre><span class="Keyword">proc</span> <span class="Identifier">SessionStart</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">async</span><span class="Other">,</span> <span class="Identifier">gcsafe</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Starts a Session   [Source](/tree/master/discordnim.nim#L1422) [Edit](/edit/devel/discordnim.nim#L1422)</dd>

</dl>

</div>

<div class="section" id="13">

# [Methods](#13)

<dl class="item">

<dt id="Channel"><a name="Channel.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">Channel</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channel_id</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">DiscordChannel</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Returns the channel with the given ID   [Source](/tree/master/discordnim.nim#L630) [Edit](/edit/devel/discordnim.nim#L630)</dd>

<dt id="ModifyChannel"><a name="ModifyChannel.e,Session,string,ChannelParams"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">ModifyChannel</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channelid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">params</span><span class="Other">:</span> <span class="Identifier">ChannelParams</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Guild</span> <span class="Other pragmabegin">{.</span>

<div class="pragma">
    <span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Modifies a channel with the ChannelParams   [Source](/tree/master/discordnim.nim#L637) [Edit](/edit/devel/discordnim.nim#L637)</dd>

<dt id="DeleteChannel"><a name="DeleteChannel.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">DeleteChannel</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channelid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">DiscordChannel</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Deletes a channel   [Source](/tree/master/discordnim.nim#L644) [Edit](/edit/devel/discordnim.nim#L644)</dd>

<dt id="ChannelMessages"><a name="ChannelMessages.e,Session,string,string,string,string,int"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">ChannelMessages</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channelid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">before</span><span class="Other">,</span> <span class="Identifier">after</span><span class="Other">,</span> <span class="Identifier">around</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span>
                       <span class="Identifier">limit</span><span class="Other">:</span> <span class="Identifier">int</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Message</span><span class="Other">]</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Returns a channels messages Maximum of 100 messages   [Source](/tree/master/discordnim.nim#L651) [Edit](/edit/devel/discordnim.nim#L651)</dd>

<dt id="ChannelMessage"><a name="ChannelMessage.e,Session,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">ChannelMessage</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channelid</span><span class="Other">,</span> <span class="Identifier">messageid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Message</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Returns a message from a channel   [Source](/tree/master/discordnim.nim#L672) [Edit](/edit/devel/discordnim.nim#L672)</dd>

<dt id="SendMessage"><a name="SendMessage.e,Session,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">SendMessage</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channelid</span><span class="Other">,</span> <span class="Identifier">message</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Message</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Sends a regular text message to a channel   [Source](/tree/master/discordnim.nim#L679) [Edit](/edit/devel/discordnim.nim#L679)</dd>

<dt id="SendMessageEmbed"><a name="SendMessageEmbed.e,Session,string,Embed"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">SendMessageEmbed</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channelid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">embed</span><span class="Other">:</span> <span class="Keyword">var</span> <span class="Identifier">Embed</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Message</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Sends an Embed message to a channel   [Source](/tree/master/discordnim.nim#L687) [Edit](/edit/devel/discordnim.nim#L687)</dd>

<dt id="SendMessageTTS"><a name="SendMessageTTS.e,Session,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">SendMessageTTS</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channelid</span><span class="Other">,</span> <span class="Identifier">message</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Message</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Sends a TTS message to a channel   [Source](/tree/master/discordnim.nim#L708) [Edit](/edit/devel/discordnim.nim#L708)</dd>

<dt id="MessageAddReaction"><a name="MessageAddReaction.e,Session,string,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">MessageAddReaction</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channelid</span><span class="Other">,</span> <span class="Identifier">messageid</span><span class="Other">,</span> <span class="Identifier">emojiid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Adds a reaction to a message   [Source](/tree/master/discordnim.nim#L719) [Edit](/edit/devel/discordnim.nim#L719)</dd>

<dt id="MessageDeleteOwnReaction"><a name="MessageDeleteOwnReaction.e,Session,string,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">MessageDeleteOwnReaction</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channelid</span><span class="Other">,</span> <span class="Identifier">messageid</span><span class="Other">,</span> <span class="Identifier">emojiid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma">
    <span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Deletes your own reaction to a message   [Source](/tree/master/discordnim.nim#L724) [Edit](/edit/devel/discordnim.nim#L724)</dd>

<dt id="MessageDeleteReaction"><a name="MessageDeleteReaction.e,Session,string,string,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">MessageDeleteReaction</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span>
                             <span class="Identifier">channelid</span><span class="Other">,</span> <span class="Identifier">messageid</span><span class="Other">,</span> <span class="Identifier">emojiid</span><span class="Other">,</span> <span class="Identifier">userid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Deletes a reaction from a user from a message   [Source](/tree/master/discordnim.nim#L729) [Edit](/edit/devel/discordnim.nim#L729)</dd>

<dt id="MessageGetReactions"><a name="MessageGetReactions.e,Session,string,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">MessageGetReactions</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channelid</span><span class="Other">,</span> <span class="Identifier">messageid</span><span class="Other">,</span> <span class="Identifier">emojiid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span>
    <span class="Identifier">User</span><span class="Other">]</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Gets a message's reactions   [Source](/tree/master/discordnim.nim#L734) [Edit](/edit/devel/discordnim.nim#L734)</dd>

<dt id="MessageDeleteAllReactions"><a name="MessageDeleteAllReactions.e,Session,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">MessageDeleteAllReactions</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channelid</span><span class="Other">,</span> <span class="Identifier">messageid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Deletes all reactions on a message   [Source](/tree/master/discordnim.nim#L741) [Edit](/edit/devel/discordnim.nim#L741)</dd>

<dt id="EditMessage"><a name="EditMessage.e,Session,string,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">EditMessage</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channelid</span><span class="Other">,</span> <span class="Identifier">messageid</span><span class="Other">,</span> <span class="Identifier">content</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Message</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Edits a message's contents   [Source](/tree/master/discordnim.nim#L746) [Edit](/edit/devel/discordnim.nim#L746)</dd>

<dt id="DeleteMessage"><a name="DeleteMessage.e,Session,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">DeleteMessage</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channelid</span><span class="Other">,</span> <span class="Identifier">messageid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Deletes a message   [Source](/tree/master/discordnim.nim#L754) [Edit](/edit/devel/discordnim.nim#L754)</dd>

<dt id="BulkDeleteMessages"><a name="BulkDeleteMessages.e,Session,string,seq[string]"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">BulkDeleteMessages</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channelid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">messages</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">string</span><span class="Other">]</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Deletes messages in bulk Will not delete messages older than 2 weeks   [Source](/tree/master/discordnim.nim#L759) [Edit](/edit/devel/discordnim.nim#L759)</dd>

<dt id="EditChannelPermissions"><a name="EditChannelPermissions.e,Session,string,Overwrite"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">EditChannelPermissions</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channelid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">overwrite</span><span class="Other">:</span> <span class="Identifier">Overwrite</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma">
    <span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Edits a channel's permissions   [Source](/tree/master/discordnim.nim#L766) [Edit](/edit/devel/discordnim.nim#L766)</dd>

<dt id="ChannelInvites"><a name="ChannelInvites.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">ChannelInvites</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channel</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Invite</span><span class="Other">]</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Returns all invites to a channel   [Source](/tree/master/discordnim.nim#L771) [Edit](/edit/devel/discordnim.nim#L771)</dd>

<dt id="CreateChannelInvite"><a name="CreateChannelInvite.e,Session,string,int,int,bool,bool"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">CreateChannelInvite</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channel</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">max_age</span><span class="Other">,</span> <span class="Identifier">max_uses</span><span class="Other">:</span> <span class="Identifier">int</span><span class="Other">;</span>
                           <span class="Identifier">temp</span><span class="Other">,</span> <span class="Identifier">unique</span><span class="Other">:</span> <span class="Identifier">bool</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Invite</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Creates an invite to a channel   [Source](/tree/master/discordnim.nim#L778) [Edit](/edit/devel/discordnim.nim#L778)</dd>

<dt id="DeleteChannelPermission"><a name="DeleteChannelPermission.e,Session,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">DeleteChannelPermission</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channel</span><span class="Other">,</span> <span class="Identifier">target</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Deletes a channel permission   [Source](/tree/master/discordnim.nim#L786) [Edit](/edit/devel/discordnim.nim#L786)</dd>

<dt id="TriggerTypingIndicator"><a name="TriggerTypingIndicator.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">TriggerTypingIndicator</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channel</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Triggers the "X is typing" indicator   [Source](/tree/master/discordnim.nim#L791) [Edit](/edit/devel/discordnim.nim#L791)</dd>

<dt id="ChannelPinnedMessages"><a name="ChannelPinnedMessages.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">ChannelPinnedMessages</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channel</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Message</span><span class="Other">]</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Returns all pinned messages in a channel   [Source](/tree/master/discordnim.nim#L796) [Edit](/edit/devel/discordnim.nim#L796)</dd>

<dt id="ChannelPinMessage"><a name="ChannelPinMessage.e,Session,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">ChannelPinMessage</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channel</span><span class="Other">,</span> <span class="Identifier">message</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Pins a message in a channel   [Source](/tree/master/discordnim.nim#L803) [Edit](/edit/devel/discordnim.nim#L803)</dd>

<dt id="ChannelDeletePinnedMessage"><a name="ChannelDeletePinnedMessage.e,Session,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">ChannelDeletePinnedMessage</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channel</span><span class="Other">,</span> <span class="Identifier">message</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>  [Source](/tree/master/discordnim.nim#L808) [Edit](/edit/devel/discordnim.nim#L808)</dd>

<dt id="CreateGuild"><a name="CreateGuild.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">CreateGuild</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">name</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Guild</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Creates a guild This endpoint is limited to 10 active guilds   [Source](/tree/master/discordnim.nim#L818) [Edit](/edit/devel/discordnim.nim#L818)</dd>

<dt id="GetGuild"><a name="GetGuild.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GetGuild</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">id</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Guild</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Gets a guild   [Source](/tree/master/discordnim.nim#L827) [Edit](/edit/devel/discordnim.nim#L827)</dd>

<dt id="ModifyGuild"><a name="ModifyGuild.e,Session,string,GuildParams"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">ModifyGuild</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">settings</span><span class="Other">:</span> <span class="Identifier">GuildParams</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Guild</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Modifies a guild with the GuildParams   [Source](/tree/master/discordnim.nim#L834) [Edit](/edit/devel/discordnim.nim#L834)</dd>

<dt id="DeleteGuild"><a name="DeleteGuild.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">DeleteGuild</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Guild</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Deletes a guild   [Source](/tree/master/discordnim.nim#L841) [Edit](/edit/devel/discordnim.nim#L841)</dd>

<dt id="GuildChannels"><a name="GuildChannels.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildChannels</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">DiscordChannel</span><span class="Other">]</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Returns all guild channels   [Source](/tree/master/discordnim.nim#L848) [Edit](/edit/devel/discordnim.nim#L848)</dd>

<dt id="GuildChannelCreate"><a name="GuildChannelCreate.e,Session,string,string,bool"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildChannelCreate</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">channelname</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">voice</span><span class="Other">:</span> <span class="Identifier">bool</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">DiscordChannel</span> <span class="Other pragmabegin">{.</span>

<div class="pragma">
    <span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Creates a new channel in a guild   [Source](/tree/master/discordnim.nim#L855) [Edit](/edit/devel/discordnim.nim#L855)</dd>

<dt id="ModifyGuildChannelPosition"><a name="ModifyGuildChannelPosition.e,Session,string,string,int"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">ModifyGuildChannelPosition</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">channel</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">position</span><span class="Other">:</span> <span class="Identifier">int</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span>
    <span class="Identifier">DiscordChannel</span><span class="Other">]</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Reorders the position of a channel and returns the new order   [Source](/tree/master/discordnim.nim#L863) [Edit](/edit/devel/discordnim.nim#L863)</dd>

<dt id="GuildMembers"><a name="GuildMembers.e,Session,string,int,int"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildMembers</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">limit</span><span class="Other">,</span> <span class="Identifier">after</span><span class="Other">:</span> <span class="Identifier">int</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">GuildMember</span><span class="Other">]</span> <span class="Other pragmabegin">{.</span>

<div class="pragma">
    <span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Returns up to 1000 guild members   [Source](/tree/master/discordnim.nim#L871) [Edit](/edit/devel/discordnim.nim#L871)</dd>

<dt id="GetGuildMember"><a name="GetGuildMember.e,Session,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GetGuildMember</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">userid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">GuildMember</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Returns a guild member with the userid   [Source](/tree/master/discordnim.nim#L884) [Edit](/edit/devel/discordnim.nim#L884)</dd>

<dt id="GuildMemberAdd"><a name="GuildMemberAdd.e,Session,string,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildMemberAdd</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">userid</span><span class="Other">,</span> <span class="Identifier">accesstoken</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">GuildMember</span> <span class="Other pragmabegin">{.</span>

<div class="pragma">
    <span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Adds a guild member to the guild   [Source](/tree/master/discordnim.nim#L891) [Edit](/edit/devel/discordnim.nim#L891)</dd>

<dt id="GuildMemberRoles"><a name="GuildMemberRoles.e,Session,string,string,seq[string]"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildMemberRoles</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">userid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">roles</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">string</span><span class="Other">]</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Modifies a guild member's roles   [Source](/tree/master/discordnim.nim#L899) [Edit](/edit/devel/discordnim.nim#L899)</dd>

<dt id="GuildMemberNick"><a name="GuildMemberNick.e,Session,string,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildMemberNick</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">userid</span><span class="Other">,</span> <span class="Identifier">nick</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Sets the nickname of a member   [Source](/tree/master/discordnim.nim#L905) [Edit](/edit/devel/discordnim.nim#L905)</dd>

<dt id="GuildMemberMute"><a name="GuildMemberMute.e,Session,string,string,bool"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildMemberMute</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">userid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">mute</span><span class="Other">:</span> <span class="Identifier">bool</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Mutes a guild member   [Source](/tree/master/discordnim.nim#L911) [Edit](/edit/devel/discordnim.nim#L911)</dd>

<dt id="GuildMemberDeafen"><a name="GuildMemberDeafen.e,Session,string,string,bool"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildMemberDeafen</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">userid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">deafen</span><span class="Other">:</span> <span class="Identifier">bool</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Deafens a guild member   [Source](/tree/master/discordnim.nim#L917) [Edit](/edit/devel/discordnim.nim#L917)</dd>

<dt id="GuildMemberMove"><a name="GuildMemberMove.e,Session,string,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildMemberMove</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">userid</span><span class="Other">,</span> <span class="Identifier">channel</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Moves a guild member from one channel to another only works if they are connected to a voice channel   [Source](/tree/master/discordnim.nim#L923) [Edit](/edit/devel/discordnim.nim#L923)</dd>

<dt id="Nick"><a name="Nick.e,Session,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">Nick</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">nick</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Sets the nick for the current user   [Source](/tree/master/discordnim.nim#L930) [Edit](/edit/devel/discordnim.nim#L930)</dd>

<dt id="GuildMemberAddRole"><a name="GuildMemberAddRole.e,Session,string,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildMemberAddRole</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">userid</span><span class="Other">,</span> <span class="Identifier">roleid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Adds a role to a guild member   [Source](/tree/master/discordnim.nim#L936) [Edit](/edit/devel/discordnim.nim#L936)</dd>

<dt id="GuildMemberRemoveRole"><a name="GuildMemberRemoveRole.e,Session,string,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildMemberRemoveRole</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">userid</span><span class="Other">,</span> <span class="Identifier">roleid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Removes a role from a guild member   [Source](/tree/master/discordnim.nim#L941) [Edit](/edit/devel/discordnim.nim#L941)</dd>

<dt id="GuildMemberRemove"><a name="GuildMemberRemove.e,Session,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildMemberRemove</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">userid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Removes a guild membe from the guild   [Source](/tree/master/discordnim.nim#L946) [Edit](/edit/devel/discordnim.nim#L946)</dd>

<dt id="GuildBans"><a name="GuildBans.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildBans</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">User</span><span class="Other">]</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Returns all users who have been banned from the guild   [Source](/tree/master/discordnim.nim#L951) [Edit](/edit/devel/discordnim.nim#L951)</dd>

<dt id="GuildBanUser"><a name="GuildBanUser.e,Session,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildBanUser</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">userid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Bans a user from the guild   [Source](/tree/master/discordnim.nim#L958) [Edit](/edit/devel/discordnim.nim#L958)</dd>

<dt id="GuildBanRemove"><a name="GuildBanRemove.e,Session,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildBanRemove</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">userid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Removes a ban from the guild   [Source](/tree/master/discordnim.nim#L963) [Edit](/edit/devel/discordnim.nim#L963)</dd>

<dt id="GuildRoles"><a name="GuildRoles.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildRoles</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Role</span><span class="Other">]</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Returns all guild roles   [Source](/tree/master/discordnim.nim#L968) [Edit](/edit/devel/discordnim.nim#L968)</dd>

<dt id="GuildRoleCreateP"><a name="GuildRoleCreateP.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildRoleCreateP</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Role</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Creates a new role in the guild Excuse the P in the name, the name conflicts with another declaration   [Source](/tree/master/discordnim.nim#L975) [Edit](/edit/devel/discordnim.nim#L975)</dd>

<dt id="GuildRoleEditPosition"><a name="GuildRoleEditPosition.e,Session,string,seq[Role]"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildRoleEditPosition</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">roles</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Role</span><span class="Other">]</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Role</span><span class="Other">]</span> <span class="Other pragmabegin">{.</span>

<div class="pragma">
    <span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Edits the positions of a guilds roles roles and returns the new roles order   [Source](/tree/master/discordnim.nim#L983) [Edit](/edit/devel/discordnim.nim#L983)</dd>

<dt id="GuildRoleEdit"><a name="GuildRoleEdit.e,Session,string,string,string,int,int,bool,bool"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildRoleEdit</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">roleid</span><span class="Other">,</span> <span class="Identifier">name</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">permissions</span><span class="Other">,</span> <span class="Identifier">color</span><span class="Other">:</span> <span class="Identifier">int</span><span class="Other">;</span>
                     <span class="Identifier">hoist</span><span class="Other">,</span> <span class="Identifier">mentionable</span><span class="Other">:</span> <span class="Identifier">bool</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Role</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Edits a role   [Source](/tree/master/discordnim.nim#L991) [Edit](/edit/devel/discordnim.nim#L991)</dd>

<dt id="GuildRoleDeleteP"><a name="GuildRoleDeleteP.e,Session,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildRoleDeleteP</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">roleid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Deletes a role Excuse the P in the name, the name conflicts with another declaration   [Source](/tree/master/discordnim.nim#L999) [Edit](/edit/devel/discordnim.nim#L999)</dd>

<dt id="GuildPruneCount"><a name="GuildPruneCount.e,Session,string,int"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildPruneCount</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">days</span><span class="Other">:</span> <span class="Identifier">int</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">int</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Returns the number of members who would get kicked during a prune operation   [Source](/tree/master/discordnim.nim#L1005) [Edit](/edit/devel/discordnim.nim#L1005)</dd>

<dt id="GuildPruneBegin"><a name="GuildPruneBegin.e,Session,string,int"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildPruneBegin</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">days</span><span class="Other">:</span> <span class="Identifier">int</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">int</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Begins a prune operation and kicks all members who haven't been active for N days   [Source](/tree/master/discordnim.nim#L1017) [Edit](/edit/devel/discordnim.nim#L1017)</dd>

<dt id="GuildVoiceRegions"><a name="GuildVoiceRegions.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildVoiceRegions</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">VoiceRegion</span><span class="Other">]</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Lists all voice regions in a guild   [Source](/tree/master/discordnim.nim#L1030) [Edit](/edit/devel/discordnim.nim#L1030)</dd>

<dt id="GuildInvites"><a name="GuildInvites.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildInvites</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Invite</span><span class="Other">]</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Lists all guild invites   [Source](/tree/master/discordnim.nim#L1037) [Edit](/edit/devel/discordnim.nim#L1037)</dd>

<dt id="GuildIntegrations"><a name="GuildIntegrations.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildIntegrations</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Integration</span><span class="Other">]</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Lists all guild integrations   [Source](/tree/master/discordnim.nim#L1044) [Edit](/edit/devel/discordnim.nim#L1044)</dd>

<dt id="GuildIntegrationCreate"><a name="GuildIntegrationCreate.e,Session,string,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildIntegrationCreate</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">typ</span><span class="Other">,</span> <span class="Identifier">id</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Creates a new guild integration   [Source](/tree/master/discordnim.nim#L1051) [Edit](/edit/devel/discordnim.nim#L1051)</dd>

<dt id="GuildIntegrationEdit"><a name="GuildIntegrationEdit.e,Session,string,string,int,int,bool"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildIntegrationEdit</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">integrationid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span>
                            <span class="Identifier">behaviour</span><span class="Other">,</span> <span class="Identifier">grace</span><span class="Other">:</span> <span class="Identifier">int</span><span class="Other">;</span> <span class="Identifier">emotes</span><span class="Other">:</span> <span class="Identifier">bool</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Edits a guild integration   [Source](/tree/master/discordnim.nim#L1057) [Edit](/edit/devel/discordnim.nim#L1057)</dd>

<dt id="GuildIntegrationDelete"><a name="GuildIntegrationDelete.e,Session,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildIntegrationDelete</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">integration</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Deletes a guild Integration   [Source](/tree/master/discordnim.nim#L1063) [Edit](/edit/devel/discordnim.nim#L1063)</dd>

<dt id="GuildIntegrationSync"><a name="GuildIntegrationSync.e,Session,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildIntegrationSync</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">,</span> <span class="Identifier">integration</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Syncs an existing guild integration   [Source](/tree/master/discordnim.nim#L1068) [Edit](/edit/devel/discordnim.nim#L1068)</dd>

<dt id="GetGuildEmbed"><a name="GetGuildEmbed.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GetGuildEmbed</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">GuildEmbed</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Gets a GuildEmbed   [Source](/tree/master/discordnim.nim#L1073) [Edit](/edit/devel/discordnim.nim#L1073)</dd>

<dt id="GuildEmbedEdit"><a name="GuildEmbedEdit.e,Session,string,bool,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildEmbedEdit</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">enabled</span><span class="Other">:</span> <span class="Identifier">bool</span><span class="Other">;</span> <span class="Identifier">channel</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">GuildEmbed</span> <span class="Other pragmabegin">{.</span>

<div class="pragma">
    <span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Edits a GuildEmbed   [Source](/tree/master/discordnim.nim#L1080) [Edit](/edit/devel/discordnim.nim#L1080)</dd>

<dt id="GetInvite"><a name="GetInvite.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GetInvite</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">code</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Invite</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Gets an invite with code   [Source](/tree/master/discordnim.nim#L1088) [Edit](/edit/devel/discordnim.nim#L1088)</dd>

<dt id="InviteDelete"><a name="InviteDelete.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">InviteDelete</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">code</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Invite</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Deletes an invite   [Source](/tree/master/discordnim.nim#L1095) [Edit](/edit/devel/discordnim.nim#L1095)</dd>

<dt id="Me"><a name="Me.e,Session"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">Me</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">User</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Returns the current user   [Source](/tree/master/discordnim.nim#L1102) [Edit](/edit/devel/discordnim.nim#L1102)</dd>

<dt id="GetUser"><a name="GetUser.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GetUser</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">userid</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">User</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Gets a user   [Source](/tree/master/discordnim.nim#L1109) [Edit](/edit/devel/discordnim.nim#L1109)</dd>

<dt id="EditUsername"><a name="EditUsername.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">EditUsername</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">name</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">User</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Edits the current users username   [Source](/tree/master/discordnim.nim#L1116) [Edit](/edit/devel/discordnim.nim#L1116)</dd>

<dt id="EditAvatar"><a name="EditAvatar.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">EditAvatar</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">avatar</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">User</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Changes the current users avatar   [Source](/tree/master/discordnim.nim#L1124) [Edit](/edit/devel/discordnim.nim#L1124)</dd>

<dt id="Guilds"><a name="Guilds.e,Session"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">Guilds</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">UserGuild</span><span class="Other">]</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Lists the current users guilds   [Source](/tree/master/discordnim.nim#L1132) [Edit](/edit/devel/discordnim.nim#L1132)</dd>

<dt id="LeaveGuild"><a name="LeaveGuild.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">LeaveGuild</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Makes the current user leave the specified guild   [Source](/tree/master/discordnim.nim#L1139) [Edit](/edit/devel/discordnim.nim#L1139)</dd>

<dt id="DMs"><a name="DMs.e,Session"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">DMs</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">DiscordChannel</span><span class="Other">]</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Lists all active DM channels   [Source](/tree/master/discordnim.nim#L1144) [Edit](/edit/devel/discordnim.nim#L1144)</dd>

<dt id="DMCreate"><a name="DMCreate.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">DMCreate</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">recipient</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">DiscordChannel</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Creates a new DM channel   [Source](/tree/master/discordnim.nim#L1151) [Edit](/edit/devel/discordnim.nim#L1151)</dd>

<dt id="VoiceRegions"><a name="VoiceRegions.e,Session"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">VoiceRegions</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">VoiceRegion</span><span class="Other">]</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Lists all voice regions   [Source](/tree/master/discordnim.nim#L1159) [Edit](/edit/devel/discordnim.nim#L1159)</dd>

<dt id="WebhookCreate"><a name="WebhookCreate.e,Session,string,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">WebhookCreate</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channel</span><span class="Other">,</span> <span class="Identifier">name</span><span class="Other">,</span> <span class="Identifier">avatar</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Webhook</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Creates a webhook   [Source](/tree/master/discordnim.nim#L1166) [Edit](/edit/devel/discordnim.nim#L1166)</dd>

<dt id="ChannelWebhooks"><a name="ChannelWebhooks.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">ChannelWebhooks</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">channel</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Webhook</span><span class="Other">]</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Lists all webhooks in a channel   [Source](/tree/master/discordnim.nim#L1174) [Edit](/edit/devel/discordnim.nim#L1174)</dd>

<dt id="GuildWebhooks"><a name="GuildWebhooks.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GuildWebhooks</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">guild</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">seq</span><span class="Other">[</span><span class="Identifier">Webhook</span><span class="Other">]</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Lists all webhooks in a guild   [Source](/tree/master/discordnim.nim#L1181) [Edit](/edit/devel/discordnim.nim#L1181)</dd>

<dt id="GetWebhookWithToken"><a name="GetWebhookWithToken.e,Session,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">GetWebhookWithToken</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">webhook</span><span class="Other">,</span> <span class="Identifier">token</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Webhook</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Gets a webhook with a token   [Source](/tree/master/discordnim.nim#L1188) [Edit](/edit/devel/discordnim.nim#L1188)</dd>

<dt id="WebhookEdit"><a name="WebhookEdit.e,Session,string,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">WebhookEdit</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">webhook</span><span class="Other">,</span> <span class="Identifier">name</span><span class="Other">,</span> <span class="Identifier">avatar</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Webhook</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Edits a webhook   [Source](/tree/master/discordnim.nim#L1195) [Edit](/edit/devel/discordnim.nim#L1195)</dd>

<dt id="WebhookEditWithToken"><a name="WebhookEditWithToken.e,Session,string,string,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">WebhookEditWithToken</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">webhook</span><span class="Other">,</span> <span class="Identifier">token</span><span class="Other">,</span> <span class="Identifier">name</span><span class="Other">,</span> <span class="Identifier">avatar</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Webhook</span> <span class="Other pragmabegin">{.</span>

<div class="pragma">
    <span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Edits a webhook with a token   [Source](/tree/master/discordnim.nim#L1203) [Edit](/edit/devel/discordnim.nim#L1203)</dd>

<dt id="WebhookDelete"><a name="WebhookDelete.e,Session,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">WebhookDelete</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">webhook</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Webhook</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Deletes a webhook   [Source](/tree/master/discordnim.nim#L1211) [Edit](/edit/devel/discordnim.nim#L1211)</dd>

<dt id="WebhookDeleteWithToken"><a name="WebhookDeleteWithToken.e,Session,string,string"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">WebhookDeleteWithToken</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">webhook</span><span class="Other">,</span> <span class="Identifier">token</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">)</span><span class="Other">:</span> <span class="Identifier">Webhook</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Deltes a webhook with a token   [Source](/tree/master/discordnim.nim#L1218) [Edit](/edit/devel/discordnim.nim#L1218)</dd>

<dt id="ExecuteWebhook"><a name="ExecuteWebhook.e,Session,string,string,bool,WebhookParams"></a>

<pre><span class="Keyword">method</span> <span class="Identifier">ExecuteWebhook</span><span class="Operator">*</span><span class="Other">(</span><span class="Identifier">s</span><span class="Other">:</span> <span class="Identifier">Session</span><span class="Other">;</span> <span class="Identifier">webhook</span><span class="Other">,</span> <span class="Identifier">token</span><span class="Other">:</span> <span class="Identifier">string</span><span class="Other">;</span> <span class="Identifier">wait</span><span class="Other">:</span> <span class="Identifier">bool</span><span class="Other">;</span>
                      <span class="Identifier">payload</span><span class="Other">:</span> <span class="Identifier">WebhookParams</span><span class="Other">)</span> <span class="Other pragmabegin">{.</span>

<div class="pragma"><span class="Identifier">base</span></div>

<span class="Other pragmaend">.}</span></pre>

</dt>

<dd>Executes a webhook   [Source](/tree/master/discordnim.nim#L1225) [Edit](/edit/devel/discordnim.nim#L1225)</dd>

</dl>

</div>

</div>

</div>

<div class="row">

<div class="twelve-columns footer"><span class="nim-sprite"></span>  
<small>Made with Nim. Generated: 2017-04-05 18:13:13 UTC</small></div>

</div>

</div>

</div>