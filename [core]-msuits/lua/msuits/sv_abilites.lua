hook.Add("PhysgunPickup", "mSuits.PhysgunPickup", function(ply, ent)
    if ply:GetNWString("mSuits_Suit") ~= "Admin Suit V2" and ent:IsPlayer() then
        ply._mSuitsPhysgunPickup = true
        ent._MSuitsStoreWeapons = ent:GetWeapons()
        ent:StripWeapons()
        return false
    end

    if ent:IsPlayer() then
        return true
    end
end)

hook.Add("PhysgunDrop", "mSuits.PhysgunDrop", function(ply, ent)
    if ply:GetNWString("mSuits_Suit") == "Admin Suit V2" and ent:IsPlayer() then
        ply._mSuitsPhysgunPickup = false
        ent:UnLock()
        for k, v in pairs(ent._MSuitsStoreWeapons) do
            ent:Give(v:GetClass())
        end
        return false
    end

end)