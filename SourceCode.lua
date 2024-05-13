--What addon does:
--Adds guild comment to invited player, adds tabard, adds rank, adds name to daily message for mail reminder.
--informs when you failed to ginv ppl by ignorance or afk.
--adds guildMessage when guild levelled up to celebrate with guild.
--adds guildMessage announcement when dominions are about to start, and repeats it several times over an hour
-------------------------------------------
-- WIDGET
local wtButton = mainForm:GetChildChecked("Button",false)
wtButton:SetVal("button_label", userMods.ToWString("Copy guild recruitment message"))
wtButton:Show(false)

-------------------------------------------
local avatarId = nil
local avatarName = nil
local getAvatarIdCount = 0 --Used for counting how often it reloaded the function to assign an Id to the avatar.
local guildTextDominion = userMods.ToWString(locales["DominionText"])
local previousGuildMessage = nil --Placeholder for the previous guild's daily message.
local currentGuildMessage = nil --Placeholder for the current guild's daily message.
local seconds = 0
local spamMessageCounter = 2
local recruitCooldown = 10 --(1.5h 5400)
Global("guildRecruitmentMessage", nil)
Global("reminderCooldown", 15) --15 is never used, was necesarry to avoid error.

function Main()
	if avatar.IsExist then --Makes sure we get the id and name of the avatar (addon user).
		avatarId = avatar.GetId()
		avatarName = object.GetName(avatarId)
	else
		GetAvatarId()
	end
	--GetEventsId()
	--ChangeGUI()
	Currencies()
	common.RegisterEventHandler(EVENT_GUILD_DECLINE_BUSY, "EVENT_GUILD_DECLINE_BUSY") --https://alloder.pro/md/LuaApi/EventGuildDeclineBusy.html
	common.RegisterEventHandler(EVENT_GUILD_DECLINE_IGNORED, "EVENT_GUILD_DECLINE_IGNORED") --https://alloder.pro/md/LuaApi/EventGuildDeclineIgnored.html
	common.RegisterEventHandler(EVENT_GUILD_MEMBER_ADDED, "EVENT_GUILD_MEMBER_ADDED") --https://alloder.pro/md/LuaApi/EventGuildMemberAdded.html
	common.RegisterEventHandler(EVENT_GUILD_MEMBER_REMOVED, "EVENT_GUILD_MEMBER_REMOVED") --https://alloder.pro/md/LuaApi/EventGuildMemberRemoved.html
	common.RegisterEventHandler(EVENT_GUILD_LEVEL_CHANGED, "EVENT_GUILD_LEVEL_CHANGED") --https://alloder.pro/md/LuaApi/EventGuildLevelChanged.html
	--common.RegisterEventHandler(EVENT_MISSION_RULE_ADDED, "EVENT_MISSION_RULE_ADDED") --https://alloder.pro/md/LuaApi/EventMissionRuleAdded.html Only works when daily reset adds calendar event
	common.RegisterEventHandler(EVENT_MISSION_RULE_CHANGED, "EVENT_MISSION_RULE_CHANGED") --https://alloder.pro/md/LuaApi/EventMissionRuleChanged.html
	--common.RegisterEventHandler(EVENT_MISSION_RULE_REMOVED, "EVENT_MISSION_RULE_REMOVED") --https://alloder.pro/md/LuaApi/EventMissionRuleAdded.html Only works when daily reset removes calendar event
	--common.RegisterEventHandler(EVENT_NEWS_POST_LOADED, "EVENT_NEWS_POST_LOADED") --https://alloder.pro/md/LuaApi/EventNewsPostLoaded.html Seems to not work for now. Awaiting feedback from Lafayette
	--common.RegisterEventHandler(EVENT_NEWS_POST_SELECTED, "EVENT_NEWS_POST_SELECTED") --https://alloder.pro/md/LuaApi/EventNewsPostSelected.html Seems to not work for now. Awaiting feedback from Lafayette
	--RecruitmentReminderTimer()	
	DnD.Init(wtButton, nil, true)
end
-- function EVENT_NEWS_POST_SELECTED(params)
-- 	ruleId = params.ruleId
-- 	local calendarEventId = rules.GetEventByRuleId( ruleId )
-- 	local calendarEventInfo = rules.GetEventInfo( calendarEventId )
-- 	chat(3, "selected post:", calendarEventInfo.name, calendarEventId)
-- end
-- function EVENT_NEWS_POST_LOADED(params)
-- 	chat(3, "hello", params.ruleId)
-- end
function ChangeGUI()
	chat(2, "changing GUI")
	
	chat(2, "I haven't crashed yet")
end

function GetEventsId()
	-- local newDailyMessage = userMods.ToWString("\nDear Avarice gamers,\nDominions are starting in less than 1 hour. Please prepare the following:\nPvP food of 10%'s | 3x3 vendor\nAlchemy potions +50 | Alchemy or playertrading, check Auction House\nPotents +40 | 3x3 vendor, Relic Master NPC\nMana Batteries | 3x3 vendor\nLegendary or Fabled Dragon Tears | Embrium vendor in Private Allod or at Auction House")
	-- guild.SetMessage(newDailyMessage)

	local calendarEvents = rules.GetEvents()
	--chat(2,calendarEvents) --table of ID's representing each calendar event.
	
	for i = 0, GetTableSize(calendarEvents) - 1 do --iterate through the table of calendar event ID's
		
	  	local calendarEventInfo = rules.GetEventInfo( calendarEvents[i]) --https://alloder.pro/md/LuaApi/FunctionRulesGetEventInfo.html
		local eventName = userMods.FromWString(calendarEventInfo.name)
		local eventId = calendarEventInfo.id
	  	--chat(2, i, eventName, eventId)
		--common.LogInfo("common", "-"..i.." "..eventName.." "..eventId.."-")
		
		-- if calendarEventInfo.types[ RULE_TYPE_GROUP ] then
		-- chat(2, "group type",calendarEventInfo.name)
		-- end
		-- if eventName == "Archdemon" then
			
		-- 	chat(2, calendarEventInfo)
		-- 	break
		-- 	--common.LogInfo("common", "-"..calendarEventInfo.."-")
		-- end
		
		
	  	-- if calendarEventInfo.sysName == "MWLadderPrepareTime" then
		-- 	chat(2, calendarEventInfo)
		-- 	local eventInterval = rules.GetEventTimeIntervals( calendarEventInfo.id )
		-- 	chat(2, "event interval:",eventInterval)
		-- 	-- if calendarEventInfo.isActive == true then
		-- 	-- 	previousGuildMessage = guild.GetMessage()
		-- 	-- 	guild.SetMessage("Dear Avarice, Dominions are about to begin. Please prepare with potion")
		-- 	-- end
		-- end
	end
end
function EVENT_GUILD_DECLINE_BUSY(params) --Sent if an invitation to a guild fails (the player is busy).
	local declinerName = userMods.FromWString(params.declinerName)
	chat(2, "failed to invite",declinerName,"to the guild. reason: busy")
end
function EVENT_GUILD_DECLINE_IGNORED(params) --Notification about the impossibility of an invitation to the guild due to ignorance. 
	local declinerName = userMods.FromWString(params.declinerName)
	chat(2, "failed to invite",declinerName,"to the guild. reason: ignored")
end
function EVENT_GUILD_MEMBER_ADDED(params) --Sent if a player has been added to the main player's guild. 
	--chat(2, params.name,"was added to the guild. guildmemberid:",params.id)
	local invitedName = params.name --the name of the guild member
	local invitedId = params.id --guild member identifier (does not match the player identifier)
	local memberInfo = guild.GetMemberInfo(invitedId) --https://alloder.pro/md/LuaApi/FunctionGuildGetMemberInfo.html

	AssignGuildRank(memberInfo, invitedId)
	AssignGuildTabard(invitedId)
	AssignGuildComment(memberInfo, invitedId)
	AddToGuildMessage(invitedName, 1)
end
function EVENT_GUILD_LEVEL_CHANGED() --Puts in guild message when we levelled up as guild, to celebrate.
	local celebrateGuildLevel = userMods.ToWString(locales["GuildLevelled"]) --Wrapping into wide string for it is required as text in guild message.
	AddToGuildMessage(celebrateGuildLevel, 3)
end
function EVENT_GUILD_MEMBER_REMOVED(params) --adds who left the guild into daily message to keep track of it.
	local hasLeftName = params.name --the name of the guild member
	local invitedId = params.id --guild member identifier (does not match the player identifier)
	AddToGuildMessage(hasLeftName, 2)
end

function EVENT_MISSION_RULE_CHANGED(params) --rule stands for calendar events. It checks when a new event starts or ends from the calendar.
	local ruleId = params.ruleId --We get the ruleId (ruleId) from the event trigger and..
	local calendarEventId = rules.GetEventByRuleId( ruleId ) -- ..and convert the ruleId into an actual calendar Id (eventRuleId) to work with.
	if calendarEventId then --avoids errors in mods.txt when game returns nil.
		--chat(2, "RULE ADDED - ruleId:",ruleId,"eventRuleId:",calendarEventId)
		local calendarEventInfo = rules.GetEventInfo( calendarEventId ) --We take all info from each Id, ready for output.
		local calendarEventName = userMods.FromWString(calendarEventInfo.name) --We prepare 1 info output into a ready to use name variable.
		--chat(2, calendarEventInfo) --Shows all info about specific event.
		if calendarEventInfo.sysName == "MWLadderPrepareTime" and calendarEventInfo.isActive then --Checks for when group dominions are about to start and announces that.
			ChangeGuildMessage(guildTextDominion)
			chat(2, calendarEventName,"event started.")
		elseif calendarEventInfo.sysName == "MWLadderPrepareTime" and not calendarEventInfo.isActive then
			ReturnGuildMessage()
			chat(2, calendarEventName,"event ended.")
		end
		if calendarEventInfo.sysName == "MWRaidPrepareTime" and calendarEventInfo.isActive then --Checks for when raid dominions are about to start and announces that.
			ChangeGuildMessage(guildTextDominion)
			chat(2, calendarEventName,"event started.")
		elseif calendarEventInfo.sysName == "MWRaidPrepareTime" and not calendarEventInfo.isActive then
			ReturnGuildMessage()
			chat(2, calendarEventName,"event ended.")
		end
		-- if calendarEventName == "Great Ball: Ice Dance" and calendarEventInfo.isActive then
		-- 	chat(2, calendarEventName,"event started.")
		-- 	ChangeGuildMessage(guildTextDominion)
		-- elseif calendarEventName == "Great Ball: Ice Dance" and not calendarEventInfo.isActive then
		-- 	ReturnGuildMessage()
		-- 	chat(2, calendarEventName,"event ended.")
		-- end
	end
end

function SpamGuildMessage() --Function will run a timer and spam the guild message a few times.
	--chat(2, "seconds:", seconds) --Logs the time passed.
	common.LogInfo("common","-"..seconds.."-")
	seconds = seconds + 1 --Makes time add up.
	if seconds == 1 or seconds == 20*60 or seconds == 40*60 then --Determines after how many seconds the guild messages gets repeated. *60 for minutes.
		if spamMessageCounter > 0 then --Checks when to end repeating the guild message.
			guild.SetMessage(currentGuildMessage.."\nThis message will be repeated "..spamMessageCounter.." more time(s).") --Sets the guild message with information about how many more times it'll be repeated.
		elseif spamMessageCounter == 0 then --Checks if it has to be repeated again, if not, then it will post the message a last time, without informing how many more times it will be repeated.
			guild.SetMessage(currentGuildMessage) --Sets the guild message with the text in currentGuildMessage.
			common.UnRegisterEventHandler(SpamGuildMessage, "EVENT_SECOND_TIMER") --Having finishes the spam, we unregister the time counter in order to free up resources.
			--chat(2, "repeating will now stop.")
			common.LogInfo("common","-".."repeating will now stop".."-")
		end
		spamMessageCounter = spamMessageCounter - 1 --Subtract how many more times it will spam the message.
	end
end

function GetAvatarId()
	while not avatarId do
		getAvatarIdCount = getAvatarIdCount + 1 --Counts how often we had to loop before getting an Id for the avatar.
		common.LogInfo("common", "-".."Got no avatarId, getting a new one | runtime"..getAvatarIdCount.."-")
		avatarId = avatar.GetId()
	end
	avatarName = object.GetName(avatarId)
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
	if avatarId then
		local descText = "Welcome mail sent to "..memberInfo.name.." lv"..tostring(memberInfo.level).." | invited by "..avatarName.." on "..memberInfo.joinTime.d.."/"..memberInfo.joinTime.m.."/"..memberInfo.joinTime.y
		common.LogInfo("common", "-"..descText.."-")
		guild.SetMemberDescription( invitedId, descText) --Add DescText to the guildmember comment.
	-- else
	-- 	GetAvatarId(memberInfo, invitedId)
	end
end
function AssignGuildTabard(invitedId)
	--Automatically gives regular tabard permission to the newly joined guildmember.
	--Somehow this works as an officer, eventhough you need to be treasurer and above rank to hand out tabard.
	if guild.CanDistributeTabard( invitedId ) then --https://alloder.pro/md/LuaApi/FunctionGuildCanDistributeTabard.html
		guild.DistributeTabard( invitedId, ENUM_TabardType_Common )
	else
		chat(3, "There are no regular tabards left to give. Check if inactives can be reclaimed and assign them to the new guild member, please.")
	end
end
function AddToGuildMessage(txt, number)
	--Add the new playername to the guild message, number is 1 for added, 2 for has left. 3 is for levelling up.
	currentGuildMessage = guild.GetMessage() --https://alloder.pro/md/LuaApi/FunctionGuildGetMessage.html
	if number == 1 then
		guild.SetMessage( currentGuildMessage.."\n"..txt.." has joined.") --https://alloder.pro/md/LuaApi/FunctionGuildSetMessage.html
	elseif number == 2 then
		guild.SetMessage( currentGuildMessage.."\n"..txt.." has left.") --https://alloder.pro/md/LuaApi/FunctionGuildSetMessage.html
	elseif number == 3 then
		guild.SetMessage(currentGuildMessage..txt)
	end
end
function ChangeGuildMessage(guildMessage)
	previousGuildMessage = guild.GetMessage() --Saves the current guild message into previousGuildMessage
	currentGuildMessage = guildMessage --puts the desired guild text message into currentGuildMessage
	common.RegisterEventHandler(SpamGuildMessage, "EVENT_SECOND_TIMER") --https://alloder.pro/md/LuaApi/EventSecondTimer.html
end
function ReturnGuildMessage()
	if previousGuildMessage then
		guild.SetMessage(previousGuildMessage)
		currentGuildMessage = guild.GetMessage()
	else
		chat(2, "No daily message stored to put back.")
	end
end
-- I STOPPED HERE LKFNKDJSBGDJSBFJLDBFJLSNGFKJSDNGJLSDGNJKSGN;JSGNDJSGNSDGJSJGSDNJK

function RecruitmentReminderTimer()
	if recruitCooldown > 0 then
	common.RegisterEventHandler(RecruitTimer, "EVENT_SECOND_TIMER") --https://alloder.pro/md/LuaApi/EventSecondTimer.html
	elseif recruitCooldown <= 0 then
		common.UnRegisterEventHandler(RecruitTimer, "EVENT_SECOND_TIMER")
		chat(2, "recruitCooldown ready")
		--Make button appear.
		wtButton:Show(true)
		recruitCooldown = reminderCooldown
		common.RegisterReactionHandler( LeftClick, "LeftClick" )
		--wtButton:SetClassVal( "button_style", "button_red" )		
	end
end
function RecruitTimer()
	chat(2, "recruitCooldown is", recruitCooldown)
	if recruitCooldown <= 0 then RecruitmentReminderTimer() end
	recruitCooldown = recruitCooldown - 1
end
-- function CheckZoneName()
-- 	local zoneName = nil
-- 	local zoneInfo = cartographer.GetCurrentZoneInfo()
-- 	if zoneInfo then
-- 		zoneName = userMods.FromWString(zoneInfo.zoneName)
-- 		return zoneName
-- 	end
-- end

function LeftClick( params )
	if DnD:IsDragging() then return	end
	common.UnRegisterReactionHandler( LeftClick, "LeftClick" )
	wtButton:Show(false)
	--mission.SetChatInputData( wtEditLine )
	SendText(guildRecruitmentMessage)
	--chat(2, "I clicked")	
	RecruitmentReminderTimer()
end
function AOLocker(params)
	if params.StatusDnD then
		DnD:Enable( wtButton, false )
	elseif not params.StatusDnD then
		DnD:Enable( wtButton, true )
	end
end
function SendText(text)
	
	mission.SetChatInputType( "zone" )
	mission.SetChatInputText( userMods.ToWString(text), 0 )
end
-- function Currency()
-- 	local ids = avatar.GetCategoryCurrencies( categoryId)
-- 	if ids and ids[0] then
-- 	  local info = avatar.GetCurrencyInfo( ids[0])
-- 	  if info then
-- 		local currentValue = info.value
-- 	  end
-- 	end
-- end
function Currencies()
	-- local myrrhId = avatar.GetCurrencyId( "myrrh" )
	-- --common.LogInfo("common","-"..tostring(myrrhId).."-")
	-- if myrrhId then	  
	-- local description = avatar.GetCurrencyDescription( myrrhId )
	-- common.LogInfo("common","-"..tostring(description).."-")
	-- --   if info then
	-- -- 	local currentValue = info.value
	-- -- 	common.LogInfo("common","-"..tostring(currentValue).."-")
	-- --   end
	-- end

	local ids = avatar.GetCurrencies()
	
	if ids and ids[0] then
		for i = 0, GetTableSize(ids) -1 do
			local info = ids[i]:GetInfo()
			--common.LogInfo("common","-"..tostring(info.name).."-")
			--chat(2, i, userMods.FromWString( info.name))
			if i == 110 then
			--	local description = avatar.GetCurrencyDescription( info.category )
				--chat(2, info)
				local myrrhId = avatar.GetCurrencyId( userMods.FromWString(info.name) )
				chat(2, myrrhId)
				if myrrhId then
				  local info = myrrhId:GetInfo()
				  if info then
					local currentValue = info.value
				  end
				end
			end
			
		end
	--   if info then
	-- 	local currentValue = info.value
	--   end
	end
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