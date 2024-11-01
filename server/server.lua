
local ESX = exports['es_extended']:getSharedObject()
local ox_inventory = exports.ox_inventory
local dbTerritory = {
}


RegisterServerEvent('eth-territories:UpdatePlayerCount')
AddEventHandler('eth-territories:UpdatePlayerCount', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local PlayerGang = GetPlayerGang(src)
    local territory = data.zone
    local counts = data.counts
    if not PlayerGang and PlayerGang == "none" then return end

    if not dbTerritory[territory].playerCounts then
        dbTerritory[territory].playerCounts = {}
    end

    if not dbTerritory[territory].playerCounts[PlayerGang] then
        dbTerritory[territory].playerCounts[PlayerGang] = 0

        if dbTerritory[territory].capturing then
            local msg = GetGangLabel(PlayerGang) .. " has Joined the war at " ..Config.Territories[territory].label
            TriggerClientEvent('eth-territories:Notify', -1 , "info", 10000, msg)
        end
    end
    dbTerritory[territory].playerCounts[PlayerGang] = dbTerritory[territory].playerCounts[PlayerGang] + counts

    print(string.format("Updated player counts for territory %s: %s", territory, json.encode(dbTerritory[territory].playerCounts)))

end)



function updateTerritory(territoryName, gangName)
    local src = source 
    local xPlayer = ESX.GetPlayerFromId(src)
    if dbTerritory[territoryName] then
        local gangNameLabel = GetGangLabel(gangName)
        local location = Config.Territories[territoryName].label
        local message = string.format("%s has captured %s", gangNameLabel, location)
        dbTerritory[territoryName].gang = gangName

        TriggerClientEvent('eth-territories:Notify', -1 , "info", 10000, message)
        exports.oxmysql:update(
            'UPDATE territories SET gang = ? WHERE name = ?',
            {gangName, territoryName}
        )
    end
end




RegisterServerEvent('eth-territories:CaptureStart')
AddEventHandler('eth-territories:CaptureStart', function(name)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local playerGangName = GetPlayerGang(src)

    local currentTime = os.time()

    -- Notify if the territory is on cooldown
    if (currentTime - Config.Territories[name]['capture']['lastCaptureTime']) < Config.CaptureCooldown and Config.Territories[name]['capture']['lastCaptureTime'] ~= 0 then
        TriggerClientEvent('eth-territories:Notify', xPlayer.source, 'error', 5000, 'This territory is on cooldown. Please wait before trying to capture it again.')
        return
    end

    -- Check if the player is in a gang
    if playerGangName == "none" then
        TriggerClientEvent('eth-territories:Notify', xPlayer.source, 'error', 5000, 'You need to be in a gang to be able to capture the territory.')
        return
    end

    -- Check if the territory is already being captured
    if dbTerritory[name] ~= nil then
        if (dbTerritory[name].capturing) then
            TriggerClientEvent('eth-territories:Notify', xPlayer.source, 'error', 5000, 'This area is already under an attempted claim.')
            return
        end

        dbTerritory[name].capturing = true

        local gangName = GetGangLabel(playerGangName)
        local location = Config.Territories[name].label
        local message = gangName .. " has begun the capture of " .. location

        TriggerClientEvent('eth-territories:Notify', -1 , "info", 10000, message)

        TriggerClientEvent('eth-territories:Capture', -1 , name)
        TriggerClientEvent('eth-territories:GlobalBlipAlert', -1, name)

        -- Capture process using player counts from dbTerritory
        ESX.SetTimeout(Config.Territories[name].capture.captureTime * 60000, function()
            local highestGang = nil
            local highestCount = 0

            for gang, count in pairs(dbTerritory[name].playerCounts) do
                if count > highestCount then
                    highestCount = count
                    highestGang = gang
                end
            end
            TriggerClientEvent('eth-territories:updateMap', -1, name, highestGang)
            updateTerritory(name, highestGang)
            TurfRewards(name, highestGang)
            dbTerritory[name].capturing = false
            Config.Territories[name]['capture']['lastCaptureTime'] = os.time()
        end)
    end    
end)


AddEventHandler('onResourceStart', function(resourceName)
    exports.oxmysql:query('SELECT * FROM territories', {}, function(result, error)
        if error then
            print("Database query error: " .. tostring(error))
            return
        end

        for _, v in pairs(result) do
            dbTerritory[v.name] = {
                gang = v.gang,
                capturing = false,
                collectZones = Config.Territories[v.name] and Config.Territories[v.name].CollectZones or {}
            }
        end

        for k, v in pairs(Config.Territories) do
            if not dbTerritory[k] then
                local defaultGang = 'none'
                exports.oxmysql:execute('INSERT INTO territories (name, gang) VALUES (@name, @gang)', {
                    ['@name'] = k,
                    ['@gang'] = defaultGang
                }, function(insertResult, insertError)
                    if insertError then
                        print("Database insert error: " .. tostring(insertError))
                    else
                        print("Inserted missing zone: " .. k)
                    end
                end)
                dbTerritory[k] = {
                    gang = defaultGang,
                    capturing = false,
                    collectZones = Config.Territories[k].CollectZones or {}
                }
            end
        end
    end)
end)


RegisterServerEvent('eth-territories:notifyGangMembers')
AddEventHandler('eth-territories:notifyGangMembers', function(gang)
	local players = GetPlayers()
	for i = 1, #players do
		local playerId = players[i]
		local xPlayers = ESX.GetPlayerFromId(playerId)
		if GetPlayerGang(playerId) == gang then
            NotifyGangMembers(playerId)
		end
	end
end)

-- Handle playerDropped to update the player count
AddEventHandler('playerDropped', function(reason)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local PlayerGang = GetPlayerGang(src)

    if not PlayerGang or PlayerGang == "none" then return end

    for territory, data in pairs(dbTerritory) do
        if dbTerritory[territory].playerCounts and dbTerritory[territory].playerCounts[PlayerGang] then

            dbTerritory[territory].playerCounts[PlayerGang] = dbTerritory[territory].playerCounts[PlayerGang] - 1

            if dbTerritory[territory].playerCounts[PlayerGang] < 0 then
                dbTerritory[territory].playerCounts[PlayerGang] = 0
            end

            print(string.format("Player dropped. Updated player counts for territory %s: %s", territory, json.encode(dbTerritory[territory].playerCounts)))

        end
    end
end)


lib.callback.register('eth-territories:getTerritories', function(source)
    return dbTerritory
end)
