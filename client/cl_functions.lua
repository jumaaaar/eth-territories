

function GetPlayerGang()
    return ESX.PlayerData.gang
end


function GetGangBlipColor(playerGang)
    if Config.Gangs[playerGang] then
        return Config.Gangs[playerGang].color
    end
    return 0
end

RegisterNetEvent('eth-territories:WeazelNews', function(title, message, duration)
	ESX.Scaleform.ShowBreakingNews(title, message, bottom, duration)
end)

function Notification(title, msg, duration, type)
    lib.notify({
        title = label,
        description = msg,
        type = type,
        duration = duration
    })
end

RegisterNetEvent('eth-territories:Notify', function(type, duration, msg)
	Notification("TERRITORIES", msg, duration, type)
end)

function GlobalBlipAlert(territoryName)
    local blip = AddBlipForRadius(Config.Territories[territoryName].capture.location, Config.Territories[territoryName].radius)
    SetBlipSprite(blip, 9)
    SetBlipDisplay(blip, 4)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, 200)
    SetBlipAsShortRange(blip, true)
    SetBlipFlashes(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.Territories[territoryName].label .. ' Territory')
    EndTextCommandSetBlipName(blip)
    Citizen.Wait(Config.Territories[territoryName].capture.captureTime * 60000) -- * 1 Minute
    RemoveBlip(blip)
end

function GetClosestTerritory()
    return closestTerritory
end
exports('GetClosestTerritory' , GetClosestTerritory)

