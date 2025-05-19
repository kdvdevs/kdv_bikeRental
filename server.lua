ESX = exports['es_extended']:getSharedObject()

local function _T(key, ...)
    local lang = Config.Language or "vi"
    local text = Config.Texts[lang][key] or ""
    if select("#", ...) > 0 then
        return string.format(text, ...)
    end
    return text
end

local playerRentals = {}

RegisterServerEvent('bikeRental:rentBike')
AddEventHandler('bikeRental:rentBike', function(bikeIndex)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local bike = Config.BikeOptions[bikeIndex]

    if not playerRentals[_source] then
        playerRentals[_source] = 0
    end

    if xPlayer.getMoney() >= bike.price then
        xPlayer.removeMoney(bike.price)
        playerRentals[_source] = playerRentals[_source] + 1
        TriggerClientEvent('bikeRental:spawnBike', _source, bike.model)
        TriggerClientEvent('bikeRental:notify', _source, "success", _T("rent_success", bike.label, bike.price))
    else
        TriggerClientEvent('bikeRental:notify', _source, "error", _T("rent_fail"))
    end
end)

ESX.RegisterServerCallback('bikeRental:getRentalCount', function(source, cb)
    cb(playerRentals[source] or 0)
end)

RegisterNetEvent('bikeRental:refund')
AddEventHandler('bikeRental:refund', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addMoney(amount)
        TriggerClientEvent('bikeRental:notify', source, "success", _T("refund", amount))
    end
end)