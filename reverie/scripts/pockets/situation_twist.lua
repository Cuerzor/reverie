local Twist = ModCard("SituationTwist", "SITUATION_TWIST");

local function GetGlobalData(create)
    return Twist:GetGlobalData(create, function()
        return {
            Queue = {}
        }
    end)
end

function Twist:EnqueueItem(item)
    local data = GetGlobalData(true);
    table.insert(data.Queue, item);
end
function Twist:HasQueuedItem()
    local data = GetGlobalData(false);
    return data and #data.Queue > 0
end

function Twist:DequeueItem()
    local data = GetGlobalData(false);
    if (data and #data.Queue > 0) then
        local item = data.Queue[1];
        table.remove(data.Queue, 1);
        return item;
    end
    return -1;
end

local function PostUseCard(mod, card, player, flags)
    local ItemSoul = THI.Effects.ItemSoul;
    local items = {};
    for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
        if (ent.SubType > 0 and ent.SubType ~= CollectibleType.COLLECTIBLE_DADS_NOTE) then
            local soul = Isaac.Spawn(ItemSoul.Type, ItemSoul.Variant, ItemSoul.SubTypes.BLACK, ent.Position, Vector(0, -20), player):ToEffect();
            soul.Timeout = 120;
            soul.LifeSpan = 120;
            ItemSoul:SetItem(soul, ent.SubType);
            table.insert(items, ent.SubType);
            SFXManager():Play(THI.Sounds.SOUND_TOUHOU_BOON);
        end
    end
    player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME);

    for _, item in ipairs(items) do
        Twist:EnqueueItem(item);
    end
end
Twist:AddCallback(ModCallbacks.MC_USE_CARD, PostUseCard, Twist.ID);

local function PreGetCollectible(mod, pool, decrease, seed, loopCount)
    if (decrease and loopCount == 1) then
        local item = Twist:DequeueItem();
        if (item > 0) then
            return item;
        end
    end
end
    
Twist:AddPriorityCallback(CuerLib.Callbacks.CLC_PRE_GET_COLLECTIBLE, -51, PreGetCollectible);


THI:AddAnnouncer(Twist.ID, THI.Sounds.SOUND_SITUATION_TWIST, 15)

return Twist;