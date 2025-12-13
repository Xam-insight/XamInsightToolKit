local MAJOR, MINOR = "XamInsightToolKit", 1
local XITK = LibStub:NewLibrary(MAJOR, MINOR)
if not XITK then
    -- A newer version is already loaded
    return
end

function XITK.GetMouseFocus()
	local frame = nil
	if GetMouseFoci then
		local region = GetMouseFoci()
		frame = region[1]
	else
		frame = GetMouseFocus()
	end
	return frame
end

-- Tip by Gello - Hyjal
-- takes an npcID and returns the name of the npc
function XITK.GetNameFromNpcID(npcID)
	local name = ""
	
	EZBlizzardUiPopupsTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	EZBlizzardUiPopupsTooltip:SetHyperlink(format("unit:Creature-0-0-0-0-%d-0000000000", npcID))
	
	local line = _G[("EZBlizzardUiPopupsTooltipTextLeft%d"):format(1)]
	if line and line:GetText() then
		name = line:GetText()
	end
	
	return name
end

function XITK.addRealm(aName, aRealm)
	if aName and not string.match(aName, "-") then
		if aRealm and aRealm ~= "" then
			aName = aName.."-"..aRealm
		else
			local realm = GetNormalizedRealmName() or UNKNOWN
			aName = aName.."-"..realm
		end
	end
	return aName
end

function XITK.delRealm(aName)
	if aName and string.match(aName, "-") then
		aName = strsplit("-", aName)
	end
	return aName
end

function XITK.fullName(unit)
	local fullName = nil
	if unit then
		local playerName, playerRealm = UnitNameUnmodified(unit)
		if not UnitIsPlayer(unit) then
			return playerName
		end
		if playerName and playerName ~= "" and playerName ~= UNKNOWN then
			if not playerRealm or playerRealm == "" then
				playerRealm = GetNormalizedRealmName()
			end
			if playerRealm and playerRealm ~= "" then
				fullName = playerName.."-"..playerRealm
			end
		end
	end
	return fullName
end

function XITK.isPlayerCharacter(aName)
	return MountMania_playerCharacter() == XITK.addRealm(aName)
end

local playerCharacter
function XITK.playerCharacter()
	if not playerCharacter then
		playerCharacter = XITK.fullName("player")
	end
	return playerCharacter
end

-- Converts a date into a timestamp (number of seconds since epoch)
function XITK.dateToTimestamp(day, month, year)
    return time({year = year, month = month, day = day, hour = 0, min = 0, sec = 0})
end

function XITK.getCurrentDate()
	local curDate = C_DateAndTime.GetCurrentCalendarTime()
	return curDate.monthDay, curDate.month, curDate.year
end

function XITK.getTimeUTCinMS()
	return tostring(time(date("!*t")))
end

function XITK.countTableElements(table)
	local count = 0
	if table then
		for _ in pairs(table) do
			count = count + 1
		end
	end
	return count
end

-- Sound handling
local willPlay, soundHandle

function XITK.PlaySound(soundID)
	if soundID then
		PlaySound(soundID, "master")
	end
end

function XITK.PlaySoundFileID(soundFileID, channel, playSound)
	if playSound then
		if soundHandle then
			StopSound(soundHandle)
		end
		willPlay, soundHandle = PlaySoundFile(soundFileID, channel)
	end
	return soundHandle
end

function XITK.PlayRandomSound(soundFileIDBank, channel, playSound)
	if playSound and soundFileIDBank then
		local nbSounds = #soundFileIDBank
		if nbSounds > 0 then
			local sound = math.random(1, nbSounds)
			return XITK.PlaySoundFileID(soundFileIDBank[sound], channel, playSound)
		end
	end
	return nil
end
