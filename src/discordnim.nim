# Wish i could split this up a bit, but errors because cyclical includes
include restapi
import marshal, json, cgi, discordobjects, endpoints,
       websocket/shared, asyncdispatch, asyncnet, uri, zip/zlib
       
# Gateway op codes
{.hint[XDeclaredButNotUsed]: off.}
const 
    opDispatch              = 0
    opHeartbeat             = 1
    opIdentify              = 2
    opStatusUpdate          = 3
    opVoiceStateUpdate      = 4
    opVoiceServerPing       = 5
    opResume                = 6
    opReconnect             = 7
    opRequestGuildMembers   = 8
    opInvalidSession        = 9
    opHello                 = 10
    opHeartbeatAck          = 11


# Permissions 
const
    permCreateInstantInvite* = 0x00000001
    permKickMembers* = 0x00000002
    permBanMembers* = 0x00000004
    permAdministrator* = 0x00000008
    permManageChannels* = 0x00000010
    permManageGuild* = 0x00000020
    permAddReactions* = 0x00000040
    permViewAuditLogs* = 0x00000080
    permReadMessages* = 0x00000400
    permSendMessages* = 0x00000800
    permSendTTSMessage* = 0x00001000
    permManageMessages* = 0x00002000
    permEmbedLinks* = 0x00004000
    permAttachFiles* = 0x00008000
    permReadMessageHistory* = 0x00010000
    permMentionEveryone* = 0x00020000
    permUseExternalEmojis* = 0x00040000
    permVoiceConnect* = 0x00100000
    permVoiceSpeak* = 0x00200000
    permVoiceMuteMembers* = 0x00400000
    permVoiceDeafenMemebrs* = 0x00800000
    permVoiceMoveMembers* = 0x01000000
    permUseVAD* = 0x02000000
    permChangeNickname* = 0x04000000
    permManageNicknames* = 0x08000000
    permManageRoles* = 0x10000000
    permManageWebhooks* = 0x20000000
    permManageEmojis* = 0x40000000
    permAllText* = permReadMessages or 
        permSendMessages or 
        permSendTTSMessage or 
        permManageMessages or
        permEmbedLinks or 
        permAttachFiles or
        permReadMessageHistory or
        permMentionEveryone
    permAllVoice* = permVoiceConnect or
        permVoiceSpeak or
        permVoiceMuteMembers or
        permVoiceMoveMembers or
        permVoiceDeafenMemebrs or
        permUseVAD
    permAllChannel* = permAllText or
        permAllVoice or
        permCreateInstantInvite or
        permManageRoles or
        permManageChannels or
        permAddReactions or
        permViewAuditLogs
    permAll* = permAllChannel or
        permKickMembers or
        permBanMembers or
        permManageGuild or
        permAdministrator


method getGateway(s: Session): Future[string] {.base, async, gcsafe.} =
    var url = gateway()
    let res = await s.request(url, "GET", url, "application/json", "", 0)
    let body = await res.body()
    type Temp = object
        url: string 
        shards: int
    let t = marshal.to[Temp](body)
    s.shardCount = t.shards
    result = t.url

type 
    UpdateStatusData = object
        idle_since: int
        game: Game

method updateStreamingStatus*(s: Session, idle: int = 0, game: string, url: string) {.base, async.} =
    ## Updates the `Playing ...` message of the current user.
    var data = UpdateStatusData()
    if idle > 0:
        data.idle_since = idle
    
    if game != "":
        var gt = 0
        if url != "":
            gt = 1
        data.game = Game(name: game, `type`: gt, url: url) 

    let payload = %*{
        "op": 3,
        "d": data
    }
    await s.connection.sock.sendText($payload, true)

# Temporary until a better solution is found
method initEvents(s: Session) {.base, gcsafe.} =
    s.addHandler(channel_create, proc(s: Session, p: ChannelCreate) = return)
    s.addHandler(channel_update, proc(s: Session, p: ChannelUpdate) = return)
    s.addHandler(channel_delete, proc(s: Session, p: ChannelDelete) = return)
    s.addHandler(channel_pins_update, proc(s: Session, p: ChannelPinsUpdate) = return)
    s.addHandler(guild_create, proc(s: Session, p: GuildCreate) = return)
    s.addHandler(guild_update, proc(s: Session, p: GuildUpdate) = return)
    s.addHandler(guild_delete, proc(s: Session, p: GuildDelete) = return)
    s.addHandler(guild_ban_add, proc(s: Session, p: GuildBanAdd) = return)
    s.addHandler(guild_ban_remove, proc(s: Session, p: GuildBanRemove) = return)
    s.addHandler(guild_emojis_update, proc(s: Session, p: GuildEmojisUpdate) = return)
    s.addHandler(guild_integrations_update, proc(s: Session, p: GuildIntegrationsUpdate) = return)
    s.addHandler(guild_member_add, proc(s: Session, p: GuildMemberAdd) = return)
    s.addHandler(guild_member_update, proc(s: Session, p: GuildMemberUpdate) = return)
    s.addHandler(guild_member_remove, proc(s: Session, p: GuildMemberRemove) = return)
    s.addHandler(guild_members_chunk, proc(s: Session, p: GuildMembersChunk) = return)
    s.addHandler(guild_role_create, proc(s: Session, p: GuildRoleCreate) = return)
    s.addHandler(guild_role_update, proc(s: Session, p: GuildRoleUpdate) = return)
    s.addHandler(guild_role_delete, proc(s: Session, p: GuildRoleDelete) = return)
    s.addHandler(message_create, proc(s: Session, p: MessageCreate) = return)
    s.addHandler(message_update, proc(s: Session, p: MessageUpdate) = return)
    s.addHandler(message_delete, proc(s: Session, p: MessageDelete) = return)
    s.addHandler(message_delete_bulk, proc(s: Session, p: MessageDeleteBulk) = return)
    s.addHandler(message_reaction_add, proc(s: Session, p: MessageReactionAdd) = return)
    s.addHandler(message_reaction_remove, proc(s: Session, p: MessageReactionRemove) = return)
    s.addHandler(message_reaction_remove_all, proc(s: Session, p: MessageReactionRemoveAll) = return)
    s.addHandler(presence_update, proc(s: Session, p: PresenceUpdate) = return)
    s.addHandler(typing_start, proc(s: Session, p: TypingStart) = return)
    s.addHandler(user_update, proc(s: Session, p: UserUpdate) = return)
    s.addHandler(voice_state_update, proc(s: Session, p: VoiceStateUpdate) = return)
    s.addHandler(voice_server_update, proc(s: Session, p: VoiceServerUpdate) = return)
    s.addHandler(on_resume, proc(s: Session, p: Resumed) = return)
    s.addHandler(on_ready, proc(s: Session, p: Ready) = return)


proc newSession*(token: string): Session {.gcsafe.} = 
    ## Creates a new Session
    if token == "":
        raise newException(Exception, "No token")

    result = Session(
            mut: Lock(), 
            compress: false, 
            limiter: newRateLimiter(),
            handlers: initTable[EventType, pointer](),
            sequence: 0,
            token: token,
            cache: Cache(
                users: initTable[string, User](),
                members: initTable[string, GuildMember](),
                guilds: initTable[string, Guild](), 
                channels: initTable[string, DChannel](),
                roles: initTable[string, Role]()
            )
        )

    var auth = ""
    
    result.initEvents()
    let gateway = waitFor result.getGateway()
    result.gateway = gateway.strip&"/"&GATEWAYVERSION



type
  IdentifyError* = object of Exception

method handleDispatch(s: Session, event: string, data: JsonNode) {.async, gcsafe, base.} =
    case event:
        of "READY":
            let payload = Ready(
                v: int(data["v"].num),
                user: marshal.to[User]($data["user"]),
                session_id: data["session_id"].str,
                private_channels: marshal.to[seq[DChannel]]($data["private_channels"]),
                presences: marshal.to[seq[Presence]]($data["presences"]),
                guilds: marshal.to[seq[Guild]]($data["guilds"]),
                trace: data["_trace"].to(seq[string])
            )
            s.session_id = payload.session_id
            s.cache.version = payload.v
            s.cache.me = payload.user
            s.cache.users[payload.user.id] = payload.user
            for channel in payload.private_channels: 
                s.cache.channels[channel.id] = channel
                
            s.cache.ready = payload
            cast[proc(s: Session, r: Ready) {.cdecl.}](s.handlers[on_ready])(s, payload)
        of "RESUMED":
            let payload = parseJson($data).to(Resumed) 
            cast[proc(s: Session, r: Resumed) {.cdecl.}](s.handlers[on_resume])(s, payload)
        of "CHANNEL_CREATE":
            let payload = parseJson($data).to(ChannelCreate)
            if s.cache.cacheChannels: s.cache.channels[payload.id] = payload
            cast[proc(s: Session, r: ChannelCreate) {.cdecl.}](s.handlers[channel_create])(s, payload)
        of "CHANNEL_UPDATE":
            let payload = parseJson($data).to(ChannelUpdate)
            if s.cache.cacheChannels: s.cache.updateChannel(payload)
            cast[proc(s: Session, r: ChannelUpdate) {.cdecl.}](s.handlers[channel_update])(s, payload)
        of "CHANNEL_DELETE":
            let payload = parseJson($data).to(ChannelDelete)
            if s.cache.cacheChannels: s.cache.removeChannel(payload.id)
            cast[proc(s: Session, r: ChannelDelete) {.cdecl.}](s.handlers[channel_delete])(s, payload)
        of "GUILD_CREATE":
            let payload = parseJson($data).to(GuildCreate)
            if s.cache.cacheGuilds: s.cache.guilds[payload.id] = payload
            cast[proc(s: Session, r: GuildCreate) {.cdecl.}](s.handlers[guild_create])(s, payload)
        of "CHANNEL_PINS_UPDATE":
            let payload = parseJson($data).to(ChannelPinsUpdate)
            cast[proc(s: Session, r: ChannelPinsUpdate) {.cdecl.}](s.handlers[channel_pins_update])(s, payload)
        of "GUILD_UPDATE":
            let payload = parseJson($data).to(GuildUpdate)
            if s.cache.cacheGuilds: s.cache.updateGuild(payload)
            cast[proc(s: Session, r: GuildUpdate) {.cdecl.}](s.handlers[guild_update])(s, payload)
        of "GUILD_DELETE":
            let payload = parseJson($data).to(GuildDelete)
            if s.cache.cacheGuilds: s.cache.removeGuild(payload.id)
            cast[proc(s: Session, r: GuildDelete) {.cdecl.}](s.handlers[guild_delete])(s, payload)
        of "GUILD_BAN_ADD":
            let payload = parseJson($data).to(GuildBanAdd)
            cast[proc(s: Session, r: GuildBanAdd) {.cdecl.}](s.handlers[guild_ban_add])(s, payload)
        of "GUILD_BAN_REMOVE":
            let payload = parseJson($data).to(GuildBanRemove)
            cast[proc(s: Session, r: GuildBanRemove) {.cdecl.}](s.handlers[guild_ban_remove])(s, payload)
        of "GUILD_EMOJIS_UPDATE":
            let payload = parseJson($data).to(GuildEmojisUpdate)
            cast[proc(s: Session, r: GuildEmojisUpdate) {.cdecl.}](s.handlers[guild_emojis_update])(s, payload)
        of "GUILD_INTEGRATIONS_UPDATE":
            let payload = parseJson($data).to(GuildIntegrationsUpdate)
            cast[proc(s: Session, r: GuildIntegrationsUpdate) {.cdecl.}](s.handlers[guild_integrations_update])(s, payload)
        of "GUILD_MEMBER_ADD":
            let payload = marshal.to[GuildMemberAdd]($data) # "nick" field may or may not exist
            if s.cache.cacheGuildMembers: s.cache.addGuildMember(payload)
            cast[proc(s: Session, r: GuildMemberAdd) {.cdecl.}](s.handlers[guild_member_add])(s, payload)
        of "GUILD_MEMBER_UPDATE":
            let payload = parseJson($data).to(GuildMemberUpdate)
            if s.cache.cacheGuildMembers: s.cache.updateGuildMember(payload)
            cast[proc(s: Session, r: GuildMemberUpdate) {.cdecl.}](s.handlers[guild_member_update])(s, payload)
        of "GUILD_MEMBER_REMOVE":
            let payload = parseJson($data).to(GuildMemberRemove)
            if s.cache.cacheGuildMembers: s.cache.removeGuildMember(payload)
            cast[proc(s: Session, r: GuildMemberRemove) {.cdecl.}](s.handlers[guild_member_remove])(s, payload)
        of "GUILD_MEMBERS_CHUNK":
            let payload = marshal.to[GuildMembersChunk]($data) # Contains seq of GuildMember
            cast[proc(s: Session, r: GuildMembersChunk) {.cdecl.}](s.handlers[guild_members_chunk])(s, payload)
        of "GUILD_ROLE_CREATE":
            let payload = parseJson($data).to(GuildRoleCreate)
            if s.cache.cacheRoles: s.cache.roles[payload.role.id] = payload.role
            cast[proc(s: Session, r: GuildRoleCreate) {.cdecl.}](s.handlers[guild_role_create])(s, payload)
        of "GUILD_ROLE_UPDATE":
            let payload = parseJson($data).to(GuildRoleUpdate)
            if s.cache.cacheRoles: s.cache.updateRole(payload.role)
            cast[proc(s: Session, r: GuildRoleUpdate) {.cdecl.}](s.handlers[guild_role_update])(s, payload)
        of "GUILD_ROLE_DELETE":
            let payload = parseJson($data).to(GuildRoleDelete)
            if s.cache.cacheRoles: s.cache.removeRole(payload.role_id)
            cast[proc(s: Session, r: GuildRoleDelete) {.cdecl.}](s.handlers[guild_role_delete])(s, payload)
        of "MESSAGE_CREATE":
            # Sometimes it would fail to decode the message
            # not sure why
            try:
                let payload = marshal.to[MessageCreate]($data)
                cast[proc(s: Session, r: MessageCreate) {.cdecl.}](s.handlers[message_create])(s, payload)
            except:
                echo getCurrentExceptionMsg()
        of "MESSAGE_UPDATE":
            let payload = marshal.to[MessageUpdate]($data)
            cast[proc(s: Session, r: MessageUpdate) {.cdecl.}](s.handlers[message_update])(s, payload)
        of "MESSAGE_DELETE":
            let payload = marshal.to[MessageDelete]($data)
            cast[proc(s: Session, r: MessageDelete) {.cdecl.}](s.handlers[message_delete])(s, payload)
        of "MESSAGE_DELETE_BULK":
            let payload = parseJson($data).to(MessageDeleteBulk)
            cast[proc(s: Session, r: MessageDeleteBulk) {.cdecl.}](s.handlers[message_delete_bulk])(s, payload)
        of "MESSAGE_REACTION_ADD":
            let payload = marshal.to[MessageReactionAdd]($data)
            cast[proc(s: Session, r: MessageReactionAdd) {.cdecl.}](s.handlers[message_reaction_add])(s, payload)
        of "MESSAGE_REACTION_REMOVE":
            let payload = parseJson($data).to(MessageReactionRemove)
            cast[proc(s: Session, r: MessageReactionRemove) {.cdecl.}](s.handlers[message_reaction_remove])(s, payload)
        of "MESSAGE_REACTION_REMOVE_ALL":
            let payload = parseJson($data).to(MessageReactionRemoveAll)
            cast[proc(s: Session, r: MessageReactionRemoveAll) {.cdecl.}](s.handlers[message_reaction_remove_all])(s, payload)
        of "PRESENCE_UPDATE":
            let js = parseJson($data)
            var payload = PresenceUpdate(
                user: User(
                    id: js["user"].fields["id"].str
                ),
                status: js["status"].str,
                guild_id: js["guild_id"].str,
                nick: if js.hasKey("nick") and js["nick"].kind == JString: js["nick"].str else: "",
                game: if js.hasKey("game") and js["game"].kind != JNull: marshal.to[Game]($js["game"]) else: Game(),
                roles: if js.hasKey("roles"): marshal.to[seq[string]]($js["roles"]) else: @[],
            )
            cast[proc(s: Session, r: PresenceUpdate) {.cdecl.}](s.handlers[presence_update])(s, payload)
        of "TYPING_START":
            let payload = parseJson($data).to(TypingStart)
            cast[proc(s: Session, r: TypingStart) {.cdecl.}](s.handlers[typing_start])(s, payload)
        of "USER_UPDATE":
            let payload = parseJson($data).to(UserUpdate)
            cast[proc(s: Session, r: UserUpdate) {.cdecl.}](s.handlers[user_update])(s, payload)
        of "VOICE_STATE_UPDATE":
            let payload = parseJson($data).to(VoiceStateUpdate)
            cast[proc(s: Session, r: VoiceStateUpdate) {.cdecl.}](s.handlers[voice_state_update])(s, payload)
        of "VOICE_SERVER_UPDATE":
            let payload = parseJson($data).to(VoiceServerUpdate)
            cast[proc(s: Session, r: VoiceServerUpdate) {.cdecl.}](s.handlers[voice_server_update])(s, payload)
        of "USER_SETTINGS_UPDATE": discard
        else:
            echo "Unknown websocket event :: " & event & "\c\L" & $data

method identify(s: Session) {.async, gcsafe, base.} =
    var properties = %*{
        "$os": system.hostOS,
        "$browser": "Discordnim v"&VERSION,
        "$device": "Discordnim v"&VERSION,
        "$referrer": "",
        "$referring_domain": ""
    }
    
    var payload = %*{
        "op": opIDENTIFY,
        "d": %*{
            "token": s.token,
            "properties": properties,
            "compress": s.compress
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

method resume(s: Session) {.async, gcsafe, base.} =
    let payload = %*{
        "token": s.token,
        "session_id": s.session_id,
        "seq": s.sequence
    }
    await s.connection.sock.sendText($payload, true)

method reconnect(s: Session) {.async, gcsafe, base.} =
    await s.connection.close()
    try:
        s.connection = await newAsyncWebsocket("gateway.discord.gg", Port 443, "/"&GATEWAYVERSION, ssl = true)
    except:
        raise getCurrentException()
    s.sequence = 0
    s.session_ID = ""
    await s.identify()

method shouldResumeSession(s: Session): bool {.gcsafe, inline, base.} = (not s.invalidated) and (not s.suspended)

method setupHeartbeats(s: Session) {.async, gcsafe, base.} =
    while not s.stop and not s.connection.sock.isClosed:
        var hb = %*{"op": opHeartbeat, "d": s.sequence}
        try:
            await s.connection.sock.sendText($hb, true)
            await sleepAsync(s.interval-5) # -5 to accomodate for delay, seems to have stabilized the connection quite a bit
        except:
            if s.stop: return
            echo "Something happened when sending heartbeat through the websocket connection"
            echo getCurrentExceptionMsg()
            return

proc sessionHandleSocketMessage(s: Session) {.gcsafe, async, thread.} =
    await s.identify()

    while not isClosed(s.connection.sock) and not s.stop:
        var res: tuple[opcode: Opcode, data: string]
        try:
            await sleepAsync 2 # This seems to fix(?) the -1 read error??
            res = await s.connection.sock.readData(true)
        except:
            echo getCurrentExceptionMsg()
            break
        
        if s.compress:
            if res.opcode == Opcode.Binary:
                let t = zlib.uncompress(res.data)
                if t == nil:
                    echo "Failed to uncompress data and I'm not sure why. Sorry."
                else: res.data = t
    
        let data = parseJson(res.data)
         
        if data["s"].kind != JNull:
            let i = data["s"].num.int
            s.sequence = i

        case data["op"].num:
        of opDispatch:
            let event = data["t"].str
            asyncCheck s.handleDispatch(event, data["d"])
        of opHello:
            if s.shouldResumeSession():
                await s.resume()
            else:
                s.suspended = false
                let interval = data["d"].fields["heartbeat_interval"].num.int
                s.interval = interval
                asyncCheck s.setupHeartbeats()
        of opHeartbeat:
            let hb = %*{"op": opHeartbeat, "d": s.sequence}
            await s.connection.sock.sendText($hb, true)
        of opHeartbeatAck:
            # TODO :: Should probably check for HEARTBEAT_ACKs and close the connection if we don't get one
            discard
        of opInvalidSession:
            s.sequence = 0
            s.session_ID = ""
            s.invalidated = true
            if data["d"].kind == JBool and data["d"].bval == false:
                await s.identify()
        of opReconnect:
            s.suspended = true
            await s.reconnect()
        else:
            echo $data
    poll()

    echo "connection closed" 
    s.suspended = true
    s.stop = true
    if not s.connection.sock.isClosed:
        s.connection.sock.close()

method disconnect*(s: Session) {.gcsafe, base, async.} =
    s.stop = true
    s.cache.clear()
    s.handlers.clear()
    await s.connection.close()

proc startSession*(s: Session){.async, gcsafe.} =
    ## Starts a Session
    if s.connection != nil:
        echo "Session is already connected"
        return
    s.suspended = true
    try:
        let wsurl = parseUri(s.gateway)
        let socket = await newAsyncWebsocket(
                wsurl.hostname, 
                if wsurl.scheme == "wss": Port(443) else: Port(80), 
                wsurl.path&GATEWAYVERSION, 
                ssl = true, 
                useragent = "Discordnim (https://github.com/Krognol/discordnim v"&VERSION&")"
            )
        s.connection = socket
    except:
        echo getCurrentExceptionMsg()
        return
    
    await sessionHandleSocketMessage(s)