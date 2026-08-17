print('[distortionz_cityhall] server.lua is loading...')

local function DebugPrint(message)
    if Config.Debug then
        print(('[%s:server] %s'):format(Config.ResourceName, message))
    end
end

local function Notify(src, message, status, duration)
    TriggerClientEvent('distortionz_cityhall:client:notify', src, message, status or 'info', duration or 5000)
end

local function GetPlayer(src)
    if GetResourceState('qbx_core') == 'started' then
        local ok, player = pcall(function()
            return exports.qbx_core:GetPlayer(src)
        end)

        if ok and player then
            return player
        end
    end

    if GetResourceState('qb-core') == 'started' then
        local ok, QBCore = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)

        if ok and QBCore then
            return QBCore.Functions.GetPlayer(src)
        end
    end

    return nil
end

local function GetPlayerData(src)
    local player = GetPlayer(src)

    if not player then return nil end

    if player.PlayerData then
        return player.PlayerData
    end

    return player
end

local function GetCitizenId(src)
    local data = GetPlayerData(src)

    if not data then
        return ('source:%s'):format(src)
    end

    return data.citizenid or data.citizenId or ('source:%s'):format(src)
end

local function GetCharName(src)
    local data = GetPlayerData(src)

    if not data then
        return 'Unknown Citizen'
    end

    if data.charinfo then
        local first = data.charinfo.firstname or data.charinfo.firstName or ''
        local last = data.charinfo.lastname or data.charinfo.lastName or ''

        local full = (first .. ' ' .. last):gsub('^%s*(.-)%s*$', '%1')

        if full ~= '' then
            return full
        end
    end

    return GetPlayerName(src) or 'Unknown Citizen'
end

local function GetCurrentJob(src)
    local data = GetPlayerData(src)

    if not data or not data.job then
        return {
            name = 'unemployed',
            label = 'Unemployed',
            grade = 0,
            gradeLabel = 'Civilian'
        }
    end

    local grade = 0
    local gradeLabel = 'Employee'

    if type(data.job.grade) == 'table' then
        grade = data.job.grade.level or data.job.grade.grade or 0
        gradeLabel = data.job.grade.name or data.job.grade.label or gradeLabel
    else
        grade = data.job.grade or 0
    end

    return {
        name = data.job.name or 'unemployed',
        label = data.job.label or data.job.name or 'Unemployed',
        grade = grade,
        gradeLabel = gradeLabel
    }
end

local function GetMetadata(src)
    local data = GetPlayerData(src)

    if not data then
        return {}
    end

    return data.metadata or data.metaData or {}
end

local function GetLicenses(src)
    local metadata = GetMetadata(src)
    return metadata.licences or metadata.licenses or {}
end

local function GetPermits(src)
    local metadata = GetMetadata(src)
    return metadata.permits or metadata.distortionz_permits or {}
end

local function SetMetadataValue(src, key, value)
    local player = GetPlayer(src)

    if not player then return false end

    if player.Functions and player.Functions.SetMetaData then
        player.Functions.SetMetaData(key, value)
        return true
    end

    if player.SetMetaData then
        player.SetMetaData(key, value)
        return true
    end

    return false
end

local function GetMoney(src, account)
    local player = GetPlayer(src)

    if not player then return 0 end

    local data = GetPlayerData(src)

    if data and data.money and data.money[account] ~= nil then
        return tonumber(data.money[account]) or 0
    end

    if player.Functions and player.Functions.GetMoney then
        local ok, amount = pcall(function()
            return player.Functions.GetMoney(account)
        end)

        if ok then
            return tonumber(amount) or 0
        end
    end

    return 0
end

local function RemoveMoney(src, account, amount, reason)
    amount = math.floor(tonumber(amount) or 0)

    if amount <= 0 then
        return true, account or Config.Money.account or 'cash'
    end

    local player = GetPlayer(src)

    if not player then
        return false, account or Config.Money.account or 'cash'
    end

    local primaryAccount = account or Config.Money.account or 'cash'
    local fallbackAccount = Config.Money.fallbackAccount or 'bank'

    local accountToUse = primaryAccount
    local primaryBalance = GetMoney(src, primaryAccount)

    if primaryBalance < amount and Config.Money.allowBankFallback and fallbackAccount ~= primaryAccount then
        local fallbackBalance = GetMoney(src, fallbackAccount)

        if fallbackBalance >= amount then
            accountToUse = fallbackAccount
        end
    end

    if GetMoney(src, accountToUse) < amount then
        return false, accountToUse
    end

    if GetResourceState('qbx_core') == 'started' then
        local ok, result = pcall(function()
            if player.Functions and player.Functions.RemoveMoney then
                return player.Functions.RemoveMoney(accountToUse, amount, reason or 'distortionz-cityhall')
            end

            return exports.qbx_core:RemoveMoney(src, accountToUse, amount, reason or 'distortionz-cityhall')
        end)

        if ok then
            return result ~= false, accountToUse
        end
    end

    if GetResourceState('qb-core') == 'started' then
        if player.Functions and player.Functions.RemoveMoney then
            local ok, result = pcall(function()
                return player.Functions.RemoveMoney(accountToUse, amount, reason or 'distortionz-cityhall')
            end)

            if ok then
                return result ~= false, accountToUse
            end
        end
    end

    return false, accountToUse
end

local function AddItem(src, item, amount, metadata)
    amount = math.floor(tonumber(amount) or 1)

    if not item or item == '' or amount <= 0 then
        return true
    end

    if GetResourceState('ox_inventory') ~= 'started' then
        print(('[%s] ox_inventory is not started. Cannot give item: %s'):format(Config.ResourceName, item))
        return false
    end

    local ok, added = pcall(function()
        return exports.ox_inventory:AddItem(src, item, amount, metadata)
    end)

    if not ok then
        print(('[%s] Failed to add item %s to source %s'):format(Config.ResourceName, item, src))
        return false
    end

    return added ~= false
end

local function BuildLicenseItemMetadata(src, service)
    local citizenId = GetCitizenId(src)
    local name = GetCharName(src)

    return {
        citizenid = citizenId,
        owner = name,
        name = name,
        type = service.label,
        issued = os.date('%Y-%m-%d'),
        description = service.label .. ' issued to ' .. name
    }
end

local function FindIdentityService(serviceId)
    for _, service in ipairs(Config.Identity or {}) do
        if service.id == serviceId and service.enabled then
            return service
        end
    end

    return nil
end

local function FindPermitService(serviceId)
    for _, service in ipairs(Config.Permits or {}) do
        if service.id == serviceId and service.enabled then
            return service
        end
    end

    return nil
end

local function BuildIdentityStatus(src)
    local licenses = GetLicenses(src)
    local result = {}

    for _, service in ipairs(Config.Identity or {}) do
        local active = false

        if service.metadataKey then
            active = licenses[service.metadataKey] == true
                or licenses[service.id] == true
        end

        result[#result + 1] = {
            id = service.id,
            label = service.label,
            description = service.description,
            icon = service.icon,
            price = service.price,
            active = active,
            enabled = service.enabled
        }
    end

    return result
end

local function BuildPermitStatus(src)
    local permits = GetPermits(src)
    local result = {}

    for _, service in ipairs(Config.Permits or {}) do
        local active = false

        if service.metadataKey then
            active = permits[service.metadataKey] == true
                or permits[service.id] == true
        end

        result[#result + 1] = {
            id = service.id,
            label = service.label,
            description = service.description,
            icon = service.icon,
            price = service.price,
            active = active,
            enabled = service.enabled
        }
    end

    return result
end

lib.callback.register('distortionz_cityhall:server:getCityHallData', function(src)
    local player = GetPlayer(src)

    if not player then
        return {
            success = false,
            status = 'error',
            message = 'Player data unavailable.'
        }
    end

    local currentJob = GetCurrentJob(src)

    return {
        success = true,

        text = Config.Text,

        meta = {
            version = Config.CurrentVersion,
            repo = Config.Repo
        },

        citizen = {
            name = GetCharName(src),
            citizenId = GetCitizenId(src),
            currentJob = currentJob,
            source = src
        },

        identity = BuildIdentityStatus(src),
        permits = BuildPermitStatus(src),

        records = Config.Records,

        money = {
            account = Config.Money.account,
            allowBankFallback = Config.Money.allowBankFallback,
            fallbackAccount = Config.Money.fallbackAccount
        }
    }
end)

lib.callback.register('distortionz_cityhall:server:purchaseService', function(src, data)
    if not data or not data.serviceId or not data.serviceType then
        return {
            success = false,
            status = 'error',
            message = 'Invalid service request.'
        }
    end

    local serviceType = tostring(data.serviceType)
    local serviceId = tostring(data.serviceId)

    local service = nil

    if serviceType == 'identity' then
        service = FindIdentityService(serviceId)
    elseif serviceType == 'permit' then
        service = FindPermitService(serviceId)
    end

    if not service then
        return {
            success = false,
            status = 'error',
            message = 'Service unavailable.'
        }
    end

    local account = Config.Money.account or 'cash'
    local price = tonumber(service.price) or 0

    local paid, paidAccount = RemoveMoney(src, account, price, ('distortionz-cityhall-%s'):format(serviceId))

    if not paid then
        return {
            success = false,
            status = 'error',
            message = ('You need $%s cash or bank funds for this service.'):format(price)
        }
    end

    if serviceType == 'identity' then
        local licenses = GetLicenses(src)
        licenses[service.metadataKey or service.id] = true
        licenses[service.id] = true

        SetMetadataValue(src, 'licences', licenses)
        SetMetadataValue(src, 'licenses', licenses)

        if service.giveItem and service.item and service.item ~= '' then
            local metadata = BuildLicenseItemMetadata(src, service)

            if not AddItem(src, service.item, 1, metadata) then
                return {
                    success = false,
                    status = 'error',
                    message = ('%s was approved, but the item could not be issued. Check ox_inventory item name.'):format(service.label)
                }
            end
        end
    elseif serviceType == 'permit' then
        local permits = GetPermits(src)
        permits[service.metadataKey or service.id] = true
        permits[service.id] = true

        SetMetadataValue(src, 'permits', permits)
        SetMetadataValue(src, 'distortionz_permits', permits)

        if service.giveItem and service.item and service.item ~= '' then
            local metadata = BuildLicenseItemMetadata(src, service)

            if not AddItem(src, service.item, 1, metadata) then
                return {
                    success = false,
                    status = 'error',
                    message = ('%s was approved, but the item could not be issued. Check ox_inventory item name.'):format(service.label)
                }
            end
        end
    end

    DebugPrint(('Source %s purchased %s:%s using %s'):format(src, serviceType, serviceId, paidAccount))

    return {
        success = true,
        status = 'success',
        message = ('%s issued successfully. Paid with %s.'):format(service.label, paidAccount)
    }
end)

CreateThread(function()
    Wait(1000)
    print(('^5[%s]^7 ^2v%s loaded — identity=%d permits=%d^7'):format(
        Config.ResourceName,
        Config.CurrentVersion,
        #Config.Identity,
        #Config.Permits
    ))
end)