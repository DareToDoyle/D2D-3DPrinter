ESX = exports["es_extended"]:getSharedObject()

local pData = {}
local isPrinterDeleted = true
local itemData = {}
local battery, pCoords, itemSpawn, printer = nil, nil, nil, nil

Citizen.CreateThread(
    function()
	Citizen.Wait(1000)
    TriggerServerEvent("D2D-3DPrinter:requestPrinter")
	Citizen.Wait(1000)
    end
)
           
function createBlip(blipData, coords)
    if not blipData.enabled then
        return -- If the blip is not enabled, return without creating it
    end
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, blipData.sprite)
    SetBlipScale(blip, blipData.scale)
    SetBlipColour(blip, blipData.colour)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipData.name)
    EndTextCommandSetBlipName(blip)
    return blip
end


RegisterNetEvent("D2D-3DPrinter:sendPrinter")
AddEventHandler("D2D-3DPrinter:sendPrinter", function(printerList)
   pData = printerList
         battery = pData.battery / 100 
        local point = lib.points.new({
            coords = vec3(pData.coords.x,pData.coords.y,pData.coords.z),
            distance = 100.0,
            onEnter = function()
                if isPrinterDeleted then
                    CreateNewPrinter(pData)
                end
            end
        })
end)


function CreateNewPrinter(pData)
    if not printer or not DoesEntityExist(printer) then
        local modelHash = GetHashKey("bzzz_electro_prop_3dprinter")
        RequestModel(modelHash)

        while not HasModelLoaded(modelHash) do
            Citizen.Wait(50)
        end

        printer = CreateObjectNoOffset(modelHash, pData.coords.x, pData.coords.y, pData.coords.z, true)
		SetEntityHeading(printer, pData.coords.h)
        SetModelAsNoLongerNeeded(modelHash)
        local options = createOptions()
        exports.ox_target:addLocalEntity(printer, options)

        -- Create blip for the printer if enabled
       --[[ local blipData = D2D.Printer.blip
        if blipData.enabled then
            local blip = createBlip(blipData, pData.coords)
        end]]--

        --isPrinterDeleted = false -- Update flag to indicate printer is created
    end
end

RegisterCommand("1", function()
ped = GetHashKey('divo')
print(ped)
end, false)



function createOptions(data)
    local options = {
        {
            name = "3d-printer",
            icon = "fa-solid fa-print",
            label = D2D.Translation["open"],
            distance = 2,
            onSelect = function()
                TriggerServerEvent("D2D-3DPrinter:requestPrinter", true)
                Citizen.Wait(100)
                openMenu()
            end
        }
    }

    return options
end

function openMenu()

    lib.registerContext({
        id = 'printer_menu',
        title = D2D.Translation["3dprinter"],
        options = {
            {
                title = string.format(D2D.Translation["battery"], battery .. "%"),
                icon = 'battery-full',
            },
            {
                title = string.format(D2D.Translation["filesTitle"], getItemCount()),
                description = D2D.Translation["filesDesc"],
                --disabled = pData.canPickup,
                onSelect = function()
                    openCraftingMenu()
                end,
                icon = 'file'
            },
            {
                title = D2D.Translation["printprogTitle"],
                description = not pData.isPrinting and D2D.Translation["noprogress"] or D2D.Translation["printprog"],
                icon = 'microchip',
                disabled = not pData.isPrinting and not pData.canPickup,
                arrow = true,
                onSelect = function()
                    openProgressMenu()
                end,
            },
            {
                title = D2D.Translation["printerSettings"],
                description = D2D.Translation["printerDesc"],
                icon = 'gear',
                onSelect = function()
                    openSettingsMenu()
                end,

            }
        }
    })


    lib.showContext('printer_menu')
end

function openCraftingMenu()
    local options = {}  

    for itemName, itemData in pairs(D2D.Items) do
      
        local option = {
            title = itemData.label,  
            description = itemData.description,  
            icon = itemData.icon, 
            disabled = false, 
            onSelect = function()
                recipeMenu(itemName, itemData)
            end,
        }

        table.insert(options, option)
    end

    lib.registerContext({
        id = 'crafting_menu',
        title = D2D.Translation["filesMenuTitle"],
        arrow = true,
        menu = 'printer_menu',
        onBack = function()
            TriggerServerEvent("D2D-3DPrinter:requestPrinter", true)
            openMenu()
        end,
        options = options
    })

    lib.showContext('crafting_menu')
end

function recipeMenu(item, data)
    itemData = data
    itemSpawn = item
    lib.registerContext({
        id = 'recipe_menu',
        title = string.format(D2D.Translation["recipepageTitle"], data.label),
        menu = 'crafting_menu',
        options = {
            {
                title = string.format(D2D.Translation["recipeRequired"], data.materialNeeded),
                icon = 'wrench',
            },
            {
                title = string.format(D2D.Translation["recipeTime"], data.craftTime),
                icon = 'clock'
            },
            {
                title = D2D.Translation["startPrint"],
                description = D2D.Translation["startPrintDesc"],
                icon = 'play',
                disabled = not pData.canStart,
                onSelect = function()
                    TriggerServerEvent('D2D-3DPrinter:startCrafting', item, data)
                end,
            }
        }
    })
    lib.showContext('recipe_menu')
end

function openSettingsMenu()

    lib.registerContext({
        id = 'settings_menu',
        title = D2D.Translation["printerSettings"],
        menu = 'printer_menu',
        options = {
            {
                title = "Serial Number 987654321 © 2024 D2D Corporation. All rights reserved.",
                icon = 'copyright',
            },
            {
                title = D2D.Translation["printerRefuel"],
                icon = 'battery-empty',
                arrow = true,
                onSelect = function()
                    DisplayPetrolCanMetadata()
                end,
            },
        }
    })

    lib.showContext('settings_menu')
end

local progressMenuCount = 0

function openProgressMenu()
    timeProgressPercentage = ((pData.timeLeft / itemData.craftTime)) * 100

    progressMenuCount = progressMenuCount + 1
    local uniqueId = progressMenuCount

    if not pData.isPrinting and pData.canPickup then
        disabled = false
    else
        disabled = true
    end
	
    lib.registerContext({
        id = 'progress_menu_' .. uniqueId,
        title = D2D.Translation["printprogTitle"],
        menu = 'printer_menu',
        options = {
            {
                title = string.format(D2D.Translation["progress"], pData.timeLeft),
                progress = timeProgressPercentage,
                colorScheme = "green",
                icon = 'hourglass'
            },
            {
                title = D2D.Translation["collect"],
                icon = 'hand',
                disabled = disabled,
                arrow = true,
                onSelect = function()
                    TriggerServerEvent('D2D-3DPrinter:Reward', itemSpawn)
                end,
            },
        }
    })

    lib.showContext('progress_menu_' .. uniqueId)
end


function DisplayPetrolCanMetadata()
    local slotsData = exports.ox_inventory:GetSlotsWithItem("WEAPON_PETROLCAN")

    if slotsData and next(slotsData) ~= nil then
        local lowestSlotId = nil
        local lowestAmmo = math.huge

        for _, slotData in ipairs(slotsData) do
            if slotData.metadata and slotData.metadata.ammo and slotData.metadata.ammo > 0 and slotData.metadata.ammo < lowestAmmo then
                lowestSlotId = slotData.slot
                lowestAmmo = slotData.metadata.ammo
            end
        end

        if lowestSlotId then
            Debug("Using petrolcan in slot: " .. lowestSlotId)
            refuelAnimation(lowestSlotId)
        else
            TriggerEvent('D2D-3DPrinter:Notifications', D2D.Translation['noJerryCan'])
        end
    else
        TriggerEvent('D2D-3DPrinter:Notifications', D2D.Translation['noJerryCan'])
    end
end

function getItemCount()
    local count = 0
    for _ in pairs(D2D.Items) do
        count = count + 1
    end
    return count
end

function refuelAnimation(slotid)
    local weaponHash = GetHashKey("WEAPON_UNARMED")

    SetCurrentPedWeapon(PlayerPedId(), weaponHash, true)

    LocalPlayer.state.canUseWeapons = false

    TaskTurnPedToFaceCoord(PlayerPedId(), pData.coords.x, pData.coords.y, pData.coords.z, 3000)
    Wait(500)

    if lib.progressCircle({
        duration = 3000,
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
        },
        anim = {
            dict = 'timetable@gardener@filling_can',
            clip = 'gar_ig_5_filling_can',
            flags = 49,
        },
        prop = {
            model = GetHashKey("w_am_jerrycan"),
            bone = 60309,
            pos = { x = 0.0, y = -0.085, z = 0.185 },
            rot = { x = 45.0, y = 165.0, z = -180.0 },
        },
    }) then
        TriggerServerEvent('D2D-3DPrinter:refuel', slotid)
    end
    LocalPlayer.state.canUseWeapons = true
end


RegisterNetEvent("ToggleParticleEffect")
AddEventHandler("ToggleParticleEffect", function()
    ToggleParticleEffect()
end)

local dict = "core"
local particleName = "ent_sht_electrical_box"
local isActive = false

function ToggleParticleEffect()
    local x, y, z = pData.coords.x, pData.coords.y,pData.coords.z
    if not isActive then

        isActive = true

        Citizen.CreateThread(function()
            while isActive do
                RequestNamedPtfxAsset(dict)
                while not HasNamedPtfxAssetLoaded(dict) do
                    Citizen.Wait(0)
                end

                UseParticleFxAssetNextCall(dict)

                StartNetworkedParticleFxNonLoopedAtCoord(particleName, x, y, z+0.3, 0.0, 0.0, 0.0, 1.0, false, false, false)
                test = PlaySoundFromCoord(GetSoundId(), "CONFIRM_BEEP", x, y, z, "HUD_MINI_GAME_SOUNDSET", true, 0.5, true)

                Citizen.Wait(1500)
            end
        end)
    else
        isActive = false
        StopSound(test)
        PlaySoundFromCoord(GetSoundId(), "Hack_Success", x, y, z, "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", true, 5.0, true)
    end
end

