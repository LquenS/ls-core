LS_CORE_CONFIG = { }

LS_CORE_CONFIG.VERSION = "1.0.4"

LS_CORE_CONFIG.Reputation = {
    ["1"] = 480,
    ["2"] = 920,
    ["3"] = 1240,
    ["4"] = 1950,
    ["5"] = 2300,

    ["6"] = 3040,
    ["7"] = 3980,
    ["8"] = 4400,
    ["9"] = 4920,
    ["10"] = 5400,
}




LS_CORE_CONFIG.FRAMEWORK = GetResourceState("es_extended") == "started" and "ESX" or "QB"

LS_CORE_CONFIG.EVENTS = {
    PlayerLoaded = {
        ["ESX"] = "esx:playerLoaded",
        ["QB"] = "QBCore:Server:PlayerLoaded",
    },
}

LS_CORE_CONFIG.DATABASE_NAME = "mysql-async"

LS_CORE_CONFIG.DATABASE                         = function(plugin,type,query,var)
    local wait = promise.new()
    if type == 'fetchAll' and plugin == 'mysql-async' then
        MySQL.Async.fetchAll(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'mysql-async' then
        MySQL.Async.execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'ghmattisql' then
        exports['ghmattimysql']:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'fetchAll' and plugin == 'ghmattisql' then
        exports.ghmattimysql:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'oxmysql' then
        exports.oxmysql:query(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'fetchAll' and plugin == 'oxmysql' then
        exports.oxmysql:query(query, var, function(result)
            wait:resolve(result)
        end)
    end
    return Citizen.Await(wait)
end

local StringCharset = {}
local NumberCharset = {}

for i = 48, 57 do NumberCharset[#NumberCharset + 1] = string.char(i) end
for i = 65, 90 do StringCharset[#StringCharset + 1] = string.char(i) end
for i = 97, 122 do StringCharset[#StringCharset + 1] = string.char(i) end

function LS_CORE_CONFIG.RandomStr(length)
    if length <= 0 then return '' end
    return LS_CORE_CONFIG.RandomStr(length - 1) .. StringCharset[math.random(1, #StringCharset)]
end

function LS_CORE_CONFIG.RandomInt(length)
    if length <= 0 then return '' end
    return LS_CORE_CONFIG.RandomInt(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
end