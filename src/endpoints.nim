# Channel endpoints

const
    BASE: string = "https://discordapp.com/api"
    GATEWAYVERSION: string = "?v=6&encoding=json"
    VERSION: string = "1.0"

proc Gateway(): string =
    return BASE & "/gateway"

proc EndpointGetChannel(cid : string): string =
    return BASE & "/channels/" & cid

proc EndpointModifyChannel(cid : string): string =
    return EndpointGetChannel(cid)

proc EndpointDeleteChannel(cid : string): string =
    return EndpointGetChannel(cid)

proc EndpointGetChannelMessages(cid : string): string =
    return EndpointGetChannel(cid) & "/messages"

proc EndpointGetChannelMessage(cid, mid : string): string =
    return EndpointGetChannelMessages(cid) & "/" & mid

proc EndpointCreateMessage(cid : string): string =
    return EndpointGetChannelMessages(cid)

proc EndpointCreateReaction(cid, mid, eid: string): string =
    return EndpointGetChannelMessage(cid, mid) & "/reactions/" & eid & "@me"

proc EndpointDeleteOwnReaction(cid, mid, eid: string): string =
    return EndpointCreateReaction(cid, mid, eid)

proc EndpointDeleteUserReaction(cid, mid, eid, uid: string): string =
    return EndpointGetChannelMessage(cid, mid) & "/reactions/" & eid & "/" & uid

proc EndpointGetMessageReactions(cid, mid, eid: string): string =
    return EndpointGetChannelMessage(cid, mid) & "/reactions/" & eid

proc EndpointDeleteAllReactions(cid, mid: string): string =
    return EndpointGetChannelMessage(cid, mid) & "/reactions"

proc EndpointEditMessage(cid, mid: string): string =
    return EndpointGetChannelMessage(cid, mid)

proc EndpointDeleteMessage(cid, mid : string): string =
    return EndpointGetChannelMessage(cid, mid)

proc EndpointBulkDelete(cid : string): string =
    return EndpointGetChannelMessages(cid) & "/bulk-delete"

proc EndpointEditChannelPermissions(cid, owid : string): string =
    return EndpointGetChannel(cid) & "/permissions" & owid

proc EndpointGetChannelInvites(cid : string): string =
    return EndpointGetChannel(cid) & "/invites"

proc EndpointCreateChannelInvite(cid : string): string =
    return EndpointGetChannelInvites(cid)

proc EndpointDeleteChannelPermission(cid, owid : string): string =
    return EndpointEditChannelPermissions(cid, owid)

proc EndpointTriggerTypingIndicator(cid : string): string =
    return EndpointGetChannel(cid) & "/typing"

proc EndpointGetPinnedMessages(cid : string): string =
    return EndpointGetChannel(cid) & "/pins"

proc EndpointAddPinnedChannelMessage(cid, mid : string): string =
    return EndpointGetPinnedMessages(cid) & "/" & mid

proc EndpointDeletePinnedChannelMessage(cid, mid : string): string =
    return EndpointAddPinnedChannelMessage(cid, mid)

proc EndpointGroupDMAddRecipient(cid, uid : string): string =
    return EndpointGetChannel(cid) & "/recipients/" & uid

proc EndpointGroupDMRemoveRecipient(cid, uid : string): string =
    return EndpointGroupDMAddRecipient(cid, uid)

# Guild endpoints

proc EndpointCreateGuild(): string =
    return BASE & "/guilds"

proc EndpointGetGuild(gid : string): string =
    return EndpointCreateGuild() & "/" & gid

proc EndpointModifyGuild(gid : string): string =
    return EndpointGetGuild(gid)

proc EndpointDeleteGuild(gid : string): string =
    return EndpointGetGuild(gid)

proc EndpointGetGuildChannels(gid : string): string =
    return EndpointGetGuild(gid) & "/channels"

proc EndpointCreateGuildChannel(gid : string): string =
    return EndpointGetGuildChannels(gid)

proc EndpointModifyGuildChannelPositions(gid : string): string =
    return EndpointGetGuildChannels(gid)

proc EndpointListGuildMembers(gid : string): string =
    return EndpointGetGuild(gid) & "/members"

proc EndpointGetGuildMember(gid, uid : string): string =
    return EndpointListGuildMembers(gid) & "/" & uid

proc EndpointAddGuildMember(gid, uid : string): string =
    return EndpointGetGuildMember(gid, uid)

proc EndpointModifyGuildMember(gid, uid : string): string =
    return EndpointGetGuildMember(gid, uid)

proc EndpointModifyNick(gid : string): string =
    return EndpointListGuildMembers(gid) & "/@me/nick"

proc EndpointAddGuildMemberRole(gid, uid, rid : string): string =
    return EndpointGetGuildMember(gid, uid) & "/roles/" & rid

proc EndpointRemoveGuildMemberRole(gid, uid, rid : string): string =
    return EndpointAddGuildMemberRole(gid, uid, rid)

proc EndpointRemoveGuildMember(gid, uid : string): string =
    return EndpointGetGuildMember(gid, uid)

proc EndpointGetGuildBans(gid : string): string =
    return EndpointGetGuild(gid) & "/bans"

proc EndpointCreateGuildBan(gid, uid : string): string =
    return EndpointGetGuildBans(gid) & "/" & uid

proc EndpointRemoveGuildBan(gid, uid : string): string =
    return EndpointCreateGuildBan(gid, uid)

proc EndpointGetGuildRoles(gid : string): string =
    return EndpointGetGuild(gid) & "/roles"

proc EndpointCreateGuildRole(gid : string): string =
    return EndpointGetGuildRoles(gid)

proc EndpointModifyGuildRolePositions(gid : string): string =
    return EndpointGetGuildRoles(gid)

proc EndpointModifyGuildRole(gid, rid : string): string =
    return EndpointGetGuildRoles(gid) & "/" & rid

proc EndpointDeleteGuildRole(gid, rid : string): string =
    return EndpointGetGuildRoles(gid) & "/" & rid

proc EndpointGetGuildPruneCount(gid : string): string =
    return EndpointGetGuild(gid) & "/prune"

proc EndpointBeginGuildPruneCount(gid : string): string =
    return EndpointGetGuild(gid) & "/prune"

proc EndpointGetGuildVoiceRegions(gid : string): string =
    return EndpointGetGuild(gid) & "/regions"

proc EndpointGetGuildInvites(gid : string): string =
    return EndpointGetGuild(gid) & "/invites"

proc EndpointGetGuildIntegrations(gid : string): string =
    return EndpointGetGuild(gid) & "/integrations"

proc EndpointModifyGuildIntegration(gid, iid : string): string =
    return EndpointGetGuild(gid) & "/integrations/" & iid

proc EndpointDeleteGuildIntegration(gid, iid : string): string =
    return EndpointGetGuild(gid) & "/integrations/" & iid

proc EndpointSyncGuildIntegration(gid, iid : string): string =
    return EndpointGetGuild(gid) & "/integrations/" & iid & "/sync"

proc EndpointGetGuildEmbed(gid : string): string =
    return EndpointGetGuild(gid) & "/embed"

proc EndpointModifyGuildEmbed(gid : string): string =
    return EndpointGetGuild(gid) & "/embed"

# Invite endpoints

proc EndpointGetInvite(ic : string): string =
    return BASE & "/invites/" & ic

proc EndpointDeleteInvite(ic : string): string =
    return EndpointGetInvite(ic)

proc EndpointAcceptInvite(ic : string): string =
    return EndpointGetInvite(ic)

# User endpoints

proc EndpointGetCurrentUser(): string =
    return BASE & "/users/@me"

proc EndpointGetUser(uid : string): string =
    return BASE & "/users/" & uid

proc EndpointModifyCurrentUser(): string =
    return EndpointGetCurrentUser()

proc EndpointGetCurrentUserGuilds(): string =
    return EndpointGetCurrentUser() & "/guilds"

proc EndpointLeaveGuild(gid : string): string =
    return EndpointGetCurrentUserGuilds() & "/" & gid

proc EndpointGetUserDMs(): string =
    return EndpointGetCurrentUser() & "/channels"

proc EndpointCreateDM(): string =
    return EndpointGetUserDMs()

proc EndpointCreateGroupDM(): string =
    return EndpointGetUserDMs()

proc EndpointGetUsersConnections(): string =
    return EndpointGetCurrentUser() & "/connections"

# Voice endpoint

proc EndpointListVoiceRegions(): string =
    return BASE & "/voice/regions"

# Webhook endpoints

proc EndpointCreateWebhook(cid : string): string =
    return EndpointGetChannel(cid) & "/webhooks"

proc EndpointGetChannelWebhooks(cid : string): string =
    return EndpointGetChannel(cid) & "/webhooks"

proc EndpointGetGuildWebhook(gid : string): string =
    return EndpointGetGuild(gid) & "/webhooks"

proc EndpointGetWebhook(wid : string): string =
    return BASE & "/webhooks/" & wid

proc EndpointGetWebhookWithToken(wid, token : string): string =
    EndpointGetWebhook(wid) & "/" & token

proc EndpointModifyWebhook(wid : string): string =
    return EndpointGetWebhook(wid)

proc EndpointModifyWebhookWithToken(wid, token : string): string =
    return EndpointGetWebhookWithToken(wid, token)

proc EndpointDeleteWebhook(wid : string): string =
    return EndpointGetWebhook(wid)

proc EndpointDeleteWebhookWithToken(wid, token : string): string =
    return EndpointGetWebhookWithToken(wid, token)

proc EndpointExecuteWebhook(wid, token : string): string =
    return EndpointGetWebhookWithToken(wid, token)

proc EndpointAuth(): string =
    return BASE & "/auth"

proc EndpointLogin(): string =
    return EndpointAuth() & "/login"
