local Lib = _TEMP_CUERLIB;

local Weapons = Lib:NewClass();
local function GetPlayerData(player)
    local data = Lib:GetLibData(player);
    data._WEAPONS = data._WEAPONS or {
        noWeapon = false,
        pickaxeBanned = false,
        ludoTear = nil
    }
    return data._WEAPONS;
end
local function GetTempPlayerData(player, create)
    
    local data = Lib:GetLibData(player, true);
    if (create) then
        data._WEAPONS = data._WEAPONS or {
            Blindfolded = false
        }
    end
    return data._WEAPONS;
end

local function GetWeaponData(weapon)
    local data = Lib:GetLibData(weapon);
    data._WEAPONS = data._WEAPONS or {
        effected = false;
    }
    return data._WEAPONS;
end

local function StopOrHideWeapons(player)
    local playerData = GetPlayerData(player);
    local weaponEntity = player:GetActiveWeaponEntity();
    if (weaponEntity ~= nil) then
        local weaponData = GetWeaponData(weaponEntity);
        local entType = weaponEntity.Type;
        local variant = weaponEntity.Variant;

        local willBan = true;
        -- Pickaxe
        if (entType == 8 and variant == 9) then
            willBan = playerData.pickaxeBanned;
        end

        -- Sword of Spirit
        if (entType == 8 and (variant == 10 or variant == 11)) then
            willBan = false;
        end

        -- Urn of soul
        if (entType == 1000 or variant == 178) then
            willBan = false;
        end

        if (willBan) then
            weaponEntity.EntityCollisionClass = 0
            weaponEntity.CollisionDamage = 0
            weaponEntity:SetColor(Color(0,0,0,0,0,0,0), 1, 0, false, false);
            weaponEntity.SpriteScale = Vector.Zero;

            -- Epic Fetus Target
            if (entType == 1000 and variant == 30) then
                weaponEntity:Remove();
            end
            weaponData.effected = true;

            if (player:HasWeaponType(WeaponType.WEAPON_LUDOVICO_TECHNIQUE)) then
                if (entType == EntityType.ENTITY_TEAR) then
                    playerData.ludoTear = weaponEntity:ToTear();
                end
            end
            if (playerData.ludoTear) then
                playerData.ludoTear.Position = player.Position + player:GetShootingJoystick():Normalized() * 10;
            end
        end
    end
end


------ Public Functions -------------
function Weapons.BanishWeapon(player, pickaxe)
    pickaxe = pickaxe or false;
    local playerData = GetPlayerData(player);
    playerData.noWeapon = true;
    playerData.pickaxeBanned = pickaxe;
    -- player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY);
    -- player:EvaluateItems();
end

function Weapons.UnbanWeapon(player)
    local playerData = GetPlayerData(player);
    playerData.noWeapon = false;
    playerData.pickaxeBanned = false;
    -- -- Set Player's Fire delay and familiar's fire delay.
    -- player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY);
    -- player:EvaluateItems();
    -- player.FireDelay = 0;
    -- player.HeadFrameDelay = 1;
    -- for i, ent in pairs(Isaac.FindByType(3)) do
    --     local familiar = ent:ToFamiliar();
    --     if (familiar.Player == player) then
    --         familiar.FireCooldown = 1;
    --     end
    -- end

    -- Remove all effected entities to reset the state.;
    for _,ent in pairs(Isaac.GetRoomEntities()) do
        local weaponData = ent:GetData();
        if (weaponData._CUERLIB_DATA ~= nil and 
        weaponData._CUERLIB_DATA.Weapons ~= nil and weaponData._CUERLIB_DATA.Weapons.effected) then
            ent:Remove();
        end
    end
end


function Weapons:IsWeaponsBanned(player)
    local playerData = GetPlayerData(player);
    return (playerData and playerData.noWeapon) or false;
end

------ Events ----------
function Weapons:onPlayerEffect(player)
    local playerData = GetPlayerData(player);
    local tempData = GetTempPlayerData(player, false);
    -- effects = player:GetEffects();
    --local blindfolded = effects:HasNullEffect(NullItemID.ID_BLINDFOLD);
    local blindfolded = tempData and tempData.Blindfolded;
    local game = Game();
    if (playerData.noWeapon) then
        if (not blindfolded) then
            local OldChallenge=game.Challenge
            game.Challenge=6
            player:UpdateCanShoot()
            tempData = GetTempPlayerData(player, true);
            tempData.Blindfolded = true;
            game.Challenge=OldChallenge
        end
        StopOrHideWeapons(player);
    else
        if (blindfolded) then
            local OldChallenge=game.Challenge
            game.Challenge=0
            player:UpdateCanShoot()
            tempData = GetTempPlayerData(player, true);
            tempData.Blindfolded = false;
            game.Challenge=OldChallenge
        end
    end
end
Weapons:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Weapons.onPlayerEffect);

-- function Weapons:evaluateCache(player, flag)
--     local playerData = GetPlayerData(player);
--     if (playerData.noWeapon and not player:HasWeaponType(WeaponType.WEAPON_SPIRIT_SWORD)) then
--         if (flag == CacheFlag.CACHE_FIREDELAY) then
--             Lib.Stats:AddTearsModifier(player, function (tears)
--                 return 0.0001;
--             end, 1000000)
--         end
--     end
-- end
-- Weapons:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Weapons.evaluateCache);


return Weapons;