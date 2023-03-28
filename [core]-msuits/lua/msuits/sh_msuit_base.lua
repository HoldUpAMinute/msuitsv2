local ENT = {}
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "mSuit Base"
ENT.mSuitName = "mSuit Base"
ENT.Author = "mSuits Development"
ENT.Category = "mSuits"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "Owner")
    self:NetworkVar("String", 1, "ItemName")
    self:NetworkVar("String", 2, "ItemRarity")
    self:NetworkVar("String", 3, "ItemSkin")
    self:NetworkVar("String", 4, "SuitHealth")
    self:NetworkVar("String", 5, "SuitShields")
end

function ENT:Initialize()
    self.ItemData = self.ItemData or {}
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NOCLIP)
    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

    self:SetModel("models/items/item_item_crate.mdl")
    self:SetItemName(self.mSuitName)
end

function ENT:Use(activator, caller)
    local ent = activator:GetEyeTrace().Entity
    if activator:IsPlayer() then
        if self:GetNWBool("mInventory:PlayerUse") then return end

        if not activator.mSuitPreventSpam then
            activator.mSuitPreventSpam = true
            net.Start("mSuits:UseSuit")
            net.WriteString(util.TableToJSON(ent:GetSuitData()))
            net.Send(activator)
        end
        
        timer.Simple(1, function()
            activator.mSuitPreventSpam = false
        end)
    end
end

function ENT:SetSuitData(data)
    self.SuitData = util.JSONToTable(data)
    self:SetItemName(self.mSuitName)
end

function ENT:GetSuitName()

    return self:GetItemName()
end

function ENT:GetSuitData()
    return self.ItemData
end

function ENT:SetSuitData(data)
    self.ItemData = util.JSONToTable(util.TableToJSON(data))
    self:SetItemName(self.mSuitName)
    self:SetMaterial(self.ItemData.skin)
end

function ENT:GetItemPickUPSuitData()

    return self.ItemData
end

function ENT:GetItemSuitData()

    return util.JSONToTable(self.ItemData)
end

function ENT:Draw()
    local bgcolor = Color(19, 4, 54, 500)
    local bcolorv2 = Color(0, 0, 0, 150)
    local btcolor = Color(32, 32, 32, 10)
    PIXEL.RegisterFont("mInventory.Main1", "Roboto Medium", 50, 800)
    PIXEL.RegisterFont("mInventory.WepName", "Roboto Medium", 35, 800)
    PIXEL.RegisterFont("mInventory.InvName", "Roboto Medium", 28, 800)
    self:DrawModel()
    if LocalPlayer():GetPos():Distance(self:GetPos()) > 250 then return end
    local ply = LocalPlayer()
    local pos = self:GetPos()
    local eyePos = ply:GetPos()
    local dist = pos:Distance(eyePos)
    local alpha = math.Clamp(2500 - dist * 2.7, 0, 255)
    if alpha <= 0 then return end
    local angle = self:GetAngles()
    local eyeAngle = ply:EyeAngles()
    angle:RotateAroundAxis(angle:Forward(), 90)
    angle:RotateAroundAxis(angle:Right(), -90)
    -- Draw overhead text
    local itemName = self:GetItemName()
    cam.Start3D2D(pos + self:GetUp() * 40, Angle(0, eyeAngle.y - 90, 90), 0.1)
    PIXEL.DrawRoundedBox(10, -250, -100, 475, 75, bgcolor)
    PIXEL.DrawRoundedBox(10, -238.5, -87.5, 450, 50, bcolorv2)
    PIXEL.DrawSimpleText(self:GetItemName(), "mInventory.Main1", 0, -62, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

scripted_ents.Register(ENT, "msuit_base", true)