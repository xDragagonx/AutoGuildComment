--What addon does:
--Adds guild comment to invited player, adds tabard, adds rank, adds name to daily message for mail reminder.
--informs when you failed to ginv ppl by ignorance or afk.
--adds guildMessage when guild levelled up to celebrate with guild.
--adds guildMessage announcement when dominions are about to start, and repeats it several times over an hour
--Remindes the user to world/zone shout recruitment for the guild at a click of a button.
-------------------------------------------
-- WIDGETS
-- RECRUITMENT BUTTON
local wtButton = mainForm:GetChildChecked("Button",false)
wtButton:SetVal("button_label", userMods.ToWString(locales["RecruitmentButtonText"])) --Text can be found in locales.lua
wtButton:Show(false)

-- GuildBot button to summon and remove the UI.
local wtGuildBotCallButton = mainForm:GetChildChecked("GuildBotCallButton",false)
wtGuildBotCallButton:SetVal("button_label", userMods.ToWString("GB"))
wtGuildBotCallButton:Show(true)

-- The GuildBot UI.
local wtMainPanel = mainForm:GetChildChecked("MainPanel", false)
wtMainPanel:Show(true) --CHANGE THIS TO FALSE TO HIDE ON STARTUP.
local TextToRemove = wtMainPanel:GetChildChecked("TextToRemove", false) --Text indicator asking what to remove; tabards or members.
--Accessing the text for the header of the addon.
local wtWindowHeader = wtMainPanel:GetChildChecked("WindowHeader", false)
local wtHeaderText = wtWindowHeader:GetChildChecked("HeaderText", false)
wtHeaderText:SetVal("window_header", userMods.ToWString("GuildBot"))

--local WidgetPanel = wtMainPanel:GetChildChecked("WidgetPanel", false)
--WidgetPanel:Show(true)
--local CornerCross = WidgetPanel:GetChildChecked("CornerCross", false)

--guildBot LEFT side.
--ContentFrame is where the buttons and TextView are inside of.
local wtContentFrameToRemove = wtMainPanel:GetChildChecked("ContentFrameToRemove", false)
--wtContentFrameToRemove:Show(false)
--ItemToRemove is what shows when the using presses the buttons.
local wtItemToRemove = wtContentFrameToRemove:GetChildChecked("ItemToRemove", false)
--Buttons
local wtButtonLeftToRemove = wtContentFrameToRemove:GetChildChecked("ButtonLeftToRemove", false)
--wtButtonLeftToRemove:Show(false)
local wtButtonRightToRemove = wtContentFrameToRemove:GetChildChecked("ButtonRightToRemove", false) -- Won't remove
--wtButtonRightToRemove:Show(false)

--guildBot RIGHT side.
local wtContentFrameToRemoveByTime = wtMainPanel:GetChildChecked("ContentFrameToRemoveByTime", false)
local wtInputTextToRemoveByTime = wtContentFrameToRemoveByTime:GetChildChecked("InputTextToRemoveByTime", false)
--Buttons
local wtButtonLeftToRemoveByTime = wtContentFrameToRemoveByTime:GetChildChecked("ButtonLeftToRemoveByTime", false)
local wtButtonRightToRemoveByTime = wtContentFrameToRemoveByTime:GetChildChecked("ButtonRightToRemoveByTime", false)
--wtButtonRightToRemoveByTime:Show(false)

--GuildBot Removal BUTTON
local wtButtonRemoveMembersTabards = wtMainPanel:GetChildChecked("ButtonRemoveMembersTabards",false)
--wtButtonRemoveMembersTabards:SetVal("button_label", userMods.ToWString(locales["RecruitmentButtonText"])) --Used for translating button text in locales.lua.
--wtButtonRemoveMembersTabards:Show(false)




-------------------------------------------
local avatarId = nil
local avatarName = nil
local getAvatarIdCount = 0 --Used for counting how often it reloaded the function to assign an Id to the avatar.
local guildTextDominion = userMods.ToWString(locales["DominionPrepText"])
local previousGuildMessage = nil --Placeholder for the previous guild's daily message.
local currentGuildMessage = nil --Placeholder for the current guild's daily message.
local seconds = 0
local spamMessageCounter = 2
local recruitCooldown = 10 --(1.5h 5400)
local GuildBotOpen = false --Registers to show or hide the GUI GuildBot.
local removalParameters = {} --Table of options for removal of tabards or members.
removalParameters[0] = "Members"
removalParameters[1] = "Tabards"
local removalParametersIndex = 0 --Index tracker for changing removalParameters.
--local currentChatType = nil --No longer used as we had to wait for user to send message before being able to put it back to the original chatCmdSys (chattype)
Global("guildRecruitmentMessage", nil)
Global("reminderCooldown", 15) --15 is never used, was necesarry to avoid error. Somehow nil didn't work.

function Main()
	GetAvatarId()
	--GetEventsId()
	--ChangeGUI() --test function for widgets.
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
	RecruitmentReminderTimer()
	common.RegisterReactionHandler( GuildBotCallButtonClick, "GuildBotCallButtonClick" )
	--Allows the widgets to be DnD
	DnD.Init(wtButton, nil, true) 
	DnD.Init(wtGuildBotCallButton, nil, true)
	DnD.Init(wtMainPanel, nil, true)
end
function GuildBotCallButtonClick( params ) --Opens and closes the GuildBot UI.
	if DnD:IsDragging() then return	end
	if GuildBotOpen == true then
		wtMainPanel:Show(false)
		GuildBotOpen = false
		--Left GuildBot buttons
		common.UnRegisterReactionHandler( ButtonLeftToRemoveClick, "ButtonLeftToRemoveClick" )
		common.UnRegisterReactionHandler( ButtonRightToRemoveClick, "ButtonRightToRemoveClick" )
		--Right GuildBot buttons
		common.UnRegisterReactionHandler( ButtonLeftToRemoveByTimeClick, "ButtonLeftToRemoveByTimeClick" )
		common.UnRegisterReactionHandler( ButtonRightToRemoveByTimeClick, "ButtonRightToRemoveByTimeClick" )
		--RemovalButton
		common.UnRegisterReactionHandler( ButtonRemoveMembersTabardsClick, "ButtonRemoveMembersTabardsClick" )
	elseif GuildBotOpen == false then
		wtMainPanel:Show(true)
		GuildBotOpen = true
		--Left GuildBot buttons
		common.RegisterReactionHandler( ButtonLeftToRemoveClick, "ButtonLeftToRemoveClick" )
		common.RegisterReactionHandler( ButtonRightToRemoveClick, "ButtonRightToRemoveClick" )
		--Right GuildBot buttons
		common.RegisterReactionHandler( ButtonLeftToRemoveByTimeClick, "ButtonLeftToRemoveByTimeClick" )
		common.RegisterReactionHandler( ButtonRightToRemoveByTimeClick, "ButtonRightToRemoveByTimeClick" )
		wtItemToRemove:SetVal("value", tostring(removalParameters[removalParametersIndex]))
		--RemovalButton
		common.RegisterReactionHandler( ButtonRemoveMembersTabardsClick, "ButtonRemoveMembersTabardsClick" )
	end
end
function ButtonRemoveMembersTabardsClick(params)
	local removalSelected = removalParameters[removalParametersIndex]
	local inactiveDaysSelected = tonumber(userMods.FromWString(wtInputTextToRemoveByTime:GetText())) --:GetText() returns WString so we unwrap it.
	--chat(2, removalSelected, inactiveDaysSelected)
	GuildInfo(inactiveDaysSelected)
end
function GuildInfo(inactiveDaysSelected)
	local members = guild.GetMembers()
	local removalCounter = 0 --Keeps track of how many players will get removed or lose tabard.
	local removalList = {} --Create a table to display at the end.
	for i = 0, GetTableSize(members) do --Loop starts
		local memberInfo = guild.GetMemberInfo( members[ i ] )
		if memberInfo then
			local lastOnlineInMs = memberInfo.lastOnlineTime.overallMs
			local currrentInMs = mission.GetGlobalDateTime().overallMs
			if CalcDateDiffInDays(currrentInMs, lastOnlineInMs) >= inactiveDaysSelected then
				removalCounter = removalCounter + 1
				table.insert(removalList, {key = userMods.FromWString(memberInfo.name), value = CalcDateDiffInDays(currrentInMs, lastOnlineInMs).." day(s)."})
			end
		end
	end --Loop ends
	chat(2, removalCounter,"player(s) will get removed that are offline for over",inactiveDaysSelected,"days." )
	chat(2, "Players to be removed are:")
	for _, pair in ipairs(removalList) do
		chat(2, pair.key, pair.value)
	end
end
function CalcDateDiffInDays(currrentInMs, lastOnlineInMs)
	local diffInDays = math.floor((currrentInMs - lastOnlineInMs) / 86400000) --Ms in a day (24h)
	return diffInDays
end
function ButtonLeftToRemoveByTimeClick(params)
	--local playerInput = wtInputTextToRemoveByTime:GetString() --Works for strings, not numbers --https://alloder.pro/md/LuaApi/FunctionEditLineGetString.html
	local playerInput = wtInputTextToRemoveByTime:GetText() --https://alloder.pro/md/LuaApi/FunctionEditLineGetString.html
	if playerInput:IsEmpty() then
		wtInputTextToRemoveByTime:SetText(userMods.ToWString("0"))
	else
		playerInput = userMods.FromWString(playerInput)
		playerInput = playerInput - 1
		if playerInput < 0 then
			playerInput = 0
		end
		playerInput = userMods.ToWString(tostring(playerInput))  --To put this back into EditLine widget, needs to be WString. We unwrapped input in order to do +1. Cannot do math on a WString otherwise.
		wtInputTextToRemoveByTime:SetText(playerInput)
	end
	chat(2, "left click", playerInput)
	--wtInputTextToRemoveByTime:BackspaceCharAtCursorPos() --Backspace function https://alloder.pro/md/LuaApi/FunctionEditLineBackspaceCharAtCursorPos.html
	--wtInputTextToRemoveByTime:DeleteCharAtCursorPos() --Delete function https://alloder.pro/md/LuaApi/FunctionEditLineDeleteCharAtCursorPos.html
end
function ButtonRightToRemoveByTimeClick (params)
	--local playerInput = wtInputTextToRemoveByTime:GetString() --Works for strings, not numbers --https://alloder.pro/md/LuaApi/FunctionEditLineGetString.html
	local playerInput = wtInputTextToRemoveByTime:GetText() --https://alloder.pro/md/LuaApi/FunctionEditLineGetString.html
	if playerInput:IsEmpty() then
		wtInputTextToRemoveByTime:SetText(userMods.ToWString("0"))
	else
		playerInput = userMods.FromWString(playerInput)
		playerInput = playerInput + 1
		if playerInput > 999 then
			playerInput = 999
		end
		playerInput = userMods.ToWString(tostring(playerInput))  --To put this back into EditLine widget, needs to be WString. We unwrapped input in order to do +1. Cannot do math on a WString otherwise.
		wtInputTextToRemoveByTime:SetText(playerInput)
	end
	chat(2, "left click", playerInput)
end
function ButtonLeftToRemoveClick(params) --Left button on GuildBot UI to rotate through options.
	removalParametersIndex = removalParametersIndex - 1
	if removalParametersIndex < 0 then
		removalParametersIndex = GetMaxKey(removalParameters)
	end
	wtItemToRemove:SetVal("value", tostring(removalParameters[removalParametersIndex]))
	chat(2,removalParameters[removalParametersIndex])
end
function ButtonRightToRemoveClick(params) --Right button on GuildBot UI to rotate through options.
	removalParametersIndex = removalParametersIndex + 1
	if removalParametersIndex > GetMaxKey(removalParameters) then
		removalParametersIndex = 0
	end
	wtItemToRemove:SetVal("value", tostring(removalParameters[removalParametersIndex]))
	chat(2,removalParameters[removalParametersIndex])
end
function GetMaxKey(table) --Function to figure out the size of table hosting options to rotate through.
    local maxKey = -1
    for k, v in pairs(table) do
        if k > maxKey then
            maxKey = k
        end
    end
    return maxKey
end
function ChangeGUI() --test function for widgets.
	chat(2, "changing GUI")
	--widgetmagic 
	chat(2, "I haven't crashed yet")
end
function GetEventsId() --testfunction to get calendar event Id's.
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
	--common.LogInfo("common","-"..seconds.."-")
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
function GetAvatarId() --gets our Id just so we can have our name in the guild comment as inviter.
	while not avatarId do
		getAvatarIdCount = getAvatarIdCount + 1 --Counts how often we had to loop before getting an Id for the avatar.
		common.LogInfo("common", "-".."Got no avatarId, getting a new one | runtime"..getAvatarIdCount.."-")
		avatarId = avatar.GetId()
	end
	avatarName = object.GetName(avatarId)
end
function AssignGuildRank(memberInfo, invitedId) --Assigns guild rank based on the invited player's level.
	--Automatically changes guild rank depending whether max level or not.
	if memberInfo.level < 105 then
		guild.ChangeRank( invitedId, 6 ) --https://alloder.pro/md/LuaApi/FunctionGuildChangeRank.html
	else --9 outlawed, 8 punished, 7 alternate, 6 trial, 5, member, 4 veteran, 3 junior officer, 2 senior officer, 1 unseen.
		guild.ChangeRank( invitedId, 5) --https://alloder.pro/md/LuaApi/FunctionGuildChangeRank.html
	end
end
function AssignGuildComment(memberInfo, invitedId) --Automatically adds comment to the newly joined guildmember.
	local memberDescription = guild.GetMemberDescription( invitedId )
	if not memberDescription:IsEmpty() then --Checks if the guild description is not empty
	else --if it is empty, adds comment.
		local descText = "Welcome mail sent to "..memberInfo.name.." lv"..tostring(memberInfo.level).." | invited by "..avatarName.." on "..memberInfo.joinTime.d.."/"..memberInfo.joinTime.m.."/"..memberInfo.joinTime.y
		common.LogInfo("common", "-"..descText.."-")
		guild.SetMemberDescription( invitedId, descText) --Add DescText to the guildmember comment.
	end
end
function AssignGuildTabard(invitedId) --Gives guild tabard if available.
	--Automatically gives regular tabard permission to the newly joined guildmember.
	--Somehow this works as an officer, eventhough you need to be treasurer and above rank to hand out tabard.
	if guild.CanDistributeTabard( invitedId ) then --https://alloder.pro/md/LuaApi/FunctionGuildCanDistributeTabard.html
		guild.DistributeTabard( invitedId, ENUM_TabardType_Common )
	else
		chat(4, locales["NoTabardsLeft"])
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
		chat(2, locales["ReturnGuildMessage"])
	end
end
function RecruitmentReminderTimer() --Starting function to start the cooldown timer and activating button for recruitment.
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
function RecruitTimer() --Timer to measure the cooldown for the recruitmentbutton.
	--chat(2, "recruitCooldown is", recruitCooldown)
	if recruitCooldown <= 0 then RecruitmentReminderTimer() end
	recruitCooldown = recruitCooldown - 1
end
function LeftClick( params ) --Function for when you leftclick the recruitmentbutton.
	if DnD:IsDragging() then return	end
	common.UnRegisterReactionHandler( LeftClick, "LeftClick" )
	wtButton:Show(false)
	--mission.SetChatInputData( wtEditLine )
	SendText(guildRecruitmentMessage)
	--mission.SetChatInputType( currentChatType ) --Can't use it because you need to wait for user to send message.	
	RecruitmentReminderTimer()
end
function AOLocker(params) --Function required for Drag and Dropping widgets.
	if params.StatusDnD then
		DnD:Enable( wtButton, false )
	elseif not params.StatusDnD then
		DnD:Enable( wtButton, true )
	end

	if params.StatusDnD then
		DnD:Enable( wtGuildBotCallButton, false )
	elseif not params.StatusDnD then
		DnD:Enable( wtGuildBotCallButton, true )
	end
end
function SendText(text) --Sends the preset text to recruit world or zone wide.
	--currentChatType = mission.GetChatInput().sysCmdType --Can't use it because you need to wait for user to send message.
	if HowManyAstralMegaphonesLeft() > 0 then
		mission.SetChatInputType( "world" )
	else
		chat(4, locales["NoMegaphonesLeft"])
		mission.SetChatInputType( "zone" )
	end
	mission.SetChatInputText( userMods.ToWString(text), 0 )
end
function HowManyAstralMegaphonesLeft() --Checks if we got enough Megaphones left for recruiting via the button.
	local currencyName = locales["Astral Megaphone"]
	local currencyId = GetCurrencyIdByName(currencyName)
	local currencyValue = GetCurrencyValue(currencyId) or 0
	--chat(2, "I have",currencyValue,"megaphones.")
	return currencyValue
end
function GetCurrencyIdByName(currencyName) --Used for the HowManyAstralMegaphonesLeft function
	local avatarCurrencies = avatar.GetCurrencies() or {}
	for _, currencyId in pairs(avatarCurrencies) do
		local currencyInfo = currencyId:GetInfo()
		if currencyInfo and currencyInfo.name and userMods.FromWString(currencyInfo.name) == currencyName then return currencyId end 
	end
end
function GetCurrencyValue(currencyId) --Used for the HowManyAstralMegaphonesLeft function
	local currencyValue = avatar.GetCurrencyValue(currencyId)
	if currencyValue then return currencyValue.value end
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