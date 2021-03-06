local identifierTypes = { 'license', 'steam', 'license2', 'xbl', 'live', 'discord', 'fivem', 'ip' }

local function GetPlayerIdentifiersAsKeyValueTable(source)
    source = ESXR.Ensure(source, 0)

    local playerIdentifiers = {
        steam = nil,
        license = nil,
        license2 = nil,
        xbl = nil,
        live = nil,
        discord = nil,
        fivem = nil,
        ip = nil
    }

    for i = 0, ESXR.Ensure(GetNumPlayerIdentifiers(source), 0) - 1 do
        local playerIdentifier = ESXR.Ensure(GetPlayerIdentifier(source, i), 'none')

        for k, v in pairs(identifierTypes) do
            if (ESXR.StartsWith(playerIdentifier, ('%s:'):format(v))) then
                playerIdentifiers[v] = playerIdentifier:sub(#v + 2)
            end
        end
    end

    return playerIdentifiers
end

local function GetPrimaryIdentifier(source)
    source = ESXR.Ensure(source, -1)

    if (source < 0) then return nil end
    if (source == 0) then return 'console' end

    if (ESXR.References.SourceToIdentifier[source] ~= nil) then
        return ESXR.References.SourceToIdentifier[source]
    end

    local primaryIdentifier = ESXR.GetIdentifierType()

    for i = 0, ESXR.Ensure(GetNumPlayerIdentifiers(source), 0) - 1 do
        local playerIdentifier = ESXR.Ensure(GetPlayerIdentifier(source, i), 'none')

        if (ESXR.StartsWith(playerIdentifier, ('%s:'):format(primaryIdentifier))) then
            local identifier = playerIdentifier:sub(#primaryIdentifier + 2)

            ESXR.References.SourceToIdentifier[source] = identifier

            return identifier
        end
    end

    return nil
end

local function GetPlayerTokens(source)
    source = ESXR.Ensure(source, 0)

    local tokens = {}

    for i = 0, ESXR.Ensure(GetNumPlayerTokens(source), 0) - 1 do
        local playerToken = ESXR.Ensure(GetPlayerToken(source, i), '0:unknown')
        local prefix = ESXR.Ensure(playerToken:sub(1, 1), 0)
        local suffix = ESXR.Ensure(playerToken:sub(3), 'unknown')

        if (suffix ~= 'unknown') then
            if (tokens[prefix] == nil) then tokens[prefix] = {} end

            table.insert(tokens[prefix], suffix)
        end
    end

    return tokens
end

_G.GetPlayerIdentifiersAsKeyValueTable = GetPlayerIdentifiersAsKeyValueTable
_G.GetPlayerTokens = GetPlayerTokens
_G.GetPrimaryIdentifier = GetPrimaryIdentifier