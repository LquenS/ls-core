--//#    CALLBACK STUFF  #\\--

LS_CORE.Callback = {}
LS_CORE.Callback.Functions = {}
LS_CORE.Callback.ServerCallbacks = {}
LS_CORE.Callback.ClientCallbacks = {}

LS_CORE.Callback.Functions.CreateClientCallback = function(name, cb)
    LS_CORE.Callback.ClientCallbacks[name] = cb
end

LS_CORE.Callback.Functions.TriggerClientCallback = function(name, cb, ...)
    if not LS_CORE.Callback.ClientCallbacks[name] then return end
    LS_CORE.Callback.ClientCallbacks[name](cb, ...)
end


function LS_CORE.Callback.Functions.TriggerCallback(name, cb, ...)
    LS_CORE.Callback.ServerCallbacks[name] = cb
    TriggerServerEvent('ls-core:Server:TriggerCallback', name, ...)
end

RegisterNetEvent('ls-core:Client:TriggerCallback', function(name, ...)
    if LS_CORE.Callback.ServerCallbacks[name] then
        LS_CORE.Callback.ServerCallbacks[name](...)
        LS_CORE.Callback.ServerCallbacks[name] = nil
    end
end)

--//#                     #\\--