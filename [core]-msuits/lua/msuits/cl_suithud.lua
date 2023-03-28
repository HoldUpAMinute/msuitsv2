mSuits = mSuits or {}
mHud = mHud or {}

local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true
}

hook.Add( "HUDShouldDraw", "mHud.DoNotDraw", function( name )
	if ( hide[ name ] ) then
		return false
	end
end )

Professor = Professor or {}
Professor.Vgui = Professor.Vgui or {}

local function scale(value)
    return math.max(value * (ScrH() / 1080), 1)
end



function FormatMoneyWithLetter(money)
    local money = tonumber(money)

    if money >= 10000000000000000000000000000000 then
        return math.Round(money / 10000000000000000000000000000, 2) .. "Y"
    elseif money >= 10000000000000000000000000 then
        return math.Round(money / 1000000000000000000000000, 2) .. "U"
    elseif money >= 1000000000000000000000 then
        return math.Round(money / 1000000000000000000, 2) .. "S"
    elseif money >= 1000000000000000 then
        return math.Round(money / 1000000000000000, 2) .. "Q"
    elseif money >= 1000000000000 then
        return math.Round(money / 1000000000000, 2) .. "T"
    elseif money >= 1000000000 then
        return math.Round(money / 1000000000, 2) .. "B"
    elseif money >= 1000000 then
        return math.Round(money / 1000000, 2) .. "M"
    elseif money >= 1000 then
        return math.Round(money / 1000, 2) .. "K"
    else
        return money
    end
end

local materials = {}
file.CreateDir("elite-copy")

Professor.Vgui.GetImgur = function(id, callback, useproxy, matSettings)
    if materials[id] then return callback(materials[id]) end

    if file.Exists("elite-copy/" .. id .. ".png", "DATA") then
        materials[id] = Material("../data/elite-copy/" .. id .. ".png", matSettings or "noclamp smooth mips")

        return callback(materials[id])
    end

    http.Fetch(useproxy and "https://proxy.duckduckgo.com/iu/?u=https://i.imgur.com" or "https://i.imgur.com/" .. id .. ".png", function(body, len, headers, code)
        if len > 2097152 then
            materials[id] = Material("nil")

            return callback(materials[id])
        end

        file.Write("elite-copy/" .. id .. ".png", body)
        materials[id] = Material("../data/elite-copy/" .. id .. ".png", matSettings or "noclamp smooth mips")

        return callback(materials[id])
    end, function(error)
        if useproxy then
            materials[id] = Material("nil")

            return callback(materials[id])
        end

        return Professor.Vgui.GetImgur(id, callback, true)
    end)
end

do
    local min = math.min
    local curTime = CurTime

    Professor.Vgui.DrawProgressWheel = function(x, y, w, h, col)
        local progSize = min(w, h)
        surface.SetMaterial(progressMat)
        surface.SetDrawColor(col.r, col.g, col.b, col.a)
        surface.DrawTexturedRectRotated(x + w * .5, y + h * .5, progSize, progSize, -curTime() * 100)
    end

    drawProgressWheel = Professor.Vgui.DrawProgressWheel
end

local materials_img = {}
local grabbingMaterials = {}
local getImgur = Professor.Vgui.GetImgur

getImgur("635PPvg", function(mat)
    progressMat = mat
end)

Professor.Vgui.DrawImgur = function(x, y, w, h, imgurId, col)
    if not materials_img[imgurId] then
        drawProgressWheel(x, y, w, h, col)
        if grabbingMaterials[imgurId] then return end
        grabbingMaterials[imgurId] = true

        getImgur(imgurId, function(mat)
            materials_img[imgurId] = mat
            grabbingMaterials[imgurId] = nil
        end)

        return
    end

    surface.SetMaterial(materials_img[imgurId])
    surface.SetDrawColor(col.r, col.g, col.b, col.a)
    surface.DrawTexturedRect(x, y, w, h)
end

Professor.Vgui.DrawImgurRotated = function(x, y, w, h, rot, imgurId, col)
    if not materials_img[imgurId] then
        drawProgressWheel(x - w * .5, y - h * .5, w, h, col)
        if grabbingMaterials[imgurId] then return end
        grabbingMaterials[imgurId] = true

        getImgur(imgurId, function(mat)
            materials_img[imgurId] = mat
            grabbingMaterials[imgurId] = nil
        end)

        return
    end

    surface.SetMaterial(materials_img[imgurId])
    surface.SetDrawColor(col.r, col.g, col.b, col.a)
    surface.DrawTexturedRectRotated(x, y, w, h, rot)
end

local function formattext(name, len)
    len = len or 19

    if #name > len then
        name = string.sub(name, 1, len) .. "..."
    end

    return name
end

local function wepformattext(name, len)
    len = len or 2

    if #name > len then
        name = string.sub(name, 1, len) .. "..."
    end

    return name
end


surface.CreateFont("EliteCopy", {
    font = "Montserrat Medium",
    size = scale(27),
})

surface.CreateFont("BEliteCopy", {
    font = "Montserrat Bold",
    size = scale(28),
})

Professor.Vgui.BuildTools = {
    weapon_physgun = true,
    gmod_tool = true,
    weapon_physcannon = true,
}

local scrw, scrh = ScrW(), ScrH()
local w, h = scale(400), scale(150)
local x, y = scale(10), scrh - h - scale(10)
local weaponW, weaponH = scale(240), scale(80)
local weaponX, weaponY = scrw - scale(10) - weaponW, scrh - scale(10) - weaponH
local AnimationSpeed = 3
local AnimationHealth = 0
local AnimationArmor = 0
local AnimationProps = 0

--LocalPlayer():Nick()
-- surface.SetFont("EliteCopy")
-- local tw, _ = surface.GetTextSize("wwwwwwwwwwwwwwww")
-- print(tw)
hook.Add("HUDPaint", "EliteCopy", function()
    local ply = LocalPlayer()
    draw.RoundedBox(8, x, y, w, h, Color(23, 23, 23))
    draw.RoundedBox(8, x, y, w, h * .18, Color(28, 28, 28))
    draw.SimpleText("Flex Networks", "BEliteCopy", x + scale(5), y + h * .18 * .5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    Professor.Vgui.DrawImgur(x + w - h * .2, y, h * .2, h * .2, "y7qmhzT", color_white)
    draw.SimpleText("1861", "BEliteCopy", x + w - scale(5) - h * .2, y + h * .18 * .5, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    Professor.Vgui.DrawImgur(h - h * .2 * .75, y + h * .3 - h * .2 * .5, h * .2, h * .2, "6xh00Vt", color_white)
    draw.SimpleText(formattext(ply:Nick(), 24), "EliteCopy", x + h, y + h * .3, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    Professor.Vgui.DrawImgur(h - h * .2 * .75, y + h * .46 - h * .2 * .5, h * .2, h * .2, "ouQiQHb", color_white)
    draw.SimpleText(formattext(team.GetName(ply:Team()), 24), "EliteCopy", x + h, y + h * .46, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    Professor.Vgui.DrawImgur(h - h * .2 * .75, y + h * .63 - h * .2 * .5, h * .2, h * .2, "3Qinfbn", color_white)
    draw.SimpleText(formattext("$" .. FormatMoneyWithLetter(ply:getDarkRPVar("money")), 24), "EliteCopy", x + h, y + h * .63, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    Professor.Vgui.DrawImgur(h - h * .2 * .75, y + h * .85 - h * .2 * .5, h * .2, h * .2, "a7rxzZ4", color_white)
    AnimationArmor = math.Approach(AnimationArmor, ply:Armor(), AnimationSpeed)
    draw.RoundedBoxEx(0, x + h, y + h * .76, (w - h - scale(5)) / ply:GetMaxArmor() * math.Clamp(AnimationArmor, 0, ply:GetMaxArmor()), h * .19, Color(25, 101, 201), false, false, true, true)
    draw.RoundedBox(0, x + h, y + h * .75, w - h - scale(5), h * .16, Color(28, 28, 28))
    AnimationHealth = math.Approach(AnimationHealth, ply:Health(), AnimationSpeed)
    draw.RoundedBoxEx(0, x + h, y + h * .75, (w - h - scale(5)) / ply:GetMaxHealth() * math.Clamp(AnimationHealth, 0, ply:GetMaxHealth()), h * .16, Color(206, 32, 32), true, true, true, true)
    local weapon = ply:GetActiveWeapon()
    if not IsValid(ply) or not IsValid(weapon) then return end
    local wepPrint = string.upper(weapon:GetPrintName())
    if ply:InVehicle() then return end
    if weapon:Clip1() < 0 and not Professor.Vgui.BuildTools[weapon:GetClass()] then return end
    draw.RoundedBox(5, weaponX, weaponY, weaponW, weaponH, Color(23, 23, 23))
    draw.RoundedBoxEx(5, weaponX, weaponY, weaponW, weaponH * .4, Color(28, 28, 28), true, true, false, false)
    draw.SimpleText(wepformattext(wepPrint, 19), "EliteCopy", weaponX + scale(5), weaponY + weaponH * .2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(weapon:Clip1() .. "/" .. ply:GetAmmoCount(weapon:GetPrimaryAmmoType()), "EliteCopy", weaponX + weaponW * .5, weaponY + weaponH * .65, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    if Professor.Vgui.BuildTools[weapon:GetClass()] then
        local MProps = "N/A"

        if GetConVar("sbox_maxprops"):GetInt() > -1 then
            MProps = GetConVar("sbox_maxprops"):GetInt()
        end

        AnimationProps = math.Approach(AnimationProps, ply:GetCount("props"), AnimationSpeed)
        draw.RoundedBox(5, weaponX, weaponY, weaponW, weaponH, Color(23, 23, 23))
        draw.RoundedBoxEx(5, weaponX, weaponY, weaponW, weaponH * .4, Color(28, 28, 28), true, true, false, false)
        draw.SimpleText(wepPrint, "EliteCopy", weaponX + scale(5), weaponY + weaponH * .2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.RoundedBox(5, weaponX + weaponW * .025, weaponY + weaponH * .5, weaponW * .95, weaponH - weaponH * .6, Color(20, 130, 233))
        draw.RoundedBox(5, weaponX + weaponW * .025, weaponY + weaponH * .5, weaponW * .95 / MProps * math.Clamp(AnimationProps, 0, MProps), weaponH - weaponH * .6, Color(13, 88, 228))
        draw.SimpleText("Props: " .. ply:GetCount("props") .. "/" .. MProps, "EliteCopy", weaponX + weaponW * .5, weaponY + weaponH * .7, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)

--draw.RoundedBox(8, x + scale(10) , y + scale(10), h - scale(20), h - scale(20), Color(32,32,32))
--   draw.RoundedBox(8, x, y, w, h, Color(23, 23, 23))
if IsValid(Professor.Vgui.AvPanel) then
    Professor.Vgui.AvPanel:Remove()
end

Professor.Vgui.AvPanel = vgui.Create("AvatarImage")
Professor.Vgui.AvPanel:SetSize(h - scale(20) - h * .18, h - scale(20) - h * .18)
Professor.Vgui.AvPanel:SetPos(x + scale(10), y + scale(10) + h * .18)
Professor.Vgui.AvPanel:SetPlayer(LocalPlayer(), 184)