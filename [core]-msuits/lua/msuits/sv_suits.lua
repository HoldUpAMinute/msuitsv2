local PLAYER = FindMetaTable("Player")

hook.Add("PlayerSpawn", "mSuits:PlayerSpawn", function(ply)
    if not ply:IsSuitEquipped() then return end
    ply:SetMaterial("")

    if ply:GetNWString("mSuits_Suit") == "" then
        ply:SetNWString("mSuits_Suit", "")
        mSuits.UnequipSuit(ply)

        return
    end
end)

hook.Add("PlayerDeath", "mSuits:PlayerDeaths", function(ply)
    if not ply:IsSuitEquipped() then return end
    local suit = ply:GetSuit()
    if not suit then return end
    ply:SetMaterial("")
    mSuits.UnequipSuit(ply)
    ply:SetNWString("mSuits_Suit", "")
end)

net.Receive("mInventory.Equip_mSuit", function(len, p)
    local place = net.ReadUInt(32)
    local ply = p
    local itemData = net.ReadTable()
    local inv = p.mInventory
    if not inv then return end

    if not ply:GetSuit() == "" then
        ply:ChatPrint("You already have a suit equipped!")

        return
    end

    if not p then
        MsgC(Color(255, 0, 0), "[mSuits] Error: No player found!\n")
    end

    if not itemData then
        MsgC(Color(255, 0, 0), "[mSuits] Error: No item data found!\n")

        return
    end

    print("Equipping Item: " .. itemData.name)
    mSuits.EquipSuit(p, itemData)
    table.remove(inv, place)
    file.Write("mInventory/" .. p:SteamID64() .. ".json", util.TableToJSON(inv))
    mInventory.UpdatePlayer(p)
    net.Start("mInventoryPerks.SendSuitData")
    print("Sending Item Data to " .. p:Nick())
    net.WriteTable(p:GetSuitData())
    net.Send(p)
    p:SetMaxHealth(itemData.SuitHealth)
    p:SetHealth(itemData.SuitHealth)
    p:SetRunSpeed(itemData.speed)
end)

net.Receive("mInventory.Drop_mSuit", function(len, ply)
    local place = net.ReadUInt(32)
    local inv = ply.mInventory
    local data = net.ReadTable()
    if not inv then return end

    if not ply then
        MsgC(Color(255, 0, 0), "[mSuits] Error: No player found!\n")
    end

    if not data then
        MsgC(Color(255, 0, 0), "[mSuits] Error: No item data found!\n")

        return
    end

    local suitEnt = ents.Create("msuit_base")
    suitEnt:SetPos(ply:GetPos())
    suitEnt.mSuitName = suit
    suitEnt.PrintName = suit
    suitEnt.SuitData = itemData
    suitEnt:SetEntItemData(data)
    suitEnt:SetSuitData(itemData)
    suitEnt:SetItemName(itemData.name)
    suitEnt:Spawn()
    table.remove(inv, place)
    file.Write("mInventory/" .. ply:SteamID64() .. ".json", util.TableToJSON(inv))
    mInventory.UpdatePlayer(ply)
end)

local net_string = {
    ["EquipSuit"] = "mSuits:EquipSuit",
    ["RemoveSuit"] = "mSuits:RemoveSuit",
    ["SendSuits"] = "mSuits:SendSuits",
    ["RequestSuits"] = "mSuits:RequestSuits",
    ["UseSuit"] = "mSuits:UseSuit",
}

for k, v in pairs(net_string) do
    util.AddNetworkString(v)
end

function PLAYER:IsSuitEquipped()
    return self:GetNWString("mSuits_Suit") ~= "none"
end

hook.Add("InitPostEntity", "mSuits:InitPostEntity", function()
    if not mSuits.Config then return end
    if not mSuits.Config.Suits then return end
    print("[mSuits] Registering suits...")

    for i, suit in pairs(mSuits.Config.Suits) do
        print("Adding suit: " .. suit.Name)
        local ENT = {}
        ENT.Type = "anim"
        ENT.Base = "msuit_base"
        ENT.PrintName = suit.Name
        ENT.Spawnable = true
        ENT.mSuitName = suit.Name
        ENT.Category = "mSuit"
        print("[mSuits] Registered suit: " .. suit.Name .. " (" .. "msuit_base_" .. string.lower(string.Replace(suit.Name, " ", "_")) .. ")")
        scripted_ents.Register(ENT, "msuit_base_" .. string.lower(string.Replace(suit.Name, " ", "_")))
    end
end)

net.Receive("mSuits:UseSuit", function(len, ply)
    local dat = net.ReadString()
    local data = util.JSONToTable(dat)

    
    if not ply:GetSuit() == "" then
        ply:ChatPrint("You already have a suit equipped!")

        return
    end

    if not data.model or not data.name or not data.speed or not data.gravity or not data.SuitHealth then
        ply:ChatPrint("This suit is invalid! [Please Inventory The Suit And Try Again]")

        return
    end

    ply:ConCommand("mSuits_Hud")
    ply.mSuitOldModel = ply:GetModel()
    ply.mSuitOldSpeed = ply:GetWalkSpeed()
    ply.mSuitOldRSpeed = ply:GetRunSpeed()
    ply.mSuitOldGravity = ply:GetGravity()
    ply.mSuitOldHealth = ply:GetMaxHealth()

    if not data then
        MsgC(Color(255, 0, 0), "[mSuits] Error: Tried to equip a suit that doesn't exist!")

        return
    end

    local ent = ply:GetEyeTrace().Entity
    ent:Remove()
    ply:SetSuit(data)
    ply:SetModel(data.model)
    ply:SetRunSpeed(data.speed or 250)
    ply:SetGravity(data.gravity)
    ply:SetHealth(data.SuitHealth)
    ply:SetMaxHealth(data.SuitHealth)
    ply:SetNWString("mSuits_Suit", data.name)
    print("Equipped suit: " .. data.name)
    print(data.skin)
    ply:SetMaterial(data.skin)
    ply.mSuitPreventSpam = false
    ply.mSuitCData = util.TableToJSON(data)
end)

net.Receive("mSuits:EquipSuit", function(len, ply)
    local data = net.ReadTable()

    if not ply:GetSuit() == "" then
        ply:ChatPrint("You already have a suit equipped!")

        return
    end

    if not data.model or not data.name or not data.speed or not data.gravity or not data.SuitHealth then
        ply:ChatPrint("This suit is invalid! [Please Inventory The Suit And Try Again]")

        return
    end

    ply:ConCommand("mSuits_Hud")
    ply.mSuitOldModel = ply:GetModel()
    ply.mSuitOldSpeed = ply:GetWalkSpeed()
    ply.mSuitOldRSpeed = ply:GetRunSpeed()
    ply.mSuitOldGravity = ply:GetGravity()
    ply.mSuitOldHealth = ply:GetMaxHealth()

    if not data then
        MsgC(Color(255, 0, 0), "[mSuits] Error: Tried to equip a suit that doesn't exist!")

        return
    end

    local ent = ply:GetEyeTrace().Entity
    ent:Remove()
    ply:SetSuit(data)
    ply:SetModel(data.model)
    ply:SetRunSpeed(data.speed or 250)
    ply:SetGravity(data.gravity)
    ply:SetHealth(data.SuitHealth)
    ply:SetMaxHealth(data.SuitHealth)
    ply:SetNWString("mSuits_Suit", data.name)
    print("Equipped suit: " .. data.name)
    print(data.skin)
    ply:SetMaterial(data.skin)
    ply.mSuitPreventSpam = false
    ply.mSuitCData = util.TableToJSON(data)
end)

util.AddNetworkString("mHud.DrawPlayerHud")

hook.Add("PlayerInitalSpawn", "mHudDraw", function()
    timer.Simple(7, function()
        ply:ConCommand("mHud.DrawPlayerHud")
    end)
end)

