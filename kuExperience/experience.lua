-- Check if max level
if UnitLevel('player') == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()] then
	DisableAddOn('kuExperience')
	print('|cffFF1493ku|r|cffffffffExperience|r: You are max level. Disabling AddOn on next reload.')
end

-- Config-ish
local font, fontSize, fontOutline = "Fonts\\FRIZQT__.ttf", 12, 'OUTLINE'
local mouseOver = false -- true/false
local classColor = 'full' -- full/letter/none

local textPos = { 'TOP', Minimap, 'TOP', 0, -1 }

-- Variables
local f = CreateFrame('Frame', 'kuExperienceFrame')
local kuExperienceText = f:CreateFontString('kuExperienceText', 'OVERLAY')
local experienceLeft
local _, class = UnitClass('player')
local playerColor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]

-- We need a display
f:SetFrameStrata('HIGH')
f:SetWidth(30)
f:SetHeight(fontSize+4)
f:ClearAllPoints()
f:SetPoint(unpack(textPos))
f:SetBackdrop({
	bgFile = 'Interface\\ChatFrame\\ChatFrameBackground',
	insets = { left = -1, right = -1, top = -1, bottom = -1 }
})
f:SetBackdropColor(0, 0, 0, 0)

kuExperienceText:SetPoint('CENTER', f, 'CENTER', 0, 0)
if classColor == 'none' then
	kuExperienceText:SetTextColor(1, 1, 1)
else
	kuExperienceText:SetTextColor(playerColor.r, playerColor.g, playerColor.b)
end
kuExperienceText:SetFont(font, fontSize, fontOutline)

-- Squash numbers to more reasonable sizes
local shortExp = function(number)
	if classColor == 'letter' then
		if number > 1e6 then
			return string.format('|cffffffff%.2f|rm', number / 1e6)
		elseif number > 1e5 then
			return string.format('|cffffffff%d|rk', number / 1e3)
		elseif number > 1e3 then
			return string.format('|cffffffff%.1f|rk', number / 1e3)
		else
			return string.format('|cffffffff%d|r', number)
		end
	else
		if number > 1e6 then
			return string.format('%.2fm', number / 1e6)
		elseif number > 1e5 then
			return string.format('%dk', number / 1e3)
		elseif number > 1e3 then
			return string.format('%.1fk', number / 1e3)
		else
			return string.format('%d', number)
		end
	end
end

-- Round remaining bars to 1 decimal
local roundBars = function(input)
	return string.format('%.1f', input)
end

-- Calculate remaining experience
local function getExperienceLeft()
	return UnitXPMax('player') - UnitXP('player')
end

-- Update text display
local function updateExp()
	kuExperienceText:SetText(string.format(shortExp(experienceLeft)))
	UIErrorsFrame:AddMessage('You have ' .. string.format(shortExp(experienceLeft)) .. ' experience left to level up.')
end

-- Mouseover stuff
if mouseOver == true then -- Hide it on login
	kuExperienceText:SetAlpha(0)
end
f:EnableMouse(true)
f:SetScript('OnEnter', function()
	GameTooltip:SetOwner(f, 'ANCHOR_BOTTOM')
	local barsLeft = experienceLeft / (UnitXPMax('player') / 20)
	GameTooltip:AddLine(roundBars(barsLeft)..' bars to level up.', 1, 1, 1)
	GameTooltip:Show()
	if mouseOver == true then
		kuExperienceText:SetAlpha(1)
	end
end)
f:SetScript('OnLeave', function()
	GameTooltip:Hide()
	if mouseOver == true then
		kuExperienceText:SetAlpha(0)
	end
end)

experienceLeft = getExperienceLeft()

-- Run!
f:SetScript('OnEvent', function(frame, event, ...)
	if event == 'PLAYER_XP_UPDATE' then	
		experienceLeft = getExperienceLeft()
		updateExp()
	elseif event == 'PLAYER_LEVEL_UP' then
		experienceLeft = getExperienceLeft()
	elseif event == 'PLAYER_ENTERING_WORLD' then
		kuExperienceText:SetText(string.format(shortExp(UnitXPMax('player') - UnitXP('player'))))
	end
end)
f:RegisterEvent('PLAYER_XP_UPDATE')
f:RegisterEvent('PLAYER_LEVEL_UP')
f:RegisterEvent('PLAYER_ENTERING_WORLD')