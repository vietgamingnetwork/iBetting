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
Citizen.CreateThread(function()
	while true do
		-- press E then open manager tools 
		-- put you more check at here, example user id, admin roles
		if IsControlJustReleased(0, 51) then
			TriggerServerEvent('iBetting:manager')
		elseif IsControlJustReleased(0, 29) then
			TriggerServerEvent('iBetting:playing')
		end
		Citizen.Wait(10)
	end
end)
-----------------------------------------------------------------------------------------------------------------
-- close
-----------------------------------------------------------------------------------------------------------------
RegisterNetEvent('iBetting:close')
AddEventHandler('iBetting:close', function()
	SetNuiFocus(false, false)
end)
-----------------------------------------------------------------------------------------------------------------
-- manager
-----------------------------------------------------------------------------------------------------------------
RegisterNetEvent('iBetting:manager')
AddEventHandler('iBetting:manager', function(data)
	SendNUIMessage({manager = true})
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
-- playing
-----------------------------------------------------------------------------------------------------------------
RegisterNetEvent('iBetting:playing')
AddEventHandler('iBetting:playing', function(data)
	local id = source
	SendNUIMessage({playing = json.encode(data)})
	SetNuiFocus(true, true)
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