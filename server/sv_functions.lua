function GetGangPlayerCount(gangName)
    local count = 0
    local players = ESX.GetPlayers()

    for _, playerId in ipairs(players) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer.gang == gangName then
            count = count + 1
        end
    end

    return count
end

function GetPlayerGang(player)
    -- USE SOURCE TO GET PLAYER GANG 
   return exports['eth-gangs']:SVGetPlayerGang(player)
end

function GetGangLabel(playerGangName)
    -- CHANGE THIS ON YOUR EXPORT TO GET THE GANGS
   return exports['eth-gangs']:SVGetGangLabel(playerGangName)
end

function TurfRewards(turf,playerGangName)
    local src = source
    --- ADD ANY REWARDSS YOU WANT
    if Config.Territories[turf].RewardMoney ~= 0 then
        exports['eth-gangs']:SVAddGangFunds(playerGangName,Config.Territories[turf].RewardMoney)
    end
end


--TriggerServerEvent('eth-territories:notifyGangMembers' , PlayerGang) --- USAGE
--- SPECIAL EXPORTS
function NotifyGangMembers(playerId)
    TriggerClientEvent('phone:addnotification',playerId, 'Territories', 'Hey homies! Some one is trying to initiate an illegal activities on our territory')
end


--- CALLBACK YOU CAN USE 

-- lib.callback.await('eth-territories:getTerritories') --- to get territories table on the backend

