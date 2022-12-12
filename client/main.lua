LS_CORE = { }
LS_CORE.Config = LS_CORE_CONFIG
LS_CORE.PLAYER_DATA = {}

RegisterNetEvent('LS_CORE:PLAYER:SETPLAYERDATA', function(val)
    LS_CORE.PLAYER_DATA = val
end)

exports('GetCoreObject', function()
    return LS_CORE
end)