#include restapi
import asyncdispatch, httpclient, asyncnet, tables, strutils, uri, options, json
import websocket, zip/zlib
import endpoints, objects

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
    permPrioritySpeaker* = 0x00000100
    permViewChannel* = 0x00000400
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
    permAllText* = permViewChannel or
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

proc getGateway(s: Shard): Future[tuple[url: string, sc: int]] {.async, gcsafe.} =
    var url = gateway()
    let client = newAsyncHttpClient(static("DiscordBot (https://github.com/Krognol/discordnim, v" & $NimblePkgVersion & ")"))
    client.headers["Authorization"] = s.token
    let
        res = await client.get(url)
        body = await res.body()

    type
        Temp2 = object
            total: int
            remaining: int
            reset_after: int
        Temp = object
            url: string
            shards: int
            session_start_limit: Temp2

    let t = body.parseJson.to(Temp)
    result = (t.url, t.shards)

type UpdateStatusData = object
    since: int # idle_since
    game: Game
    afk: bool
    status: string

proc updateStreamingStatus*(s: Shard, idle: int = 0, game: string, url: string = "", status: string = "online") {.async, gcsafe.} =
    ## Updates the ``Playing ...`` message of the current user.
    if isClosed(s.connection.sock): return
    var data = UpdateStatusData(status: status, afk: false)

    if idle > 0: data.since = idle

    if game != "":
        data.game = Game(name: game, `type`: 0)

        if url != "":
            data.game.`type` = 1
            data.game.url = some(url)

    await s.connection.sendText($(%*{
        "op": 3,
        "d": data
    }))

proc updateStatus*(s: Shard, idle: int = 0, game: string = "") {.gcsafe, async, inline.} =
    ## Updates the ``Playing ...`` status
    asyncCheck s.updateStreamingStatus(idle, game, "")

proc newShard*(token: string): Shard {.gcsafe.} =
    if token == "": raise newException(Exception, "No token")

    result = Shard(
        token: token,
        globalRL: newRateLimiter(),
        handlers: initTable[EventType, seq[pointer]](),
        compress: false,
        limiter: newRateLimiter(),
        sequence: 0,
        cache: Cache(
            users: initTable[string, User](),
            members: initTable[string, GuildMember](),
            guilds: initTable[string, Guild](),
            channels: initTable[string, Channel](),
            roles: initTable[string, Role]()
        )
    )

    let gateway = waitFor result.getGateway()
    result.gateway = gateway.url.strip&"/"&GATEWAYVERSION


proc each(arr: seq[pointer], s: Shard) =
    for p in arr:
        cast[proc(_: Shard){.cdecl.}](p)(s)

proc each[T](s: Shard, want: EventType, data: T) {.async, gcsafe.} =
    if s.handlers.hasKey(want):
        for p in s.handlers[want]:
            cast[proc(_: Shard, d: T){.cdecl.}](p)(s, data)

proc handleDispatch(s: Shard, event: string, data: JsonNode) {.async, gcsafe.} =
    case event:
        of "READY":
            let payload = newReady(data)
            s.session_id = payload.session_id
            s.cache.version = payload.v
            s.cache.me = payload.user
            s.cache.users[payload.user.id] = payload.user
            for channel in payload.private_channels:
                s.cache.channels[channel.id] = channel

            s.cache.ready = payload
            asyncCheck s.each(on_ready, payload)
        of "RESUMED":
            asyncCheck s.each(on_ready, newResumed(data))
        of "CHANNEL_CREATE":
            let payload = newChannelCreate(data)
            if s.cache.cacheChannels: s.cache.channels[payload.id] = payload
            asyncCheck s.each(channel_create, payload)
        of "CHANNEL_UPDATE":
            let payload = newChannelUpdate(data)
            if s.cache.cacheChannels: s.cache.updateChannel(payload)
            asyncCheck s.each(on_ready, payload)
        of "CHANNEL_DELETE":
            let payload = newChannelDelete(data)
            if s.cache.cacheChannels: s.cache.removeChannel(payload.id)
            asyncCheck s.each(channel_delete, payload)
        of "CHANNEL_PINS_UPDATE":
            asyncCheck s.each(channel_pins_update, newChannelPinsUpdate(data))
        of "GUILD_CREATE":
            let payload = newGuildCreate(data)
            if s.cache.cacheGuilds: s.cache.guilds[payload.id] = payload
            asyncCheck s.each(guild_create, payload)
        of "GUILD_UPDATE":
            let payload = newGuildUpdate(data)
            if s.cache.cacheGuilds: s.cache.updateGuild(payload)
            asyncCheck s.each(guild_update, payload)
        of "GUILD_DELETE":
            let payload = newGuildDelete(data)
            if s.cache.cacheGuilds: s.cache.removeGuild(payload.id)
            asyncCheck s.each(guild_delete, payload)
        of "GUILD_BAN_ADD":
            asyncCheck s.each(guild_ban_add, newGuildBanAdd(data))
        of "GUILD_BAN_REMOVE":
            asyncCheck s.each(guild_ban_remove, newGuildBanRemove(data))
        of "GUILD_EMOJIS_UPDATE":
            asyncCheck s.each(guild_emojis_update, newGuildEmojisUpdate(data))
        of "GUILD_INTEGRATIONS_UPDATE":
            asyncCheck s.each(guild_integrations_update, newGuildIntegrationsUpdate(data))
        of "GUILD_MEMBER_ADD":
            let payload = newGuildMemberAdd(data)
            if s.cache.cacheGuildMembers: s.cache.addGuildMember(payload)
            asyncCheck s.each(guild_member_add, payload)
        of "GUILD_MEMBER_UPDATE":
            let payload = newGuildMemberUpdate(data)
            if s.cache.cacheGuildMembers: s.cache.updateGuildMember(payload)
            asyncCheck s.each(guild_member_update, payload)
        of "GUILD_MEMBER_REMOVE":
            let payload = newGuildMemberRemove(data)
            if s.cache.cacheGuildMembers: s.cache.removeGuildMember(payload)
            asyncCheck s.each(guild_member_remove, payload)
        of "GUILD_MEMBERS_CHUNK":
            asyncCheck s.each(guild_members_chunk, newGuildMembersChunk(data))
        of "GUILD_ROLE_CREATE":
            let payload = newGuildRoleCreate(data)
            if s.cache.cacheRoles: s.cache.roles[payload.role.id] = payload.role
            asyncCheck s.each(guild_role_create, payload)
        of "GUILD_ROLE_UPDATE":
            let payload = newGuildRoleUpdate(data)
            if s.cache.cacheRoles: s.cache.updateRole(payload.role)
            asyncCheck s.each(guild_role_update, payload)
        of "GUILD_ROLE_DELETE":
            let payload = newGuildRoleDelete(data)
            if s.cache.cacheRoles: s.cache.removeRole(payload.role_id)
            asyncCheck s.each(guild_role_delete, payload)
        of "MESSAGE_CREATE":
            asyncCheck s.each(message_create, newMessageCreate(data))
        of "MESSAGE_UPDATE":
            asyncCheck s.each(message_update, newMessageUpdate(data))
        of "MESSAGE_DELETE":
            asyncCheck s.each(message_delete, newMessageDelete(data))
        of "MESSAGE_DELETE_BULK":
            asyncCheck s.each(message_delete_bulk, newMessageDeleteBulk(data))
        of "MESSAGE_REACTION_ADD":
            asyncCheck s.each(message_reaction_add, newMessageReactionAdd(data))
        of "MESSAGE_REACTION_REMOVE":
            asyncCheck s.each(message_reaction_remove, newMessageReactionRemove(data))
        of "MESSAGE_REACTION_REMOVE_ALL":
            asyncCheck s.each(message_reaction_remove_all, newMessageReactionRemoveAll(data))
        of "PRESENCE_UPDATE":
            asyncCheck s.each(presence_update, newPresenceUpdate(data))
        of "TYPING_START":
            asyncCheck s.each(typing_start, newTypingStart(data))
        of "USER_UPDATE":
            asyncCheck s.each(user_update, newUserUpdate(data))
        of "VOICE_STATE_UPDATE":
            asyncCheck s.each(voice_state_update, newVoiceStateUpdate(data))
        of "VOICE_SERVER_UPDATE":
            asyncCheck s.each(voice_server_update, newVoiceServerUpdate(data))
        of "WEBHOOKS_UPDATE":
            asyncCheck s.each(webhooks_update, newWebhooksUpdate(data))
        of "USER_SETTINGS_UPDATE", "PRESENCES_REPLACE": discard
        else:
            echo "Unknown websocket event :: " & event & "\n" & $data

proc identify(s: Shard) {.async, gcsafe.} =
    let payload = %*{
            "op": opIDENTIFY,
            "d": %*{
                "token": s.token,
                "properties": %*{
                    "$os": system.hostOS,
                    "$browser": static("Discordnim v" & $NimblePkgVersion),
                    "$device": static("Discordnim v" & $NimblePkgVersion),
                    "$referrer": "",
                    "$referring_domain": ""
                },
                "compress": s.compress
            }
        }

    if s.shardCount > 1:
        if s.shardID >= s.shardCount:
            raise newException(Exception, "ShardID has to be lower than ShardCount")
        payload["shard"] = %*[s.shardID, s.shardCount]

    try:
        await s.connection.sendText($payload)
    except:
        echo "Error sending identify packet\n" & getCurrentExceptionMsg()

proc resume(s: Shard) {.async, gcsafe.} =
    await s.connection.sendText($(%*{
        "token": s.token,
        "session_id": s.session_id,
        "seq": s.sequence
    }))

proc reconnect(s: Shard) {.async, gcsafe.} =
    await s.connection.close()
    try:
        s.connection = await newAsyncWebsocketClient("gateway.discord.gg", Port 443, "/"&GATEWAYVERSION, true)
    except:
        raise getCurrentException()
    s.sequence = 0
    s.session_ID = ""
    await s.identify()

proc shouldResumeSession(s: Shard): bool {.gcsafe, inline.} = s.suspended and (not s.invalidated)

proc setupHeartbeats(s: Shard) {.async, gcsafe.} =
    while not s.stop and not isClosed(s.connection.sock):
        var hb = %*{"op": opHeartbeat, "d": s.sequence}
        try:
            await s.connection.sendText($hb)
            await sleepAsync s.interval
        except:
            if s.stop: break
            echo "Something happened when sending heartbeat through the websocket connection"
            echo getCurrentExceptionMsg()
            break

proc sessionHandleSocketMessage(s: Shard) {.async, gcsafe.} =
    waitFor s.identify()

    var res: tuple[opcode: Opcode, data: string]

    while not isClosed(s.connection.sock) and not s.stop:
        try:
            res = await s.connection.readData()
        except:
            echo "Encountered an error while waiting for websocket data\n", getCurrentExceptionMsg()
            break

        if s.compress and res.opcode == Opcode.Binary:
            let t = zlib.uncompress(res.data)
            if t == "":
                echo "Failed to uncompress data and I'm not sure why. Sorry."
            else: res.data = t

        var data: JsonNode
        try:
            data = parseJson(res.data)
        except:
            echo "Error while parsing json: " & res.data
            break

        if data["s"].kind != JNull:
            s.sequence = data["s"].getInt()

        case data["op"].num
        of opDispatch:
            asyncCheck s.handleDispatch(data["t"].str, data["d"])
        of opHello:
            if s.shouldResumeSession():
                waitFor s.resume()
            else:
                s.interval = data["d"].fields["heartbeat_interval"].getInt()
                asyncCheck s.setupHeartbeats()
        of opHeartbeat:
            waitFor s.connection.sendText($(%*{"op": opHeartbeat, "d": s.sequence}))
        of opHeartbeatAck:
            # TODO :: Should probably check for HEARTBEAT_ACKs and close the connection if we don't get one
            discard
        of opInvalidSession:
            s.sequence = 0
            s.session_ID = ""
            s.invalidated = true
            if data["d"].kind == JBool and not (data["d"].bval):
                waitFor s.identify()
        of opReconnect:
            s.suspended = true
            waitFor s.reconnect()
        else:
            echo "Unknown opcode :: ", $data

    echo "connection closed\ncode: ", res.opcode, "\ndata: ", res.data

    s.suspended = true
    s.stop = true

    if not isClosed(s.connection.sock):
        await s.connection.close()

    if s.handlers.hasKey(on_disconnect):
        (s.handlers[on_disconnect]).each(s)

proc disconnect*(s: Shard) {.gcsafe, async.} =
    ## Disconnects a shard
    s.stop = true
    s.cache.clear()
    await s.connection.close()

proc startSession*(s: Shard) {.async, gcsafe.} =
    ## Connects a Shard
    if s.connection != nil and not isClosed(s.connection.sock):
        echo "Shard is already connected"
        return

    try:
        let wsurl = parseUri(s.gateway)
        s.connection = await newAsyncWebsocketClient(
                wsurl.hostname,
                if wsurl.scheme == "wss": Port(443) else: Port(80),
                wsurl.path&GATEWAYVERSION,
                true,
                useragent = static("Discordnim (https://github.com/Krognol/discordnim v" & $NimblePkgVersion & ")")
            )
    except:
        echo getCurrentExceptionMsg()
        s.stop = true
        return

    try:
        await sessionHandleSocketMessage(s)
    except:
        echo "Something happened in the socket listening :: ", getCurrentExceptionMsg()
