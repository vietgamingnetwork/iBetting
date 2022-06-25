-----------------------------------------------------------------------------------------------------------------
-- variables
-----------------------------------------------------------------------------------------------------------------
local ESX, QBCore
-----------------------------------------------------------------------------------------------------------------
-- ESX, QBCore
-----------------------------------------------------------------------------------------------------------------
if Config.Framework == "ESX" then
    TriggerEvent(Config.EsxSharedObject, function(obj) ESX = obj end)
elseif Config.Framework == "QBCore" then
    QBCore = exports['qb-core']:GetCoreObject()
end
-----------------------------------------------------------------------------------------------------------------
-- nui call client
-----------------------------------------------------------------------------------------------------------------
RegisterNUICallback('callClient', function(data) event = tostring(data.event); data.event = nil; TriggerEvent(event, data); end)
-----------------------------------------------------------------------------------------------------------------
-- open
-----------------------------------------------------------------------------------------------------------------
if Config.BetCommand then
	RegisterCommand(Config.BetCommand, function(source, args, raw)
		if Config.Framework == "ESX" then
			ESX.TriggerServerCallback('iBetting:getApiData', function(apiData)
				print(json.encode(apiData))
				SendNUIMessage({playing = json.encode(apiData)})
				SetNuiFocus(true, true)
			end)
		elseif Config.Framework == "QBCore" then
			
		end
	end)
end
-----------------------------------------------------------------------------------------------------------------
-- close
-----------------------------------------------------------------------------------------------------------------
RegisterNetEvent('iBetting:close')
AddEventHandler('iBetting:close', function()
	SetNuiFocus(false, false)
end)
-----------------------------------------------------------------------------------------------------------------
-- list
-----------------------------------------------------------------------------------------------------------------
RegisterNetEvent('iBetting:list')
AddEventHandler('iBetting:list', function(data)
	TriggerServerEvent('iBetting:list', data)
end)
-----------------------------------------------------------------------------------------------------------------
-- place bet
-----------------------------------------------------------------------------------------------------------------
RegisterNetEvent('iBetting:bet')
AddEventHandler('iBetting:bet', function(data)
	-- vaild bet amount
	if tonumber(data.amount) > 0 then	
		TriggerServerEvent('iBetting:bet', data)
	end
end)
