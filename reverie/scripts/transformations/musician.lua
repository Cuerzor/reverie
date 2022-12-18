local PlayerForms = CuerLib.PlayerForms;
local Stats = CuerLib.Stats;

local Musician = {
    Pool = {
    }
}

PlayerForms.CustomForms.Musician = {
    NameGetter = function(language) 
        return THI.GetText("#TRANSFORMATION_MUSICIAN");
    end,
    CostumeId = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_musician.anm2"),
    Pool = {
        Isaac.GetItemIdByName("Melancholic Violin"),
        Isaac.GetItemIdByName("Maniac Trumpet"),
        Isaac.GetItemIdByName("Illusionary Keyboard"),
        CollectibleType.COLLECTIBLE_METRONOME,
        CollectibleType.COLLECTIBLE_PLUM_FLUTE,
        Isaac.GetItemIdByName("DELETED ERHU"),
        Isaac.GetItemIdByName("Song of Nightbird"),
        THI.Collectibles.MountainEar.Item,
        THI.Collectibles.ThunderDrum.Item,
        THI.Collectibles.ReverieMusic.Item
    }
}

function Musician.GetPlayerData(player, create)
    local data = THI.GetData(player);
    if (create) then
        data.Musician = data.Musician or {
            Has = false
        }
    end
    return data.Musician;
end

function Musician:onPlayerEffect(player)
    local data = Musician.GetPlayerData(player, false);
    local prevHas = not not (data and data.Has)
    local has = PlayerForms:HasPlayerForm(player, "Musician");
    if (prevHas ~= has) then
        data = Musician.GetPlayerData(player, true);
        data.Has = has;
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_TEARFLAG);
        player:EvaluateItems();
    end
end

function Musician:onFireTear(tear)
    local player = tear.SpawnerEntity:ToPlayer();
    if (player ~= nil) then
        local data = Musician.GetPlayerData(player, false);
        if (data and data.Has) then
            if (tear.Variant == TearVariant.BLUE) then
                tear:ChangeVariant(TearVariant.PUPULA);
            elseif (tear.Variant == TearVariant.BLOOD) then
                tear:ChangeVariant(TearVariant.PUPULA_BLOOD);
            end
            tear.Scale = tear.Scale * 1.5;
        end
    end
end

function Musician:onEvaluateCache(player, flag)
    local data = Musician.GetPlayerData(player, false);
    if (data and data.Has) then
        if (flag == CacheFlag.CACHE_TEARFLAG) then
            player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING;
        elseif (flag == CacheFlag.CACHE_FIREDELAY) then
            Stats:AddTearsModifier(player, function(tears) return tears + 1; end)
        end
    end
end


THI:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Musician.onFireTear);
THI:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Musician.onEvaluateCache);
THI:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Musician.onPlayerEffect);

return Musician;