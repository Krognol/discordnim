# Wish i could split this up a bit, but errors because cyclical includes
include restapi
import marshal, json, cgi, discordobjects, endpoints,
       websocket/shared, asyncdispatch, asyncnet, uri

# Gateway op codes
{.hint[XDeclaredButNotUsed]: off.}
const 
    OP_DISPATCH              = 0
    OP_HEARTBEAT             = 1
    OP_IDENTIFY              = 2
    OP_STATUS_UPDATE         = 3
    OP_VOICE_STATE_UPDATE    = 4
    OP_VOICE_SERVER_PING     = 5
    OP_RESUME                = 6
    OP_RECONNECT             = 7
    OP_REQUEST_GUILD_MEMBERS = 8
    OP_INVALID_SESSION       = 9
    OP_HELLO                 = 10
    OP_HEARTBEAT_ACK         = 11


# Permissions 
const
    CREATE_INSTANT_INVITE* = 0x00000001
    KICK_MEMBERS*          = 0x00000002
    BAN_MEMBERS*           = 0x00000004
    ADMINISTRATOR*         = 0x00000008
    MANAGE_CHANNELS*       = 0x00000010
    MANAGE_GUILD*          = 0x00000020
    ADD_REACTIONS*         = 0x00000040
    READ_MESSAGES*         = 0x00000400
    SEND_MESSAGES*         = 0x00000800
    SEND_TTS_MESSAGES*     = 0x00001000
    MANAGE_MESSAGES*       = 0x00002000
    EMBED_LINKS*           = 0x00004000
    ATTACH_FILES*          = 0x00008000
    READ_MESSAGE_HISTORY*  = 0x00010000
    MENTION_EVERYONE*      = 0x00020000
    USE_EXTERNAL_EMOJIS*   = 0x00040000
    CONNECT*               = 0x00100000
    SPEAK*                 = 0x00200000
    MUTE_MEMBERS*          = 0x00400000
    DEAFEN_MEMBERS*        = 0x00800000
    MOVE_MEMBERS*          = 0x01000000
    USE_VAD*               = 0x02000000
    CHANGE_NICKNAME*       = 0x04000000
    MANAGE_NICKNAMES*      = 0x08000000
    MANAGE_ROLES*          = 0x10000000
    MANAGE_WEBHOOKS*       = 0x20000000
    MANAGE_EMOJIS*         = 0x40000000

method GetGateway(s: Session): string {.base.} =
    var url = Gateway()
    let res = s.Request(url, "GET", url, "application/json", "", 0)
    type Temp = object
        url: string
        shards: int
    let t = marshal.to[Temp](res.body)
    s.shardCount = t.shards
    result = t.url

method Login(s: Session, email, password : string) {.base.} =
    var payload = %*{"email": email, "password": password}
    var id = EndpointLogin()
    let res = s.Request(id, "POST", id, "application/json", $payload, 0)
    type Temp = object
        Token: string

    var t = marshal.to[Temp](res.body)
    s.token = t.Token

# Temporary until a better solution is found
method initEvents(s: Session) {.base.} =
    s.channelCreate =            proc(s: Session, p: ChannelCreate) = return
    s.channelUpdate =            proc(s: Session, p: ChannelUpdate) = return
    s.channelDelete =            proc(s: Session, p: ChannelDelete) = return
    s.guildCreate =              proc(s: Session, p: GuildCreate) = return
    s.guildUpdate =              proc(s: Session, p: GuildUpdate) = return
    s.guildDelete =              proc(s: Session, p: GuildDelete) = return
    s.guildBanAdd =              proc(s: Session, p: GuildBanAdd) = return
    s.guildBanRemove =           proc(s: Session, p: GuildBanRemove) = return
    s.guildEmojisUpdate =        proc(s: Session, p: GuildEmojisUpdate) = return
    s.guildIntegrationsUpdate =  proc(s: Session, p: GuildIntegrationsUpdate) = return
    s.guildMemberAdd =           proc(s: Session, p: GuildMemberAdd) = return
    s.guildMemberUpdate =        proc(s: Session, p: GuildMemberUpdate) = return
    s.guildMemberRemove =        proc(s: Session, p: GuildMemberRemove) = return
    s.guildMembersChunk =        proc(s: Session, p: GuildMembersChunk) = return
    s.guildRoleCreate =          proc(s: Session, p: GuildRoleCreate) = return
    s.guildRoleUpdate =          proc(s: Session, p: GuildRoleUpdate) = return
    s.guildRoleDelete =          proc(s: Session, p: GuildRoleDelete) = return
    s.messageCreate =            proc(s: Session, p: MessageCreate) = return
    s.messageUpdate =            proc(s: Session, p: MessageUpdate) = return
    s.messageDelete =            proc(s: Session, p: MessageDelete) = return
    s.messageDeleteBulk =        proc(s: Session, p: MessageDeleteBulk) = return
    s.messageReactionAdd =       proc(s: Session, p: MessageReactionAdd) = return
    s.messageReactionRemove =    proc(s: Session, p: MessageReactionRemove) = return
    s.messageReactionRemoveAll = proc(s: Session, p: MessageReactionRemoveAll) = return
    s.presenceUpdate =           proc(s: Session, p: PresenceUpdate) = return
    s.typingStart =              proc(s: Session, p: TypingStart) = return
    s.userUpdate =               proc(s: Session, p: UserUpdate) = return
    s.voiceStateUpdate =         proc(s: Session, p: VoiceStateUpdate) = return
    s.voiceServerUpdate =        proc(s: Session, p: VoiceServerUpdate) = return
    s.onResume =                 proc(s: Session, p: Resumed) = return
    s.onReady =                  proc(s: Session, p: Ready) = return


proc NewSession*(args: varargs[string, `$`]): Session = 
    ## Creates a new Session
    var rl = newRateLimiter()
    var
        s = Session(
            mut: Lock(), 
            compress: false, 
            limiter: rl, 
            sequence: 0,
            cache: Cache(
                users: initTable[string, User](), 
                guilds: initTable[string, Guild](), 
                channels: initTable[string, DChannel](),
                roles: initTable[string, Role]()
                    )
            )

        auth = ""
        pass = ""
    
    s.initEvents()
    for arg in args:
        if auth == "":
            auth = arg
        elif pass == "":
            pass = arg
        elif s.token == "":
            s.token = arg
    

    if pass == "":
        s.token = auth
    else:
        s.Login(auth, pass)
        if s.token == "":
            echo "Failed to get auth token"
            return nil
    s.gateway = s.GetGateway().strip&"/"&GATEWAYVERSION

    return s



type
  IdentifyError* = object of Exception

method handleDispatch(s: Session, event: string, data: JsonNode){.gcsafe, base.} =
    case event:
        of "READY":
            var payload = Ready(
                v: int(data["v"].num),
                user_settings: data["user_settings"],
                user: marshal.to[User]($data["user"]),
                session_id: data["session_id"].str,
                relationships: data["relationships"],
                private_channels: marshal.to[seq[DChannel]]($data["private_channels"]),
                presences: marshal.to[seq[Presence]]($data["presences"]),
                guilds: marshal.to[seq[Guild]]($data["guilds"]),
                trace: data["_trace"].to(seq[string])
            )
            s.session_ID = payload.session_id
            s.cache.version = payload.v
            s.cache.me = payload.user
            s.cache.users[payload.user.id] = payload.user
            for channel in payload.private_channels:
                s.cache.channels[channel.id] = channel
            
            for guild in payload.guilds:
                s.cache.guilds[guild.id] = guild

            s.onReady(s, payload)            
        of "RESUMED":
            let payload = marshal.to[Resumed]($data)
            s.onResume(s, payload)
        of "CHANNEL_CREATE":
            let payload = marshal.to[ChannelCreate]($data)
            if s.cache.cacheChannels: s.cache.channels[payload.id] = payload
            s.channelCreate(s, payload)
        of "CHANNEL_UPDATE":
            let payload = marshal.to[ChannelUpdate]($data)
            if s.cache.cacheChannels: s.cache.updateChannel(payload)
            s.channelUpdate(s, payload)
        of "CHANNEL_DELETE":
            let payload = marshal.to[ChannelDelete]($data)
            if s.cache.cacheChannels: s.cache.removeChannel(payload.id)
            s.channelDelete(s, payload)
        of "GUILD_CREATE":
            let payload = marshal.to[GuildCreate]($data)
            if s.cache.cacheGuilds: s.cache.guilds[payload.id] = payload
            s.guildCreate(s, payload)
        of "GUILD_UPDATE":
            let payload = marshal.to[GuildUpdate]($data)
            if s.cache.cacheGuilds: s.cache.updateGuild(payload)
            s.guildUpdate(s, payload)
        of "GUILD_DELETE":
            let payload = marshal.to[GuildDelete]($data)
            if s.cache.cacheGuilds: s.cache.removeGuild(payload.id)
            s.guildDelete(s, payload)
        of "GUILD_BAN_ADD":
            let payload = marshal.to[GuildBanAdd]($data)
            s.guildBanAdd(s, payload)
        of "GUILD_BAN_REMOVE":
            let payload = marshal.to[GuildBanRemove]($data)
            s.guildBanRemove(s, payload)
        of "GUILD_EMOJIS_UPDATE":
            let payload = marshal.to[GuildEmojisUpdate]($data)
            s.guildEmojisUpdate(s, payload)
        of "GUILD_INTEGRATIONS_UPDATE":
            let payload = marshal.to[GuildIntegrationsUpdate]($data)
            s.guildIntegrationsUpdate(s, payload)
        of "GUILD_MEMBER_ADD":
            let payload = marshal.to[GuildMemberAdd]($data)
            if s.cache.cacheGuildMembers: s.cache.addGuildMember(payload)
            s.guildMemberAdd(s, payload)
        of "GUILD_MEMBER_UPDATE":
            let payload = marshal.to[GuildMemberUpdate]($data)
            if s.cache.cacheGuildMembers: s.cache.updateGuildMember(payload)
            s.guildMemberUpdate(s, payload)
        of "GUILD_MEMBER_REMOVE":
            let payload = marshal.to[GuildMemberRemove]($data)
            if s.cache.cacheGuildMembers: s.cache.removeGuildMember(payload)
            s.guildMemberRemove(s, payload)
        of "GUILD_MEMBERS_CHUNK":
            let payload = marshal.to[GuildMembersChunk]($data)
            s.guildMembersChunk(s, payload)
        of "GUILD_ROLE_CREATE":
            let payload = marshal.to[GuildRoleCreate]($data)
            if s.cache.cacheRoles: s.cache.roles[payload.role.id] = payload.role
            s.guildRoleCreate(s, payload)
        of "GUILD_ROLE_UPDATE":
            let payload = marshal.to[GuildRoleUpdate]($data)
            if s.cache.cacheRoles: s.cache.updateRole(payload.role)
            s.guildRoleUpdate(s, payload)
        of "GUILD_ROLE_DELETE":
            let payload = marshal.to[GuildRoleDelete]($data)
            if s.cache.cacheRoles: s.cache.removeRole(payload.role_id)
            s.guildRoleDelete(s, payload)
        of "MESSAGE_CREATE":
            let payload = marshal.to[MessageCreate]($data)
            s.messageCreate(s, payload)
        of "MESSAGE_UPDATE":
            let payload = marshal.to[MessageUpdate]($data)
            s.messageUpdate(s, payload)
        of "MESSAGE_DELETE":
            let payload = marshal.to[MessageDelete]($data)
            s.messageDelete(s, payload)
        of "MESSAGE_DELETE_BULK":
            let payload = marshal.to[MessageDeleteBulk]($data)
            s.messageDeleteBulk(s, payload)
        of "MESSAGE_REACTION_ADD":
            let payload = marshal.to[MessageReactionAdd]($data)
            s.messageReactionAdd(s, payload)
        of "MESSAGE_REACTION_REMOVE":
            let payload = marshal.to[MessageReactionRemove]($data)
            s.messageReactionRemove(s, payload)
        of "MESSAGE_REACTION_REMOVE_ALL":
            let payload = marshal.to[MessageReactionRemoveAll]($data)
            s.messageReactionRemoveAll(s, payload)
        of "PRESENCE_UPDATE":
            let payload = marshal.to[PresenceUpdate]($data)
            s.presenceUpdate(s, payload)
        of "TYPING_START":
            let payload = marshal.to[TypingStart]($data)
            s.typingStart(s, payload)
        of "USER_UPDATE":
            let payload = marshal.to[UserUpdate]($data)
            s.userUpdate(s, payload)
        of "VOICE_STATE_UPDATE":
            let payload = marshal.to[VoiceStateUpdate]($data)
            s.voiceStateUpdate(s, payload)
        of "VOICE_SERVER_UPDATE":
            let payload = marshal.to[VoiceServerUpdate]($data)
            s.voiceServerUpdate(s, payload)
        of "USER_SETTINGS_UPDATE":
            discard
        else:
            echo "Unknown websocket event :: " & event & "\c\L" & $data

proc identify(s: Session) {.async.} =
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
            "token": s.token,
            "properties": properties,
        }
    }
    if s.shardCount > 1: 
        if s.shardID >= s.shardCount:
            raise newException(IdentifyError, "ShardID has to be lower than ShardCount")
        payload["shard"] = %*[s.shardID, s.shardCount]

    try:
        await s.connection.sock.sendText($payload, true)
    except:
        echo "Error sending identify packet\c\L" & getCurrentExceptionMsg()

proc resume(s: Session) {.async, gcsafe.} =
    let payload = %*{
        "token": s.token,
        "session_id": s.session_ID,
        "seq": s.sequence
    }
    await s.connection.sock.sendText($payload, true)

proc reconnect(s: Session) {.async, gcsafe.} =
    await s.connection.close()
    s.connection = nil
    s.connection = await newAsyncWebsocket("gateway.discord.gg", Port 443, "/"&GATEWAYVERSION, ssl = true)
    s.sequence = 0
    s.session_ID = ""
    await s.identify()

proc shouldResumeSession(s: Session): bool {.gcsafe.} =
    return (not s.invalidated) and (not s.suspended)

method setupHeartbeats(s: Session) {.async, gcsafe, base.} =
    var hb: JsonNode
    
    while not s.stop:
        if s.sequence == 0:
            hb = %*{"op": OP_HEARTBEAT, "d": nil}
        else:
            hb = %*{"op": OP_HEARTBEAT, "d": s.sequence}

        try:
            await s.connection.sock.sendText($hb, true)
            await sleepAsync(s.interval)        
        except:
            echo getCurrentExceptionMsg()
            return

proc sessionHandleSocketMessage(s: Session) {.gcsafe, async, thread.} =
    await s.identify()

    var res: tuple[opcode: Opcode, data: string]
    while not isClosed(s.connection.sock) and not s.stop:
        res = await s.connection.sock.readData(true)
        
        let data = parseJson(res.data)
         
        if data["s"].kind != JNull:
            let i = data["s"].num.int
            s.sequence = i

        case data["op"].num:
            of OP_HELLO:
                if s.shouldResumeSession():
                    await s.resume()
                else:
                    s.suspended = false
                    let interval = data["d"].fields["heartbeat_interval"].num.int
                    s.interval = interval
                    asyncCheck s.setupHeartbeats()
            of OP_HEARTBEAT:
                let hb = %*{"op": OP_HEARTBEAT, "d": s.sequence}
                await s.connection.sock.sendText($hb, true)
            of OP_HEARTBEAT_ACK:
                continue
            of OP_INVALID_SESSION:
                s.sequence = 0
                s.session_ID = ""
                s.invalidated = true
                if data["d"].bval == false:
                    await s.identify()
            of OP_RECONNECT:
                s.suspended = true
                await s.reconnect()
            of OP_DISPATCH:
                let event = data["t"].str
                s.handleDispatch(event, data["d"])
            else:
                echo $data

    echo "connection closed\c\L" 
    s.suspended = true
    s.connection.sock.close()
    return

# For gracefuler shutdown
proc d_quit() {.noconv.} =
    quit 0

proc SessionStart*(s: Session){.async, gcsafe.} =
    ## Starts a Session
    if s.connection != nil:
        echo "Session is already connected"
        return
    s.suspended = true
    try:
        let socket = await newAsyncWebsocket("gateway.discord.gg", Port(443), path = "/"&GATEWAYVERSION, ssl = true, useragent = "DiscordNim(https://github.com/Krognol/discordnim v"&VERSION)
        s.connection = socket
        asyncCheck sessionHandleSocketMessage(s)
    except:
        echo getCurrentException().msg
        return

    setControlCHook(d_quit)
    while not s.stop:
        poll()