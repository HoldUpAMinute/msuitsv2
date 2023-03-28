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