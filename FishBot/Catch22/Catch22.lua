-- Author: WiNiFiX, use at own risk as with all botting tools

local parent = CreateFrame("frame", "Recount", UIParent)

local fishingOn = 0;

local button = CreateFrame("Button", nil, UIParent)
button:SetPoint("TOP", UIParent, "TOP", 400, 0)
button:SetWidth(85)
button:SetHeight(20)
button:SetText("Fish: On")
button:SetNormalFontObject("GameFontNormal")
button:SetFrameStrata("TOOLTIP");

local ntex = button:CreateTexture()
ntex:SetTexture("Interface/Buttons/UI-Button-Outline")
ntex:SetTexCoord(0, 0, 0, 0)
ntex:SetAllPoints()
button:SetNormalTexture(ntex)

local htex = button:CreateTexture()
htex:SetTexture("Interface/Buttons/UI-Button-Borders2")
htex:SetTexCoord(0, 0, 0, 0)
htex:SetAllPoints()
button:SetHighlightTexture(htex)

local ptex = button:CreateTexture()
ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
ptex:SetTexCoord(0, 0, 0, 0)
ptex:SetAllPoints()
button:SetPushedTexture(ptex)

button:RegisterForClicks("AnyDown")

-- These offsets MAY need updates
local OBJECT_BOBBING_OFFSET = 0x0
local OBJECT_CREATOR_OFFSET = 0x0

local FishingSpellID = 131474
local BobberID = 35591

local function GetObjectGUID(object)
	if ObjectExists(object) then
		return tonumber(ObjectDescriptor(object, 0, "ulong"))
	end
end

local function IsObjectCreatedBy(owner, object)
	if not owner then return false end;
	if ObjectExists(owner) and ObjectExists(object) then
		return tonumber(ObjectDescriptor(object, OBJECT_CREATOR_OFFSET, "ulong")) == GetObjectGUID(owner)
	end
end

function getBobber()
	local objectCount = GetObjectCount() or 0
	for i = 1, objectCount do
		local currentObj = GetObjectWithIndex(i)
		if ObjectID(currentObj) == BobberID and IsObjectCreatedBy("player", currentObj) then
			return currentObj;
		end
	end
	return nil
end

local FishCD = 0
local startX = 0
local startY = 0
local startZ = 0
local BaitCD = 0
local equipPoleCD = 0;
local originalWeaponID = 0
local fishingPoleID = 0


function fish()
	if (OBJECT_BOBBING_OFFSET == 0x0) then
		OBJECT_BOBBING_OFFSET = GetOffset("CGGameObject_C__Animation")
		print (string.format('Bobbing Offset = 0x%X', OBJECT_BOBBING_OFFSET))
	end
	if (OBJECT_CREATOR_OFFSET == 0x0) then	
		OBJECT_CREATOR_OFFSET = GetDescriptor("CGGameObjectData", "CreatedBy")
		print (string.format('Creator Offset = 0x%X ', OBJECT_CREATOR_OFFSET))
	end
	
	-- if GetTime() > equipPoleCD then return end;

	local weaponItemID = GetInventoryItemID('player', 16)
	
	-- Use the best fishing bait - if we have a fishing pole equipped
	if originalWeaponID ~= weaponItemID then
		if select(1, GetWeaponEnchantInfo()) == false and GetTime() > BaitCD then
			BaitCD = GetTime() + 5 -- we prevent it from applying a bait for 5 seconds, to deal with game latency
			useBestBait();
		end
	end
	
	-- check for movement since fishing started, if x, y, z is different then stop fishing
	local currentX, currentY, currentZ = ObjectPosition("Player")
	if (currentX ~= startX) or (currentY ~= startY) or (currentZ ~= startZ) then
		equipOriginalWeapon();
		fishingOn = 0
		button:SetText("Fish: On")
	end
	
	local BobberObject = getBobber()
	
	if BobberObject and ObjectExists(BobberObject) then
		local bobbing = ObjectField(BobberObject, OBJECT_BOBBING_OFFSET, "bool")
		if bobbing == true or bobbing == 1 then
			InteractUnit(BobberObject)
		end
	else 
		if FishCD < GetTime() then
			FishCD = GetTime() + 2
			CastSpellByID(FishingSpellID)
		end		
	end	
end

local tick = 0;

function update(self, elapsed)
	tick = tick + elapsed	
	if tick >= 1 and fishingOn == 1 then
		fish()
		tick = 0
	end
end

local polesTable = {
	{ ID = 118381, Bonus = 100, Name = 'Ephemeral Fishing Pole' },
	{ ID = 19970,  Bonus = 40,  Name = 'Arcanite Fishing Pole' },
	{ ID = 84661,  Bonus = 30,  Name = 'Dragon Fishing Pole' },
	{ ID = 116825, Bonus = 30,  Name = 'Savage Fishing Pole' },
	{ ID = 116826, Bonus = 30,  Name = 'Draenic Fishing Pole' },
	{ ID = 45991,  Bonus = 30,  Name = 'Bone Fishing Pole' },
	{ ID = 45992,  Bonus = 30,  Name = 'Jeweled Fishing Pole' },
	{ ID = 44050,  Bonus = 30,  Name = 'Mastercraft Kalu\'ak Fishing Pole' },
	{ ID = 45858,  Bonus = 25,  Name = 'Nat\'s Lucky Fishing Pole' },
	{ ID = 6367,   Bonus = 20,  Name = 'Big Iron Fishing Pole' },
	{ ID = 19022,  Bonus = 20,  Name = 'Nat Pagle\'s Extreme Angler FC-5000' },
	{ ID = 25978,  Bonus = 20,  Name = 'Seth\'s Graphite Fishing Pole' },
	{ ID = 6366,   Bonus = 15,  Name = 'Darkwood Fishing Pole' },
	{ ID = 84660,  Bonus = 10,  Name = 'Pandaren Fishing Pole' },
	{ ID = 6365,   Bonus = 5,   Name = 'Strong Fishing Pole' },
	{ ID = 12225,  Bonus = 3,   Name = 'Blump Family Fishing Pole' },
	{ ID = 46337,  Bonus = 3,   Name = 'Staats\' Fishing Pole' },
	{ ID = 120163, Bonus = 3,   Name = 'Thruk\'s Fishing Rod' },
	{ ID = 6256,   Bonus = 0,   Name = 'Fishing Pole' },
}

local fishBaitTable = {
{ ItemID = 118391, BuffID = 5386, Weight = 200, ItemName = 'Worm Supreme' }, -- 10 min
{ ItemID = 124674, BuffID = 5386, Weight = 200, ItemName = 'Day-Old Darkmoon Doughnut' }, -- 10 min
{ ItemID = 68049,  BuffID = 4225, Weight = 150, ItemName = 'Heat-Treated Spinning Lure' }, -- 15 min
{ ItemID = 46006,  BuffID = 3868, Weight = 100, ItemName = 'Glow Worm' }, -- 1 hour
{ ItemID = 34861,  BuffID = 266,  Weight = 100, ItemName = 'Sharpened Fish Hook' }, -- 10 min
{ ItemID = 6533,   BuffID = 266,  Weight = 100, ItemName = 'Aquadynamic Fish Attractor' }, -- 10 min
{ ItemID = 7307,   BuffID = 265,  Weight = 75,  ItemName = 'Flesh Eating Worm' }, -- 10 min
{ ItemID = 6532,   BuffID = 265,  Weight = 75,  ItemName = 'Bright Baubles' }, -- 10 min
{ ItemID = 62673,  BuffID = 266,  Weight = 75,  ItemName = 'Feathered Lure' }, -- 10 min
{ ItemID = 6811,   BuffID = 264,  Weight = 50,  ItemName = 'Aquadynamic Fish Lens' }, -- 10 min
{ ItemID = 6530,   BuffID = 264,  Weight = 50,  ItemName = 'Nightcrawlers' }, -- 10 min
{ ItemID = 69907,  BuffID = 263,  Weight = 25,  ItemName = 'Corpse Worm' }, -- 10 min
{ ItemID = 6529,   BuffID = 263,  Weight = 25,  ItemName = 'Shiny Bauble' }, -- 10 min
{ ItemID = 67404,  BuffID = 4264, Weight = 15,  ItemName = 'Glass Fishing Bobber' }, -- 10 min
}

local function ItemInBag( ItemID )
	local ItemCount = 0
	local ItemFound = false
	for bag=0,4 do
	for slot=1,GetContainerNumSlots(bag) do
			if select(10, GetContainerItemInfo(bag, slot)) == ItemID then
				ItemFound = true
				ItemCount = ItemCount + select(2, GetContainerItemInfo(bag, slot))
			end
		end
	end
	if ItemFound then
		return true, ItemCount
	end
	return false, 0
end

local function pickupItem(item)
	if GetItemCount(item, false, false) > 0 then
		for bag = 0, NUM_BAG_SLOTS do
			for slot = 1, GetContainerNumSlots(bag) do
				if GetContainerItemID(bag, slot) == item then
					PickupContainerItem(bag, slot)
				end
			end
		end
	end
end

function findPoles()
	local polesFound = {}
	for i = 1, #polesTable do
		if GetItemCount(polesTable[i].ID, false, false) > 0 then
			polesFound[#polesFound + 1] = 
			{
				ID = polesTable[i].ID,
				Name = polesTable[i].Name,
				Bonus = polesTable[i].Bonus
			}
		end
	end
	table.sort(polesFound, function(a,b) return a.Bonus > b.Bonus end)
	return polesFound
end

function equipPole()
	local polesFound = findPoles()
	if #polesFound > 0 then
	
		local weaponItemID = GetInventoryItemID('player', 16)
		originalWeaponID = weaponItemID;
		local bestPole = polesFound[1]
		
		if weaponItemID ~= bestPole.ID then
			--print('[Equiped]: '..bestPole.Name)
			pickupItem(bestPole.ID)
			fishingPoleID = bestPole.ID
			AutoEquipCursorItem()
		end
	end
end

function useBestBait()
	local baitFound = {}
	
	for i = 1, #fishBaitTable do
		if GetItemCount(fishBaitTable[i].ItemID, false, false) > 0 then
			local row = fishBaitTable[i]
			table.insert(baitFound, row)
			--print('Bait: ' .. row.ItemName .. ' Weight: ' .. row.Weight)
		end
	end
	table.sort(baitFound, function(a,b) return a.Weight > b.Weight end)
	
	if #baitFound > 0 then
		local bestBait = baitFound[1]
		--print('Using Best Bait: ' .. bestBait.ItemName)
		UseItemByName(bestBait.ItemID)
	else
		--print('No bait found to use')
	end
end

function equipOriginalWeapon()
	--print('[Equiped]: Original Weapon')
	pickupItem(originalWeaponID)
	AutoEquipCursorItem()
end

function startStop()
	if fishingOn == 0 then
		-- Equip best fishing pole
		equipPole();
		equipPoleCD = GetTime() + 5
		
		fishingOn = 1
		button:SetText("Fish: Off")
		startX, startY, startZ = ObjectPosition("Player")
	else
		equipOriginalWeapon();
		JumpOrAscendStart()
		button:SetText("Fish: On")
		fishingOn = 0
	end
end

function Log(message)
	print('|cffAAAAAA' .. message)
end

function init()
	Log('Welcome to Catch22 by WiNiFiX...')
end

function eventHandler(self, event, ...)
	local arg1 = ...
	if event == "LFG_PROPOSAL_SHOW" then	
		GetLFGProposal()	
		AcceptProposal()	
	end
	if event == "ADDON_LOADED" and arg1 == "Catch22" then
		init()            		
	end
end

parent:RegisterEvent("LFG_PROPOSAL_SHOW")
parent:RegisterEvent("ADDON_LOADED")
parent:SetScript("OnEvent", eventHandler)
parent:SetScript("OnUpdate", update)
button:SetScript("OnClick", startStop)