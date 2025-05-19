Config = {}

Config.RentalLocations = {
    vector4(-239.2149, -989.0035, 29.28831, 254.0296),
    vector4(239.6978, -862.4493, 29.74767, 163.2569)
}

Config.ReturnStations = {
    vector4(-237.935, -985.5645, 29.28832, 245.8022),
    vector4(236.4369, -862.2419, 29.82195, 138.4417)
}

Config.BlipSettings = {
    rentalSprite = 226,
    returnSprite = 357,
    rentalColor = 3,
    returnColor = 2,
    scale = 0.8,
    text = "Thuê xe đạp"
}

Config.BikeOptions = {
    { model = 'bmx', price = 100, label = "Xe BMX" },
    { model = 'scorcher', price = 150, label = "Xe đạp leo núi" },
    { model = 'faggio', price = 200, label = "Xe tay ga" }
}

Config.EnableRentalTimer = false -- Set to false if you don't want to use the rental countdown timer
Config.RentalTime = 600 -- 10 minutes

Config.EnableRefundOnReturn = true -- Set to false if you don't want to refund when returning the bike
Config.RefundPercent = 0.5 -- 0.5 = 50%, 1 = 100%

Config.Language = "vi" -- "vi" or "en" or any other language

Config.Texts = {
    vi = {
        ['rent_bike'] = "[~g~E~s~] Thuê xe đạp",
        ['already_rented'] = "Bạn đã thuê một chiếc xe đạp.",
        ['return_bike'] = "[~g~E~s~] Trả xe đạp",
        ['bike_rental_title'] = "Thuê xe đạp",
        ['bike_rental_success'] = "Xe đã được trả thành công!",
        ['bike_rental_expired'] = "Thời gian thuê xe của bạn đã hết!",
        ['time_left'] = "Thời gian còn lại: %s giây",
        ['rented_bike_blip'] = "Xe đạp đã thuê",
        ['rental_point_blip'] = "Điểm thuê xe đạp",
        ['rent_success'] = "Bạn đã thuê một chiếc %s với giá $%s",
        ['rent_fail'] = "Bạn không đủ tiền để thuê xe",
        ['refund'] = "Bạn đã được trả lại $%s tiền cọc",
        ['cannot_rent_while_in_vehicle'] = "Bạn không thể thuê xe khi đang ngồi trên xe."
    },
    en = {
        ['rent_bike'] = "[~g~E~s~] Rent a bike",
        ['already_rented'] = "You have already rented a bike.",
        ['return_bike'] = "[~g~E~s~] Return bike",
        ['bike_rental_title'] = "Bike Rental",
        ['bike_rental_success'] = "Bike returned successfully!",
        ['bike_rental_expired'] = "Your bike rental time has expired!",
        ['time_left'] = "Time left: %s seconds",
        ['rented_bike_blip'] = "Rented Bike",
        ['rental_point_blip'] = "Bike Rental Point",
        ['rent_success'] = "You have rented a %s for $%s",
        ['rent_fail'] = "You do not have enough money to rent a bike",
        ['refund'] = "You have been refunded $%s",
        ['cannot_rent_while_in_vehicle'] = "You cannot rent a bike while in a vehicle."
    }
}