-----------------------------------------------------------------------------------------------------------------
-- variables
-----------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------
-- nui call client
-----------------------------------------------------------------------------------------------------------------
RegisterNUICallback('callClient', function(data) event = tostring(data.event); data.event = nil; TriggerEvent(event, data); end)
-----------------------------------------------------------------------------------------------------------------
-- open
-----------------------------------------------------------------------------------------------------------------
if configs.managerCMD then
	RegisterCommand(configs.managerCMD, function(source, args, raw)
		TriggerServerEvent('iBetting:manager')
	end)
end
if configs.playingCMD then
	RegisterCommand(configs.playingCMD, function(source, args, raw)
		TriggerServerEvent('iBetting:playing')
	end)
end
-----------------------------------------------------------------------------------------------------------------
-- manager
-----------------------------------------------------------------------------------------------------------------
RegisterNetEvent('iBetting:manager')
AddEventHandler('iBetting:manager', function(playing, apiKey)
	SendNUIMessage({manager = json.encode(playing), apiKey = apiKey})
	SetNuiFocus(true, true)
end)
-----------------------------------------------------------------------------------------------------------------
-- playing
-----------------------------------------------------------------------------------------------------------------
RegisterNetEvent('iBetting:playing')
AddEventHandler('iBetting:playing', function(playing, playerBets)
	SendNUIMessage({playing = json.encode(playing), playerBets = json.encode(playerBets)})
	SetNuiFocus(true, true)
end)
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
-- update
-----------------------------------------------------------------------------------------------------------------
RegisterNetEvent('iBetting:update')
AddEventHandler('iBetting:update', function(data)
	TriggerServerEvent('iBetting:list', data)
end)
-----------------------------------------------------------------------------------------------------------------
-- place bet
-----------------------------------------------------------------------------------------------------------------
RegisterNetEvent('iBetting:bet')
AddEventHandler('iBetting:bet', function(data)
	-- vaild bet amount
	data.amount = tonumber(data.amount)
	TriggerServerEvent('iBetting:bet', data)
end)
