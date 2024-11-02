

local ESX = exports['es_extended']:getSharedObject()
local closestTerritory = nil
local playerCounts = {} 
local blipTable = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler("esx:playerLoaded", function(xPlayer)
    while (ESX == nil) do Citizen.Wait(100) end
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true

end)

Citizen.CreateThread(function()
    CreateMapBlips()
end)

RegisterNetEvent('esx:setGang')
AddEventHandler('esx:setGang', function(gang, gang_rank)
	ESX.PlayerData.gang = gang
    ESX.PlayerData.gang_rank = gang_rank
end)

RegisterNetEvent('eth-territories:Capture')
AddEventHandler('eth-territories:Capture', function(territory)
    local territoryCfg = Config.Territories[territory]
    local captureDuration = territoryCfg.capture.captureTime * 60000
    local territoryName = territoryCfg.label or "Unknown Territory"

    CreateThread(function()
        while captureDuration > 0 do
            Wait(1000)
            captureDuration = captureDuration - 1000
        end
    end)

    CreateThread(function()
        while captureDuration > 0 do
            Wait(0) -- Keep drawing every frame
            local secondsRemaining = math.floor(captureDuration / 1000)
            DrawTopScreenText('~b~' .. territoryName .. ': ~r~' .. secondsRemaining .. '~w~ seconds remaining before capture')
        end
    end)
end)


function DrawTopScreenText(text)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.5, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.5, 0.05) 
end


function GetBlipFromZone(zone)
    return blipTable[zone] 
end

function CreateMapBlips()
    Citizen.CreateThread(function()
        for k, v in pairs(Config.Territories) do
            local dbTerritory = lib.callback.await('eth-territories:getTerritories', false)
            local gang = dbTerritory[k].gang
            local radiusBlip = AddBlipForRadius(v.capture.location, v.radius or 100.0)

            local blip = AddBlipForCoord(v.capture.location.x, v.capture.location.y, v.capture.location.z)
            SetBlipSprite(blip, 303)
            SetBlipScale(blip, 0.6)
            SetBlipAsShortRange(blip, true)
            SetBlipColour(blip, 1)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v['label'])
            EndTextCommandSetBlipName(blip)
            
            if gang then
                SetBlipColour(radiusBlip, GetGangBlipColor(gang))
            else
                SetBlipColour(radiusBlip, 0)
            end

            SetBlipAlpha(radiusBlip, 128)

            local isInsideZone = false

            local function kickOutOfVehicle()
                local playerPed = PlayerPedId()
                local playerVehicle = GetVehiclePedIsIn(playerPed, false)
                
                -- If the player is in a vehicle, kick them out
                if playerVehicle and playerVehicle ~= 0 then
                    TaskLeaveVehicle(playerPed, playerVehicle, 0)
                end
            end

            local territoryZone = lib.zones.sphere({
                coords = v.capture.location,
                radius = v.radius or 100.0,
                debug = Config.DebugSphereZone,
                inside = function()

                    if Config.BlockVehicleInTerritory then
                        local playerPed = PlayerPedId()
                        if IsPedInAnyVehicle(playerPed, false) then
                            kickOutOfVehicle()
                            return
                        end
                    end
                    
                    if not isInsideZone then
                        isInsideZone = true
                        lib.showTextUI(v.label .. " Territory", { position = 'right-center' })
                        playerCounts = 1
                        closestTerritory = k
                        TriggerServerEvent('eth-territories:UpdatePlayerCount', {
                            zone = k,
                            counts = playerCounts
                        })
                    end
                end,
                onExit = function()
                    if isInsideZone then
                        isInsideZone = false
                        lib.hideTextUI()
                        playerCounts = -1
                        closestTerritory = nil
                        TriggerServerEvent('eth-territories:UpdatePlayerCount', {
                            zone = k,
                            counts = playerCounts
                        })
                    end
                end
            })

            blipTable[k] = radiusBlip
        end
    end)
end

function GetClosestTerritory()
    return closestTerritory
end
exports('GetClosestTerritory' , GetClosestTerritory)



RegisterCommand("turds", function()
    TriggerServerEvent('eth-territories:CaptureStart' , "BURRITO")
end)


local captureLimit = 0


function DrawText3D(x, y, z, text)
    SetDrawOrigin(x, y, z, 0)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.35, 0.35)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end


function DrawMarkerAtLocation(coords, r, g, b, a)
    DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, r, g, b, a, false, false, 2, false, nil, nil, false)
end

CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        
        for k, v in pairs(Config.Territories) do
            local dist = #(coords - v['capture']['location'])
            
            if dist <= 1.0 then
                sleep = 0
                DrawText3D(v['capture']['location'].x, v['capture']['location'].y, v['capture']['location'].z, '[~b~E~w~] Capture ' .. v.label)
                
                if IsControlJustReleased(0, 38) then
                    if (GetGameTimer() - captureLimit) < 3000 then
                        Notification('RATE LIMIT', 'You must wait ' .. (3 - math.floor((GetGameTimer() - captureLimit) / 1000)) .. ' seconds', 5000, 'error')
                    else
                        if not IsPedArmed(PlayerPedId(), 4) then
                            Notification("TERRITORIES", 'You must have a firearm to begin the capture.', 5000, 'error')
                        else
                            TriggerServerEvent('eth-territories:CaptureStart', closestTerritory)
                        end
                    end
                    captureLimit = GetGameTimer()
                end
            elseif dist <= 5.0 then
                sleep = 0
                DrawMarkerAtLocation(v['capture']['location'], 255, 255, 255, 150)
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('eth-territories:GlobalBlipAlert')
AddEventHandler('eth-territories:GlobalBlipAlert', GlobalBlipAlert)

RegisterNetEvent('eth-territories:updateMap')
AddEventHandler('eth-territories:updateMap', function(territoryName,gangName)
    local dbTerritory = lib.callback.await('eth-territories:getTerritories', false)
    if dbTerritory[territoryName] then
        dbTerritory[territoryName].gang = gangName
        local blip = GetBlipFromZone(territoryName)
        if blip then
            SetBlipColour(blip, GetGangBlipColor(gangName))
        end
    end
end)



AddEventHandler('playerDropped', function(reason)
    ESX.PlayerLoaded = false
    local playerCounts = -1
    if closestTerritory then
        TriggerServerEvent('eth-territories:UpdatePlayerCountOnLogOut', {
            zone = closestTerritory,
            counts = playerCounts,
            gang = GetPlayerGang()
        })
    end
end)

AddEventHandler('esx:onPlayerDeath', function(data)
    local playerId = GetPlayerServerId(PlayerId())
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local xPlayer = ESX.PlayerData

    local playerCounts = 0
    if closestTerritory then
         playerCounts =  -1
         TriggerServerEvent('eth-territories:UpdatePlayerCount', {
             zone = closestTerritory,
             counts = playerCounts
         })
    end
end)


AddEventHandler('onResourceStop', function(resource)
    closestTerritory = nil
end)

