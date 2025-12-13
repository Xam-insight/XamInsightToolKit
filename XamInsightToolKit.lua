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

-- Returns the full player name in the form "Name-Realm".
-- Uses the raw (unmodified) name to avoid color codes or realm shorthands.
function XITK.playerCharacter()
	-- UnitNameUnmodified("player") returns: name, realm
	local playerName, playerRealm = UnitNameUnmodified("player")

	-- SAFETY: playerName should always exist but we do not silently fail.
	-- If it is ever nil (very rare login edge case), we keep the nil to surface the abnormal state.
	return XITK.addRealm(playerName, playerRealm)
end


-- Returns true if the given name refers to the local player.
-- Ensures both sides are normalized to the "Name-Realm" format.
function XITK.isPlayerCharacter(aName)
	-- SAFETY: Do not suppress nil. If aName is nil, this returns false (correct behavior).
	return XITK.playerCharacter() == XITK.addRealm(aName)
end


-- Ensures a character name is in the form "Name-Realm".
-- If the realm is not provided, fallback to the player's normalized realm.
function XITK.addRealm(aName, aRealm)
	-- Keep nil explicit: if aName is nil, this should not be silently handled.
	if not aName then
		return nil
	end

	-- Only append a realm if the name does not already contain one.
	if not string.match(aName, "-") then
		local realm = aRealm

		-- If no realm provided, use the player's realm
		if not realm or realm == "" then
			realm = GetNormalizedRealmName() or UNKNOWN
		end

		aName = aName .. "-" .. realm
	end

	return aName
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