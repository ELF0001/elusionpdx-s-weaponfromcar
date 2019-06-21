local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 163333336, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX 			    			= nil

local HasBag = false
local Bags = {}
local BagId = false
local HasdBag = false

Citizen.CreateThread(function()
	while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) 
            ESX = obj 
        end)

		Citizen.Wait(0)
    end
    
    -- On restart check down below.

    if ESX.IsPlayerLoaded() then
        ESX.TriggerServerCallback('esx-kr-bag:getAllBags', function(bags)
            if bags ~= nil then
                for i=1, #bags, 1 do
                    TriggerEvent('esx-kr-bag:SpawnBagIntoClient', bags[i].x, bags[i].y, bags[i].z)
                    TriggerEvent('esx-kr-bag:insertIntoClient', bags[i].id)
                end
            end

            ESX.TriggerServerCallback('esx-kr-bag:getBag', function(bag)
                if bag ~= nil then
                    BagId = bag.bag[1].id
                    HasBag = true
                    TriggerEvent('esx-kr-bag:SetOntoPlayer')
                end
            end)
        end)
    end
end)

function Draw3DText(x, y, z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = 0.25
   
    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(1, 1, 0, 0, 255)
        SetTextEdge(0, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(2)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)

    Citizen.Wait(200)

    PlayerData = xPlayer

    ESX.TriggerServerCallback('esx-kr-bag:getAllBags', function(bags)
        if bags ~= nil then
            for i=1, #bags, 1 do
                TriggerEvent('esx-kr-bag:SpawnBagIntoClient', bags[i].x, bags[i].y, bags[i].z)
                TriggerEvent('esx-kr-bag:insertIntoClient', bags[i].id)

            
            end
        end

        ESX.TriggerServerCallback('esx-kr-bag:getBag', function(bag)
            if bag ~= nil then
                BagId = bag.bag[1].id
                HasBag = true
                TriggerEvent('esx-kr-bag:SetOntoPlayer')

            end
        end)
    end)
end)

RegisterNetEvent('esx-kr-bag:SetOntoPlayer')
AddEventHandler('esx-kr-bag:SetOntoPlayer', function(id)
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
        if HasBag and skin.bags_1 ~= 45 then
            TriggerEvent('skinchanger:change', "bags_1", 45)
            TriggerEvent('skinchanger:change', "bags_2", 0)
            TriggerEvent('skinchanger:getSkin', function(skin)
            TriggerServerEvent('esx_skin:save', skin)
            end)
        end
    end)
end)

function LoadAnimation(dict)
    RequestAnimDict(dict)

    while not HasAnimDictLoaded(dict) do
      Wait(100)
    end 
end

RegisterNetEvent('esx-kr-bag:insertIntoClient')
AddEventHandler('esx-kr-bag:insertIntoClient', function(id)
    ESX.TriggerServerCallback('esx-kr-bag:getAllBags', function(bags)
        for i=1, #bags, 1 do
            table.insert(Bags, {id = {coords = {x = bags[i].x, y = bags[i].y, z = bags[i].z}, id = bags[i].id}})
        end
    end)
end)

RegisterNetEvent('esx-kr-bag:ReSync')
AddEventHandler('esx-kr-bag:ReSync', function(id)
    Bags = {}

    ESX.TriggerServerCallback('esx-kr-bag:getAllBags', function(bags)
        for i=1, #bags, 1 do
            table.insert(Bags, {id = {coords = {x = bags[i].x, y = bags[i].y, z = bags[i].z}, id = bags[i].id}})
        end
    end)
end)


function Bag()

    local elements = {}

    table.insert(elements, {label = 'Put object', value = 'put'})
    table.insert(elements, {label = 'Take object', value = 'take'})
    table.insert(elements, {label = 'Drop bag', value = 'drop'})
        
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'lel',
        {
            title    = 'Bag',
            align    = 'left',
            elements = elements
        }, function(data, menu)

            if data.current.value == 'put' then
                PutItem()
            elseif data.current.value == 'take'then
                TakeItem()
            elseif data.current.value == 'drop' then
                DropBag()
            end
        end, function(data, menu)
        menu.close()
    end)
end


RegisterNetEvent('esx-kr-bag:GiveBag')
AddEventHandler('esx-kr-bag:GiveBag', function()
    ESX.TriggerServerCallback('esx-kr-bag:getBag', function(bag)
        if bag ~= nil then
            BagId = bag.bag[1].id
            HasBag = true
            TriggerEvent('esx-kr-bag:SetOntoPlayer')
        end
    end)
end)

RegisterNetEvent('esx-kr-bag:CheckBag')
AddEventHandler('esx-kr-bag:CheckBag', function()
    if HasBag then
        return true
    else
        return false
    end
end)

RegisterNetEvent('esx-kr-bag:SpawnBagIntoClient')
AddEventHandler('esx-kr-bag:SpawnBagIntoClient', function(x, y ,z)
    local coords3 = {
        x = x, 
        y = y, 
        z = z
    }

    ESX.Game.SpawnObject(1626933972, coords3, function(bag)
        FreezeEntityPosition(bag, true)
        SetEntityAsMissionEntity(object, true, false)
        SetEntityCollision(bag, false, true)
    end)
end)

function DropBag()
        ESX.UI.Menu.CloseAll()
        HasBag = false
		HasdBag = false

        local coords1 = GetEntityCoords(PlayerPedId())
        local headingvector = GetEntityForwardVector(PlayerPedId())
        local x, y, z = table.unpack(coords1 + headingvector * 1.0)

        local coords2 = {
            x = x,
            y = y,
            z = z - 1
        }

        z2 = z - 1

        TriggerServerEvent('esx-kr-bag:DropBag', BagId, x, y, z2)

        ESX.Game.SpawnObject(1626933972, coords2, function(bag)
            FreezeEntityPosition(bag, true)
            SetEntityCollision(bag, false, true)
            TriggerEvent('skinchanger:change', "bags_1", 0)
            TriggerEvent('skinchanger:change', "bags_2", 0)
            TriggerEvent('skinchanger:getSkin', function(skin)
            TriggerServerEvent('esx_skin:save', skin)
        end)
    end)
end

function IsWeapon(item)
    local hash = GetHashKey(item)
    local IsWeapon = IsWeaponValid(hash)
    
    if IsWeapon then 
        return true 
    else 
        return false 
    end
end


function TakeItem()

    local elements = {}

    ESX.TriggerServerCallback('esx-kr-bag:getBagInventory', function(bag)

        for i=1, #bag, 1 do
            table.insert(elements, {label = bag[i].label .. ' | ' .. bag[i].count .. 'x', value = bag[i].item, count = bag[i].count})
        end
        
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'lels',
        {
            title    = 'Bag',
            align    = 'left',
            elements = elements
        }, function(data, menu)

            local IsWeapon = IsWeapon(data.current.value)
            menu.close()
            if IsWeapon then
                TriggerServerEvent('esx-kr-bag:TakeItem', BagId, data.current.value, data.current.count, "weapon")
            else
                TriggerServerEvent('esx-kr-bag:TakeItem', BagId, data.current.value, data.current.count, "item")
            end

            end, function(data, menu)
            menu.close()
        end)
    end, BagId)
end


function PutItem()

    local elements = {}

    ESX.TriggerServerCallback('esx-kr-bag:getPlayerInventory', function(result)

            for i=1, #result.items, 1 do
            local invitem = result.items[i]
                if invitem.count > 0 then
                    table.insert(elements, { label = invitem.label .. ' | ' .. invitem.count .. 'x', count = invitem.count, name = invitem.name, label2 = invitem.label})
                end
            end
          
          local weaponList = ESX.GetWeaponList()

            for i=1, #weaponList, 1 do
                local weaponHash = GetHashKey(weaponList[i].name)
                local ammo = GetAmmoInPedWeapon(GetPlayerPed(-1), weaponHash)
        
                if HasPedGotWeapon(GetPlayerPed(-1), weaponHash, false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
                    table.insert(elements, {label = weaponList[i].label .. ' | ' .. ammo .. 'x', name = weaponList[i].name, count = ammo, label2 = weaponList[i].label})
                end
            end
        
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'lel3',
        {
            title    = 'Bag',
            align    = 'left',
            elements = elements
        }, function(data, menu)
            
            local IsWeapon = IsWeapon(data.current.name)
            menu.close()

                if IsWeapon then
                    TriggerServerEvent('esx-kr-bag:PutItem', BagId, data.current.name, data.current.label2, data.current.count, "weapon")
                else
                    TriggerServerEvent('esx-kr-bag:PutItem', BagId, data.current.name, data.current.label2, data.current.count, "item")
                end

            end, function(data, menu)
            menu.close()
        end)
    end)
end

Citizen.CreateThread(function()
    while true do

        local wait = 500

        for i=1, #Bags, 1 do

            local playercoords = GetEntityCoords(PlayerPedId())

            if GetDistanceBetweenCoords(playercoords, Bags[i].id.coords.x, Bags[i].id.coords.y, Bags[i].id.coords.z, true) <= 1.5 and not HasBag then
                wait = 5


                Draw3DText(Bags[i].id.coords.x, Bags[i].id.coords.y, Bags[i].id.coords.z + 0.45, '~g~[E]~w~ to Pick up the bag')
                Draw3DText(Bags[i].id.coords.x, Bags[i].id.coords.y, Bags[i].id.coords.z + 0.35, '~o~[N]~w~ to Search the bag')
            
                if IsControlJustReleased(0, Keys['E']) then
                    HasBag = true
                    BagId = Bags[i].id.id

                    local Bag = GetClosestObjectOfType(Bags[i].id.coords.x, Bags[i].id.coords.y, Bags[i].id.coords.z, 1.5, 1626933972, false, false, false)

                    NetworkFadeOutEntity(Bag, false, false)
                    DeleteObject(Bag)
                
                    TriggerServerEvent('esx-kr-bag:PickUpBag', Bags[i].id.id)
                end

                if IsControlJustReleased(0, Keys['N']) then
                        HasBag = false
                        BagId = Bags[i].id.id
                        TakeItem()

                    wait = 5
                    Draw3DText(Bags[i].id.coords.x, Bags[i].id.coords.y, Bags[i].id.coords.z + 0.45, '~g~[E]~w~ to pick up the bag')
                    Draw3DText(Bags[i].id.coords.x, Bags[i].id.coords.y, Bags[i].id.coords.z + 0.35, '~o~[N]~w~ to Search bag')
             
                        if IsControlJustReleased(0, Keys['E']) then
                            HasBag = true
                            BagId = Bags[i].id.id
                            local Bag = GetClosestObjectOfType(Bags[i].id.coords.x, Bags[i].id.coords.y, Bags[i].id.coords.z, 1.5, 1626933972, false, false, false)
    
                                NetworkFadeOutEntity(Bag, false, false)
                                DeleteObject(Bag)
                         
                                TriggerServerEvent('esx-kr-bag:PickUpBag', Bags[i].id.id)
                        end
                    if IsControlJustReleased(0, Keys['N']) then
                            HasBag = false
                            BagId = Bags[i].id.id
                            TakeItem()

                        end

                    end
                end
            end

            Citizen.Wait(wait)
        end
    end)

Citizen.CreateThread(function()
    while true do
        Wait(5)

        if IsControlJustReleased(0, Keys['F15']) and HasBag and not IsPedInAnyVehicle(GetPlayerPed(-1), true) and not IsEntityInAir(PlayerPedId()) then -- Change F5 to the key you want to open the meny with
            Bag()
        end
    end
end)

RegisterCommand("zzyz1", function(source, args, rawCommand)
if HasBag and not IsPedInAnyVehicle(GetPlayerPed(-1), true) and not IsEntityInAir(PlayerPedId()) and not isDead then
    Bag()
	end
end)


--   made by ELF#0001 <- my discord --
--  3dme made by Elio  --



--   wfc settings   --

local duffle = false -- do not use wip not working -- change if you dont want weapons out of a duffle-bag

local tafbw = true -- Text Above For Big Weapons - change if you dont want text above for the weapons you take out of the car 
local tafsw = true -- Text Above For Small Weapons -||-
local tafmw = true -- Text Above For Melee Weapons -||-
local tafdb = true -- Text Above For Duffle-Bag -||-

local txt = "" -- /me text
local bwtxt = "* Takes a weapon out of the Trunk. *"
local dbtxt = "* Takes a weapon out of the dufflebag. *"
local dbtxterr = "Hey - This weapon can only be taken out of a car or a dufflebag."
local bwtxterr = "Hey - This weapon can only be taken out of a car."
local swtxt = "* Takes a weapon out. *"
local mwtxt = "* Takes a melee weapon out. *"



-- 3dtext settings --

local color = { r = 250, g = 140, b = 0, alpha = 255 } -- color of the text 
local font = 0 -- font of the text
local time = 4 -- duration of the display of the text in seconds
local background = {
    enable = false, -- background toggle
    color = { r = 35, g = 35, b = 35, alpha = 200 }, -- background color
}
local chatMessage = false 
local dropShadow = false



-- list of weapons to be taken out of a car

bigweaponslist = {	
	"WEAPON_MICROSMG",
	"WEAPON_MINISMG",
	"WEAPON_SMG",
	"WEAPON_SMG_MK2",
	"WEAPON_ASSAULTSMG",
	"WEAPON_MG",
	"WEAPON_COMBATMG",
	"WEAPON_COMBATMG_MK2",
	"WEAPON_COMBATPDW",
	"WEAPON_GUSENBERG",
	"WEAPON_ASSAULTRIFLE",
	"WEAPON_ASSAULTRIFLE_MK2",
	"WEAPON_CARBINERIFLE",
	"WEAPON_CARBINERIFLE_MK2",
	"WEAPON_ADVANCEDRIFLE",
	"WEAPON_SPECIALCARBINE",
	"WEAPON_BULLPUPRIFLE",
	"WEAPON_COMPACTRIFLE",
	"WEAPON_PUMPSHOTGUN",
	"WEAPON_SWEEPERSHOTGUN",
	"WEAPON_SAWNOFFSHOTGUN",
	"WEAPON_BULLPUPSHOTGUN",
	"WEAPON_ASSAULTSHOTGUN",
	"WEAPON_MUSKET",
	"WEAPON_HEAVYSHOTGUN",
	"WEAPON_DBSHOTGUN",
	"WEAPON_SNIPERRIFLE",
	"WEAPON_HEAVYSNIPER",
	"WEAPON_HEAVYSNIPER_MK2",
	"WEAPON_MARKSMANRIFLE",
	"WEAPON_GRENADELAUNCHER",
	"WEAPON_GRENADELAUNCHER_SMOKE",
	"WEAPON_RPG",
	"WEAPON_MINIGUN",
	"WEAPON_FIREWORK",
	"WEAPON_RAILGUN",
	"WEAPON_HOMINGLAUNCHER",
	"WEAPON_COMPACTLAUNCHER",
	"WEAPON_SPECIALCARBINE_MK2",
	"WEAPON_BULLPUPRIFLE_MK2",
	"WEAPON_PUMPSHOTGUN_MK2",
	"WEAPON_MARKSMANRIFLE_MK2",
	"WEAPON_RAYPISTOL",
	"WEAPON_RAYCARBINE",
	"WEAPON_RAYMINIGUN",
	"WEAPON_DIGISCANNER"
}



-- list of weapons for small weapons message

smallweaponslist = {
	"WEAPON_REVOLVER",
	"WEAPON_PISTOL",
	"WEAPON_PISTOL_MK2",
	"WEAPON_COMBATPISTOL",
	"WEAPON_APPISTOL",
	"WEAPON_PISTOL50",
	"WEAPON_SNSPISTOL",
	"WEAPON_HEAVYPISTOL",
	"WEAPON_VINTAGEPISTOL",
	"WEAPON_STUNGUN",
	"WEAPON_FLAREGUN",
	"WEAPON_MARKSMANPISTOL",
	"WEAPON_MACHINEPISTOL",
	"WEAPON_SNSPISTOL_MK2",
	"WEAPON_REVOLVER_MK2",
	"WEAPON_DOUBLEACTION",
	
	"WEAPON_PROXMINE",
	"WEAPON_BZGAS",
	"WEAPON_SMOKEGRENADE",
	"WEAPON_MOLOTOV",
	"WEAPON_FIREEXTINGUISHER",
	"WEAPON_PETROLCAN",
	"WEAPON_SNOWBALL",
	"WEAPON_FLARE",
	"WEAPON_BALL",
	"WEAPON_GRENADE",
	"WEAPON_STICKYBOMB"
}



-- list of weapons for melee weapons message

meleeweaponslist = {
	"WEAPON_KNIFE",
	"WEAPON_KNUCKLE",
	"WEAPON_NIGHTSTICK",
	"WEAPON_HAMMER",
	"WEAPON_BAT",
	"WEAPON_GOLFCLUB",
	"WEAPON_CROWBAR",
	"WEAPON_BOTTLE",
	"WEAPON_DAGGER",
	"WEAPON_HATCHET",
	"WEAPON_MACHETE",
	--"WEAPON_FLASHLIGHT",
	"WEAPON_SWITCHBLADE",
	"WEAPON_POOLCUE",
	"WEAPON_PIPEWRENCH"
}



--   end of settings   --

--   made by ELF#0001  --
-- Edits by Karma Life Roleplay --
--  Uses 3dme for above head msg made by Elio  --



-- do not edit !!

-- do not edit !!

RegisterCommand('vinfo', function(source, args)
    playerPed = GetPlayerPed(-1)
	if playerPed then
		local weapon = GetSelectedPedWeapon(playerPed, true)
		nameWeapon(weapon)
	end
end)

-- do not edit !!

allweaponslist = {
	"WEAPON_MICROSMG",
	"WEAPON_MINISMG",
	"WEAPON_SMG",
	"WEAPON_SMG_MK2",
	"WEAPON_ASSAULTSMG",
	"WEAPON_MG",
	"WEAPON_COMBATMG",
	"WEAPON_COMBATMG_MK2",
	"WEAPON_COMBATPDW",
	"WEAPON_GUSENBERG",
	"WEAPON_ASSAULTRIFLE",
	"WEAPON_ASSAULTRIFLE_MK2",
	"WEAPON_CARBINERIFLE",
	"WEAPON_CARBINERIFLE_MK2",
	"WEAPON_ADVANCEDRIFLE",
	"WEAPON_SPECIALCARBINE",
	"WEAPON_BULLPUPRIFLE",
	"WEAPON_COMPACTRIFLE",
	"WEAPON_PUMPSHOTGUN",
	"WEAPON_SWEEPERSHOTGUN",
	"WEAPON_SAWNOFFSHOTGUN",
	"WEAPON_BULLPUPSHOTGUN",
	"WEAPON_ASSAULTSHOTGUN",
	"WEAPON_MUSKET",
	"WEAPON_HEAVYSHOTGUN",
	"WEAPON_DBSHOTGUN",
	"WEAPON_SNIPERRIFLE",
	"WEAPON_HEAVYSNIPER",
	"WEAPON_HEAVYSNIPER_MK2",
	"WEAPON_MARKSMANRIFLE",
	"WEAPON_GRENADELAUNCHER",
	"WEAPON_GRENADELAUNCHER_SMOKE",
	"WEAPON_RPG",
	"WEAPON_MINIGUN",
	"WEAPON_FIREWORK",
	"WEAPON_RAILGUN",
	"WEAPON_HOMINGLAUNCHER",
	"WEAPON_COMPACTLAUNCHER",
	"WEAPON_SPECIALCARBINE_MK2",
	"WEAPON_BULLPUPRIFLE_MK2",
	"WEAPON_PUMPSHOTGUN_MK2",
	"WEAPON_MARKSMANRIFLE_MK2",
	"WEAPON_RAYPISTOL",
	"WEAPON_RAYCARBINE",
	"WEAPON_RAYMINIGUN",
	"WEAPON_DIGISCANNER",
	
	"WEAPON_REVOLVER",
	"WEAPON_PISTOL",
	"WEAPON_PISTOL_MK2",
	"WEAPON_COMBATPISTOL",
	"WEAPON_APPISTOL",
	"WEAPON_PISTOL50",
	"WEAPON_SNSPISTOL",
	"WEAPON_HEAVYPISTOL",
	"WEAPON_VINTAGEPISTOL",
	"WEAPON_STUNGUN",
	"WEAPON_FLAREGUN",
	"WEAPON_MARKSMANPISTOL",
	"WEAPON_MACHINEPISTOL",
	"WEAPON_SNSPISTOL_MK2",
	"WEAPON_REVOLVER_MK2",
	"WEAPON_DOUBLEACTION",
	
	"WEAPON_PROXMINE",
	"WEAPON_BZGAS",
	"WEAPON_SMOKEGRENADE",
	"WEAPON_MOLOTOV",
	"WEAPON_FIREEXTINGUISHER",
	"WEAPON_PETROLCAN",
	"WEAPON_SNOWBALL",
	"WEAPON_FLARE",
	"WEAPON_BALL",
	"WEAPON_GRENADE",
	"WEAPON_STICKYBOMB",
	
	"WEAPON_KNIFE",
	"WEAPON_KNUCKLE",
	"WEAPON_NIGHTSTICK",
	"WEAPON_HAMMER",
	"WEAPON_BAT",
	"WEAPON_GOLFCLUB",
	"WEAPON_CROWBAR",
	"WEAPON_BOTTLE",
	"WEAPON_DAGGER",
	"WEAPON_HATCHET",
	"WEAPON_MACHETE",
	"WEAPON_FLASHLIGHT",
	"WEAPON_SWITCHBLADE",
	"WEAPON_POOLCUE",
	"WEAPON_PIPEWRENCH"
}

-- do not edit !!

daw = false
bigWeaponOut = false
smallWeaponOut = false
meleeWeaponOut = false

-- do not edit !!

Citizen.CreateThread(function()
	while true do
		Wait(250)
		local playerPed = GetPlayerPed(-1)
		--	playerPed = GetPlayerPed(-1)
			if playerPed then
				local weapon = GetSelectedPedWeapon(playerPed, true)
				if daw == true then
					RemoveAllPedWeapons(playerPed, true)
				else
					if isWeaponBig(weapon) then
						local vehicle = VehicleInFront()
						if GetVehiclePedIsIn(playerPed, false) == 0 and DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) and bigWeaponOut == false then
							bigWeaponOut = true
							SetVehicleDoorOpen(vehicle, 5, false, false)
							if tafbw == true then
								local text = bwtxt
								TriggerServerEvent('3dme:shareDisplay', text)
							end
							Citizen.Wait(2000)
							SetVehicleDoorShut(vehicle, 5, false)
							else
							if bigWeaponOut == false and GetVehiclePedIsIn(playerPed, false) == 0 then -- male
								if HasBag == true then
									bigWeaponOut = true
									if tafdb == true then
										local text = dbtxt
										TriggerServerEvent('3dme:shareDisplay', text)
									end
								else
									drawNotification("~p~Stop the fail RP ~r~"..dbtxterr.."")
									SetCurrentPedWeapon(playerPed, -1569615261)
									end
								end
							if GetVehiclePedIsIn(playerPed, false) == 0 and isWeaponSmall(weapon) then
								if smallWeaponOut == false then
								smallWeaponOut = true
								if tafsw == true then
								local text = swtxt
								TriggerServerEvent('3dme:shareDisplay', text)
							end
							Citizen.Wait(100)
								end
							if GetVehiclePedIsIn(playerPed, false) == 0 and isWeaponSmall(weapon) then
								if smallWeaponOut == false then
									smallWeaponOut = true
									if tafsw == true then
										local text = swtxt
										TriggerServerEvent('3dme:shareDisplay', text)
									end
									Citizen.Wait(100)
								end
							end
							if GetVehiclePedIsIn(playerPed, false) == 0 and isWeaponMelee(weapon) then
								if meleeWeaponOut == false then
									meleeWeaponOut = true
									if tafmw == true then
										local text = mwtxt
										TriggerServerEvent('3dme:shareDisplay', text)
									end
									Citizen.Wait(100)
								end
							end
						end
					end
				end
			end
		end
	end
end)

-- do not edit !!

Citizen.CreateThread(function()
	while true do
		Wait(1)
		
		playerPed = GetPlayerPed(-1)
		if playerPed then
			local weapon = GetSelectedPedWeapon(playerPed, true)
			if not isWeaponBig(weapon) and bigWeaponOut == true then
				Wait(100)
				bigWeaponOut = false
			end
			if not isWeaponSmall(weapon) and smallWeaponOut == true then
				Wait(100)
				smallWeaponOut = false
			end
			if not isWeaponMelee(weapon) and meleeWeaponOut == true then
				Wait(100)
				meleeWeaponOut = false
			end	
		end
	end
end)

-- do not edit !!

function VehicleInFront()
	local player = PlayerPedId()
    local pos = GetEntityCoords(player)
    local entityWorld = GetOffsetFromEntityInWorldCoords(player, 0.0, 2.0, 0.0)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 30, player, 0)
    local _, _, _, _, result = GetRaycastResult(rayHandle)
    return result
end

-- do not edit !!

function isWeaponBig(model)
	for _, bigWeapon in pairs(bigweaponslist) do
		if model == GetHashKey(bigWeapon) then
			return true
		end
	end

	return false
end

-- do not edit !!

function isWeaponSmall(model)
	for _, smallWeapon in pairs(smallweaponslist) do
		if model == GetHashKey(smallWeapon) then
			return true
		end
	end

	return false
end

-- do not edit !!

function isWeaponMelee(model)
	for _, meleeWeapon in pairs(meleeweaponslist) do
		if model == GetHashKey(meleeWeapon) then
			return true
		end
	end

	return false
end

-- do not edit !!

function nameWeapon(model)
	if model == -1569615261 then
		local text = "* "..model.." Unarmed *"
		TriggerEvent('chat:addMessage', {
        color = { color.r, color.g, color.b },
        multiline = true,
        args = { text}
		})
		return true
	else
		for _, weapons in pairs(allweaponslist) do
			if model == GetHashKey(weapons) then
				local text = "* "..model.." "..weapons.." *"
				TriggerEvent('chat:addMessage', {
				color = { color.r, color.g, color.b },
				multiline = true,
				args = { text}
				})
				return true
			end
		end
	end
	local text = "* "..model.." ERROR *"
	TriggerEvent('chat:addMessage', {
	color = { color.r, color.g, color.b },
	multiline = true,
	args = { text}
	})
	return false
end

function drawNotification(Notification)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(Notification)
	DrawNotification(false, false)
end