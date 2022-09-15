-----------------------------------------------------------------------------------------------------------------
-- Frameworks
-----------------------------------------------------------------------------------------------------------------
local framework = nil
if configs.framework == 'esx' then
    TriggerEvent('esx:getSharedObject', function(obj) framework = obj end);
elseif configs.framework == 'qbcore' then
    framework = exports['qb-core']:GetCoreObject()
end

function Notify(id, message, type, length)
    TriggerClientEvent(configs.framework == 'esx' and 'esx:showNotification' or 'QBCore:Notify' , id, message, type, length)
end

function getIdentifier(src)
    local identifier = ''
    if configs.framework == 'esx' then
        local xPlayer = framework.GetPlayerFromId(src)
        identifier = xPlayer.getIdentifier()
    elseif configs.framework == 'qbcore' then
        local Player = framework.Functions.GetPlayer(src)
        identifier = Player.PlayerData.citizenid
    end
    return identifier
end

function addMoney(src, amount)
    if configs.framework == 'esx' then
        local xPlayer = framework.GetPlayerFromId(src)
	xPlayer.addAccountMoney('bank', amount)
    elseif configs.framework == 'qbcore' then
        local Player = framework.Functions.GetPlayer(src)
        Player.Functions.AddMoney('bank', amount, 'iBetting Balance Withdraw')
    end
end

function removeMoney(src, amount)
    local hasEnough = false
    if configs.framework == 'esx' then
        local xPlayer = framework.GetPlayerFromId(src)
        local accountMoney = xPlayer.getAccount('bank').money
        if accountMoney >= amount then
            xPlayer.removeAccountMoney('bank', amount)
            hasEnough = true
        end
    elseif configs.framework == 'qbcore' then
        local Player = framework.Functions.GetPlayer(src)
        hasEnough = Player.Functions.RemoveMoney('bank', amount, 'iBetting Bet Placed')
    end
    return hasEnough
end

-----------------------------------------------------------------------------------------------------------------
-- configs
-----------------------------------------------------------------------------------------------------------------
local apiKey = ''
local adminId = 'char1:0ce13144566dd4bb91deff72f33d68332e7b525a' -- (ESX)char1:0ce13144566dd4bb91deff72f33d68332e7b525a or (QBCore)JLU37881
-----------------------------------------------------------------------------------------------------------------
-- variables
-----------------------------------------------------------------------------------------------------------------
local iBetting = {}
-----------------------------------------------------------------------------------------------------------------
-- load betting list data
-----------------------------------------------------------------------------------------------------------------
CreateThread(function()
    MySQL.Sync.execute('SELECT * FROM bettinglist', nil, function(result)
		if result then
			for _, value in pairs(result) do
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
	local identifier = getIdentifier(id)
	if identifier == adminId then
		TriggerClientEvent('iBetting:manager', id, iBetting, apiKey)
	end
end)
-----------------------------------------------------------------------------------------------------------------
-- playing
-----------------------------------------------------------------------------------------------------------------
RegisterNetEvent('iBetting:playing')
AddEventHandler('iBetting:playing', function()
	local id = source
	local identifier = getIdentifier(id)
	MySQL.query('SELECT * FROM bettingbets WHERE userId = ? ORDER BY id DESC', {identifier}, function(result)
		local playerBets = {}
		if result then
			for _, value in pairs(result) do
				-- wining 
				if value.completed == 1 then
					local amount = value.amount * value.odd
					addMoney(id, amount)
					MySQL.query('DELETE FROM bettingbets WHERE id = ?', {value.id})
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
	local identifier = getIdentifier(id)
	if identifier == adminId then
		-- create new match listing
		if not iBetting[data.keym] then
			MySQL.insert.await('INSERT INTO bettinglist (keym, sport, cham, away, home, awayIcon, homeIcon, odd0, odd1, odd2, time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ', {
				data.keym, data.sport, data.cham, data.away, data.home, data.awayIcon, data.homeIcon, data.odd0, data.odd1, data.odd2, data.time
			})
			Notify(id, 'The match listed and bet ready', "success", 5000)
		-- update old match listing
		else
			MySQL.update.await('UPDATE bettinglist SET awayIcon = ?, homeIcon = ?, odd0 = ?, odd1 = ?, odd2 = ? WHERE keym = ?', {data.awayIcon, data.homeIcon, data.odd0, data.odd1, data.odd2, data.keym})
			Notify(id, 'The match updated', "success", 5000)
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
		if removeMoney(id, amount) then
			local odd = 0
			if bet == 0 then odd = iBetting[keym].odd0 elseif bet == 1 then odd = iBetting[keym].odd1 elseif bet == 2 then odd = iBetting[keym].odd2 end

			MySQL.insert.await('INSERT INTO bettingbets (userId, keym, bet, odd, amount, data) VALUES (?, ?, ?, ?, ?, ?) ', {
				getIdentifier(id), keym, bet, odd, amount, json.encode(iBetting[keym])
			})
			MySQL.query('SELECT * FROM bettingbets WHERE userId = ? ORDER BY id DESC', {xPlayer.getIdentifier()}, function(result)
				local playerBets = {}
				if result then
					for index, value in pairs(result) do
						playerBets[tostring(value.id)] = value
					end
					TriggerClientEvent('iBetting:playing', id, iBetting, playerBets)
				end
			end)
			Notify(id, 'Place bet successfully', "success", 5000)
		else
			Notify(id, 'Do not have enough money to bet', "error", 5000)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------
-- cron for scores and wining calc
-----------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		MySQL.query('SELECT sport FROM `bettinglist` GROUP BY sport', {}, function(sports)
			if sports then
				for _, sport in pairs(sports) do
					PerformHttpRequest('https://api.the-odds-api.com/v4/sports/' .. sport.sport .. '/scores/?apiKey=' .. apiKey .. '&daysFrom=3&dateFormat=unix', function (errorCode, resultData, resultHeaders)
						for _, result in pairs(json.decode(resultData)) do
							if result.completed == true then
								local homeScore = result.scores[1].score
								local awayScore = result.scores[2].score
								MySQL.query('SELECT * FROM bettingbets WHERE keym = ? AND completed = 0 ORDER BY id DESC', {result.id}, function(bets)
									if bets then
										for _, bet in pairs(result) do
											if homeScore == awayScore then
												if bet.bet == 2 then
													MySQL.update.await('UPDATE bettingbets SET completed = 1 WHERE id = ?', {bet.id})
												end
											elseif awayScore > homeScore then
												if bet.bet == 0 then
													MySQL.update.await('UPDATE bettingbets SET completed = 1 WHERE id = ?', {bet.id})
												end
											else
												if bet.bet == 1 then
													MySQL.update.await('UPDATE bettingbets SET completed = 1 WHERE id = ?', {bet.id})
												end
											end
										end
									end
									MySQL.query('DELETE FROM bettingbets WHERE keym = ? AND completed = 0', {result.id})
								end)
							end
						end
					end)
				end
			end
		end)
		-- wait next run every 5 hours
		Wait(1000*60*5)
	end
end)
