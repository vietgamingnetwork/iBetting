-----------------------------------------------------------------------------------------------------------------
-- variables
-----------------------------------------------------------------------------------------------------------------
local iBetting = {}
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
-- load betting list data
-----------------------------------------------------------------------------------------------------------------
CreateThread(function()
    exports.oxmysql:query('SELECT * FROM bettingList', nil, function(result)
		if result then
			for index, value in pairs(result) do
				iBetting[value.keym] = value
			end
		end
	end)
end)
-----------------------------------------------------------------------------------------------------------------
-- manager
-----------------------------------------------------------------------------------------------------------------
RegisterNetEvent('iBetting:manager')
AddEventHandler('iBetting:manager', function()
	local id = source
	-- check for permission here again
	TriggerClientEvent('iBetting:manager', id, iBetting)
end)
-----------------------------------------------------------------------------------------------------------------
-- list
-----------------------------------------------------------------------------------------------------------------
RegisterNetEvent('iBetting:list')
AddEventHandler('iBetting:list', function(data)
	local id = source
	-- check for permission here
	local listId = exports.oxmysql:insert_async('INSERT INTO bettingList (keym, cham, away, home, awayIcon, homeIcon, odd0, odd1, odd2, time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ', {
		data.keym, data.cham, data.away, data.home, data.awayIcon, data.homeIcon, data.odd0, data.odd1, data.odd2, data.time
	})
	iBetting[data.keym] = data
end)
-----------------------------------------------------------------------------------------------------------------
-- playing data
-----------------------------------------------------------------------------------------------------------------
RegisterNetEvent('iBetting:playing')
AddEventHandler('iBetting:playing', function()
	local id = source
	TriggerClientEvent('iBetting:playing', id, iBetting)
end)
-----------------------------------------------------------------------------------------------------------------
-- bet
-----------------------------------------------------------------------------------------------------------------
RegisterNetEvent('iBetting:bet')
AddEventHandler('iBetting:bet', function(data)
	local id = source
	local keym = data.keym; local bet = data.bet; local amount = tonumber(data.amount);
	local currentTime = os.time(os.date("!*t"))
	-- check the match exist and vaild time
	if iBetting[keym] and currentTime < iBetting[keym].time then
		if Config.Framework == "ESX" then
			local xPlayer = ESX.GetPlayerFromId(id)
			-- check player money
			if xPlayer.getAccount(Config.PaymentAccount).money < bet then
				-- send error notify
				TriggerClientEvent('esx:showNotification', id, 'Do not have enough money to bet', "error", 3000)
			else
				-- set player money
				xPlayer.removeAccountMoney(Config.PaymentAccount, bet)
				-- bet odd
				local odd = 0
				if bet == 0 then odd = iBetting[keym].odd0 elseif bet == 1 then odd = iBetting[keym].odd1 elseif bet == 2 then odd = iBetting[keym].odd2 end
				-- insert bet to database
				local betId = exports.oxmysql:insert_async('INSERT INTO bettingbets (keym, bet, odd, data) VALUES (?, ?, ?, ?) ', {
					keym, bet, odd, json.encode(iBetting[keym])
				})
				-- send info notify
				TriggerClientEvent('esx:showNotification', id, 'Beted successfully!', "info", 3000)
			end
		elseif Config.Framework == "QBCore" then
			local xPlayer = QBCore.Functions.GetPlayer(id)
			-- check player money
			if xPlayer.Functions.GetMoney(Config.PaymentAccount) < bet then
				-- send error notify
				TriggerClientEvent('esx:showNotification', id, 'Do not have enough money to bet', "error", 3000)
			else
				-- set player money
				xPlayer.Functions.RemoveMoney(Config.PaymentAccount, bet)
				-- bet odd
				local odd = 0
				if bet == 0 then odd = iBetting[keym].odd0 elseif bet == 1 then odd = iBetting[keym].odd1 elseif bet == 2 then odd = iBetting[keym].odd2 end
				-- insert bet to database
				local betId = exports.oxmysql:insert_async('INSERT INTO bettingbets (keym, bet, odd, data) VALUES (?, ?, ?, ?) ', {
					keym, bet, odd, json.encode(iBetting[keym])
				})
				-- send info notify
				TriggerClientEvent('esx:showNotification', id, 'Beted successfully!', "info", 3000)
			end
		end
	end
end)

function performAPIRequest(URL)
	PerformHttpRequest(URL, function(error, result, headers)
		return result
	end,'GET')
end

function loadDataToInternal()
	
end

loadDataToInternal()
