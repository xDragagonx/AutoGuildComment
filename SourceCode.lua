local avatarId = avatar.GetId()
local avatarName = object.GetName(avatarId)
local guildTextDominion = userMods.ToWString("\nDear Avarice gamers,\nDominion(s) are starting in less than 1 hour. Please prepare the following:\nPvP food of 10%'s | 3x3 vendor\nAlchemy potions +50 | Alchemy or playertrading, check Auction House\nPotents +40 | 3x3 vendor, Relic Master NPC\nMana Batteries | 3x3 vendor\nLegendary or Fabled Dragon Tears | Embrium vendor in Private Allod or at Auction House")
local holdDailyMessage = nil
function Main()
	GetEventsId()
	
	common.RegisterEventHandler(EVENT_GUILD_DECLINE_BUSY, "EVENT_GUILD_DECLINE_BUSY") --https://alloder.pro/md/LuaApi/EventGuildDeclineBusy.html
	common.RegisterEventHandler(EVENT_GUILD_DECLINE_IGNORED, "EVENT_GUILD_DECLINE_IGNORED") --https://alloder.pro/md/LuaApi/EventGuildDeclineIgnored.html
	common.RegisterEventHandler(EVENT_GUILD_MEMBER_ADDED, "EVENT_GUILD_MEMBER_ADDED") --https://alloder.pro/md/LuaApi/EventGuildMemberAdded.html

	common.RegisterEventHandler(EVENT_MISSION_RULE_ADDED, "EVENT_MISSION_RULE_ADDED") --https://alloder.pro/md/LuaApi/EventMissionRuleAdded.html
	-- common.RegisterEventHandler(EVENT_MISSION_RULE_CHANGED, "EVENT_MISSION_RULE_CHANGED") --https://alloder.pro/md/LuaApi/EventMissionRuleAdded.html
	-- common.RegisterEventHandler(EVENT_MISSION_RULE_COUNTER_CHANGED, "EVENT_MISSION_RULE_COUNTER_CHANGED") --https://alloder.pro/md/LuaApi/EventMissionRuleAdded.html
	common.RegisterEventHandler(EVENT_MISSION_RULE_REMOVED, "EVENT_MISSION_RULE_REMOVED") --https://alloder.pro/md/LuaApi/EventMissionRuleAdded.html
end

function EVENT_GUILD_DECLINE_BUSY(params) --Sent if an invitation to a guild fails (the player is busy). 
	chat(2, "failed to invite",userMods.FromWString(params),"to the guild. reason: busy")

end
function EVENT_GUILD_DECLINE_IGNORED(params) --Notification about the impossibility of an invitation to the guild due to ignorance. 
	chat(2, "failed to invite",userMods.FromWString(params),"to the guild. reason: ignored")

end
function EVENT_GUILD_MEMBER_ADDED(params) --Sent if a player has been added to the main player's guild. 
	--chat(2, params.name,"was added to the guild. guildmemberid:",params.id)
	local invitedName = params.name --the name of the guild member
	local invitedId = params.id --guild member identifier (does not match the player identifier)
	local memberInfo = guild.GetMemberInfo(invitedId) --https://alloder.pro/md/LuaApi/FunctionGuildGetMemberInfo.html

	AssignGuildRank(memberInfo, invitedId)
	AssignGuildComment(memberInfo, invitedId)
	AssignGuildTabard(invitedId)
	AddToGuildMessage(invitedName)
end
function EVENT_MISSION_RULE_ADDED(params)
	local eventId = params.ruleId
	local calendarEventInfo = rules.GetEventInfo( eventId )
	if calendarEventInfo.sysName == "MWLadderPrepareTime" then
		ChangeGuildMessage(guildTextDominion)
	end
	if calendarEventInfo.sysName == "MWRaidPrepareTime" then
		ChangeGuildMessage(guildTextDominion)
	end
	chat(2, calendarEventInfo.sysName,"event started.")
end
-- function EVENT_MISSION_RULE_CHANGED(params)
-- 	local eventId = params.ruleId
-- 	local calendarEventInfo = rules.GetEventInfo( eventId )
-- 	chat(2, calendarEventInfo.name,"event changed.")
-- end
-- function EVENT_MISSION_RULE_COUNTER_CHANGED(params)
-- 	local eventId = params.ruleId
-- 	local calendarEventInfo = rules.GetEventInfo( eventId )
-- 	chat(2, calendarEventInfo.name,"event counter changed.")
-- end
function EVENT_MISSION_RULE_REMOVED(params)
	local eventId = params.ruleId
	local calendarEventInfo = rules.GetEventInfo( eventId )
	if calendarEventInfo.sysName == "MWLadderPrepareTime" then
		ReturnGuildMessage()
	end
	if calendarEventInfo.sysName == "MWRaidPrepareTime" then
		ReturnGuildMessage()
	end
	chat(2, calendarEventInfo.name,"event has ended.")
end

function AssignGuildRank(memberInfo, invitedId)
	--Automatically changes guild rank depending whether max level or not.
	if memberInfo.level < 105 then
		guild.ChangeRank( invitedId, 6 ) --https://alloder.pro/md/LuaApi/FunctionGuildChangeRank.html
	else --9 outlawed, 8 punished, 7 alternate, 6 trial, 5, member, 4 veteran, 3 junior officer, 2 senior officer, 1 unseen.
		guild.ChangeRank( invitedId, 5) --https://alloder.pro/md/LuaApi/FunctionGuildChangeRank.html
	end
end

function AssignGuildComment(memberInfo, invitedId)
	--Automatically adds comment to the newly joined guildmember.
	common.LogInfo("common", "-".."789 Info upon inviting a new player, addonUsername: "..avatarName.."id: "..avatarId.."-")
	local DescText = "Welcome mail sent to "..memberInfo.name.." lv"..tostring(memberInfo.level).." | invited by "..avatarName.." on "..memberInfo.joinTime.d.."/"..memberInfo.joinTime.m.."/"..memberInfo.joinTime.y
	guild.SetMemberDescription( invitedId, DescText) --Add DescText to the guildmember comment.
end

function AssignGuildTabard(invitedId)
	--Automatically gives regular tabard permission to the newly joined guildmember.
	--Somehow this works as an officer, eventhough you need to be treasurer and above rank to hand out tabard.
	if guild.CanDistributeTabard( invitedId ) then --https://alloder.pro/md/LuaApi/FunctionGuildCanDistributeTabard.html
		guild.DistributeTabard( invitedId, ENUM_TabardType_Common )
	else
		chat(2, "There are no regular tabards left to give. Check if inactives can be reclaimed and assign them to the new guild member, please.")
	end
end

function AddToGuildMessage(invitedName)
	--Add the new playername to the guild message
	holdDailyMessage = guild.GetMessage() --https://alloder.pro/md/LuaApi/FunctionGuildGetMessage.html
	guild.SetMessage( holdDailyMessage..invitedName..", ") --https://alloder.pro/md/LuaApi/FunctionGuildSetMessage.html
end

function ChangeGuildMessage(guildTextDominion)
	holdDailyMessage = guild.GetMessage()
	guild.SetMessage(guildTextDominion)
end
function ReturnGuildMessage()
	guild.SetMessage(holdDailyMessage)
end

function GetEventsId()
	-- local newDailyMessage = userMods.ToWString("\nDear Avarice gamers,\nDominions are starting in less than 1 hour. Please prepare the following:\nPvP food of 10%'s | 3x3 vendor\nAlchemy potions +50 | Alchemy or playertrading, check Auction House\nPotents +40 | 3x3 vendor, Relic Master NPC\nMana Batteries | 3x3 vendor\nLegendary or Fabled Dragon Tears | Embrium vendor in Private Allod or at Auction House")
	-- guild.SetMessage(newDailyMessage)

	local eventRules = rules.GetEvents() 
	--chat(2,eventRules) --table of ID's representing each calendar event.
	for index = 20, 40 - 1 do --iterate through the table of calendar event ID's
		--For each ID we find, we get the eventInfo and store that in a table eventRuleInfo
	  	local eventRuleInfo = rules.GetEventInfo( eventRules[ index ] ) --https://alloder.pro/md/LuaApi/FunctionRulesGetEventInfo.html
		local eventName = userMods.FromWString(eventRuleInfo.name)
		local eventId = eventRuleInfo.id
	  	chat(1, eventName, eventId)
		if eventId == 25229 then
			chat(2, eventRuleInfo)
			common.LogInfo("common", "-"..eventRuleInfo.sysName.."-")
		end
		
		-- if eventName == "Storm" then
		-- 	chat(2, eventRuleInfo)
		-- 	--common.LogInfo("common", "-"..eventRuleInfo.."-")
		-- end
		
		
	  	-- if eventRuleInfo.sysName == "MWLadderPrepareTime" then
		-- 	chat(2, eventRuleInfo)
		-- 	local eventInterval = rules.GetEventTimeIntervals( eventRuleInfo.id )
		-- 	chat(2, "event interval:",eventInterval)
		-- 	-- if eventRuleInfo.isActive == true then
		-- 	-- 	holdDailyMessage = guild.GetMessage()
		-- 	-- 	guild.SetMessage("Dear Avarice, Dominions are about to begin. Please prepare with potion")
		-- 	-- end
		-- end
	end
	
	
	

	-- local time = mission.GetGlobalDateTime()
	-- if time.wday == 7 and time.h == 9 and time.min == 23 then
	-- 	chat(1, "it's domi time!")
	-- 	holdDailyMessage = guild.GetMessage()
	-- 	guild.SetMessage(holdDailyMessage.."Domi is about to start, please prepare with pots etc.")
	-- end

	--guild.GetMessage() --https://alloder.pro/md/LuaApi/FunctionGuildGetMessage.html
	--guild.SetMessage( guild.GetMessage()..params.name..", ") --https://alloder.pro/md/LuaApi/FunctionGuildSetMessage.html


end
-- ||Maybe of use for later||
-- function GetMemberDescrptn() --https://alloder.pro/md/LuaApi/FunctionGuildGetMemberDescription.html
-- 	local memberDescription = guild.GetMemberDescription( memberId )
-- 	chat(2, memberDescription)
-- end

if (avatar.IsExist()) then
	chat(2,"Loaded.")
	Main()
else
	chat(2,"Loaded.")
	common.RegisterEventHandler(Main, "EVENT_AVATAR_CREATED")
end