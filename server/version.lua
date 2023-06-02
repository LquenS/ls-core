LS_CORE.Functions.GetVersionScript = function(CURRENT_VERSION, SCRIPT_NAME)
    PerformHttpRequest("https://raw.githubusercontent.com/LquenS/ls-core/main/versions.json", function (_, data, __)
        if data ~= nil then
            local SCRIPT_LIST = json.decode(data)
            for _, value in pairs ( SCRIPT_LIST ) do 
                if value.name == SCRIPT_NAME then
                    print("[================================================================================]\n")
                    print("^1["..SCRIPT_NAME.."] ^7 checking started.")
                    if value.version == CURRENT_VERSION then
                        print("^2[" ..SCRIPT_NAME.. "] VERSION IS LATEST\n[" ..SCRIPT_NAME.. "] VERSION TITLE ^3" .. value.version_name.."^2.\n".."[" ..SCRIPT_NAME.. "] ^3" .. value.version_desc.."^2.^7")
                    else
                        print("^8[" ..SCRIPT_NAME.. "] ^1IS OUTDATED, NEEDS TO BE UPDATED!^8\n[" ..SCRIPT_NAME.. "] ^1LATEST VERSION IS^8 ^3" .. value.version .. "^8.^7")
                        LS_CORE.Functions.CreateUpdateLoop("[================================================================================]\n".."^8[" ..SCRIPT_NAME.. "] ^1IS OUTDATED, NEEDS TO BE UPDATED!^8\n[" ..SCRIPT_NAME.. "] ^1LATEST VERSION IS^8 ^3" .. value.version .. "^8.^7".."\n[================================================================================]")
                    end
                    print("\n[================================================================================]")
                end
            end
        else
            print("[ls-core] Versions cannot accessiable. Wait do not distrub dev, it\'s will pass soon!")
        end
    end)
end

LS_CORE.Functions.CreateUpdateLoop = function(PRINT)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(2500)
            print(PRINT)
        end
    end)
end

Citizen.CreateThread(function()
    Citizen.Wait(500)
    LS_CORE.Functions.GetVersionScript(GetResourceMetadata("ls-core", "version"), "ls-core")
end)

exports("CheckVersion", LS_CORE.Functions.GetVersionScript)
