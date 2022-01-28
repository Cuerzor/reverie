local Players = {}

function Players.TeleportToPosition(player, pos)
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position,Vector.Zero, nil);
    local spr = poof:GetSprite();
    spr:Load(player:GetSprite():GetFilename(), true);
    spr:Play("TeleportUp");
    THI.SFXManager:Play(SoundEffect.SOUND_HELL_PORTAL1);
    THI.SFXManager:Play(SoundEffect.SOUND_HELL_PORTAL2);
    player.Position = pos;
    player:AnimateTeleport(false);
    player:SetMinDamageCooldown(30);
end
local config = Isaac.GetItemConfig();

function Players.IsTIsaacExcluded(id)
    if (id == CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        return true;
    end
    local collectible = config:GetCollectible(id);
    if (collectible ) then
        if (collectible.Type == ItemType.ITEM_ACTIVE or collectible:HasTags(ItemConfig.TAG_QUEST)) then
            return true;
        end
    end
    return false;
end

local function GetExceptedItems()
    local results = {};
    local size = config:GetCollectibles().Size
    for i = 1, size do
        if (Players.IsTIsaacExcluded(i)) then
            table.insert(results, i);
        end
    end

    return results;
end
local TIsaacExcepted = GetExceptedItems();



function Players.GetTIsaacItemSlots(player)
    if (player:GetPlayerType() == PlayerType.PLAYER_ISAAC_B) then
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
            return 12;
        end
        return 8;
    end
    return nil;
end
function Players.GetTIsaacRemainSpaces(player)
    if (player:GetPlayerType() == PlayerType.PLAYER_ISAAC_B) then
        local count = player:GetCollectibleCount();
        for i, quest in pairs(TIsaacExcepted) do
            count = count - player:GetCollectibleNum(quest);
        end

        local slots = Players.GetTIsaacItemSlots(player);
        return slots - count;
    end
    return nil;
end


function Players.HasJudasBook(player)
    local playerType = player:GetPlayerType();
    return (playerType == PlayerType.PLAYER_JUDAS or playerType == PlayerType.PLAYER_BLACKJUDAS) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT);
end

return Players;