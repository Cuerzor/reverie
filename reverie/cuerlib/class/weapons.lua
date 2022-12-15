local Lib = LIB;

local Weapons = Lib:NewClass();
local function GetPlayerData(player)
    local data = Lib:GetEntityLibData(player);
    data._WEAPONS = data._WEAPONS or {
        noWeapon = false,
        pickaxeBanned = false,
        urnBanned = false,
        ludoTear = nil
    }
    return data._WEAPONS;
end
-- local function GetTempPlayerData(player, create)
    
--     local data = Mod:GetEntityLibData(player, true);
--     if (create) then
--         data._WEAPONS = data._WEAPONS or {
--             Blindfolded = false
--         }
--     end
--     return data._WEAPONS;
-- end

local function GetWeaponData(weapon, create)
    local data = Lib:GetEntityLibData(weapon);
    if (create) then
        data._WEAPONS = data._WEAPONS or {
            effected = false;
        }
    end
    return data._WEAPONS;
end

local function StopOrHideWeapons(player)
    local playerData = GetPlayerData(player);
    local weaponEntity = player:GetActiveWeaponEntity();
    if (weaponEntity ~= nil) then
        local weaponData = GetWeaponData(weaponEntity, true);
        local entType = weaponEntity.Type;
        local variant = weaponEntity.Variant;
        local subtype = weaponEntity.SubType;

        local willBan = true;
        -- Pickaxe
        if (entType == 8 and variant == 9 and subtype == 0) then
            if (playerData.pickaxeBanned) then
                local effects = player:GetEffects();
                if (effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_NOTCHED_AXE)) then
                    effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_NOTCHED_AXE, -1)
                end
            end
            willBan = false;
        end

        -- Sword of Spirit
        if (entType == 8 and (variant == 10 or variant == 11)) then
            willBan = false;
        end

        -- Urn of soul
        if (entType == 1000 and variant == 178) then
            if (playerData.urnBanned) then
                local effects = player:GetEffects();
                if (effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_URN_OF_SOULS)) then
                    effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_URN_OF_SOULS, -1)
                end
            end
            willBan = false;
        end

        if (willBan) then
            weaponEntity.EntityCollisionClass = 0
            weaponEntity.Visible = false;
            weaponEntity:Remove();
            weaponData.effected = true;
            -- Epic Fetus Target
            if (entType == 1000 and variant == 30) then
                weaponEntity:Remove();
            end

            if (player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE)) then
                weaponEntity.Position = player.Position + player:GetShootingJoystick():Normalized() * 10;
            end
        end
    end
end

------ Public Functions -------------


function Weapons:BanishWeapon(player, pickaxe, urn)
    pickaxe = pickaxe or false;
    local playerData = GetPlayerData(player);
    playerData.noWeapon = true;
    playerData.pickaxeBanned = pickaxe;
    playerData.urnBanned = urn;
end

function Weapons:UnbanWeapon(player)
    local playerData = GetPlayerData(player);
    playerData.noWeapon = false;
    playerData.pickaxeBanned = false;
    playerData.urnBanned = false;
    -- Remove all effected entities to reset the state.;
    for _,ent in pairs(Isaac.GetRoomEntities()) do
        local weaponData = GetWeaponData(ent, false);
        if (weaponData and weaponData.effected) then
            ent:Remove();
        end
    end
    player:UpdateCanShoot()
end


function Weapons:IsWeaponsBanned(player)
    local playerData = GetPlayerData(player);
    return (playerData and playerData.noWeapon) or false;
end

------ Events ----------
local function PostPlayerUpdate(mod, player)
    local playerData = GetPlayerData(player);
    local blindfolded = not player:CanShoot();
    local game = Game();
    if (playerData.noWeapon) then
        if (not blindfolded) then
            local OldChallenge=game.Challenge
            game.Challenge=6
            player:UpdateCanShoot()
            game.Challenge=OldChallenge
        end
        StopOrHideWeapons(player);
    end
end
Weapons:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate);

return Weapons;