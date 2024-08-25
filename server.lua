ESX = exports["es_extended"]:getSharedObject()


function formatMoney(amount)
	local suffixes = { "K", "M", "B"}
	local divisors = { 1000, 1000000, 1000000000}
	
	local formatted
  
	if amount < 1000 then
		formatted = tostring(amount)
	else
		for i = #suffixes, 1, -1 do
			if amount >= divisors[i] then
				formatted = string.format("%.1f%s", amount / divisors[i], suffixes[i])
				break
			end
		end
	end
  
	local formattedWithCommas = ""
	local reversed = string.reverse(formatted)
	local commaSeparated = reversed:gsub("(%d%d%d)", "%1,")
	formattedWithCommas = string.reverse(commaSeparated):gsub("^,", "")
  
	return formattedWithCommas
  end

function getPlayerList()
	local players = {}
	for _, serverId in pairs(GetPlayers()) do
		local xPlayer = ESX.GetPlayerFromId(serverId)
		if xPlayer then
			local job = xPlayer.getJob()
			local jobText = job.label .. " - " .. job.grade_label
			local bank1 = xPlayer.getAccount('bank').money
			local money1 = xPlayer.getMoney()

			table.insert(players, {
				serverId = serverId,
				money = formatMoney(money1),
				bank = formatMoney(bank1),
				name = xPlayer.getName() .. " (" .. GetPlayerName(serverId) .. ")",
				group = xPlayer.getGroup(),
				jobText = jobText,
			})
		end
	end

	return players
end

ESX.RegisterServerCallback("requestServerPlayers", function(source, cb)
	local xSource = ESX.GetPlayerFromId(source)

	if not xSource or not ALLOWED_GROUPS[xSource.getGroup()] then
		return cb(false)
	end

	cb(getPlayerList())
end)

ESX.RegisterServerCallback("requestPlayerCoords", function(source, cb, serverId)
	local xSource = ESX.GetPlayerFromId(source)

	if not xSource then
		return cb(false)
	end

	local targetPed = GetPlayerPed(serverId)
	if targetPed <= 0 or not ALLOWED_GROUPS[xSource.getGroup()] then
		return cb(false)
	end

	cb(GetEntityCoords(targetPed))
end)

ESX.RegisterServerCallback("kickPlayerSpectate", function(source, cb, target, reason)
	local xSource = ESX.GetPlayerFromId(source)
	if not xSource or not ALLOWED_GROUPS[xSource.getGroup()] then
		return
	end

	

	cb(getPlayerList())
end)

RegisterNetEvent("fl_spectate:kickplayer", function(source, cb, reason, playerId)
	local xSource = ESX.GetPlayerFromId(source)
	if not xSource or not ALLOWED_GROUPS[xSource.getGroup()] then
		return
	end
	print(playerId .. " " .. reason)
	--DropPlayer(playerId, ("Kicked from the server.\nReason: %s\nAdmin: %s"):format(reason, GetPlayerName(source)))
	cb(getPlayerList())
end)

RegisterCommand("spectate", function(player)
	local xPlayer = ESX.GetPlayerFromId(player)
	if not xPlayer or not ALLOWED_GROUPS[xPlayer.getGroup()] then
		return
	end

	TriggerClientEvent("openSpectateMenu", player, getPlayerList())
end)
