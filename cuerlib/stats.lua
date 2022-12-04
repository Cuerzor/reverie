local Lib = _TEMP_CUERLIB;
local Stats = Lib:NewClass();

function Stats.GetAddFireRate(firedelay, addition)
    return 30 / (30 / (firedelay + 1) + addition) - 1;
end

local function GetPlayerData(player, init)
    local data = Lib:GetLibData(player, true);
    if (init) then
        data.Stats = data.Stats or {
            Damage = {
                Multiplier = 1,
                DamageUp = 0,
                Flat = 0
            },
            Speed = {
                Limit = -1
            },
            Tears = {
                TearsUp = 0,
                Modifiers = {}
            }
        }
    end
    return data.Stats;
end

local function ResetDamageCaches(player)
    local data = GetPlayerData(player, true);
    data.Damage.Multiplier = 1;
    data.Damage.DamageUp = 0;
    data.Damage.Flat = 0;
end

local function ResetTearsCaches(player)
    local data = GetPlayerData(player, true);
    data.Tears.TearsUp = 0;
    data.Tears.Modifiers = {};
end

function Stats:GetDamageUp(player)
    local data = GetPlayerData(player, false);
    return (data and data.Damage.DamageUp) or 0;
end
function Stats:SetDamageUp(player, value)
    local data = GetPlayerData(player, true);
    data.Damage.DamageUp = value;
end
function Stats:AddDamageUp(player, value)
    local data = GetPlayerData(player, true);
    data.Damage.DamageUp = data.Damage.DamageUp + value;
end

function Stats:GetFlatDamage(player)
    local data = GetPlayerData(player, false);
    return (data and data.Damage.Flat) or 0;
end
function Stats:SetFlatDamage(player, value)
    local data = GetPlayerData(player, true);
    data.Damage.Flat = value;
end
function Stats:AddFlatDamage(player, value)
    local data = GetPlayerData(player, true);
    data.Damage.Flat = data.Damage.Flat + value;
end

function Stats:GetDamageMultiplier(player)
    local data = GetPlayerData(player, false);
    return (data and data.Damage.Multiplier) or 1;
end
function Stats:SetDamageMultiplier(player, value)
    local data = GetPlayerData(player, true);
    data.Damage.Multiplier = value;
end
function Stats:MultiplyDamage(player, value)
    local data = GetPlayerData(player, true);
    data.Damage.Multiplier = data.Damage.Multiplier * value;
end
--Tears
function Stats:GetTearsUp(player)
    local data = GetPlayerData(player, false);
    return (data and data.Tears.TearsUp) or 0;
end
function Stats:SetTearsUp(player, value)
    local data = GetPlayerData(player, true);
    data.Tears.TearsUp = value;
end
function Stats:AddTearsUp(player, value)
    local data = GetPlayerData(player, true);
    data.Tears.TearsUp = data.Tears.TearsUp + value;
end
function Stats:AddTearsModifier(player, func, priority)
    priority = priority or 0;
    local data = GetPlayerData(player, true);
    table.insert(data.Tears.Modifiers, {Func = func, Priority = priority} );
end


function Stats:GetSpeedLimit(player)
    local data = GetPlayerData(player, false);
    if (data)then
        return data.Speed.Limit;
    end
    return -1;
end
function Stats:SetSpeedLimit(player, value)
    local data = GetPlayerData(player, true);
    data.Speed.Limit = value;
end

local CharacterMultipliers = {
    -- Normal characters
    [PlayerType.PLAYER_ISAAC] = 1,
    [PlayerType.PLAYER_MAGDALENA] = 1,
    [PlayerType.PLAYER_CAIN] = 1.2,
    [PlayerType.PLAYER_JUDAS] = 1.35,
    [PlayerType.PLAYER_XXX] = 1.05,
    [PlayerType.PLAYER_EVE] = function (player)
      if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON) then return 1 end
      return 0.75
    end,
    [PlayerType.PLAYER_SAMSON] = 1,
    [PlayerType.PLAYER_AZAZEL] = 1.5,
    [PlayerType.PLAYER_LAZARUS] = 1,
    [PlayerType.PLAYER_THELOST] = 1,
    [PlayerType.PLAYER_LAZARUS2] = 1.4,
    [PlayerType.PLAYER_BLACKJUDAS] = 2,
    [PlayerType.PLAYER_LILITH] = 1,
    [PlayerType.PLAYER_KEEPER] = 1.2,
    [PlayerType.PLAYER_APOLLYON] = 1,
    [PlayerType.PLAYER_THEFORGOTTEN] = 1.5,
    [PlayerType.PLAYER_THESOUL] = 1,
    [PlayerType.PLAYER_BETHANY] = 1,
    [PlayerType.PLAYER_JACOB] = 1,
    [PlayerType.PLAYER_ESAU] = 1,
  
    -- Tainted characters
    [PlayerType.PLAYER_ISAAC_B] = 1,
    [PlayerType.PLAYER_MAGDALENA_B] = 0.75,
    [PlayerType.PLAYER_CAIN_B] = 1,
    [PlayerType.PLAYER_JUDAS_B] = 1,
    [PlayerType.PLAYER_XXX_B] = 1,
    [PlayerType.PLAYER_EVE_B] = 1.2,
    [PlayerType.PLAYER_SAMSON_B] = 1,
    [PlayerType.PLAYER_AZAZEL_B] = 1.5,
    [PlayerType.PLAYER_LAZARUS_B] = 1,
    [PlayerType.PLAYER_EDEN_B] = 1,
    [PlayerType.PLAYER_THELOST_B] = 1.3,
    [PlayerType.PLAYER_LILITH_B] = 1,
    [PlayerType.PLAYER_KEEPER_B] = 1,
    [PlayerType.PLAYER_APOLLYON_B] = 1,
    [PlayerType.PLAYER_THEFORGOTTEN_B] = 1.5,
    [PlayerType.PLAYER_BETHANY_B] = 1,
    [PlayerType.PLAYER_JACOB_B] = 1,
    [PlayerType.PLAYER_LAZARUS2_B] = 1.5,
  }

local CollectibleMultipliers = {
    [CollectibleType.COLLECTIBLE_MEGA_MUSH] = function (player)
      if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) then return 1 end
      return 4
    end,
    [CollectibleType.COLLECTIBLE_MAXS_HEAD] = 1.5,
    [CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM] = function (player)
      -- Cricket's Head/Blood of the Martyr/Magic Mushroom don't stack with each other
      if player:HasCollectible(CollectibleType.COLLECTIBLE_MAXS_HEAD) then return 1 end
      return 1.5
    end,
    [CollectibleType.COLLECTIBLE_BLOOD_MARTYR] = function (player)
      if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL) then return 1 end
  
      -- Cricket's Head/Blood of the Martyr/Magic Mushroom don't stack with each other
      if
        player:HasCollectible(CollectibleType.COLLECTIBLE_MAXS_HEAD) or
        player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM)
      then return 1 end
      return 1.5
    end,
    [CollectibleType.COLLECTIBLE_POLYPHEMUS] = 2,
    [CollectibleType.COLLECTIBLE_SACRED_HEART] = 2.3,
    [CollectibleType.COLLECTIBLE_EVES_MASCARA] = 2,
    [CollectibleType.COLLECTIBLE_ODD_MUSHROOM_RATE] = 0.9,
    [CollectibleType.COLLECTIBLE_20_20] = 0.75,
    [CollectibleType.COLLECTIBLE_EVES_MASCARA] = 2,
    [CollectibleType.COLLECTIBLE_SOY_MILK] = function (player)
      -- Almond Milk overrides Soy Milk
      if player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK) then return 1 end
      return 0.2
    end,
    [CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT] = function (player)
      if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT) then return 2 end
      return 1
    end,
    [CollectibleType.COLLECTIBLE_ALMOND_MILK] = 0.33,
    [CollectibleType.COLLECTIBLE_IMMACULATE_HEART] = 1.2,
}

local CollectibleFlatDamages = {
    [CollectibleType.COLLECTIBLE_SACRED_HEART] =  function (player, num)return 0.1 end,
    [CollectibleType.COLLECTIBLE_BOZO] = function (player, num)return 0.1 end,
}

local TrinketFlatDamages = {
    [TrinketType.TRINKET_CURVED_HORN] = 2
}
  
  
  
function Stats:GetVanillaCharacterDamage(player)
    local damage = 3.5;
    local playerType = player:GetPlayerType();
    local playerMulti = CharacterMultipliers[playerType];
    if (playerMulti) then
        if (type(playerMulti)== "function") then
            damage = damage * playerMulti(player);
        else
            damage = damage * playerMulti;
        end
    end
    return damage;
end

function Stats:GetVanillaDamageMultiplier(player)
    local multiplier = 1;
    for id, multi in pairs(CollectibleMultipliers) do
        if (multi) then
            if (player:HasCollectible(id)) then
                if (type(multi)== "function") then
                    multiplier = multiplier * multi(player);
                else
                    multiplier = multiplier * multi;
                end
            end
        end
    end
    
    return multiplier;
end
function Stats:GetVanillaFlatDamage(player)
    local damage = 0;
    for id, flat in pairs(CollectibleFlatDamages) do
        if (flat) then
            local num = player:GetCollectibleNum(id);
            if (num > 0) then
                if (type(flat)== "function") then
                    damage = damage + flat(player, num);
                else
                    damage = damage + flat * num;
                end
            end
        end
    end

    for id, flat in pairs(TrinketFlatDamages) do
        if (flat) then
            local num = player:GetTrinketMultiplier(id);
            if (num > 0) then
                if (type(flat)== "function") then
                    damage = damage + flat(player, num);
                else
                    damage = damage + flat * num;
                end
            end
        end
    end
    
    return damage;
end


function Stats:GetEvaluatedDamage(player)
    
    local data = GetPlayerData(player, false);
    local originDamage = player.Damage;

    local characterDamage = Stats:GetVanillaCharacterDamage(player);
    local oMulti = Stats:GetVanillaDamageMultiplier(player);
    local oFlat = Stats:GetVanillaFlatDamage(player);
    local oDamageUps = (((originDamage / oMulti - oFlat) / characterDamage) ^ 2 - 1 ) / 1.2;

    local totalDamage = oDamageUps;
    local flat = oFlat;
    local multiplier = oMulti;
    if (data) then
        totalDamage = totalDamage + data.Damage.DamageUp;
        flat = flat + data.Damage.Flat;
        multiplier = multiplier * data.Damage.Multiplier;
    end
    
    return (characterDamage * (totalDamage * 1.2 + 1) ^ 0.5 + flat) * multiplier;
end


local PlayerTearsUps = {
    [PlayerType.PLAYER_SAMSON] = -0.1,
    [PlayerType.PLAYER_AZAZEL] = 0.5,
    [PlayerType.PLAYER_KEEPER] = -1.9,
    [PlayerType.PLAYER_JACOB] = 5/18,
    [PlayerType.PLAYER_ESAU] = -0.1,
    [PlayerType.PLAYER_XXX_B] = -0.35,
    [PlayerType.PLAYER_EVE_B] = -0.1,
    [PlayerType.PLAYER_SAMSON_B] = -0.1,
    [PlayerType.PLAYER_LAZARUS2_B] = -0.1,
    [PlayerType.PLAYER_KEEPER_B] = -2.2,
    [PlayerType.PLAYER_APOLLYON_B] = -0.5,
    [PlayerType.PLAYER_JACOB_B] = 5/18,
    [PlayerType.PLAYER_JACOB2_B] = 5/18,
}

local CollectibleTearsUps = {
    [CollectibleType.COLLECTIBLE_SAD_ONION] = 0.7,
    [CollectibleType.COLLECTIBLE_NUMBER_ONE] = 1.5,
    [CollectibleType.COLLECTIBLE_WIRE_COAT_HANGER] = 0.7,
    [CollectibleType.COLLECTIBLE_ROSARY] = 0.5,
    [CollectibleType.COLLECTIBLE_PACT] = 0.7,
    [CollectibleType.COLLECTIBLE_SMALL_ROCK] = 0.2,
    [CollectibleType.COLLECTIBLE_HALO] = 0.2,
    [CollectibleType.COLLECTIBLE_ODD_MUSHROOM_THIN] = 1.7,
    [CollectibleType.COLLECTIBLE_SACRED_HEART] = -0.4,
    [CollectibleType.COLLECTIBLE_TOOTH_PICKS] = 0.7,
    [CollectibleType.COLLECTIBLE_SMB_SUPER_FAN] = 0.2,
    [CollectibleType.COLLECTIBLE_SQUEEZY] = 0.4,
    [CollectibleType.COLLECTIBLE_DEATHS_TOUCH] = -0.3,
    [CollectibleType.COLLECTIBLE_SCREW] = 0.5,
    [CollectibleType.COLLECTIBLE_GODHEAD] = -0.3,
    [CollectibleType.COLLECTIBLE_TORN_PHOTO] = 0.7,
    [CollectibleType.COLLECTIBLE_BLUE_CAP] = 0.7,
    [CollectibleType.COLLECTIBLE_MR_DOLLY] = 0.7,
    [CollectibleType.COLLECTIBLE_EDENS_BLESSING] = 0.7,
    [CollectibleType.COLLECTIBLE_MARKED] = 0.7,
    [CollectibleType.COLLECTIBLE_BINKY] = 0.75,
    [CollectibleType.COLLECTIBLE_APPLE] = 0.3,
    [CollectibleType.COLLECTIBLE_ANALOG_STICK] = 0.35,
    [CollectibleType.COLLECTIBLE_DIVORCE_PAPERS] = 0.7,
    [CollectibleType.COLLECTIBLE_BAR_OF_SOAP] = 0.5,
    [CollectibleType.COLLECTIBLE_PLUTO] = 0.7,
    [CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION] = 0.7,
    [CollectibleType.COLLECTIBLE_SAUSAGE] = 0.5,
    -- Cannot Detect Candy Heart, Soul Locket.
}
local TrinketTearsUps = {
    [TrinketType.TRINKET_HOOK_WORM] = 0.4,
    [TrinketType.TRINKET_RING_WORM] = 0.4,
    [TrinketType.TRINKET_WIGGLE_WORM] = 0.4,
    [TrinketType.TRINKET_OUROBOROS_WORM] = 0.4,
    [TrinketType.TRINKET_DIM_BULB] = function(player)
        local activeItem = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY);
        if (activeItem > 0) then
            if (player:GetActiveCharges(ActiveSlot.SLOT_PRIMARY) + player:GetBatteryCharges(ActiveSlot.SLOT_PRIMARY) <= 0) then
                return 0.5
            end
        end
        return 0;
    end,
    [TrinketType.TRINKET_VIBRANT_BULB] = function(player)
        local activeItem = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY);
        if (activeItem > 0) then
            local maxCharges = Isaac.GetItemConfig():GetCollectible(activeItem).MaxCharges;
            if (player:GetActiveCharges(ActiveSlot.SLOT_PRIMARY) + 
            player:GetBatteryCharges(ActiveSlot.SLOT_PRIMARY) + 
            player:GetEffectiveSoulCharges() + 
            player:GetEffectiveBloodCharges() >= maxCharges) then
                return 0.2
            end
        end
        return 0;
    end,

}
local MiscTearsUps = function (player)
    local tearsUp = 0;
    if (player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH)) then
        tearsUp = tearsUp -1.9;
    end

    if (player:HasPlayerForm(PlayerForm.PLAYERFORM_BABY)) then
        tearsUp = tearsUp - 0.3
    end
    return tearsUp;
end

local function AddTearsModifier(tears, value, reverse)
    if (reverse) then
        return tears - value;
    else
        return tears + value;
    end
end
local function MultiplyTearsModifier(tears, value, reverse)
    if (reverse) then
        return tears / value;
    else
        return tears * value;
    end
end


local VanillaTearsModifiers = {
    -- 1
    {
        function(player, tears, reverse)
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_DROPS)) then
                tears = MultiplyTearsModifier(tears, 1.2, reverse)
            end
            return tears;
        end
    },
    -- 2
    {
        function(player, tears, reverse)
            local crownCount = player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN);
            if (crownCount > 0) then
                local multiplier = 0.2 * crownCount;
                if (reverse) then
                    tears = (tears + multiplier * 30 / 11) / (multiplier + 1)
                else
                    tears = tears + multiplier * (tears - 30 / 11)
                end
            end

            if (player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B) then
                local multiplier = -0.25;
                if (reverse) then
                    tears = (tears + multiplier * 30 / 11) / (multiplier + 1)
                else
                    tears = tears + multiplier * (tears - 30 / 11)
                end
            end

            return tears;
        end
    },
    -- 3
    {
        function(player, tears, reverse)
            local effects = player:GetEffects();
            local num;
            num = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_GUILLOTINE) + 
            player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CRICKETS_BODY) + 
            player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MOMS_PERFUME) + 
            player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CAPRICORN) + 
            player:GetCollectibleNum(CollectibleType.COLLECTIBLE_PISCES);
            if (num > 0) then
                tears = AddTearsModifier(tears, 0.5 * num, reverse)
            end

            
            -- Cannot detect Experimental Treatment or Missing No.

            -- Tractor Beam.
            num = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_TRACTOR_BEAM);
            if (num > 0) then
                tears = AddTearsModifier(tears, 1 * num, reverse)
            end

            -- Cannot detect Purity (Blue).

            -- Milk!
            num = effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_MILK);
            if (num > 0) then
                tears = AddTearsModifier(tears, 1 * num, reverse)
            end
            -- Dark Prince's Crown
            if (effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_DARK_PRINCES_CROWN)) then
                tears = AddTearsModifier(tears, 2, reverse)
            end

            -- Cannot detect Void nor Black rune.

            -- Cannot detect Death's List.
            
            -- Cannot detect Brittle Bones.

            -- It Hurts
            num = effects:GetNullEffectNum(NullItemID.ID_IT_HURTS);
            if (num > 0) then
                tears = AddTearsModifier(tears, 0.8 + 0.4 * num, reverse)
            end

            -- Paschal Candle
            num = effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_PASCHAL_CANDLE);
            if (num > 0) then
                tears = AddTearsModifier(tears,  0.4 * num, reverse)
            end

            -- Wavy Cap
            num = effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_WAVY_CAP);
            if (num > 0) then
                tears = AddTearsModifier(tears,  0.75 * num, reverse)
            end

            -- Luna
            num = effects:GetNullEffectNum(NullItemID.ID_LUNA);
            if (num > 0) then
                tears = AddTearsModifier(tears, 0.5 + 0.5 * num, reverse)
            end

            -- Cannot detect Consolation Prize.
            
            -- Cancer.
            num = player:GetTrinketMultiplier(TrinketType.TRINKET_CANCER);
            if (num > 0) then
                tears = AddTearsModifier(tears, 1 * num, reverse)
            end

            -- Empress?
            if (effects:HasNullEffect(NullItemID.ID_REVERSE_EMPRESS)) then
                tears = AddTearsModifier(tears, 1.5, reverse)
            end

            -- Liquid Poop
            for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_LIQUID_POOP)) do
                local playerPosition = ent.Position + (player.Position - ent.Position) * Vector(1, 12/13);
                if (ent.Position:Distance(playerPosition) <= 20) then
                    tears = AddTearsModifier(tears, 1.5, reverse)
                    break;
                end
            end

            -- Anti-Gravity.
            if (not player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE)) then
                num = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ANTI_GRAVITY);
                if (num > 0) then
                    tears = AddTearsModifier(tears, 1 * num, reverse)
                end
            end


            return tears;
        end
    },
    -- 4
    {
        function(player, tears, reverse)
            local effects = player:GetEffects();
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER) or
            player:HasCollectible(CollectibleType.COLLECTIBLE_POLYPHEMUS)) then
                tears = MultiplyTearsModifier(tears, 0.42, reverse);
            elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE) or
            effects:HasNullEffect(NullItemID.ID_REVERSE_HANGED_MAN)) then
                tears = MultiplyTearsModifier(tears, 0.51, reverse);
            end
            
            return tears;
        end
    },
    -- 5
    {
        function(player, tears, reverse)
            
            local cSection = player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION);
            local brimstone = player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE);
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA)) then
                if (cSection) then
                    tears = 30 * tears / (30 + 4 * tears);
                else
                    local playerType = player:GetPlayerType();
                    local multiplier = 1/3;
                    local flat = 2;
                    if (player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)) then
                        multiplier = 4.3/3;
                        flat = 4.3;
                    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC)) then
                        multiplier = 1/3;
                        flat = 3;
                    elseif (playerType == PlayerType.PLAYER_THEFORGOTTEN or playerType == PlayerType.PLAYER_THEFORGOTTEN_B) then
                        multiplier = 2/3;
                    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS)) then
                        multiplier = 2/3;
                    end

                    if (reverse) then
                        tears = tears * flat / (1- tears * multiplier);
                    else
                        tears = tears / (multiplier * tears + flat);
                    end
                end
                if (brimstone) then
                    tears = 30 * tears / (30 + 20 * tears);
                end
            end
            return tears;
        end
    },
    -- 6
    {
        function(player, tears, reverse)
            local playerType = player:GetPlayerType();
            local effects = player:GetEffects();
            local haemolacria = player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA);
            local brimstone = player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE);
            local drFetus = player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS);
            local lung = player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG);
            local ipecac = player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC);
            local berserk = effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK);
            local azazel = playerType == PlayerType.PLAYER_AZAZEL;
            local forgotten = playerType == PlayerType.PLAYER_THEFORGOTTEN or playerType == PlayerType.PLAYER_THEFORGOTTEN_B;

            -- Azazel.
            if (azazel) then
                if (not drFetus and not brimstone and not haemolacria and not berserk) then
                    tears = MultiplyTearsModifier(tears, 4/15, reverse);
                end
            elseif (playerType == PlayerType.PLAYER_AZAZEL_B) then
                if (not drFetus and not brimstone and not haemolacria and not berserk) then
                    tears = MultiplyTearsModifier(tears, 1/3, reverse);
                end
            elseif (forgotten) then
                if (not haemolacria and not berserk) then
                    tears = MultiplyTearsModifier(tears, 4/15, reverse);
                end
            elseif (playerType == PlayerType.PLAYER_EVE_B) then
                tears = MultiplyTearsModifier(tears, 0.66, reverse);
            end
            if (not haemolacria and not berserk and not forgotten) then
                if (drFetus) then
                    tears = MultiplyTearsModifier(tears, 0.4, reverse);
                elseif (brimstone) then
                    tears = MultiplyTearsModifier(tears, 1/3, reverse);
                elseif (ipecac and not azazel) then
                    tears = MultiplyTearsModifier(tears, 1/3, reverse);
                end
            end

            -- Technology 2.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2)) then
                tears = MultiplyTearsModifier(tears, 2/3, reverse);
            end
            -- Lung.
            if (lung and not azazel and not forgotten and not berserk) then
                tears = MultiplyTearsModifier(tears, 10/43, reverse);
            end
            -- Eve's Mascara.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_EVES_MASCARA)) then
                tears = MultiplyTearsModifier(tears, 0.66, reverse);
            end
            -- Almond Milk and Soy Milk.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK)) then
                tears = MultiplyTearsModifier(tears, 4, reverse);
            elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)) then
                tears = MultiplyTearsModifier(tears, 5.5, reverse);
            end
            -- Cannot Detect Epiphora.
            -- Cannot Detect Kidney Stone.

            -- Hallowed Ground, Star of Bethlehem
            for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND)) do
                local playerPos = ent.Position + (player.Position - ent.Position) * Vector(1 /ent.SpriteScale.X, 1 /ent.SpriteScale.Y);
                if (ent.Position:Distance(playerPos) < 80) then
                    tears = MultiplyTearsModifier(tears, 2.5, reverse);
                    break;
                end
            end

            -- Chariot?
            if (effects:HasNullEffect(NullItemID.ID_REVERSE_CHARIOT) or effects:HasNullEffect(NullItemID.ID_REVERSE_CHARIOT_ALT)) then
                tears = MultiplyTearsModifier(tears, 2.5, reverse);
            end

            
            return tears;
        end
    },
    -- 7
    {
        function(player, tears, reverse)
            local effects = player:GetEffects();
            local berserk = effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK);
            if (berserk) then
                if (reverse) then
                    tears = (tears - 2) / 0.5;
                else
                    tears = tears * 0.5 + 2;
                end
            end
            return tears;
        end
    },
    -- 8
    -- Cannot Detect Bloody Gust.
    -- {
    --     function(player, tears, reverse)
    --         local effects = player:GetEffects();
    --         -- Bloody Gust
    --         local num = effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BLOODY_GUST);
    --         if (num > 0) then
    --             tears = AddTearsModifier(tears, 0.05 * num^ 2 + 0.2 * num, reverse);
    --         end
    --         return tears;
    --     end
    -- }
}

function Stats:GetVanillaTearsUp(player)
    local tearsUp = 0;
    local playerTearsUp = PlayerTearsUps[player:GetPlayerType()];
    if (playerTearsUp) then
        if (type(playerTearsUp) == "function") then
            tearsUp = tearsUp + playerTearsUp(player);
        else
            tearsUp = tearsUp + playerTearsUp;
        end
    end

    for id, up in pairs(CollectibleTearsUps) do
        local num = player:GetCollectibleNum(id);
        if (num > 0) then
            if (type(up) == "function") then
                tearsUp = tearsUp + up(player, num);
            else
                tearsUp = tearsUp + up * num;
            end
        end
    end

    tearsUp = tearsUp + MiscTearsUps(player);

    return tearsUp;
end

function Stats:GetSplitVanillaTears(player)
    
    local tears = 30 / (player.MaxFireDelay + 1)
    local splitTears = tears;
    for priority = #VanillaTearsModifiers, 1, -1 do
        local functions = VanillaTearsModifiers[priority];
        for i = #functions, 1, -1 do
            local func = functions[i];
            splitTears = func(player, splitTears, true);
        end
    end
    return splitTears;
end

function Stats:GetFireDelayByTearsUp(tearsUp)
    
    if (tearsUp < -10/13) then
        return 16 - 6 * tearsUp;
    elseif (tearsUp < 0) then
        return 16 - 6 * (1.3 * tearsUp + 1) ^ 0.5 - 6 * tearsUp;
    elseif (tearsUp < 425/234) then
        return 16 - 6 * (1.3 * tearsUp + 1) ^ 0.5
    else
        return 5;
    end
end
function Stats:GetTearsUpByFireDelay(delay)
    
    if (delay > 268/13) then
        return (16 - delay)/6;
    elseif (delay > 10) then
        return 199/60 - delay / 6 - ( (5867-260 * delay) / 1200)^0.5
    elseif (delay > 5) then
        return ((16 - delay) ^ 2 /36 - 1) /1.3
    else
        return 425/234;
    end
end


function Stats:ModifyTears(player, tears)
    local result = tears;
    for priority = 1, #VanillaTearsModifiers do
        local functions = VanillaTearsModifiers[priority];
        for i = 1, #functions do
            local func = functions[i];
            result = func(player, result, false);
        end
    end
    return result;
end


function Stats:GetEvaluatedTears(player)
    
    local data = GetPlayerData(player, false);
    local origin = 30 / (player.MaxFireDelay + 1)
    local tears = origin;

    if (data) then
        -- Expected Vanilla Tears.
        --local evTears = Stats:GetSplitVanillaTears(player);
        -- local evTearsUp = Stats:GetVanillaTearsUp(player);
        -- local modTearsUp = math.min(2, data.Tears.TearsUp);
        -- -- Expected Modded Tears.
        -- local eModTears = evTears + modTearsUp;
        -- local meModTears = Stats:ModifyTears(player, eModTears);

        --tears = meModTears;

        local modMultiplier = 1;
        local maxTearsUp = 2;
        local maxMultiplier = 1.4;
        local minMultiplier = 0.6;
        local modTearsUp = data.Tears.TearsUp;
        if (modTearsUp > maxTearsUp) then
            modMultiplier = maxMultiplier;
        elseif (modTearsUp > 0) then
            modMultiplier = -((maxMultiplier - 1) / maxTearsUp ^ 2)*(modTearsUp - maxTearsUp)^2 + maxMultiplier;
        else
            modMultiplier = (1 - minMultiplier)*(0.5^modTearsUp-1) + 1
        end
        tears = tears * modMultiplier;

        table.sort(data.Tears.Modifiers, function(a, b) 
            return a.Priority < b.Priority
        end)
        for _, modi in ipairs(data.Tears.Modifiers) do
            tears = modi.Func(tears, origin);
        end
    end
    
    return tears;
end

function Stats:EvaluateCache(player, cache)
    if (cache == CacheFlag.CACHE_DAMAGE) then
        player.Damage = Stats:GetEvaluatedDamage(player);
        ResetDamageCaches(player);
    elseif (cache == CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = 30 / Stats:GetEvaluatedTears(player) - 1;
        ResetTearsCaches(player);
    elseif (cache == CacheFlag.CACHE_SPEED) then
        local limit = Stats:GetSpeedLimit(player);
        if (limit >= 0) then
            player.MoveSpeed = math.min(limit, player.MoveSpeed)
        end
    end
end

function Stats:LateRegister()
    Lib.ModInfo.Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Stats.EvaluateCache);
end

return Stats;