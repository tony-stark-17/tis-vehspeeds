--[[
    tis-vehspeeds
    Copyright (C) 2022 IllusionSquid

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]
local ESX = exports['es_extended']:getSharedObject()
local Encryptions = {}
local charset = {}  do -- [0-9a-zA-Z]
    for c = 48, 57  do table.insert(charset, string.char(c)) end
    for c = 65, 90  do table.insert(charset, string.char(c)) end
    for c = 97, 122 do table.insert(charset, string.char(c)) end
end

local function randomString(length)
    if not length or length <= 0 then return '' end
    math.randomseed(os.clock())
    return randomString(length - 1) .. charset[math.random(1, #charset)]
end

ESX.RegisterCommand({'speedtest'}, 'admin', function(xPlayer, args, showError)
  if not args.vehicle then
      TriggerClientEvent('esx:showNotification', source, "Please pass arguments", "error")
      return
  end

  Encryptions[source] = randomString(16)
  TriggerClientEvent("tis-vehspeeds:client:DoSpeedTest", source, Encryptions[source], args.vehicle)
end, false, {help = 'Vehicle Speed Test', arguments = {{name = 'vehicle', help = 'Vehicle Model', type = 'any'}}})
        
ESX.RegisterCommand({'speedtestlist'}, 'admin', function(xPlayer, args, showError)
  Encryptions[source] = randomString(16)
  TriggerClientEvent("tis-vehspeeds:client:DoSpeedTestList", source, Encryptions[source])
end, false, {help = 'Do speed test on the list in config.lua'})

ESX.RegisterCommand({'speedtarget'}, 'admin', function(xPlayer, args, showError)
  if not args.model or not args.target then
     TriggerClientEvent('esx:showNotification', source, "Please pass arguments", "error")
      return
  end

    Encryptions[source] = randomString(16)
    TriggerClientEvent("tis-vehspeeds:client:DoSpeedTarget", source, Encryptions[source], args.model, args.target)
end, false, {help = '"Train" model for target speed', arguments = {{name = 'model', help = 'the model to speedtest', type = 'any'}, {name = "target", help = "Target 0-60mph (Float e.g.: 5.7)", type = 'number'}}})

RegisterServerEvent("tis-vehspeeds:server:SaveVehicleSpecs")
AddEventHandler("tis-vehspeeds:server:SaveVehicleSpecs", function (encrypt, data)
    if Encryptions[source] ~= encrypt then
        DropPlayer(source, "Kindly stop trying a cheap hack - Squid")
    end

    MySQL.Async.insert('INSERT INTO vehicle_specs (model_hash, model_name, model_class, version, zero_sixty, zero_hundered, quarter_mile, quarter_mile_speed, half_mile, half_mile_speed, mile, mile_speed, max_speed) VALUES (:model_hash, :model_name, :model_class, :version, :zero_sixty, :zero_hundered, :quarter_mile, :quarter_mile_speed, :half_mile, :half_mile_speed, :mile, :mile_speed, :max_speed) ON DUPLICATE KEY UPDATE model_name = :model_name, model_class = :model_class, version = :version, zero_sixty = :zero_sixty, zero_hundered = :zero_hundered, quarter_mile = :quarter_mile, quarter_mile_speed = :quarter_mile_speed, half_mile = :half_mile, half_mile_speed = :half_mile_speed, mile = :mile, mile_speed = :mile_speed, max_speed = :max_speed', {
        model_hash = data.model,
        model_name = data.model_name,
        model_class = data.model_class,
        version = Config.Version,
        zero_sixty = data.zero_sixty,
        zero_hundered = data.zero_hundered,
        quarter_mile = data.quarter_mile,
        quarter_mile_speed = data.quarter_mile_speed,
        half_mile = data.half_mile,
        half_mile_speed = data.half_mile_speed,
        mile = data.mile,
        mile_speed = data.mile_speed,
        max_speed = data.max_speed
    })
end)
