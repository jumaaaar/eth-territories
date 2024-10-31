

function GetPlayerGang()
    return ESX.PlayerData.gang
end


function GetGangBlipColor(playerGang)
    if Config.Gangs[playerGang] then
        return Config.Gangs[playerGang].color
    end
    return 0
end

function Notification(label, msg, duration, type)
    exports['cfx-hu-notify']:Custom({style = type, duration = duration, title = label, message = msg, sound = false})
end

function GlobalBlipAlert(territoryName)
    local blip = AddBlipForRadius(Config.Territories[territoryName].capture.location, Config.Territories[territoryName].radius)
    print(Config.Territories[territoryName].capture.location)
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

