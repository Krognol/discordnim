# Channel endpoints
{.hint[XDeclaredButNotUsed]: off.}
const
    BASE: string = "https://discordapp.com/api/v7"
    GATEWAYVERSION: string = "?v=7&encoding=json"
    VERSION*: string = "1.5.0"

proc Gateway(): string =
    return BASE & "/gateway/bot"

proc endpointChannels(cid : string): string = BASE & "/channels/" & cid

proc endpointChannelMessages(cid : string): string = endpointChannels(cid) & "/messages"

proc endpointChannelMessage(cid, mid : string): string = endpointChannelMessages(cid) & "/" & mid

proc endpointReactions(cid, mid: string): string = endpointChannelMessage(cid, mid) & "/reactions"

proc endpointOwnReactions(cid, mid, eid: string): string = endpointReactions(cid, mid) & "/@me"

proc endpointMessageReactions(cid, mid, eid: string): string = endpointReactions(cid, mid) & eid

proc endpointMessageUserReaction(cid, mid, eid, uid: string): string = endpointMessageReactions(cid, mid, eid) & "/" & uid

proc endpointBulkDelete(cid : string): string = endpointChannelMessages(cid) & "/bulk-delete"

proc endpointChannelPermissions(cid, owid : string): string = endpointChannels(cid) & "/permissions" & owid

proc endpointChannelInvites(cid : string): string = endpointChannels(cid) & "/invites"

proc endpointTriggerTypingIndicator(cid : string): string = endpointChannels(cid) & "/typing"

proc endpointChannelPinnedMessages(cid : string): string = endpointChannels(cid) & "/pins"

proc endpointPinnedChannelMessage(cid, mid : string): string = endpointChannelPinnedMessages(cid) & "/" & mid

proc endpointGroupDMRecipient(cid, uid : string): string = endpointChannels(cid) & "/recipients/" & uid

# Guild endpoints

proc endpointGuilds(): string =
    return BASE & "/guilds"

proc endpointGuild(gid : string): string = endpointGuilds() & "/" & gid

proc endpointGuildChannels(gid : string): string = endpointGuild(gid) & "/channels"

proc endpointGuildMembers(gid : string): string = endpointGuild(gid) & "/members"

proc endpointGuildMember(gid, uid : string): string = endpointGuildMembers(gid) & "/" & uid

proc endpointEditNick(gid : string): string = endpointGuildMembers(gid) & "/@me/nick"

proc endpointGuildMemberRoles(gid, uid, rid : string): string = endpointGuildMember(gid, uid) & "/roles/" & rid

proc endpointGuildBans(gid : string): string = endpointGuild(gid) & "/bans"

proc endpointGuildBan(gid, uid : string): string = endpointGuildBans(gid) & "/" & uid

proc endpointGuildRoles(gid : string): string = endpointGuild(gid) & "/roles"

proc endpointGuildRole(gid, rid : string): string = endpointGuildRoles(gid) & "/" & rid

proc endpointGuildPruneCount(gid : string): string = endpointGuild(gid) & "/prune"

proc endpointGuildVoiceRegions(gid : string): string = endpointGuild(gid) & "/regions"

proc endpointGuildInvites(gid : string): string = endpointGuild(gid) & "/invites"

proc endpointGuildIntegrations(gid : string): string = endpointGuild(gid) & "/integrations"

proc endpointGuildIntegration(gid, iid : string): string = endpointGuildIntegrations(gid) & "/" & iid

proc endpointSyncGuildIntegration(gid, iid : string): string = endpointGuildIntegration(gid, iid) & "/sync"

proc endpointGuildEmbed(gid : string): string = endpointGuild(gid) & "/embed"

# Invite endpoints

proc endpointInvite(ic : string): string = BASE & "/invites/" & ic

# User endpoints

proc endpointCurrentUser(): string = BASE & "/users/@me"

proc endpointUser(uid : string): string = BASE & "/users/" & uid

proc endpointCurrentUserGuilds(): string = endpointCurrentUser() & "/guilds"

proc endpointLeaveGuild(gid : string): string = endpointCurrentUserGuilds() & "/" & gid

proc endpointUserDMs(): string = endpointCurrentUser() & "/channels"

proc endpointDM(): string = endpointUserDMs()

proc endpointUsersConnections(): string = endpointCurrentUser() & "/connections"

# Voice endpoint

proc endpointListVoiceRegions(): string = BASE & "/voice/regions"

# Webhook endpoints

proc endpointWebhooks(cid : string): string = endpointChannels(cid) & "/webhooks"

proc endpointGuildWebhooks(gid: string): string = endpointGuild(gid) & "/webhooks"

proc endpointWebhook(wid : string): string = BASE & "/webhooks/" & wid

proc endpointWebhookWithToken(wid, token : string): string = endpointWebhook(wid) & "/" & token

proc endpointAuth(): string = BASE & "/auth"