LS_CORE = { }
LS_CORE.Config = LS_CORE_CONFIG
LS_CORE.Functions = {}
LS_CORE.Player = {} 
LS_CORE.Players = {} 


if (LS_CORE.Config.FRAMEWORK == "QB") then
    QBCore = exports['qb-core']:GetCoreObject()
elseif (LS_CORE.Config.FRAMEWORK == "ESX") then
    ESX = exports['es_extended']:getSharedObject()
end

LS_CORE.Functions.GetPlayer = function (source)
    local Player = LS_CORE.Players[source]
	if Player == nil then return nil end
	Player.RefreshPlayer()
	
    return Player
end
exports('GetPlayer', function(source)
    return LS_CORE.Functions.GetPlayer(source)
end)

LS_CORE.Functions.GetIdentifier = function (id)
    for src in pairs(LS_CORE.Players) do
        if LS_CORE.Players[src].DATA.identifier == id or LS_CORE.Players[src].DATA.cid == id then
            local Player = LS_CORE.Players[src]
            Player.RefreshPlayer()

            return Player
        end
    end
    return nil
end
exports('GetIdentifier', function(id)
    return LS_CORE.Functions.GetIdentifier(id)
end)

LS_CORE.Functions.GetPlayerFramework = function (source)
    local Player = nil
    if (LS_CORE.Config.FRAMEWORK == "QB") then
        Player =  QBCore.Functions.GetPlayer(source)
    elseif (LS_CORE.Config.FRAMEWORK == "ESX") then
        Player =  ESX.GetPlayerFromId(source)
    end
     

    return Player
end

LS_CORE.Functions.GetPlayerFrameworkIdentifier = function (identifier)
    local Player = nil
    if (LS_CORE.Config.FRAMEWORK == "QB") then
        Player =  QBCore.Functions.GetPlayerByCitizenId(identifier)
    elseif (LS_CORE.Config.FRAMEWORK == "ESX") then
        Player =  ESX.GetPlayerFromIdentifier(identifier)
    end
     

    return Player
end

LS_CORE.Functions.GetPlayers = function ()
    return LS_CORE.Players
end

LS_CORE.Functions.GetPlayerIdentifier = function (source)
    local Identifier = nil
    if (LS_CORE.Config.FRAMEWORK == "QB") then
        Identifier=  LS_CORE.Functions.GetPlayerFramework(source).PlayerData.citizenid
    elseif (LS_CORE.Config.FRAMEWORK == "ESX") then
        Identifier=  LS_CORE.Functions.GetPlayerFramework(source).identifier
    end
     

    return Identifier
end


LS_CORE.Player.CreatePlayerData = function(source)
    local identifier = LS_CORE.Functions.GetPlayerIdentifier(source)
	
	local Database = {}
	local result = LS_CORE.Config.DATABASE(LS_CORE.Config.DATABASE_NAME, 'fetchAll', 'SELECT * FROM ls_core where identifier = ?', { identifier })
	if result[1] ~= nil then
		Database = json.decode(result[1].data)
	end
    local Data = Database

    Data.identifier = identifier
    Data.Reputation = Data.Reputation or 0
    Data.XP = Data.XP or 0
    Data.Skills = Data.Skills or { }
    Data.cid = Data.cid or LS_CORE.Player.CreateCustomID(identifier, false)
    Data.charinfo = Data.charinfo or LS_CORE.Player.CreateCharInfo(identifier) or { firstname = "none", lastname = "none", birthdate = "00/00/0000" }
    Data.walletid = Data.walletid or LS_CORE.Player.CreateCustomID(identifier, true)
    Data.items = GetResourceState('ls-inventory') ~= 'missing' and exports['ls-inventory']:LoadInventory(source, Data.cid) or {}
    Data.craftinghistory = Data.craftinghistory or {}


    local createdUser = LS_CORE.Player.CreatePlayer(source, Data)

    TriggerClientEvent("LS_CORE:PLAYER:CREATED", source, createdUser)
    TriggerEvent("LS_CORE:PLAYER:CREATED", createdUser)
end

function LS_CORE.Player.CreateCharInfo(id)
    local Player = LS_CORE.Functions.GetPlayerFrameworkIdentifier(id)
    if Player == nil then return end
    if (LS_CORE.Config.FRAMEWORK == "QB") then
        return { firstname = Player.PlayerData.charinfo.firstname, lastname = Player.PlayerData.charinfo.lastname, birthdate = Player.PlayerData.charinfo.birthdate }
    elseif (LS_CORE.Config.FRAMEWORK == "ESX") then
        local result = LS_CORE.Config.DATABASE( LS_CORE.Config.DATABASE_NAME, 'fetchAll', 'SELECT firstname, lastname, dateofbirth FROM users WHERE identifier = @identifier', {
            ['@identifier'] = Player.identifier
        })

        return { firstname = result[1].firstname, lastname = result[1].lastname, birthdate = result[1].dateofbirth }
    end  
    
end

LS_CORE.Player.CreatePlayer = function(source, PLAYER_DATA)
    local self = {}
    self.Functions = {}
    
    self.Source = source
    self.Identifier = PLAYER_DATA.identifier
    self.DATA = PLAYER_DATA
    self.Player = LS_CORE.Functions.GetPlayerFramework(self.Source)
	
	self.RefreshPlayer = function ()
		self.Player = LS_CORE.Functions.GetPlayerFramework(self.Source)
	end
    
    
    self.Functions.GetPlayerData = function ()
        return self.DATA
    end

    self.Functions.SetPlayerData = function (PlayerInfo)
        self.DATA = PlayerInfo

        TriggerEvent('LS_CORE:PLAYER:SETPLAYERDATA', self.DATA)
        TriggerClientEvent('LS_CORE:PLAYER:SETPLAYERDATA', self.Source, self.DATA)

        return self.DATA
    end




    self.Functions.Experience = function(type, amount)
        if (type == "ADD") then
            self.DATA.XP = tonumber(self.DATA.XP) + tonumber(amount)
        elseif (type == "REMOVE") then
            self.DATA.XP = tonumber(self.DATA.XP) - tonumber(amount)
        elseif (type == "RESET") then
            self.DATA.XP = 0
        end

        self.Functions.SetPlayerData(self.DATA)

        if tonumber(self.DATA.XP) >= LS_CORE.Config.Reputation[tostring(tonumber(self.DATA.Reputation) + 1)] then
            self.Functions.Reputation("ADD", 1)
            self.Functions.Experience("RESET", nil)
        end
    end

    
    
    self.Functions.Reputation = function(type, amount)
        if (type == "ADD") then
            self.DATA.Reputation = tonumber(self.DATA.Reputation) + tonumber(amount)
        elseif (type == "REMOVE") then
            self.DATA.Reputation = tonumber(self.DATA.Reputation) - tonumber(amount)
        elseif (type == "RESET") then
            self.DATA.Reputation = 0
        end

        self.Functions.SetPlayerData(self.DATA)
    end



    self.Functions.AddItem = function(item, amount, slot, info)
        if GetResourceState("ls-inventoryhud") == 'started' then
            exports["ls-inventoryhud"]:AddItem(self.Source, item, amount, slot, info)
        elseif GetResourceState("ls-inventory") == 'started' then
            exports["ls-inventory"]:AddItem(self.Source, item, amount, slot)
        else
            if (LS_CORE.Config.FRAMEWORK == "QB") then
                self.Player.Functions.AddItem(item, amount, slot, info)
            elseif (LS_CORE.Config.FRAMEWORK == "ESX") then
                self.Player.addInventoryItem(item, amount, info)
            end 
        end
    end

    self.Functions.RemoveItem = function(item, amount, slot)
        if GetResourceState("ls-inventoryhud") == 'started' then
            exports["ls-inventoryhud"]:RemoveItem(self.Source, slot, amount)
        elseif GetResourceState("ls-inventory") == 'started' then
            exports["ls-inventory"]:RemoveItem(self.Source, item, amount, slot)
        else
            if (LS_CORE.Config.FRAMEWORK == "QB") then
                self.Player.Functions.RemoveItem(item, amount, slot)
            elseif (LS_CORE.Config.FRAMEWORK == "ESX") then
                self.Player.removeInventoryItem(item, amount)
            end 
        end
    end

    self.Functions.GetItem = function(item)
        if GetResourceState("ls-inventoryhud") == 'started' then
            local foundItem = exports["ls-inventoryhud"]:GetItem(self.Source, item)
            if foundItem == nil then
                for _,v in pairs ( exports["ls-inventoryhud"]:GetItems(self.Source) ) do
                    if (v._tpl == item) then
                        foundItem = v
                        break
                    end
                end
            end

            return foundItem
        elseif GetResourceState("ls-inventory") == 'started' then
            exports["ls-inventory"]:GetItemByName(self.Source, item)
        else
            if (LS_CORE.Config.FRAMEWORK == "QB") then
                return self.Player.Functions.GetItemByName(item)
            elseif (LS_CORE.Config.FRAMEWORK == "ESX") then
                return self.Player.getInventoryItem(item)
            end 
        end
    end

    

    self.Functions.GetPlayerMoney = function(type)
        if (LS_CORE.Config.FRAMEWORK == "QB") then
			local PlayerFUN = QBCore.Functions.GetPlayer(self.Source)
            return PlayerFUN.PlayerData.money[type]
        elseif (LS_CORE.Config.FRAMEWORK == "ESX") then
			if type == "cash" then type = "money" end
            return self.Player.getAccount(type).money
        end 
    end

    self.Functions.AddMoney = function(type, amount, reason)
        if (LS_CORE.Config.FRAMEWORK == "QB") then
            self.Player.Functions.AddMoney(type, amount, reason)
        elseif (LS_CORE.Config.FRAMEWORK == "ESX") then
			if type == "cash" then type = "money" end
            self.Player.addAccountMoney(type, amount)
        end 
    end

    self.Functions.RemoveMoney = function(type, amount, reason)
        if (LS_CORE.Config.FRAMEWORK == "QB") then
            self.Player.Functions.RemoveMoney(type, amount, reason)
        elseif (LS_CORE.Config.FRAMEWORK == "ESX") then
			if type == "cash" then type = "money" end
            self.Player.removeAccountMoney(type, amount)
        end 
    end

    self.Functions.GetProfile = function()
        if (LS_CORE.Config.FRAMEWORK == "QB") then
            return self.Player.PlayerData.charinfo
        elseif (LS_CORE.Config.FRAMEWORK == "ESX") then
            local result = LS_CORE.Config.DATABASE( LS_CORE.Config.DATABASE_NAME, 'fetchAll', 'SELECT * FROM users where identifier = ?', { self.Identifier })
            return result[1]
        end 
    end




    self.Functions.Save = function()
        LS_CORE.Player.Save(self.Source)
    end

    LS_CORE.Players[self.Source] = self
    self.Functions.SetPlayerData(self.DATA)

    RconPrint("[ls-core] Player "..self.Identifier.." has succesfully logged!\n")
    return self
end

function LS_CORE.Player.Save(source)
    local PlayerData = LS_CORE.Players[source]
    if PlayerData then
        -- If using ls-inventory save Inventory if not do not do anything
        if GetResourceState("ls-inventory") == "started" then exports["ls-inventory"]:SaveInventory(PlayerData.DATA, true) end

        -- Clean items, because after logout never used again for this reason there is no reason to save again.
        PlayerData.DATA.items = {} 

        local IsValid = LS_CORE.Config.DATABASE( LS_CORE.Config.DATABASE_NAME, 'fetchAll', 'SELECT * FROM ls_core where identifier = ?', { PlayerData.Identifier })
        if IsValid[1] then
            LS_CORE.Config.DATABASE( LS_CORE.Config.DATABASE_NAME, 'execute', 'UPDATE `ls_core` SET `data` = @data WHERE `identifier` = @identifier', {
                ['@identifier'] = PlayerData.Identifier,
                ['@data']       = json.encode(PlayerData.DATA),
            })
        else
			LS_CORE.Config.DATABASE( LS_CORE.Config.DATABASE_NAME, 'execute', 'INSERT INTO `ls_core` (identifier, data) VALUES (@identifier, @data)', {
                ["@identifier"] = PlayerData.Identifier,
                ["data"] = json.encode(PlayerData.DATA),
            })
        end

    else
        RconPrint("[ls-core] PLAYER CANNOT FOUND\n")
    end
end

function LS_CORE.Player.CreateCustomID(identifier, avoid)
    if (LS_CORE.Config.FRAMEWORK == "QB") and not avoid then return identifier end

    local fnd = true
    local cid = nil
    while fnd do
        cid = tostring(LS_CORE.Config.RandomStr(3) .. LS_CORE.Config.RandomInt(5)):upper()
		local query = '%' .. cid .. '%'
        local result = LS_CORE.Config.DATABASE(LS_CORE.Config.DATABASE_NAME, "fetchAll", 'SELECT COUNT(*) as count FROM ls_core WHERE data LIKE ?', { query })
		if result[1].count == 0 then
            fnd = false
        end
    end
    return cid
end

AddEventHandler('playerDropped', function()
    local src = source
    if not LS_CORE.Players[src] then return end
    local Player = LS_CORE.Players[src]
    
    Player.Functions.Save()
    LS_CORE.Players[src] = nil

    TriggerClientEvent("LS_CORE:PLAYER:PLAYERUNLOAD", src)
    TriggerEvent("LS_CORE:PLAYER:PLAYERUNLOAD")
end)

RegisterCommand("convertplayers", function(src)
    if src == 0 then

        if (LS_CORE.Config.FRAMEWORK == "QB") then
            local result = LS_CORE.Config.DATABASE(LS_CORE.Config.DATABASE_NAME, "fetchAll", 'SELECT * FROM players', { })
            for _,v in pairs( result ) do
                if v ~= nil then
                    local result2 = LS_CORE.Config.DATABASE(LS_CORE.Config.DATABASE_NAME, 'fetchAll', 'SELECT * FROM ls_core where identifier = ?', { v.citizenid })
                    if result2[1] == nil then
                        v.charinfo = json.decode(v.charinfo)
                        local Data = {}
                        local identifier = v.citizenid

                        Data.identifier = identifier
                        Data.Reputation = 0
                        Data.XP = 0
                        Data.Skills = { }
                        Data.cid = LS_CORE.Player.CreateCustomID(identifier, false)
                        Data.charinfo = { firstname = v.charinfo.firstname, lastname = v.charinfo.lastname, birthdate = v.charinfo.birthdate } or { firstname = "none", lastname = "none", birthdate = "00/00/0000" }
                        Data.walletid = Data.walletid or LS_CORE.Player.CreateCustomID(identifier, true)

                        LS_CORE.Config.DATABASE( LS_CORE.Config.DATABASE_NAME, 'execute', 'INSERT INTO `ls_core` (identifier, data) VALUES (@identifier, @data)', {
                            ["@identifier"] = identifier,
                            ["data"] = json.encode(Data),
                        })
                    end
                end
            end
            
        elseif (LS_CORE.Config.FRAMEWORK == "ESX") then
            local result = LS_CORE.Config.DATABASE(LS_CORE.Config.DATABASE_NAME, "fetchAll", 'SELECT * FROM users', { })
            for _,v in pairs( result ) do
                if v ~= nil then
                    local result2 = LS_CORE.Config.DATABASE(LS_CORE.Config.DATABASE_NAME, 'fetchAll', 'SELECT * FROM ls_core where identifier = ?', { v.identifier })
                    if result2[1] == nil then
                        local Data = {}
                        local identifier = v.identifier

                        Data.identifier = identifier
                        Data.Reputation = 0
                        Data.XP = 0
                        Data.Skills = { }
                        Data.cid = LS_CORE.Player.CreateCustomID(identifier, false)
                        Data.charinfo = { firstname = v.firstname, lastname = v.lastname, birthdate = v.birthdate } or { firstname = "none", lastname = "none", birthdate = "00/00/0000" }
                        Data.walletid = Data.walletid or LS_CORE.Player.CreateCustomID(identifier, true)

                        LS_CORE.Config.DATABASE( LS_CORE.Config.DATABASE_NAME, 'execute', 'INSERT INTO `ls_core` (identifier, data) VALUES (@identifier, @data)', {
                            ["@identifier"] = identifier,
                            ["data"] = json.encode(Data),
                        })
                    end
                end
            end
        end
        
    else
        print( "This command only used by server console, " .. src .. " tried to use." )
    end
end)

exports('GetCoreObject', function()
    return LS_CORE
end)
