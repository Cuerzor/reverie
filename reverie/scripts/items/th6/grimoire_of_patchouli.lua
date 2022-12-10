local SaveAndLoad = CuerLib.SaveAndLoad
local Stages = CuerLib.Stages;
local Synergies = CuerLib.Synergies;
local Math = CuerLib.Math;
local Players = CuerLib.Players;
local Actives = CuerLib.Actives;
local Tears = CuerLib.Tears;

local Grimoire = ModItem("Grimoire of Patchouli", "Grimoire");
Grimoire.WispItems = {
    CollectibleType.COLLECTIBLE_SOL,
    CollectibleType.COLLECTIBLE_LUNA,
    CollectibleType.COLLECTIBLE_MARS,
    CollectibleType.COLLECTIBLE_MERCURIUS,
    CollectibleType.COLLECTIBLE_JUPITER,
    CollectibleType.COLLECTIBLE_VENUS,
    CollectibleType.COLLECTIBLE_SATURNUS,
};
local ElementStrings = {
    Names = {
        "#GRIMOIRE_SUN_NAME",
        "#GRIMOIRE_MOON_NAME",
        "#GRIMOIRE_FIRE_NAME",
        "#GRIMOIRE_WATER_NAME",
        "#GRIMOIRE_WOOD_NAME",
        "#GRIMOIRE_METAL_NAME",
        "#GRIMOIRE_EARTH_NAME"
    },
    Descs = {
        "#GRIMOIRE_SUN_DESCRIPTION",
        "#GRIMOIRE_MOON_DESCRIPTION",
        "#GRIMOIRE_FIRE_DESCRIPTION",
        "#GRIMOIRE_WATER_DESCRIPTION",
        "#GRIMOIRE_WOOD_DESCRIPTION",
        "#GRIMOIRE_METAL_DESCRIPTION",
        "#GRIMOIRE_EARTH_DESCRIPTION"
    }
}


local MagneticFlag = Math.GetTearFlag(66);
local RockFlag = Math.GetTearFlag(70);

function Grimoire:GetPlayerData(player, init)
    return Grimoire:GetData(player, init, function() return {
        Elements = {false,false,false,false,false,false,false}
    } end);
end

local function GetTempPlayerData(player, init)
    return Grimoire:GetTempData(player, init, function() return {
        ElementCount = nil;
    } end);
end

function Grimoire:ClearEffects(player)
    local data = Grimoire:GetPlayerData(player, false);
    if (data) then
        data.Elements = {false,false,false,false,false,false,false};
        local tempData = GetTempPlayerData(player, true);
        tempData.ElementCount = nil;
        player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG | CacheFlag.CACHE_TEARCOLOR);
        player:EvaluateItems();
    end
end

function Grimoire:GetElementCount(player)
    local tempData = GetTempPlayerData(player, true);
    if (tempData) then
        if (not tempData.ElementCount) then
            local elementCount = 0;
            local data = Grimoire:GetPlayerData(player, false);
            if (data) then
                for i, value in ipairs(data.Elements) do
                    if (value) then
                        elementCount = elementCount + 1;
                    end
                end
            end
            tempData.ElementCount = elementCount;
        end
        return tempData.ElementCount;
    end
    return 0;
end

function Grimoire:onNewLevel()
    for p, player in Players.PlayerPairs(true, true) do
        Grimoire:ClearEffects(player)
    end
end
Grimoire:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Grimoire.onNewLevel)



local function TrySetTearRock(player, tear)
    if (player) then
        local grimoireData = Grimoire:GetPlayerData(player, false);
                
        if (grimoireData) then
            local elements = grimoireData.Elements;
            if (elements[7]) then
                if (Tears:CanOverrideVariant(TearVariant.ROCK, tear.Variant)) then
                    tear:ChangeVariant(TearVariant.ROCK);
                    return true;
                end
            end
        end
    end
    return false;
end

function Grimoire:onFireTear(tear)
    local spawner = tear.SpawnerEntity;
    if (spawner ~= nil) then
        local player = spawner:ToPlayer()
        TrySetTearRock(player, tear)
    end
end
Grimoire:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Grimoire.onFireTear);

function Grimoire:useGrimoire(t, RNG, player, flags, slot)
    local grimoireData = Grimoire:GetPlayerData(player, true);
    local key = "undefined";
    local descKey = "undefined";
    
    local index = -1;
    local selected = false;
    local elements = grimoireData.Elements;
    while (not selected) do
        index = RNG:RandomInt(7) + 1;
        
        if (not elements[index]) then
            selected = true;
        end
        
        -- if all elements are selected
        if (not selected) then
            local allSelected = true;
            for i=1,7 do
                if (not elements[i]) then
                    allSelected = false;
                    goto endofwhile
                end
            end
            if (allSelected) then
                if (Actives.CanSpawnWisp(player, flags)) then
                    player:AddWisp(CollectibleType.COLLECTIBLE_UNDEFINED, player.Position);
                end
                THI.Game:StartRoomTransition(-2, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player)
                return
            end
        end
        
        ::endofwhile::
    end
    
    -- Show Item Text.
    grimoireData.Elements[index] = true;
    
    local tempData = GetTempPlayerData(player, true);
    tempData.ElementCount = Grimoire:GetElementCount(player) + 1;
    local strings = ElementStrings;
    key = strings.Names[index];
    descKey = strings.Descs[index];
    local category = THI.StringCategories.DEFAULT;
    local titleStr = THI.GetText(category, key);
    local descStr = THI.GetText(category, descKey);
    THI.Game:GetHUD():ShowItemText(titleStr, descStr, false)



    THI.SFXManager:Play(SoundEffect.SOUND_DEVILROOM_DEAL);
    if (Actives.CanSpawnWisp(player, flags)) then
        player:AddWisp(Grimoire.WispItems[index], player.Position);
    end
    
    player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG | CacheFlag.CACHE_TEARCOLOR);
    player:EvaluateItems();
    
    return { ShowAnim = true };
end
Grimoire:AddCallback(ModCallbacks.MC_USE_ITEM, Grimoire.useGrimoire, Grimoire.Item);

function Grimoire:GetTearColor(player)
    local grimoireData = Grimoire:GetPlayerData(player, false);
    
    if (not grimoireData) then
        return player.TearColor;
    end

    local elements = grimoireData.Elements;

    -- Sun
    if (elements[1]) then
        return Color(0.4, 0.15, 0.38, 1, 0.27843, 0, 0.4549);
    -- Charm
    elseif (elements[2]) then
        return Color(1, 0, 1, 1, 0.196, 0, 0);
    -- Poison
    elseif (elements[5]) then
        return Color(0.4, 0.97, 0.5, 1, 0, 0, 0)
    -- Magnetize
    elseif (elements[6]) then
        return Color(0.5, 0.5, 0.5, 1, 0, 0, 0);
    -- Slow
    elseif (elements[4]) then
        return Color(2, 2, 2, 1, 0.196, 0.196, 0.196);
    -- Burn
    elseif (elements[3]) then
        return Color(1, 1, 1, 1, 0.3, 0, 0);
    end
    return player.TearColor;
end

function Grimoire:GetTearFlags(player)
    local grimoireData = Grimoire:GetPlayerData(player, false);
    
    if (not grimoireData) then
        return 0;
    end

    local elements = grimoireData.Elements;
    local flags = 0;

    -- Sun
    if (elements[1]) then
        flags = flags | TearFlags.TEAR_HOMING;
    end
    if (elements[2]) then
        flags = flags | TearFlags.TEAR_CHARM;
    end
    if (elements[3]) then
        flags = flags | TearFlags.TEAR_BURN;
    end
    if (elements[4]) then
        flags = flags | TearFlags.TEAR_SLOW;
    end
    if (elements[5]) then
        flags = flags | TearFlags.TEAR_POISON;
    end
    if (elements[6]) then
        flags = flags | MagneticFlag;--TearFlags.TEAR_MAGNETIZE;
    end
    if (elements[7]) then
        flags = flags | RockFlag;--TearFlags.TEAR_ROCK;
    end
    return flags;
end

function Grimoire:ApplyTearEffects(player, tear)
    tear.TearFlags = tear.TearFlags | self:GetTearFlags(player);
    tear:SetColor(Grimoire:GetTearColor(player), -1, 0);
    TrySetTearRock(player, tear)
end

function Grimoire:onEvaluateCache(player, flag)
    if (flag == CacheFlag.CACHE_TEARFLAG) then
        player.TearFlags = player.TearFlags | Grimoire:GetTearFlags(player);
    elseif (flag == CacheFlag.CACHE_TEARCOLOR) then
        player.TearColor = Grimoire:GetTearColor(player);
    end
end
Grimoire:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Grimoire.onEvaluateCache);

local function GetShaderParams(mod, name)
    if (Game():GetHUD():IsVisible ( ) and name == "HUD Hack") then
        Actives.RenderActivesCount(Grimoire.Item, function(player) return Grimoire:GetElementCount(player) end)
    end
end
Grimoire:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, GetShaderParams);

return Grimoire;