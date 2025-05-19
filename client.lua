ESX = exports['es_extended']:getSharedObject()

local bikeRented = false
local rentedBike = nil
local bikeBlip = nil
local rentedBikeIndex = nil

local function _T(key, ...)
    local lang = Config.Language or "vi"
    local text = Config.Texts[lang][key] or ""
    if select("#", ...) > 0 then
        return string.format(text, ...)
    end
    return text
end

Citizen.CreateThread(function()
    for _, location in pairs(Config.RentalLocations) do
        local blip = AddBlipForCoord(location.x, location.y, location.z)
        SetBlipSprite(blip, Config.BlipSettings.rentalSprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.BlipSettings.scale)
        SetBlipColour(blip, Config.BlipSettings.rentalColor)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(_T("rental_point_blip"))
        EndTextCommandSetBlipName(blip)
    end

    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _, location in pairs(Config.RentalLocations) do
            DrawMarker(38, location.x, location.y, location.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, nil, nil, false)

            if GetDistanceBetweenCoords(playerCoords, location.x, location.y, location.z, true) < 1.5 then
                if not bikeRented then
                    drawText3D(location.x, location.y, location.z + 0.5, _T("rent_bike"))
                    if IsControlJustReleased(1, 51) then
                        if IsPedInAnyVehicle(playerPed, false) then
                            TriggerEvent('bikeRental:notify', "error", _T("cannot_rent_while_in_vehicle"))
                        else
                            OpenBikeMenu()
                        end
                    end
                else
                    drawText3D(location.x, location.y, location.z + 0.5, _T("already_rented"))
                end
            end
        end

        if bikeRented then
            for _, station in pairs(Config.ReturnStations) do
                DrawMarker(38, station.x, station.y, station.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 0, 0, 100, false, true, 2, nil, nil, false)

                if GetDistanceBetweenCoords(playerCoords, station.x, station.y, station.z, true) < 1.5 then
                    drawText3D(station.x, station.y, station.z + 0.5, _T("return_bike"))
                    if IsControlJustReleased(1, 51) then
                        ReturnBike()
                    end
                end
            end
        end
    end
end)

function OpenBikeMenu()
    local elements = {}
    for i, bike in ipairs(Config.BikeOptions) do
        table.insert(elements, { label = bike.label .. " - $" .. bike.price, value = i })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bike_rental', {
        title    = _T("bike_rental_title"),
        align    = 'bottom-right',
        elements = elements
    }, function(data, menu)
        local bikeIndex = data.current.value
        rentedBikeIndex = bikeIndex
        TriggerServerEvent('bikeRental:rentBike', bikeIndex)
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

function drawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local scale = 0.35

    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 100)
    end
end

RegisterNetEvent('bikeRental:notify')
AddEventHandler('bikeRental:notify', function(type, message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, true)
end)

RegisterNetEvent('bikeRental:spawnBike')
AddEventHandler('bikeRental:spawnBike', function(bikeModel)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local model = GetHashKey(bikeModel)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end

    rentedBike = CreateVehicle(model, coords.x, coords.y, coords.z, GetEntityHeading(playerPed), true, false)
    TaskWarpPedIntoVehicle(playerPed, rentedBike, -1)
    bikeRented = true
    bikeBlip = AddBlipForEntity(rentedBike)
    SetBlipSprite(bikeBlip, 226)
    SetBlipColour(bikeBlip, 3)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(_T("rented_bike_blip"))
    EndTextCommandSetBlipName(bikeBlip)

    if Config.EnableRentalTimer then
        StartRentalCountdown()
    end
end)

function StartRentalCountdown()
    local endTime = GetGameTimer() + Config.RentalTime * 1000

    Citizen.CreateThread(function()
        while GetGameTimer() < endTime and bikeRented do
            Citizen.Wait(0)
            local remainingTime = math.floor((endTime - GetGameTimer()) / 1000)
            DrawTextOnScreen(_T("time_left", remainingTime), 0.5, 0.05)
        end

        if DoesEntityExist(rentedBike) then
            DeleteVehicle(rentedBike)
            RemoveBlip(bikeBlip)
            TriggerEvent('bikeRental:notify', "warning", _T("bike_rental_expired"))
        end

        bikeRented = false
        rentedBike = nil
        bikeBlip = nil
    end)
end

function ReturnBike()
    if DoesEntityExist(rentedBike) and rentedBikeIndex then
        DeleteVehicle(rentedBike)
        RemoveBlip(bikeBlip)
        TriggerEvent('bikeRental:notify', "success", _T("bike_rental_success"))
        if Config.EnableRefundOnReturn then
            local refundAmount = Config.BikeOptions[rentedBikeIndex].price * Config.RefundPercent
            TriggerServerEvent('bikeRental:refund', refundAmount)
        end
    end

    bikeRented = false
    rentedBike = nil
    bikeBlip = nil
    rentedBikeIndex = nil
end

function DrawTextOnScreen(text, x, y)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.5, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentString(text)
    EndTextCommandDisplayText(x, y)
end