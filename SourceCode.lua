--Use common.LogInfo("common", "-"..name.."-") --Log to mods.txt
--Use tostring() to concatenate non-string values in chat()
--itemLib.GetName(itemId) gets the name of the itemId. Wrap userMods.FromWString() around it for proper output.

function Main()
	
	--common.RegisterEventHandler(EVENT_LOOT_TO_DISTRIBUTE, "EVENT_LOOT_TO_DISTRIBUTE")

end
-- function EVENT_LOOT_DISTRIBUTION_STARTED(params)
-- 	chat(2, params.itemObject)
-- end


if (avatar.IsExist()) then
	chat(2,"Loaded.")
	Main()
else
	chat(2,"Loaded.")
	common.RegisterEventHandler(Main, "EVENT_AVATAR_CREATED")
end