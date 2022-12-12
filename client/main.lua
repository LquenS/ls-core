LS_CORE = { }
LS_CORE.Config = LS_CORE_CONFIG
LS_CORE.PLAYER_DATA

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    LS_CORE.PLAYER_DATA = val
end)

exports('GetCoreObject', function()
    return LS_CORE
end)