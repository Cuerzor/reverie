local Collectibles = CuerLib.Collectibles;
local Tools = ModItem("Carving Tools", "CARVING_TOOLS")

local function GetTempGlobalData(create)
    return Tools:GetTempGlobalData(create, function()
        return {
            Rocks = {}
        }
    end)
end

local Rocks = {
    GridEntityType.GRID_ROCK,
    GridEntityType.GRID_ROCK_ALT,
    GridEntityType.GRID_ROCK_ALT2,
    GridEntityType.GRID_ROCK_BOMB,
    GridEntityType.GRID_ROCK_GOLD,
    GridEntityType.GRID_ROCK_SPIKED,
    GridEntityType.GRID_ROCK_SS,
    GridEntityType.GRID_ROCKT
}
Tools.HaniwaSubTypes = nil;

function Tools:IsRock(gridEntity)
    if (gridEntity) then
        local type = gridEntity:GetType();
        for _, t in ipairs(Rocks) do
            if (type == t) then
                return true;
            end
        end
    end
    return false;
end

function Tools:SpawnHaniwa(position, subtype)
    local Haniwa = THI.Familiars.Haniwa;
    return Haniwa:TrySpawnHaniwa(position, subtype);
end

function Tools:GetHaniwaSubType(gridType)
    local Haniwa = THI.Familiars.Haniwa;
    if (gridType == GridEntityType.GRID_ROCK_SS) then
        return Haniwa.SubTypes.HANIWA_GENERAL;
    elseif (gridType == GridEntityType.GRID_ROCKT) then
        return Haniwa.SubTypes.HANIWA_OFFICER;
    elseif (gridType == GridEntityType.GRID_ROCK_BOMB) then
        return Haniwa.SubTypes.HANIWA_KAMIKAZE;
    elseif (gridType == GridEntityType.GRID_ROCK_GOLD) then
        return Haniwa.SubTypes.HANIWA_BRASS;
    elseif (gridType == GridEntityType.GRID_ROCK_SPIKED) then
        return Haniwa.SubTypes.HANIWA_ARCHER;
    elseif (gridType == GridEntityType.GRID_ROCK_ALT or gridType == GridEntityType.GRID_ROCK_ALT2) then
        local backdrop = Game():GetRoom():GetBackdropType();
        if (backdrop == BackdropType.CAVES or
        backdrop == BackdropType.CATACOMBS or
        backdrop == BackdropType.FLOODED_CAVES or  
        backdrop == BackdropType.SECRET or
        backdrop == BackdropType.MINES or 
        backdrop == BackdropType.MINES_ENTRANCE or 
        backdrop == BackdropType.MINES_SHAFT or
        backdrop == BackdropType.ASHPIT or 
        backdrop == BackdropType.ASHPIT_SHAFT) then
            return Haniwa.SubTypes.HANIWA_MAGE;

        elseif (backdrop == BackdropType.DEPTHS or
        backdrop == BackdropType.NECROPOLIS or
        backdrop == BackdropType.DANK_DEPTHS or
        backdrop == BackdropType.SHEOL or
        backdrop == BackdropType.DARKROOM or  
        backdrop == BackdropType.SACRIFICE or
        backdrop == BackdropType.MAUSOLEUM_ENTRANCE or
        backdrop == BackdropType.MAUSOLEUM or
        backdrop == BackdropType.MAUSOLEUM2 or
        backdrop == BackdropType.MAUSOLEUM3 or
        backdrop == BackdropType.MAUSOLEUM4 or
        backdrop == BackdropType.GEHENNA) then
            return Haniwa.SubTypes.HANIWA_SKELETON;

        elseif (backdrop == BackdropType.WOMB or 
        backdrop == BackdropType.UTERO or 
        backdrop == BackdropType.SCARRED_WOMB or 
        backdrop == BackdropType.BLUE_WOMB or  
        backdrop == BackdropType.BLUE_WOMB_PASS or  
        backdrop == BackdropType.CORPSE_ENTRANCE or
        backdrop == BackdropType.CORPSE or 
        backdrop == BackdropType.CORPSE2 or 
        backdrop == BackdropType.CORPSE3 or 
        backdrop == BackdropType.MORTIS) then
            return Haniwa.SubTypes.HANIWA_FLESH;

        end
        return Haniwa.SubTypes.HANIWA_TOMB;
    end
    return Haniwa.SubTypes.HANIWA_SOLDIER;
end

local function PostUpdate(mod)
    if (Collectibles.IsAnyHasCollectible(Tools.Item)) then
        local game = Game();
        local room = game:GetRoom();
        local level = game:GetLevel();
        local width = room:GetGridWidth();
        local height = room:GetGridHeight();

        local data = GetTempGlobalData(true);
        for x = 1, width - 1 do
            for y = 1, height - 1 do
                local index = x + y * width;
                -- Check Changes.
                local gridEntity = room:GetGridEntity(index);
                local isRock = Tools:IsRock(gridEntity);
                local isBreak = gridEntity and (gridEntity.State ~= 1 or gridEntity:GetType() == GridEntityType.GRID_STAIRS)
                if (data.Rocks[index]) then
                    if (isBreak) then
                        Tools:SpawnHaniwa(gridEntity.Position, Tools:GetHaniwaSubType(data.Rocks[index]))
                    end
                end

                if (isRock and not isBreak) then
                    data.Rocks[index] = gridEntity:GetType();
                else
                    data.Rocks[index] = nil;
                end
            end
        end
    end
end
Tools:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)

local function PostNewRoom(mod)
    local data = GetTempGlobalData(false)
    if (data) then
        for k,v in pairs(data.Rocks) do
            data.Rocks[k] = nil;
        end
    end
end
Tools:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)

return Tools;