LS_CORE = { }
LS_CORE.Config = LS_CORE_CONFIG
LS_CORE.PLAYER_DATA = {}

LS_CORE.Functions = {}

RegisterNetEvent('LS_CORE:PLAYER:SETPLAYERDATA', function(val)
    LS_CORE.PLAYER_DATA = val
end)

LS_CORE.Functions.GetPlayerData = function()
    return LS_CORE.PLAYER_DATA
end

exports('GetCoreObject', function()
    return LS_CORE
end)