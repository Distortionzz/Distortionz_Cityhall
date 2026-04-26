local cityhallPed = nil
local cityhallBlip = nil
local nuiOpen = false

local function DebugPrint(message)
    if Config.Debug then
        print(('[%s:client] %s'):format(Config.ResourceName, message))
    end
end

local function Notify(message, status, duration)
    status = status or 'info'
    duration = duration or 5000

    if Config.Notify.useDistortionzNotify and GetResourceState('distortionz_notify') == 'started' then
        local ok = pcall(function()
            exports['distortionz_notify']:Notify(message, status, duration, Config.Notify.title)
        end)

        if ok then return end

        ok = pcall(function()
            exports['distortionz_notify']:Send(message, status, duration)
        end)

        if ok then return end

        ok = pcall(function()
            TriggerEvent('distortionz_notify:client:notify', message, status, duration)
        end)

        if ok then return end
    end

    lib.notify({
        title = Config.Notify.title,
        description = message,
        type = status,
        duration = duration
    })
end

RegisterNetEvent('distortionz_cityhall:client:notify', function(message, status, duration)
    Notify(message, status, duration)
end)

local function LoadModel(model)
    local hash = type(model) == 'number' and model or joaat(model)

    if not IsModelInCdimage(hash) then
        DebugPrint(('Invalid ped model: %s'):format(tostring(model)))
        return nil
    end

    RequestModel(hash)

    local timeout = GetGameTimer() + 10000

    while not HasModelLoaded(hash) do
        Wait(25)

        if GetGameTimer() > timeout then
            DebugPrint(('Model load timeout: %s'):format(tostring(model)))
            return nil
        end
    end

    return hash
end

local function DeleteEntitySafe(entity)
    if entity and DoesEntityExist(entity) then
        SetEntityAsMissionEntity(entity, true, true)
        DeleteEntity(entity)
    end
end

local function RemoveBlipSafe(blip)
    if blip and DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
end

local function MarkProtectedPed(ped)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return end

    Entity(ped).state:set('distortionz_protected_ped', true, true)
    Entity(ped).state:set('distortionz_contact_ped', true, true)
    Entity(ped).state:set('distortionz_cityhall_ped', true, true)
end

local function CloseCityHall()
    nuiOpen = false
    SetNuiFocus(false, false)

    SendNUIMessage({
        action = 'close'
    })
end

local function OpenCityHall()
    if nuiOpen then return end

    local data = lib.callback.await('distortionz_cityhall:server:getCityHallData', false)

    if not data then
        Notify('City Hall services are unavailable.', 'error')
        return
    end

    if not data.success then
        Notify(data.message or 'Unable to open City Hall.', data.status or 'error')
        return
    end

    nuiOpen = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'open',
        data = data
    })
end

local function CreateCityHallBlip()
    if not Config.CityHall.blip.enabled then return end

    local coords = Config.CityHall.ped.coords

    cityhallBlip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(cityhallBlip, Config.CityHall.blip.sprite)
    SetBlipDisplay(cityhallBlip, 4)
    SetBlipScale(cityhallBlip, Config.CityHall.blip.scale)
    SetBlipColour(cityhallBlip, Config.CityHall.blip.colour)
    SetBlipAsShortRange(cityhallBlip, Config.CityHall.blip.shortRange)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.CityHall.blip.label)
    EndTextCommandSetBlipName(cityhallBlip)
end

local function SpawnCityHallPed()
    if not Config.CityHall.ped.enabled then return end

    local pedConfig = Config.CityHall.ped
    local model = LoadModel(pedConfig.model)

    if not model then return end

    local coords = pedConfig.coords

    cityhallPed = CreatePed(
        0,
        model,
        coords.x,
        coords.y,
        coords.z - 1.0,
        coords.w,
        false,
        false
    )

    if not cityhallPed or cityhallPed == 0 or not DoesEntityExist(cityhallPed) then
        DebugPrint('Failed to create City Hall ped.')
        SetModelAsNoLongerNeeded(model)
        return
    end

    SetEntityAsMissionEntity(cityhallPed, true, true)
    SetBlockingOfNonTemporaryEvents(cityhallPed, true)
    SetPedCanRagdoll(cityhallPed, false)
    SetPedDiesWhenInjured(cityhallPed, false)
    SetPedCanRagdollFromPlayerImpact(cityhallPed, false)
    SetEntityInvincible(cityhallPed, true)
    FreezeEntityPosition(cityhallPed, true)

    MarkProtectedPed(cityhallPed)

    if pedConfig.scenario and pedConfig.scenario ~= '' then
        TaskStartScenarioInPlace(cityhallPed, pedConfig.scenario, 0, true)
    end

    exports.ox_target:addLocalEntity(cityhallPed, {
        {
            name = 'distortionz_cityhall_open',
            icon = Config.CityHall.target.icon,
            label = Config.CityHall.target.label,
            distance = Config.CityHall.target.distance,
            onSelect = function()
                OpenCityHall()
            end
        }
    })

    SetModelAsNoLongerNeeded(model)
end

RegisterNUICallback('close', function(_, cb)
    CloseCityHall()
    cb({ success = true })
end)

RegisterNUICallback('purchaseService', function(data, cb)
    local result = lib.callback.await('distortionz_cityhall:server:purchaseService', false, data)

    if not result then
        cb({
            success = false,
            message = 'Service request failed.'
        })
        return
    end

    cb(result)

    if result.success then
        Notify(result.message or 'Service completed.', 'success')
        OpenCityHall()
    else
        Notify(result.message or 'Service failed.', result.status or 'error')
    end
end)

RegisterNUICallback('selectJob', function(data, cb)
    local result = lib.callback.await('distortionz_cityhall:server:selectJob', false, data)

    if not result then
        cb({
            success = false,
            message = 'Employment request failed.'
        })
        return
    end

    cb(result)

    if result.success then
        Notify(result.message or 'Employment updated.', 'success')
        OpenCityHall()
    else
        Notify(result.message or 'Employment update failed.', result.status or 'error')
    end
end)

RegisterNUICallback('refreshData', function(_, cb)
    local data = lib.callback.await('distortionz_cityhall:server:getCityHallData', false)

    cb(data or {
        success = false,
        message = 'Failed to refresh City Hall data.'
    })
end)

RegisterCommand('cityhalltest', function()
    OpenCityHall()
end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    CloseCityHall()
    DeleteEntitySafe(cityhallPed)
    RemoveBlipSafe(cityhallBlip)

    pcall(function()
        if cityhallPed and DoesEntityExist(cityhallPed) then
            exports.ox_target:removeLocalEntity(cityhallPed, 'distortionz_cityhall_open')
        end
    end)
end)

CreateThread(function()
    Wait(1000)
    CreateCityHallBlip()
    SpawnCityHallPed()
end)