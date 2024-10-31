

local ESX = exports['es_extended']:getSharedObject()
local claimPos, closestTerritory, halfwayAlert, captureBlip = nil, nil, false, nil
local CircleZone = CircleZone
local territoryZone = nil
local playerCounts = {} 
local blipTable = {}
local insideTerritory = false


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
AddEventHandler('eth-territories:Capture', function(data)
    local territoryCfg = Config.Territories[closestTerritory]
    local captureDuration = territoryCfg.capture.captureTime * 60000

    CreateThread(function()
        while captureDuration > 0 do
            Wait(1000)

            captureDuration = captureDuration - 1000  -- Decrement by 1 second

            local secondsRemaining = math.floor(captureDuration / 1000)
            lib.showTextUI('Capturing... ' .. secondsRemaining .. ' seconds remaining', {
                position = "left-center",
                icon = 'fa-regular fa-clock',
                style = {
                    borderRadius = 5,
                    backgroundColor = '#212121',
                    color = 'white'
                }
            })
        end
        lib.hideTextUI()
    end)
end)

function GetBlipFromZone(zone)
    return blipTable[zone] 
end

function CreateMapBlips()
    Citizen.CreateThread(function()
        for k, v in pairs(Config.Territories) do
            local dbTerritory = lib.callback.await('eth-territories:getTerritories', false)
            local gang = dbTerritory[k].gang
            local radiusBlip = AddBlipForRadius(v.capture.location, v.radius or 100.0)

            -- Create a blip for the territory
            local blip = AddBlipForCoord(v.capture.location.x, v.capture.location.y, v.capture.location.z)
            SetBlipSprite(blip, 303)
            SetBlipScale(blip, 0.6)
            SetBlipAsShortRange(blip, true)
            SetBlipColour(blip, 1)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v['label'])
            EndTextCommandSetBlipName(blip)

            -- Set the blip color based on gang ownership
            print(GetGangBlipColor(gang))
            if gang then
                SetBlipColour(radiusBlip, GetGangBlipColor(gang))
            else
                SetBlipColour(radiusBlip, 0)
            end

            SetBlipAlpha(radiusBlip, 128)

            -- Create the territory zone with `lib.zones.sphere`
            local isInsideZone = false
            local territoryZone = lib.zones.sphere({
                coords = v.capture.location,
                radius = v.radius or 100.0,
                debug = false,
                inside = function()
                    if not isInsideZone then
                        isInsideZone = true
                        lib.showTextUI("[E] Capture " .. v.label .. " Territory", { position = 'right-center' })
                        playerCounts = 1
                        closestTerritory = k
                        TriggerServerEvent('eth-territories:UpdatePlayerCount', {
                            zone = k,
                            counts = playerCounts
                        })

                        -- Listen for "E" key press to capture the territory
                        Citizen.CreateThread(function()
                            while isInsideZone do
                                Citizen.Wait(0) -- Short wait for responsiveness
                                if IsControlJustPressed(0, 38) then -- 38 is the key code for "E"
                                    TriggerServerEvent('eth-territories:CaptureStart' , k)
                                    lib.hideTextUI()
                                    break
                                end
                            end
                        end)
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



RegisterNetEvent('eth-territories:GlobalBlipAlert')
AddEventHandler('eth-territories:GlobalBlipAlert', GlobalBlipAlert)


-- local captureLimit = 0

-- CreateThread(function()
-- 	while true do
-- 		local sleep = 500
-- 		local ped = PlayerPedId()
-- 		local coords = GetEntityCoords(ped)
-- 		for k, v in pairs(Config.Territories) do
-- 			local dist = #(coords - v['capture']['location'])
-- 			if dist <= 1.0 then
-- 					sleep = 0
-- 					ESX.DrawText3D(v['capture']['location'].x, v['capture']['location'].y, v['capture']['location'].z, '[~b~E~w~] ' ..'Capture '..v.label)
-- 					if IsControlJustReleased(0, 38) then
-- 						if (GetGameTimer() - captureLimit) < 3000 then 
-- 							exports['es_extended']:Notify('error', 5000, 'You must wait '..(3 - math.floor((GetGameTimer() - captureLimit) / 1000))..' seconds', 'RATE LIMIT')
-- 						else
--                             if (not IsPedArmed(PlayerPedId(), 4)) then
--                                 exports['es_extended']:Notify('error', 5000, 'You must have a firearm to begin the capture.')
--                             else
--                                 TriggerServerEvent('eth-territories:CaptureStart' , closestTerritory)
--                             end

-- 						end
-- 						captureLimit = GetGameTimer()
-- 					end
-- 			elseif dist <= 5.0 then
-- 				sleep = 0
-- 				ESX.DrawMarker(v['capture']['location'], 255, 255, 255, 150)
-- 			end 
-- 		end
-- 		Wait(sleep)
-- 	end
-- end)




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
    -- Get player information
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

