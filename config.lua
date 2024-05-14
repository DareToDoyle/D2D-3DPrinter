D2D = {}

D2D.Debug = true

D2D.DiscordWebhook = "https://discord.com/api/webhooks/1207104549471649792/MlmlkmUOctKlE1bKcDfwkSUY82xJi0-WielhMXPGGStVhyMDsKRw_yVc4VvZxp4SAOBT" -- Generate your webhook here.

D2D.WebhookName = "Server Name" -- Put your servers name here.

D2D.WebhookID = "discord" -- What ID the discord logs should use, by default I use Discord accounts. If the logs wont show discord accounts change to either "steam" or "license" depending on your server.
 
D2D.PrinterMaterialItem = "filament" -- What you need to print the items below.
 
D2D.Printer = {
    coords = {
        {x = 221.3891, y = 2800.9641, z = 44.8399, h = 100.6897}, 
      --  {x = 1518.9989, y = 3109.1792, z = 39.5319, h = 223.9779},
    },
    blip = {
        enabled = true,
        colour = 81,
        scale = 1.0,
        sprite = 740,
        name = "3D Printer"
    },
    group = {},
    cooldown = 30, -- After the print is done how long till the next person can use it? | Seconds.
    effects = {
        visual = true,
        sound = false
    }
}


D2D.Items = {
	["weapon_assaultrifle"] = {
	    group = {},
	    label = "Assault Rifle",
		prop = "w_ar_assaultrifle", -- Leave nil if you wish, some custom models (especially weapons) MAY not load. Make sure you are putting the actual model in the stream folder of your stuff and not just the spawncode e.g ak47 NOT weapon_ak47
		materialNeeded = 1,
		craftTime = 10, -- In seconds
		description = 'Considerable damage and has a good rate of fire. It does, however, suffer from tremendous recoil and accuracy problems at long range. ',
		icon = 'gun', -- https://fontawesome.com
	},
}


RegisterNetEvent('D2D-3DPrinter:Notifications')
AddEventHandler('D2D-3DPrinter:Notifications', function(msg, Time, Type)
   TriggerEvent("esx:showNotification", msg) -- ESX
end)


D2D.Translation = {
    ["3dprinter"] = "3D Printer",
    ["battery"] = "Battery - %s",
    ["open"] = "Open 3D Printer",
    ["filesTitle"] =  "Files - [%s Available]",
    ["filesDesc"] =  "Show pre-installed printable files.",
    ["filesMenuTitle"] =  "Files",
    ["printprogTitle"] =  "Current Print",
    ["printprog"] =  "Check print progress.",
    ["noprogress"] =  "No print in progress.",
    ["progress"] =  "Progress - %s seconds left.",
    ["recipepageTitle"] = "File: %s ",
    ["recipeRequired"] = "Material Required: %s",
    ["recipeTime"] = "Time to Print: %s seconds",
    ["startPrint"] = "Start Print",
    ["startPrintDesc"] = "Ensure you have enough materials and fuel to finish.",
    ["printerSettings"] = "Printer Settings",
    ["printerDesc"] = "Put the printer on standby for fueling or view software information here.",
    ["printerRefuel"] = "Refuel printer",
    ["printerRefuelYes"] = "Ensure you have enough materials and fuel to finish.",
    ["printerRefuelNo"] = "Ensure you have enough materials and fuel to finish.",
    ["collect"] = "Collect your print",
   
   ["noJerryCan"] = "You dont have a Jerrycan to fuel the Printer.",
   ["fueled"] = "3D Printer has been fueled to %s.",
   ["done"] = "Your %s has finished printing.",
   ["lowBattery"] = "You need to refuel the Printer before starting a print.",
   ["cantcarry"] = "You are too full to carry this.",
   ["insufficientMaterials"] = "You do not have enough materials.",
   ["itemReceived"] = "You have received your item!"
}

function Debug(statement)
    if D2D.Debug then
        print(statement)
    end
end

