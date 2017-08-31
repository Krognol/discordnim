# Channel endpoints
{.hint[XDeclaredButNotUsed]: off.}
const
    BASE = "https://discordapp.com/api/v7"
    
    CDN_BASE = "https://cdn.discordapp.com"
    CDN_ATTACHMENTS = CDN_BASE & "/attachments/"
    CDN_AVATARS = CDN_BASE & "/avatars/"
    CDN_ICONS = CDN_BASE & "/icons/"
    CDN_SPLASHES = CDN_BASE & "/splashes/"
    CDN_CHANNEL_ICONS = CDN_BASE & "/channel-icons"
    
    GATEWAYVERSION = "?v=7&encoding=json"
    VERSION* = "2.0.0"

proc gateway*(): string {.inline.} = BASE & "/gateway/bot"

# CDN endpoints

proc endpointAttachment*(cid, aid, fname: string): string {.inline.} = CDN_ATTACHMENTS & cid & "/" & aid & "/" & fname & ".png"

proc endpointAvatar*(uid, hash: string): string {.inline.} = CDN_AVATARS & uid & "/" & hash & ".png"

proc endpointGuildIcon*(gid, hash: string): string {.inline.} = CDN_ICONS & gid & "/" & hash & ".png"

proc endpointGuildSplash*(gid, hash: string): string {.inline.} = CDN_SPLASHES & gid & "/" & hash & ".png"

proc endpointGroupIcon*(cid, hash: string): string{.inline.} = CDN_CHANNEL_ICONS & cid & "/" & hash & ".png"

# Channel endpoints

proc endpointChannels*(cid : string): string {.inline.} = BASE & "/channels/" & cid

proc endpointChannelMessages*(cid : string): string {.inline.} = endpointChannels(cid) & "/messages"

proc endpointChannelMessage*(cid, mid : string): string {.inline.} = endpointChannelMessages(cid) & "/" & mid

proc endpointReactions*(cid, mid: string): string{.inline.} = endpointChannelMessage(cid, mid) & "/reactions"

proc endpointOwnReactions*(cid, mid, eid: string): string {.inline.} = endpointReactions(cid, mid) & "/@me"

proc endpointMessageReactions*(cid, mid, eid: string): string {.inline.} = endpointReactions(cid, mid) & eid

proc endpointMessageUserReaction*(cid, mid, eid, uid: string): string {.inline.} = endpointMessageReactions(cid, mid, eid) & "/" & uid

proc endpointBulkDelete*(cid : string): string {.inline.} = endpointChannelMessages(cid) & "/bulk-delete"

proc endpointChannelPermissions*(cid, owid : string): string {.inline.} = endpointChannels(cid) & "/permissions" & owid

proc endpointChannelInvites*(cid : string): string {.inline.} = endpointChannels(cid) & "/invites"

proc endpointTriggerTypingIndicator*(cid : string): string {.inline.} = endpointChannels(cid) & "/typing"

proc endpointChannelPinnedMessages*(cid : string): string {.inline.} = endpointChannels(cid) & "/pins"

proc endpointPinnedChannelMessage*(cid, mid : string): string {.inline.} = endpointChannelPinnedMessages(cid) & "/" & mid

proc endpointGroupDMRecipient*(cid, uid : string): string {.inline.} = endpointChannels(cid) & "/recipients/" & uid

# Guild endpoints

proc endpointGuilds*(): string {.inline.} = BASE & "/guilds"

proc endpointGuild*(gid : string): string {.inline.} = endpointGuilds() & "/" & gid

proc endpointGuildChannels*(gid : string): string {.inline.} = endpointGuild(gid) & "/channels"

proc endpointGuildMembers*(gid : string): string {.inline.} = endpointGuild(gid) & "/members"

proc endpointGuildMember*(gid, uid : string): string {.inline.} = endpointGuildMembers(gid) & "/" & uid

proc endpointEditNick*(gid : string): string {.inline.} = endpointGuildMembers(gid) & "/@me/nick"

proc endpointGuildMemberRoles*(gid, uid, rid : string): string {.inline.} = endpointGuildMember(gid, uid) & "/roles/" & rid

proc endpointGuildBans*(gid : string): string {.inline.} = endpointGuild(gid) & "/bans"

proc endpointGuildBan*(gid, uid : string): string {.inline.} = endpointGuildBans(gid) & "/" & uid

proc endpointGuildRoles*(gid : string): string {.inline.} = endpointGuild(gid) & "/roles"

proc endpointGuildRole*(gid, rid : string): string {.inline.} = endpointGuildRoles(gid) & "/" & rid

proc endpointGuildPruneCount*(gid : string): string {.inline.} = endpointGuild(gid) & "/prune"

proc endpointGuildVoiceRegions*(gid : string): string {.inline.} = endpointGuild(gid) & "/regions"

proc endpointGuildInvites*(gid : string): string {.inline.} = endpointGuild(gid) & "/invites"

proc endpointGuildIntegrations*(gid : string): string {.inline.} = endpointGuild(gid) & "/integrations"

proc endpointGuildIntegration*(gid, iid : string): string {.inline.} = endpointGuildIntegrations(gid) & "/" & iid

proc endpointSyncGuildIntegration*(gid, iid : string): string {.inline.} = endpointGuildIntegration(gid, iid) & "/sync"

proc endpointGuildEmbed*(gid : string): string {.inline.} = endpointGuild(gid) & "/embed"

proc endpointGuildAuditLog(gid: string): string {.inline.} = endpointGuild(gid) & "/audit-logs"

# Invite endpoints

proc endpointInvite*(ic : string): string {.inline.} = BASE & "/invites/" & ic

# User endpoints

proc endpointCurrentUser*(): string {.inline.} = BASE & "/users/@me"

proc endpointUser*(uid : string): string {.inline.} = BASE & "/users/" & uid

proc endpointCurrentUserGuilds*(): string {.inline.} = endpointCurrentUser() & "/guilds"

proc endpointLeaveGuild*(gid : string): string {.inline.} = endpointCurrentUserGuilds() & "/" & gid

proc endpointUserDMs*(): string {.inline.} = endpointCurrentUser() & "/channels"

proc endpointDM*(): string {.inline.} = endpointUserDMs()

proc endpointUsersConnections*(): string {.inline.} = endpointCurrentUser() & "/connections"

# Voice endpoint

proc endpointListVoiceRegions*(): string {.inline.} = BASE & "/voice/regions"

# Webhook endpoints

proc endpointWebhooks*(cid : string): string {.inline.} = endpointChannels(cid) & "/webhooks"

proc endpointGuildWebhooks*(gid: string): string {.inline.} = endpointGuild(gid) & "/webhooks"

proc endpointWebhook*(wid : string): string {.inline.} = BASE & "/webhooks/" & wid

proc endpointWebhookWithToken*(wid, token : string): string {.inline.} = endpointWebhook(wid) & "/" & token

proc endpointAuth*(): string {.inline.} = BASE & "/auth"