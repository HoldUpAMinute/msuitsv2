mSuits = mSuits or {}
mSuits.Config = mSuits.Config or {}

mSuits.Config.Suits = {
    ["Tier 1"] = {
        ["Name"] = "Tier 1",
        ["Health"] = 100, // max & starting health
        ["Armor"] = 100,
        ["Model"] = "models/auditor/r6s/rook/chr_gign_lifeline_outbreak.mdl",
        ["Speed"] = 100,
        ["Gravity"] = 1,
        ["Ability"] = "none",
        ["weaponScale"] = 1,
        ["Scale"] = 1, // scale the weapon damage any? 1 is default.
    },
    ["Tier 2"] = {
        ["Name"] = "Tier 2",
        ["Health"] = 250, // max & starting health
        ["Armor"] = 100,
        ["Model"] = "models/arachnit/csgoheavyphoenix/tm_phoenix_heavyplayer.mdl",
        ["Speed"] = 100,
        ["Gravity"] = 1,
        ["Ability"] = "none",
        ["weaponScale"] = 1,
        ["Scale"] = 1, // scale the weapon damage any? 1 is default
    },
    ["Tier 3"] = {
        ["Name"] = "Tier 3",
        ["Health"] = 300, // max & starting health
        ["Armor"] = 200,
        ["Model"] = "models/kryptonite/inf_war_machine/inf_war_machine.mdl",
        ["Speed"] = 100,
        ["Gravity"] = 1,
        ["Ability"] = "none",
        ["weaponScale"] = 1,
        ["Scale"] = 1, 
    },
    ["Tier 4"] = {
        ["Name"] = "Tier 4",
        ["Health"] = 500, // max & starting health
        ["Armor"] = 400,
        ["Model"] = "models/kryptonite/inf_war_machine/inf_war_machine.mdl",
        ["Speed"] = 100,
        ["Gravity"] = 1,
        ["Ability"] = "none",
        ["weaponScale"] = 1,
        ["Scale"] = 1, 
    },
    ["Tier 5"] = {
        ["Name"] = "Tier 5",
        ["Health"] = 1000, // max & starting health
        ["Armor"] = 400,
        ["Model"] = "models/mailer/characters/blackknight.mdl",
        ["Speed"] = 100,
        ["Gravity"] = 1,
        ["Ability"] = "none",
        ["weaponScale"] = 1,
        ["Scale"] = 1, 
    },
    ["Admin Suit V2"] = {
        ["Name"] = "Admin Suit V2",
        ["Health"] = 50000, // max & starting health
        ["Armor"] = 1000,
        ["Model"] = "models/player/combine_soldier_prisonguard.mdl",
        ["Speed"] = 160,
        ["Gravity"] = 1,
        ["Ability"] = "none",
        ["weaponScale"] = 1,
        ["Scale"] = 1, 
    },
    ["Admin Suit V3"] = {
        ["Name"] = "Admin Suit V3",
        ["Health"] = 40000, // max & starting health
        ["Armor"] = 2500,
        ["Model"] = "models/player/nmickey/nmickey.mdl",
        ["Speed"] = 180,
        ["Gravity"] = 1,
        ["Ability"] = "none",
        ["weaponScale"] = 1,
        ["Scale"] = 1, 
    },
    ["Hypno Suit"] = {
        ["Name"] = "Hypno Suit",
        ["Health"] = 50000, // max & starting health
        ["Armor"] = 1000,
        ["Model"] = "models/player/dewobedil/persona/futaba/dance_p.mdl",
        ["Speed"] = 100,
        ["Gravity"] = 1,
        ["Ability"] = "none",
        ["weaponScale"] = 1,
        ["Scale"] = 1, 
    },
    ["Ultra God Suit"] = {
        ["Name"] = "Ultra God Suit",
        ["Health"] = 25000, // max & starting health
        ["Armor"] = 1000,
        ["Model"] = "models/epangelmatikes/MTU/MTUltimate.mdl",
        ["Speed"] = 100,
        ["Gravity"] = 1,
        ["Ability"] = "none",
        ["weaponScale"] = 1,
        ["Scale"] = 1,
    },
    ["Fallen God Suit"] = {
        ["Name"] = "Fallen God Suit",
        ["Health"] = 50000, // max & starting health
        ["Armor"] = 1000,
        ["Model"] = "models/mailer/characters/cordana.mdl",
        ["Speed"] = 100,
        ["Gravity"] = 1,
        ["Ability"] = "none",
        ["weaponScale"] = 1,
        ["Scale"] = 1,
    },
    ["Tier God Slayer"] = {
        ["Name"] = "Tier God Slayer",
        ["Health"] = 75000, // max & starting health
        ["Armor"] = 1000,
        ["Model"] = "models/reverse/ironman_endgame/ironman_endgame.mdl",
        ["Speed"] = 100,
        ["Gravity"] = 1,
        ["Ability"] = "none",
        ["weaponScale"] = 1,
        ["Scale"] = 1,
    },
    ["Minutes Suit"] = {
        ["Name"] = "Minutes Suit",
        ["Health"] = 100000, // max & starting health
        ["Armor"] = 1000,
        ["Model"] = "models/player/dewobedil/fire_emblem_warriors/camilla/default_p.mdl",
        ["Speed"] = 500,
        ["Gravity"] = 1,
        ["Ability"] = "Teleport",
        ["weaponScale"] = 1,
        ["Scale"] = 1,
        ["OnUse"] = function(ply)
            ply:ChatPrint("You have used your ability!")
            if ply.mSuits_Teleport then return end
            if ply:KeyDown(KEY_T) then
                local tr = util.TraceLine({
                    start = ply:GetShootPos(),
                    endpos = ply:GetShootPos() + ply:GetAimVector() * 1000,
                    filter = ply
                })
                if tr.Hit then
                    ply:SetPos(tr.HitPos)
                    ply:ChatPrint("You have teleported to your location")
                    ply.mSuits_Teleport = true
                    timer.Simple(120, function()
                        ply.mSuits_Teleport = false
                    end)
                end
            end
        end
    }
}

mSuits.Config.Abilities = {
    ["god"] = {
        ["Name"] = "god",
        ["Cooldown"] = 10,
        ["Duration"] = 10,
        ["Restricted"] = true, 
        ["OnUse"] = function(ply)
            if ply.mSuits_God then return end
            if ply:KeyDown(KEY_E) then
                ply:GodEnable()
                ply:ChatPrint("You are now invincible for  minutes")
                ply:SetMaterial("models/debug/debugwhite")
                ply:SetColor(Color(255, 255, 255, 0))
                ply.mSuits_God = true
                timer.Simple(self.Duration * 60, function()
                    ply:GodDisable()
                    ply:SetMaterial("")
                    ply:SetColor(Color(255, 255, 255, 255))
                    timer.Simple(self.Cooldown, function()
                        ply.mSuits_God = false
                    end)
                end)
            end
        end
    },
    ["jetpack"] = {
        ["Name"] = "jetpack",
        ["Cooldown"] = 10, 
        ["Duration"] = 10, 
        ["OnUse"] = function( ply )
            if ply:KeyDown( KEY_E ) then
                if not ply.mSuits_Jetpack or ply.mSuits_JetCoolDown then
                    ply.mSuits_Jetpack = true
                    ply:ChatPrint( "You are now in jetpack mode. Press E to fly." )
                    timer.Simple( self.Duration * 60, function()
                        ply.mSuits_Jetpack = false
                        ply.mSuits_JetCoolDown = true
                        ply:ChatPrint( "You are no longer in jetpack mode." )
                        timer.Simple( self.Cooldown * 60, function()
                            ply.mSuits_JetCoolDown = false
                        end )
                    end )
                else
                    ply.mSuits_Jetpack = false
                    ply:ChatPrint( "You are no longer in jetpack mode." )
                end
                ply:SetMaterial( "models/debug/debugwhite" )
                ply:SetColor( Color( 255, 255, 255, 0 ) )
            end
        end
    },
    ["speed"] = {
        ["Name"] = "speed",
        ["Cooldown"] = 10, 
        ["Duration"] = 10, 
        ["OnUse"] = function( ply )
            if ply:KeyDown( KEY_E ) then
                if not ply.mSuits_Speed or ply.mSuits_SpeedCoolDown then
                    ply.mSuits_Speed = true
                    ply:ChatPrint( "You are now in speed mode. Press E to speed." )
                    timer.Simple( self.Duration * 60, function()
                        ply.mSuits_Speed = false
                        ply.mSuits_SpeedCoolDown = true
                        ply:ChatPrint( "You are no longer in speed mode." )
                        timer.Simple( self.Cooldown * 60, function()
                            ply.mSuits_SpeedCoolDown = false
                        end )
                    end )
                else
                    ply.mSuits_Speed = false
                    ply:ChatPrint( "You are no longer in speed mode." )
                end
            end
        end
    },
    ["Teleport"] = {
        ["Name"] = "Teleport",
        ["Cooldown"] = 10, 
        ["Duration"] = 10, 
        ["OnUse"] = function( ply )
            if ply:KeyDown( KEY_T ) then
                if ply.mSuits_TeleportCooldown then return end
                if not ply.mSuits_Teleport then
                    ply.mSuits_Teleport = true
                    ply.mSuits_TeleportPos = ply:GetPos()
                    ply:ChatPrint( "You are now in teleport mode. Press E to teleport." )
                else
                    ply.mSuits_Teleport = false
                    ply:SetPos(mSuits_TeleportPos)
                    ply.mSuits_TeleportCooldown = true
                    ply:ChatPrint( "You are no longer in teleport mode." )
                    timer.Simple( self.Cooldown * 60, function()
                        ply.mSuits_TeleportCooldown = false
                    end )
                end
            end
        end
    },
    ["Invisible"] = {
        ["Name"] = "Invisible",
        ["Cooldown"] = 10, 
        ["Duration"] = 10, 
        ["OnUse"] = function( ply )
            if ply:KeyDown( KEY_E ) then
                if not ply.mSuits_Invisible or ply.mSuits_InvisibleCoolDown then
                    ply.mSuits_Invisible = true
                    ply:SetMaterial( "models/debug/debugwhite" )
                    ply:SetColor( Color( 255, 255, 255, 0 ) )
                    ply:ChatPrint( "You are now invisible." )
                    timer.Simple( self.Cooldown, function()
                        ply.mSuits_InvisibleCoolDown = false
                    end)
                end
                timer.Simple( self.Duration, function()
                    ply.mSuits_Invisible = false
                    ply:SetMaterial( "" )
                    ply:SetColor( Color( 255, 255, 255, 255 ) )
                    ply:ChatPrint( "You are no longer invisible." )
                end)
            end
        end
    },
    ["Slay"] = {
        ["Name"] = "Slay",
        ["Cooldown"] = 10, 
        ["Duration"] = 10, 
        ["OnUse"] = function( ply )
            if ply:KeyDown( KEY_E ) then
                if not ply.mSuits_Slay then
                    ply.mSuits_Slay = true
                    local poorbitch = ply:GetEyeTrace().Entity
                    poorbitch:Kill()
                    poorbitch:ChatPrint( "You have been slayed." )
                    timer.Simple( self.Cooldown, function()
                        ply.mSuits_Slay = false
                    end)
                end
            end
        end
    }
}