local MAJOR, MINOR = "XamInsightToolKit", 1
local XITK = LibStub:NewLibrary(MAJOR, MINOR)
if not XITK then
    -- A newer version is already loaded
    return
end

---------------------------------------------------------------------------------------------------
-- WoW Client version workarounds                                                                --
---------------------------------------------------------------------------------------------------

-- Determine WoW TOC Version
XITK.WoWClassicEra, XITK.WoWClassicTBC, XITK.WoWWOTLKC, XITK.WoWRetail = false
local wowversion = select(4, GetBuildInfo())
if wowversion < 20000 then
	XITK.WoWClassicEra = true
elseif wowversion < 30000 then 
	XITK.WoWClassicTBC = true
elseif wowversion < 40000 then 
	XITK.WoWWOTLKC = true
elseif wowversion < 50000 then 
	XITK.WoWCATA = true
elseif wowversion < 60000 then 
	XITK.WoWMISTS = true
elseif wowversion > 90000 then
	XITK.WoWRetail = true

else
	-- n/a
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

---------------------------------------------------------------------------------------------------
-- Names functions                                                                               --
---------------------------------------------------------------------------------------------------

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
	return XITK.playerCharacter() == XITK.addRealm(aName)
end

local playerCharacter
function XITK.playerCharacter()
	if not playerCharacter then
		playerCharacter = XITK.fullName("player")
	end
	return playerCharacter
end

---------------------------------------------------------------------------------------------------
-- String, date and table functions                                                              --
---------------------------------------------------------------------------------------------------

local function XITK.upperCaseBusiness(aText)
	return string.utf8upper(aText)
end

function XITK.titleFormat(aText)
	local retOK, ret
	local newText = ""
	if aText then
		newText = strtrim(aText):gsub("%s+", " ")
		retOK, ret = pcall(XITK.upperCaseBusiness, string.utf8sub(newText, 1 , 1))
		if retOK then
			newText = ret..string.utf8sub(newText, 2)
		end
	end
	return newText
end


function XITK.upperCase(aText)
	local retOK, ret
	local newText = ""
	if aText then
		retOK, ret = pcall(XITK.upperCaseBusiness, aText)
		if retOK then
			newText = ret
		else
			newText = aText
		end
	end
	return newText
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

---------------------------------------------------------------------------------------------------
-- Sound handling functions                                                                      --
---------------------------------------------------------------------------------------------------

local willPlay, soundHandle

function XITK.PlaySound(soundID, channel)
	if soundID then
		PlaySound(soundID, channel or "master")
	end
end

function XITK.PlaySoundFile(addon, soundFile, channel)
	if addon and soundFile then
		if soundHandle then
			StopSound(soundHandle)
		end
		willPlay, soundHandle = PlaySoundFile("Interface\\AddOns\\"..addon.."\\sound\\"..soundFile.."_"..GetLocale()..".ogg", channel, _, true)
		if not willPlay then
			willPlay, soundHandle = PlaySoundFile("Interface\\AddOns\\"..addon.."\\sound\\"..soundFile..".ogg", channel, _, true)
		end
	end
	return soundHandle
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
