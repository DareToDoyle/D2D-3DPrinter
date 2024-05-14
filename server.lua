ESX = exports["es_extended"]:getSharedObject()

local printer = {}
local printerCoords = {}
local printedObject, currentItem, rewardID, randomCoords = nil, nil, nil, nil
local cooldowns = {}
local cooldownTime = D2D.Printer.cooldown * 1000
local cooldownTick = 0

Citizen.CreateThread(
    function()
        local coords = D2D.Printer.coords
        if #coords > 0 then
            local randomIndex = math.random(1, #coords)
            randomCoords = coords[randomIndex]
            printer = {coords = randomCoords, battery = 0, isPrinting = false, canStart = true, canPickup = false, timeLeft = 0}
        end
    end
)

RegisterServerEvent("D2D-3DPrinter:requestPrinter")
AddEventHandler(
    "D2D-3DPrinter:requestPrinter",
    function()
        local playerId = source
        TriggerClientEvent("D2D-3DPrinter:sendPrinter", playerId, printer)
    end
)

RegisterServerEvent("D2D-3DPrinter:startCrafting")
AddEventHandler(
    "D2D-3DPrinter:startCrafting",
    function(item, data)
        currentItem = item
        local pID = source
        local craftTime = data.craftTime

        local enoughMaterials = CheckItemAmount(pID, D2D.PrinterMaterialItem, data.materialNeeded)
        if not enoughMaterials then
            return
        end
      
            if printer.battery < 10000 then
                TriggerClientEvent('D2D-3DPrinter:Notifications', source, D2D.Translation["lowBattery"])
                return
            end
            printer.canStart = false
            printer.isPrinting = true
         

        exports.ox_inventory:RemoveItem(source, D2D.PrinterMaterialItem, data.materialNeeded)

        TriggerClientEvent('ToggleParticleEffect', source)

        local totalTicks = craftTime * 10
        local batteryStep = 10000 / totalTicks

        Citizen.CreateThread(function()
            for tick = 1, totalTicks do
                local remainingTicks = totalTicks - tick
                printer.timeLeft = remainingTicks/10
                local remainingBattery = math.max(0, 10000 - tick * batteryStep)

                printer.battery = remainingBattery

                Citizen.Wait(100)
            end

            SpawnPropOnPrinter(printer.coords, item, data)
            TriggerClientEvent('ToggleParticleEffect', pID)
            TriggerClientEvent('D2D-3DPrinter:Notifications', pID, string.format(D2D.Translation["done"], data.label))
            printer.canPickup = true
            printer.isPrinting = false
        end)
    end
)

function SpawnPropOnPrinter(printerCoords, item, data)
    local modelhash = GetHashKey(data.prop)

    printedObject = CreateObjectNoOffset(modelhash, printerCoords.x, printerCoords.y, printerCoords.z+0.18, true)

    while not DoesEntityExist(printedObject) do
        Wait(1)
    end

    SetEntityRotation(printedObject, -150.0, 0.0, -100.0)

    SetEntityDistanceCullingRadius(printedObject, 25000.0) -- Depreciated native (use at own risk), if you know of a replacement please let me know!

end

function CheckItemAmount(playerId, itemName, requiredAmount)
    local slotIds = exports.ox_inventory:GetSlotIdsWithItem(playerId, itemName)

    if not slotIds or type(slotIds) ~= "table" then
        print("Error: Invalid slotIds for item " .. itemName)
        return false
    end

    local totalCount = 0
    for _, slotId in ipairs(slotIds) do
        local slotData = exports.ox_inventory:GetSlot(playerId, slotId)
        totalCount = totalCount + slotData.count
    end

    if totalCount >= requiredAmount then
        Debug("Player has enough " .. itemName .. ": " .. totalCount)
        return true
    else
        TriggerClientEvent('D2D-3DPrinter:Notifications', playerId, D2D.Translation["insufficientMaterials"])
        return false
    end
end

RegisterServerEvent("D2D-3DPrinter:refuel")
AddEventHandler("D2D-3DPrinter:refuel", function(slotId)
    local slotData = exports.ox_inventory:GetSlot(source, slotId)
    local newBattery = nil
    Debug("Received slot ID: " .. slotId)

    if slotData then
        -- Check if the item is a petrol can
        if slotData.name == "WEAPON_PETROLCAN" then
            -- Check if the itemMetadata is valid and contains ammo and durability
            if slotData.metadata and slotData.metadata.ammo and slotData.metadata.durability then
                local oldBattery = nil -- Placeholder for the old battery level

                -- Iterate through printer objects to find the old battery level

                 oldBattery = printer.battery / 100 -- Scale back to percentage


                local ammo = slotData.metadata.ammo
                local batteryIncrease = ammo * 100 -- Scale the ammo to match the battery range

                -- Debug statement to display the ammo and battery increase
                Debug("Battery Refueling to: " .. batteryIncrease/100)

                -- Update the printer battery with the calculated increase

                    printer.battery = math.min(10000, printer.battery + batteryIncrease)
                    newBattery = printer.battery / 100 -- Scale back to percentage


                -- Calculate the fuel used for refueling
                local fuelUsed = newBattery - oldBattery -- Calculate the difference

                -- Deduct the fuel used from the petrol can's metadata
                slotData.metadata.ammo = slotData.metadata.ammo - fuelUsed
                slotData.metadata.durability = slotData.metadata.durability - fuelUsed

                -- Set the updated metadata back to the petrol can item
                exports.ox_inventory:SetMetadata(source, slotId, slotData.metadata)

                -- Debug statement to confirm metadata update
                Debug("Updated ammo metadata: " .. slotData.metadata.ammo)
                Debug("Updated durability metadata: " .. slotData.metadata.durability)

                -- Send notification to the client with the updated battery level
                TriggerClientEvent('D2D-3DPrinter:Notifications', source, string.format(D2D.Translation["fueled"], newBattery.. "%"))
            end
        end
    end
end)

local rewardGiven = false

RegisterServerEvent("D2D-3DPrinter:Reward")
AddEventHandler("D2D-3DPrinter:Reward", function(item)
    local playerId = source
    local itemName = item
    local itemCount = 1

    if not rewardGiven then
        if exports.ox_inventory:CanCarryItem(playerId, itemName, itemCount) then
            exports.ox_inventory:AddItem(playerId, itemName, itemCount)
            rewardGiven = true
            DeleteEntity(printedObject)
			printer.canPickup = false
			printer.isPrinting = false
			printer.canStart = true
        else
            TriggerClientEvent('D2D-3DPrinter:Notifications', playerId, D2D.Translation["cantcarry"])
        end
    else
        print("DUPE")
        --DropPlayer(playerId, "Stop trying to duplicate items :) ")
    end
end)

function CanCarryItem(playerId, itemName, count)
    return exports.ox_inventory:CanCarryItem(playerId, itemName, count)
end
