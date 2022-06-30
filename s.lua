-----------------------------------------------------------------------------------------------------------------
-- ESX
-----------------------------------------------------------------------------------------------------------------
local ESX; TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end);
-----------------------------------------------------------------------------------------------------------------
-- configs
-----------------------------------------------------------------------------------------------------------------
local apiKey = ''
local adminId = 'char1:0ce13144566dd4bb91deff72f33d68332e7b525a'
-----------------------------------------------------------------------------------------------------------------
-- variables
-----------------------------------------------------------------------------------------------------------------
local iBetting = {}
-----------------------------------------------------------------------------------------------------------------
-- load betting list data
-----------------------------------------------------------------------------------------------------------------
CreateThread(function()
    exports.oxmysql:query('SELECT * FROM bettinglist', nil, function(result)
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
	local xPlayer = ESX.GetPlayerFromId(id)
	if xPlayer.getIdentifier() == adminId then
		TriggerClientEvent('iBetting:manager', id, iBetting, apiKey)
	end	
end)
-----------------------------------------------------------------------------------------------------------------
-- playing
-----------------------------------------------------------------------------------------------------------------
RegisterNetEvent('iBetting:playing')
AddEventHandler('iBetting:playing', function()
	local id = source
	local xPlayer = ESX.GetPlayerFromId(id)
	exports.oxmysql:query('SELECT * FROM bettingbets WHERE userId = ? ORDER BY id DESC', {xPlayer.getIdentifier()}, function(result)
		local playerBets = {}
		if result then
			for index, value in pairs(result) do
				-- wining 
				if value.completed == 1 then
					local amount = value.amount * value.odd
					xPlayer.addMoney(amount)
					exports.oxmysql:query('DELETE FROM bettingbets WHERE id = ?', {value.id})
					--------------------
					-- may send notify -
					--------------------
					
				-- player bets
				else
					playerBets[tostring(value.id)] = value
				end
			end
			TriggerClientEvent('iBetting:playing', id, iBetting, playerBets)
		end
	end)
end)
-----------------------------------------------------------------------------------------------------------------
-- list
-----------------------------------------------------------------------------------------------------------------
RegisterNetEvent('iBetting:list')
AddEventHandler('iBetting:list', function(data)
	local id = source
	local xPlayer = ESX.GetPlayerFromId(id)
	if xPlayer.getIdentifier() == adminId then
		-- create new match listing
		if not iBetting[data.keym] then
			exports.oxmysql:insert_async('INSERT INTO bettinglist (keym, sport, cham, away, home, awayIcon, homeIcon, odd0, odd1, odd2, time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ', {
				data.keym, data.sport, data.cham, data.away, data.home, data.awayIcon, data.homeIcon, data.odd0, data.odd1, data.odd2, data.time
			})
			TriggerClientEvent('esx:showNotification', id, 'The match listed and bet ready', "success", 5000)
		-- update old match listing
		else
			exports.oxmysql:update_async('UPDATE bettinglist SET awayIcon = ?, homeIcon = ?, odd0 = ?, odd1 = ?, odd2 = ? WHERE keym = ?', {data.awayIcon, data.homeIcon, data.odd0, data.odd1, data.odd2, data.keym})
			TriggerClientEvent('esx:showNotification', id, 'The match updated', "success", 5000)
		end
		iBetting[data.keym] = data
	end	
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
		local xPlayer = ESX.GetPlayerFromId(id)
		if amount < 1 or xPlayer.getMoney() < amount then
			TriggerClientEvent('esx:showNotification', id, 'Do not have enough money to bet', "error", 5000)
		else
			local odd = 0
			if bet == 0 then odd = iBetting[keym].odd0 elseif bet == 1 then odd = iBetting[keym].odd1 elseif bet == 2 then odd = iBetting[keym].odd2 end
			xPlayer.removeMoney(amount)
			exports.oxmysql:insert_async('INSERT INTO bettingbets (userId, keym, bet, odd, amount, data) VALUES (?, ?, ?, ?, ?, ?) ', {
				xPlayer.getIdentifier(), keym, bet, odd, amount, json.encode(iBetting[keym])
			})
			exports.oxmysql:query('SELECT * FROM bettingbets WHERE userId = ? ORDER BY id DESC', {xPlayer.getIdentifier()}, function(result)
				local playerBets = {}
				if result then
					for index, value in pairs(result) do
						playerBets[tostring(value.id)] = value
					end
					TriggerClientEvent('iBetting:playing', id, iBetting, playerBets)
				end
			end)
			TriggerClientEvent('esx:showNotification', id, 'Place bet successfully', "success", 5000)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------
-- cron for scores and wining calc
-----------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		exports.oxmysql:query('SELECT sport FROM `bettinglist` GROUP BY sport', {}, function(sports)
			if sports then
				for _, sport in pairs(sports) do
					PerformHttpRequest('https://api.the-odds-api.com/v4/sports/' .. sport.sport .. '/scores/?apiKey=' .. apiKey .. '&daysFrom=3&dateFormat=unix', function (errorCode, resultData, resultHeaders)
						for _, result in pairs(json.decode(resultData)) do
							if result.completed == true then
								local homeScore = result.scores[1].score
								local awayScore = result.scores[2].score
								exports.oxmysql:query('SELECT * FROM bettingbets WHERE keym = ? AND completed = 0 ORDER BY id DESC', {result.id}, function(bets)
									if bets then
										for _, bet in pairs(result) do
											if homeScore == awayScore then
												if bet.bet == 2 then
													exports.oxmysql:update_async('UPDATE bettingbets SET completed = 1 WHERE id = ?', {bet.id})
												end
											elseif awayScore > homeScore then
												if bet.bet == 0 then
													exports.oxmysql:update_async('UPDATE bettingbets SET completed = 1 WHERE id = ?', {bet.id})
												end
											else
												if bet.bet == 1 then
													exports.oxmysql:update_async('UPDATE bettingbets SET completed = 1 WHERE id = ?', {bet.id})
												end
											end
										end
									end
									exports.oxmysql:query('DELETE FROM bettingbets WHERE keym = ? AND completed = 0', {result.id})
								end)
							end
						end
					end)
				end
			end
		end)
		-- wait next run every 5 hours
		Citizen.Wait(1000*60*5)
	end		
end)