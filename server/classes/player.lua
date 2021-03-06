local function CreatePlayerClass(playerInfo, source)
    playerInfo = ESXR.Ensure(playerInfo, {})

    local identifierType = ESXR.GetIdentifierType()
    local pos = ESXR.Ensure(playerInfo.position, {})
    local playerId = ESXR.Ensure(playerInfo.id, 0)

    if (ESXR.Players ~= nil and ESXR.Players[playerId] ~= nil) then
        local prefValue = ESXR.Ensure(ESXR.Players[playerId].source, -1)

        ESXR.Players[playerId].source = ESXR.Ensure(source, prefValue)

        return ESXR.Players[playerId]
    end

    local xPlayer = {
        loaded = false,
        source = ESXR.Ensure(source, -1),
        id = playerId,
        identifier = ESXR.Ensure(playerInfo.identifier, 'none'),
        name = ESXR.Ensure(playerInfo.name, 'Unknown'),
        group = ESXR.Ensure(playerInfo.group, 'user'),
        job = CreateJobObject(playerInfo.job, playerInfo.grade),
        job2 = CreateJobObject(playerInfo.job2, playerInfo.grade2),
        position = vector3(
            ESXR.Ensure(pos[1], Configuration.DefaultSpawn.x),
            ESXR.Ensure(pos[2], Configuration.DefaultSpawn.y),
            ESXR.Ensure(pos[3], Configuration.DefaultSpawn.z)
        ),
        wallets = {},
        inventory = {},
        variables = {},
        identifiers = {},
        tokens = {},
    }

    if (playerId <= 0) then
        error('xPlayer must have an valid `id` and must exsist in `players` table')
        return
    end

    ExecuteCommand(('add_principal identifier.%s:%s group.%s'):format(identifierType, xPlayer.identifier, xPlayer.group))

    function xPlayer:IsOnline()
        local src = ESXR.Ensure(self.source, 0)

        return src > 0
    end

    function xPlayer:IsConnected()
        local src = ESXR.Ensure(self.source, 0)

        return src > 0 and src < 65535
    end

    function xPlayer:IsLoaded()
        return ESXR.Ensure(self.loaded, false)
    end

    function xPlayer:TriggerEvent(name, ...)
        name = ESXR.Ensure(name, 'unknown')

        if (self:IsConnected()) then
            TriggerClientEvent(name, self.source, ...)
        end

        return self
    end

    function xPlayer:Kick(reason)
        reason = ESXR.Ensure(reason, _('no_reason_specified'))

        if (self:IsConnected()) then
            DropPlayer(self.source, reason)
        end

        return self
    end

    function xPlayer:GetIdentifier()
        return ESXR.Ensure(self.identifier, 'none')
    end

    function xPlayer:GetGroup()
        return ESXR.Ensure(self.group, 'user')
    end

    function xPlayer:SetGroup(group)
        ExecuteCommand(('remove_principal identifier.%s:%s group.%s'):format(identifierType, self:GetIdentifier(), self:GetGroup()))

        self.group = ESXR.Ensure(group, 'user')

        ExecuteCommand(('add_principal identifier.%s:%s group.%s'):format(identifierType, self:GetIdentifier(), self:GetGroup()))

        return self
    end

    function xPlayer:Set(values)
        self.variables = ESXR.Concat(
            ESXR.Ensure(self.variables, {}),
            ESXR.Ensure(values, {}))

        return self
    end

    function xPlayer:Get(key)
        key = ESXR.Ensure(key, 'unknown')

        for k, v in pairs(ESXR.Ensure(self.variables, {})) do
            if (ESXR.Ensure(k) == key) then
                return v
            end
        end

        return nil
    end

    function xPlayer:GetMoney()
        local wallet = self:GetWallet('money')

        if (wallet) then
            return ESXR.Ensure(wallet.saldo, 0)
        end

        return 0
    end

    function xPlayer:SetMoney(money)
        money = ESXR.Ensure(money, 0)
        money = ESXR.Round(money, 0)

        return xPlayer:SetWallet('money', money)
    end

    function xPlayer:AddMoney(money)
        money = ESXR.Ensure(money, 0)
        money = ESXR.Round(money, 0)

        if (money > 0) then
            return xPlayer:AddWallet('money', money)
        end

        return self
    end

    function xPlayer:RemoveMoney(money)
        money = ESXR.Ensure(money, 0)
        money = ESXR.Round(money, 0)

        if (money > 0) then
            return xPlayer:RemoveWallet('money', money)
        end

        return self
    end

    function xPlayer:GetBank()
        local wallet = self:GetWallet('bank')

        if (wallet) then
            return ESXR.Ensure(wallet.saldo, 0)
        end

        return 0
    end

    function xPlayer:SetBank(money)
        money = ESXR.Ensure(money, 0)
        money = ESXR.Round(money, 0)

        return xPlayer:SetWallet('bank', money)
    end

    function xPlayer:AddBank(money)
        money = ESXR.Ensure(money, 0)
        money = ESXR.Round(money, 0)

        if (money > 0) then
            return xPlayer:AddWallet('bank', money)
        end

        return self
    end

    function xPlayer:RemoveBank(money)
        money = ESXR.Ensure(money, 0)
        money = ESXR.Round(money, 0)

        if (money > 0) then
            return xPlayer:RemoveWallet('bank', money)
        end

        return self
    end

    function xPlayer:GetWallet(name)
        name = ESXR.Ensure(name, 'unknown')

        return ESXR.Ensure(self.wallets, {})[name] or nil
    end

    function xPlayer:SetWallet(name, money)
        name = ESXR.Ensure(name, 'unknown')
        money = ESXR.Ensure(money, 0)
        money = ESXR.Round(money, 0)

        local wallet = self:GetWallet(name)

        if (wallet) then
            wallet.saldo = money
        end

        return self
    end

    function xPlayer:AddWallet(name, money)
        name = ESXR.Ensure(name, 'unknown')
        money = ESXR.Ensure(money, 0)
        money = ESXR.Round(money, 0)

        local wallet = self:GetWallet(name)

        if (wallet and money > 0) then
            wallet.saldo = wallet.saldo + money
        end

        return self
    end

    function xPlayer:RemoveWallet(name, money)
        name = ESXR.Ensure(name, 'unknown')
        money = ESXR.Ensure(money, 0)
        money = ESXR.Round(money, 0)

        local wallet = self:GetWallet(name)

        if (wallet and money > 0) then
            wallet.saldo = wallet.saldo - money
        end

        return self
    end

    function xPlayer:GetWallets(minimal)
        minimal = ESXR.Ensure(minimal, false)

        if (minimal) then
            local accounts = {}

            for k, v in pairs(ESXR.Ensure(self.wallets, {})) do
                local name = ESXR.Ensure(v.name, 'unknown')
                local saldo = ESXR.Ensure(v.saldo, 0)

                accounts[name] = saldo
            end

            return accounts
        end

        return ESXR.Ensure(self.wallets, {})
    end

    function xPlayer:GetWeapons(storage)
        local weapons = {}

        if (ESXR.TypeOf(storage) == 'nil') then
            for k, v in pairs(ESXR.Ensure(ESXR.Weapons, {})) do
                table.insert(weapons, ESXR.Ensure(v, {}))
            end

            return weapons
        end

        local storageName = ESXR.Ensure(storage, 'unknown')
        local storageId = ESXR.Ensure(storage, 0)

        storageId = storageId > 0 and storageId or
            ESXR.Ensure(ESXR.Ensure((ESXR.References or {}).Storages, {})[storageName], 0)

        if (storageId > 0) then
            for k, v in pairs(ESXR.Ensure(ESXR.Weapons, {})) do
                local xWeapon = ESXR.Ensure(v, {})

                if (xWeapon.storageId == storageId) then
                    table.insert(weapons, xWeapon)
                end
            end

            return weapons
        end

        return weapons
    end

    function xPlayer:HasPermission(permission)
        permission = ESXR.Ensure(permission, 'unknown')

        local group = ESXR.Ensure(self.group, 'user')
        local hasPerm = ESXR.Permissions.GroupHasPermission(group, permission)

        if (hasPerm) then return true end

        return ESXR.Ensure(IsPrincipalAceAllowed(('group.%s'):format(group), permission), false)
    end

    if (ESXR.Players == nil) then ESXR.Players = ESXR.Ensure(ESXR.Players, {}) end
    if (ESXR.References == nil) then ESXR.References = ESXR.Ensure(ESXR.References, {}) end
    if (ESXR.References.Players == nil) then ESXR.References.Players = ESXR.Ensure(ESXR.References.Players, {}) end

    ESXR.Players[playerId] = xPlayer
    ESXR.References.Players[xPlayer.identifier] = playerId

    if (xPlayer.source > 0) then
        ESXR.References.SourceToIds[xPlayer.source] = playerId
    end

    LoadPlayerDataAsync(playerId)

    return ESXR.Players[playerId]
end

local function AddMissingData(pId, callback)
    Citizen.CreateThread(function()
        pId = ESXR.Ensure(pId, 0)
        callback = ESXR.Ensure(callback, function() end)

        if (pId <= 0) then
            callback()
            return
        end

        MySQL.Sync.execute('INSERT IGNORE INTO `inventory` (`player_id`, `item_id`, `amount`) SELECT @playerId AS `player_id`, `id` AS `item_id`, 0 AS `amount` FROM `items`', {
            ['playerId'] = pId
        })

        for k, v in pairs(ESXR.Wallets) do
            MySQL.Sync.execute('INSERT IGNORE INTO `player_wallets` (`wallet_id`, `player_id`, `saldo`) VALUES (@walletId, @playerId, @saldo)', {
                ['walletId'] = ESXR.Ensure(v.id, 0),
                ['playerId'] = pId,
                ['saldo'] = ESXR.Ensure(v.default, 0)
            })
        end

        callback()
    end)
end

local function LoadPlayerDataAsync(pId)
    Citizen.CreateThread(function()
        local playerId = ESXR.Ensure(pId, 0)
        local loaded = { wallets = false, inventory = false, added = false }
        local xPlayer = ESXR.Ensure(ESXR.Ensure(ESXR.Players, {})[playerId], {})

        if (pId <= 0 or xPlayer == nil or xPlayer.loaded == true) then return end

        AddMissingData(pId, function()
            loaded.added = true
        end)

        repeat Citizen.Wait(0) until loaded.added == true

        MySQL.Async.fetchAll('SELECT * FROM `player_wallets` WHERE `player_id` = @playerId', {
            ['playerId'] = playerId
        }, function(playerWallets)
            for k, v in pairs(ESXR.Ensure(playerWallets, {})) do
                v = ESXR.Ensure(v, {})

                local walletId = ESXR.Ensure(v.wallet_id, 0)
                local wallet = ESXR.Ensure(ESXR.Ensure(ESXR.Wallets, {})[walletId], {})
                local name = ESXR.Ensure(wallet.name, 'unknown')
                local wallets = ESXR.Ensure(Configuration.Wallets, {})
                local defaultSaldo = ESXR.Ensure(wallets[name], 0)
                local xPlayerWallet = {
                    id = ESXR.Ensure(wallet.id, 0),
                    playerId = playerId,
                    name = ESXR.Ensure(wallet.name, 'unknown'),
                    label = ESXR.Ensure(wallet.label, 'Unknown'),
                    saldo = ESXR.Ensure(v.saldo, defaultSaldo)
                }

                function xPlayerWallet:Save(callback)
                    callback = ESXR.Ensure(callback, function() end)

                    MySQL.Async.execute('UPDATE `player_wallets` SET `saldo` = @saldo WHERE `wallet_id` = @wallet AND `player_id` = @player', {
                        ['saldo'] = ESXR.Ensure(self.saldo, 0),
                        ['wallet'] = ESXR.Ensure(self.id, 0),
                        ['player'] = ESXR.Ensure(self.playerId, 0)
                    }, function()
                        callback()
                    end)
                end

                if (ESXR.Players[playerId].wallets == nil) then
                    ESXR.Players[playerId].wallets = ESXR.Ensure(ESXR.Players[playerId].wallets, {})
                end

                ESXR.Players[playerId].wallets[xPlayerWallet.name] = xPlayerWallet
            end

            loaded.wallets = true
        end)

        MySQL.Async.fetchAll('SELECT * FROM `inventory` WHERE `player_id` = @playerId', {
            ['playerId'] = playerId
        }, function(playerInventory)
            for k, v in pairs(ESXR.Ensure(playerInventory, {})) do
                v = ESXR.Ensure(v, {})

                local itemId = ESXR.Ensure(v.item_id, 0)
                local item = ESXR.Ensure(ESXR.Ensure(ESXR.Items, {})[itemId], {})
                local xPlayerInventory = {
                    id = ESXR.Ensure(item.id, 0),
                    playerId = playerId,
                    name = ESXR.Ensure(item.name, 'unknown'),
                    label = ESXR.Ensure(item.label, 'unknown'),
                    weight = ESXR.Ensure(item.weight, 0.25),
                    amount = ESXR.Ensure(v.amount, 0)
                }

                function xPlayerInventory:Save(callback)
                    callback = ESXR.Ensure(callback, function() end)

                    MySQL.Async.execute('UPDATE `inventory` SET `amount` = @amount WHERE `player_id` = @playerId AND `item_id` = @itemId', {
                        ['amount'] = ESXR.Ensure(self.amount, 0),
                        ['playerId'] = ESXR.Ensure(self.playerId, 0),
                        ['itemId'] = ESXR.Ensure(self.id, 0)
                    }, function()
                        callback()
                    end)
                end

                if (ESXR.Players[playerId].inventory == nil) then
                    ESXR.Players[playerId].inventory = ESXR.Ensure(ESXR.Players[playerId].inventory, {})
                end

                ESXR.Players[playerId].inventory[xPlayerInventory.name] = xPlayerInventory
            end

            loaded.inventory = true
        end)

        repeat Citizen.Wait(0) until
            loaded.wallets == true and
            loaded.inventory == true

        ESXR.Players[playerId].loaded = true
    end)
end

local function UpdatePlayerSource(source)
    source = ESXR.Ensure(source, -1)

    local identifier = GetPrimaryIdentifier(source)

    if (identifier == nil or source <= 0) then
        return nil
    end

    if (ESXR.References.Players == nil or ESXR.References.Players[identifier] == nil) then
        local playerObjects = MySQL.Sync.fetchAll('SELECT * FROM `players` WHERE `identifier` = @identifier LIMIT 1', {
            ['identifier'] = identifier
        })
        local playerObject = ESXR.Ensure(ESXR.Ensure(playerObjects, {})[1], {})

        return CreatePlayerClass(playerObject, source)
    else
        local playerId = ESXR.Ensure(ESXR.References.Players[identifier], 0)

        if (playerId > 0) then
            ESXR.Players[playerId].source = source

            return ESXR.Players[playerId]
        else
            local playerObjects = MySQL.Sync.fetchAll('SELECT * FROM `players` WHERE `identifier` = @identifier LIMIT 1', {
                ['identifier'] = identifier
            })
            local playerObject = ESXR.Ensure(ESXR.Ensure(playerObjects, {})[1], {})

            return CreatePlayerClass(playerObject, source)
        end
    end
end

local function GetPlayerByIdentifier(identifier)
    identifier = ESXR.Ensure(identifier, 'unknown')

    if (identifier == 'unknown') then return nil end
    if (ESXR.References.Players == nil or ESXR.References.Players[identifier]) then return nil end

    local playerId = ESXR.Ensure(ESXR.References.Players[identifier], 0)

    if (playerId <= 0) then return nil end

    return ESXR.Players[playerId] or nil
end

local function GetPlayerById(playerId)
    playerId = ESXR.Ensure(playerId, 0)

    if (playerId > 0) then return nil end

    return ESXR.Players[playerId] or nil
end

local function GetPlayerBySource(source)
    source = ESXR.Ensure(source, 0)

    if (source <= 0) then return nil end

    local playerId = ESXR.Ensure(ESXR.References.SourceToIds[source], -1)

    if (playerId > 0) then
        return ESXR.Players[playerId] or nil
    end

    for k, v in pairs(ESXR.Players) do
        if (v.source == source) then
            return v
        end
    end

    return nil
end

_G.LoadPlayerDataAsync = LoadPlayerDataAsync
_G.UpdatePlayerSource = UpdatePlayerSource
_G.GetPlayerByIdentifier = GetPlayerByIdentifier
_G.GetPlayerById = GetPlayerById
_G.GetPlayerBySource = GetPlayerBySource