mSuits = mSuits or {}


local PLAYER = FindMetaTable( "Player" )

function mSuits:LoadSuits()
    for k, v in pairs( mSuits.Config.Suits ) do
        if SERVER then
            mSuits:RegisterSuit( k, v.Health, v.Shields, v.Speed, v.Gravity, v.Model, v.Ability, v.weaponScale, v.Access )
        end
    end
end

local PLAYER = FindMetaTable( "Player" )

function PLAYER:SetSuit( suit )
    self.mSuitActive = suit
end

function PLAYER:GetSuit()
    return self.mSuitActive
end


function mSuits:LoadAbilities()
    for k, v in pairs( mSuits.Config.Abilities ) do
        if SERVER then
            mSuits:RegisterAbility( k, v.OnUse, v.Cooldown, v.Duration, v.Restricted, v.Type )
        end
    end
end

function mSuits:RegisterSuit( name, health, shields, speed, gravity, model, ability, weaponScale, Access, Allowed, OnEquip, OnUnequip  )
    self.Config.Suits[name] = {
        Health = health,
        Shields = shields,
        Model = model,
        Speed = speed,
        Gravity = gravity,
        Ability = ability,
        weaponScale = 1,  -- Default weapon scale is 1, If you make it 0.5, the weapon will be half the size
        Scale = 1, -- model size 
        OnEquip = OnEquip,
        OnUnequip = OnUnequip
    }
end

function mSuits:RegisterAbility( name, OnUse, Cooldown, Duration, Restricted, Type )
    self.Config.Abilities[name] =  {
        Name = name,
        OnUse = OnUse,
        Cooldown = Cooldown,
        Duration = Duration,
    }
end

function PLAYER:GetSuit()
    return self:GetNWString( "mSuits_Suit" )
end

function PLAYER:RemoveSuit()
    self:SetSuit( nil )
    self:SetNWString( "mSuits_Suit", "" )
    mSuits.UnequipSuit( self )
end

function PLAYER:GetSuitData()
    if not self then
        MsgC( Color( 255, 0, 0 ), "[mSuits] Error: No player found!\n" )
        return
    end
    return util.JSONToTable( self.mSuitCData )
end

function mSuits.EquipSuit(ply, suitData)
    if not ply:GetSuit() == "" then 
        ply:ChatPrint("You already have a suit equipped!")
        return
    end
    ply:ConCommand("mSuits_Hud")
    ply.mSuitOldModel = ply:GetModel()
    ply.mSuitOldSpeed = ply:GetWalkSpeed()
    ply.mSuitOldRSpeed = ply:GetRunSpeed()
    ply.mSuitOldGravity = ply:GetGravity()
    ply.mSuitOldHealth = ply:GetMaxHealth()
    if not suitData then
        MsgC(Color(255, 0, 0), "[mSuits] Error: Tried to equip a suit that doesn't exist!")
        return
    end
    ply:SetSuit(suitData)
    print("Equipping suit: " .. suitData.name)
    ply:SetModel(suitData.model)
    ply:SetRunSpeed(suitData.speed)
    ply:SetGravity(suitData.gravity)
    for k,v in pairs(suitData.perks) do
        if k == "health" then
            ply:SetMaxHealth(v * suitData.SuitHealth)
            ply:SetHealth(v * suitData.SuitHealth)
        end
    end 
    ply:SetNWString("mSuits_Suit", suitData.name)
    print("Equipped suit: " .. suitData.name)
    print(suitData.skin)
    ply:SetMaterial(suitData.skin)
    ply.mSuitCData = util.TableToJSON(suitData)
    net.Start("mInventoryPerks.SendSuitData")
    print("Sending Item Data to " .. ply:Nick())
    net.WriteTable(ply:GetSuitData())
    net.Send(ply)
end

function mSuits.UnequipSuit(ply)
    ply:ConCommand("close_hud")
    ply:SetSuit(nil)
    if not ply.mSuitOldModel then return end
    if not ply.mSuitOldSpeed then return end
    if not ply.mSuitOldRSpeed then return end
    if not ply.mSuitOldGravity then return end
    if not ply.mSuitOldHealth then return end
    ply:SetRunSpeed(ply.mSuitOldRSpeed)
    ply:SetModel(ply.mSuitOldModel)
    ply:SetWalkSpeed(ply.mSuitOldSpeed)
    ply:SetGravity(ply.mSuitOldGravity)
    ply:SetHealth(100)
    ply:SetMaxHealth(100)
    ply:SetMaterial("")
    ply:SetNWString("mSuits_Suit", "")

end
function mSuits.SuitInformation(suit)
    for k, v in pairs(mSuits.Config.Suits) do
        if k == suit then
            return v
        end
    end
end

timer.Create("mInventory.IDCHECK", 20, 0, function()
    for k,v in pairs(player.GetAll()) do
        local inv = v.mInventory

    end
end)
function mSuits.DropSuit(ply)
    local suit = ply:GetSuit()
    print(suit)
    local suitData = mSuits.SuitInformation(suit)
    if not suit then
        MsgC(Color(255, 0, 0), "[mSuits] Error: Tried to drop a suit that doesn't exist!")
        return
    end
    local data = util.JSONToTable(ply.mSuitCData)
    mSuits.UnequipSuit(ply)
    local suitEnt = ents.Create("msuit_base")
    suitEnt:SetPos(ply:GetPos())
    suitEnt.mSuitName = suit
    suitEnt.PrintName = suit
    suitEnt.SuitData = util.JSONToTable(ply.mSuitCData)
    suitEnt:SetEntItemData(data)
    suitEnt:SetSuitData(util.JSONToTable(ply.mSuitCData))
    suitEnt:SetItemName(suit)
    suitEnt:Spawn()

    ply:RemoveSuit()
end

hook.Add("PlayerDeath", "mSuits:PlayerDeath", function(ply)
    if ply:GetSuit() then
        mSuits.UnequipSuit(ply)
    end
end)

hook.Add("PlayerSay", "mSuits:PlayerDropSuit", function(ply, text)
    if text == "/dropsuit" then
        if ply:GetSuit() == "" then 
            ply:ChatPrint("You don't have a suit equipped!")
            return
        end
        mSuits.DropSuit(ply)
    end
end)

concommand.Add("mSuits_GetSuitData", function(ply, cmd, args)
    local suit = args[1]
    local ent = ply:GetEyeTrace().Entity
    if not ent:IsValid() then return end
    ply:ChatPrint("Suit Data: " .. ent.mSuitName)
    ply:ChatPrint("Suit Data: " .. ent:GetSuitData().rarity)
end)

hook.Add("PlayerSpawn", "mSuits:PlayerSpawn2", function(ply)
    ply:ConCommand("close_hud")
end)
