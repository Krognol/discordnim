{.hint[XDeclaredButNotUsed]: off.}
const
    BASE = "https://discordapp.com/api/v7"

    CDN_BASE = "https://cdn.discordapp.com"
    CDN_ATTACHMENTS = CDN_BASE & "/attachments/"
    CDN_AVATARS = CDN_BASE & "/avatars/"
    CDN_ICONS = CDN_BASE & "/icons/"
    CDN_SPLASHES = CDN_BASE & "/splashes/"
    CDN_CHANNEL_ICONS = CDN_BASE & "/channel-icons"

    GATEWAYVERSION* = "?v=7&encoding=json"
    NimblePkgVersion* {.strdefine.} = "2.3.0" # Compile-time defined by Nim from version on .nimble file

template gateway*(): string = BASE & "/gateway/bot"

# CDN endpoints

template endpointAttachment*(cid, aid, fname: string): string = CDN_ATTACHMENTS & cid & "/" & aid & "/" & fname & ".png"

template endpointAvatar*(uid, hash: string): string = CDN_AVATARS & uid & "/" & hash & ".png"

template endpointAvatarAnimated*(uid, hash: string): string = CDN_AVATARS & uid & "/" & hash & ".gif"

template endpointGuildIcon*(gid, hash: string): string = CDN_ICONS & gid & "/" & hash & ".png"

template endpointGuildSplash*(gid, hash: string): string = CDN_SPLASHES & gid & "/" & hash & ".png"

template endpointGroupIcon*(cid, hash: string): string = CDN_CHANNEL_ICONS & cid & "/" & hash & ".png"

# Channel endpoints

template endpointChannels*(cid: string): string = BASE & "/channels/" & cid

template endpointChannelMessages*(cid: string): string = endpointChannels(cid) & "/messages"

template endpointChannelMessage*(cid, mid: string): string = endpointChannelMessages(cid) & "/" & mid

template endpointReactions*(cid, mid: string): string = endpointChannelMessage(cid, mid) & "/reactions"

template endpointOwnReactions*(cid, mid, eid: string): string = endpointReactions(cid, mid) & "/@me"

template endpointMessageReactions*(cid, mid, eid: string): string = endpointReactions(cid, mid) & eid

template endpointMessageUserReaction*(cid, mid, eid, uid: string): string = endpointMessageReactions(cid, mid, eid) & "/" & uid

template endpointBulkDelete*(cid: string): string = endpointChannelMessages(cid) & "/bulk-delete"

template endpointChannelPermissions*(cid, owid: string): string = endpointChannels(cid) & "/permissions" & owid

template endpointChannelInvites*(cid: string): string = endpointChannels(cid) & "/invites"

template endpointTriggerTypingIndicator*(cid: string): string = endpointChannels(cid) & "/typing"

template endpointChannelPinnedMessages*(cid: string): string = endpointChannels(cid) & "/pins"

template endpointPinnedChannelMessage*(cid, mid: string): string = endpointChannelPinnedMessages(cid) & "/" & mid

template endpointGroupDMRecipient*(cid, uid: string): string = endpointChannels(cid) & "/recipients/" & uid

# Guild endpoints

template endpointGuilds*(): string = BASE & "/guilds"

template endpointGuild*(gid: string): string = endpointGuilds() & "/" & gid

template endpointGuildChannels*(gid: string): string = endpointGuild(gid) & "/channels"

template endpointGuildMembers*(gid: string): string = endpointGuild(gid) & "/members"

template endpointGuildMember*(gid, uid: string): string = endpointGuildMembers(gid) & "/" & uid

template endpointEditNick*(gid: string): string = endpointGuildMembers(gid) & "/@me/nick"

template endpointGuildMemberRoles*(gid, uid, rid: string): string = endpointGuildMember(gid, uid) & "/roles/" & rid

template endpointGuildBans*(gid: string): string = endpointGuild(gid) & "/bans"

template endpointGuildBan*(gid, uid: string): string = endpointGuildBans(gid) & "/" & uid

template endpointGuildRoles*(gid: string): string = endpointGuild(gid) & "/roles"

template endpointGuildRole*(gid, rid: string): string = endpointGuildRoles(gid) & "/" & rid

template endpointGuildPruneCount*(gid: string): string = endpointGuild(gid) & "/prune"

template endpointGuildVoiceRegions*(gid: string): string = endpointGuild(gid) & "/regions"

template endpointGuildInvites*(gid: string): string = endpointGuild(gid) & "/invites"

template endpointGuildIntegrations*(gid: string): string = endpointGuild(gid) & "/integrations"

template endpointGuildIntegration*(gid, iid: string): string = endpointGuildIntegrations(gid) & "/" & iid

template endpointSyncGuildIntegration*(gid, iid: string): string = endpointGuildIntegration(gid, iid) & "/sync"

template endpointGuildEmbed*(gid: string): string = endpointGuild(gid) & "/embed"

template endpointGuildAuditLog(gid: string): string = endpointGuild(gid) & "/audit-logs"

template endpointGuildEmojis(gid: string): string = endpointGuild(gid) & "/emojis"

template endpointGuildEmoji(gid, eid: string): string = endpointGuildEmojis(gid) & "/" & eid

# Invite endpoints

template endpointInvite*(ic: string): string = BASE & "/invites/" & ic

# User endpoints

template endpointCurrentUser*(): string = BASE & "/users/@me"

template endpointUser*(uid: string): string = BASE & "/users/" & uid

template endpointCurrentUserGuilds*(): string = endpointCurrentUser() & "/guilds"

template endpointLeaveGuild*(gid: string): string = endpointCurrentUserGuilds() & "/" & gid

template endpointUserDMs*(): string = endpointCurrentUser() & "/channels"

template endpointDM*(): string = endpointUserDMs()

template endpointUsersConnections*(): string = endpointCurrentUser() & "/connections"

# Voice endpoint

template endpointListVoiceRegions*(): string = BASE & "/voice/regions"

# Webhook endpoints

template endpointWebhooks*(cid: string): string = endpointChannels(cid) & "/webhooks"

template endpointGuildWebhooks*(gid: string): string = endpointGuild(gid) & "/webhooks"

template endpointWebhook*(wid: string): string = BASE & "/webhooks/" & wid

template endpointWebhookWithToken*(wid, token: string): string = endpointWebhook(wid) & "/" & token

template endpointAuth*(): string = BASE & "/auth"
