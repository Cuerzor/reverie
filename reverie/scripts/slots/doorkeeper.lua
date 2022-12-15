local Screen = CuerLib.Screen;
local Collectibles = CuerLib.Collectibles;
local Players = CuerLib.Players;
local Keeper = ModEntity("Door Keeper","DOOR_KEEPER");

Keeper.States = {
    STATE_COLLECTIBLE = 10,
    STATE_TRINKET = 11,
    STATE_DEALT = 12
}
local config = Isaac.GetItemConfig();

Keeper.InvalidSubType = 1<<24;

function Keeper:GetKeeperData(keeper, create)
    return Keeper:GetData(keeper, create, function()
        return {
            Sprite = nil
        }
    end)
end

local PlayerItems = nil
function Keeper:CachePlayerItems()
    local game = Game();
    local results = {};
    local count = 0;
    for p, player in Players.PlayerPairs() do
        local filter = function(id, config, num)
            if (player:GetActiveItem(ActiveSlot.SLOT_POCKET) == id) then
                num = num - 1;
            end
            if (player:GetActiveItem(ActiveSlot.SLOT_POCKET2) == id) then
                num = num - 1;
            end
            if (config:HasTags(ItemConfig.TAG_QUEST)) then
                num = 0;
            end
            return num;
        end
        local collectibles = Collectibles:GetPlayerCollectibles(player, filter);
        for id, num in pairs(collectibles) do
            results[id] = (results[id] or 0) + num;
            count = count + num;
        end
    end
    PlayerItems = {
        Items = results,
        Count = count;
    }
end

function Keeper:ClearCache()
    PlayerItems = nil;
end

function Keeper:GetRandomItem(seed)
    if (not PlayerItems) then
        Keeper:CachePlayerItems()
    end
    local count = PlayerItems.Count;
    local items = PlayerItems.Items;
    if (count > 0) then
        local rng = RNG();
        rng:SetSeed(seed, 1);
        local point = rng:RandomInt(count) + 1;
        for k, v in pairs(items) do
            point = point - v;
            if (point <= 0) then
                return k;
            end
        end
    end
    return 25;
end

function Keeper:GetSprite(state, id)
    local sprite = Sprite();
    if (state == Keeper.States.STATE_COLLECTIBLE) then
        local gfx = config:GetCollectible(id).GfxFileName;
        sprite:Load("gfx/005.100_collectible.anm2", false);
        sprite:ReplaceSpritesheet(1, gfx);
        sprite:LoadGraphics();
        sprite:Play("ShopIdle");
        sprite.Scale = Vector(0.5, 0.5);
    elseif (state == Keeper.States.STATE_TRINKET) then
        local gfx = config:GetTrinket(id.GfxFileName);
        sprite:Load("gfx/005.350_trinket.anm2", false);
        sprite:ReplaceSpritesheet(0, gfx);
        sprite:LoadGraphics();
        sprite:Play("Idle");
        sprite.Scale = Vector(0.5, 0.5);
    end
    return sprite;
end

function Keeper:PostKeeperInit(npc)
    if (npc.Variant == Keeper.Variant) then
        if (npc.SubType == Keeper.InvalidSubType) then
            npc:Remove();
            return ;
        elseif (not config:GetCollectible(npc.SubType)) then
            npc.SubType = Keeper:GetRandomItem(npc.InitSeed);
        end
        npc.TargetPosition = npc.Position;
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY;
        local flags = EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_SPIKE_DAMAGE | EntityFlag.FLAG_DONT_OVERWRITE | EntityFlag.FLAG_NO_PLAYER_CONTROL | EntityFlag.FLAG_HIDE_HP_BAR;
        npc:AddEntityFlags(flags);
        npc.State = Keeper.States.STATE_COLLECTIBLE;
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
    end
end
Keeper:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Keeper.PostKeeperInit, Keeper.Type)


function Keeper:PostNPCUpdate(npc)
    if (npc.Variant == Keeper.Variant) then

        npc.Velocity = npc.TargetPosition - npc.Position;
        npc:MultiplyFriction(0.6);

        if (npc.State == Keeper.States.STATE_DEALT) then
            local spr = npc:GetSprite();
            if (npc.StateFrame < 30) then
                npc.StateFrame = npc.StateFrame + 1;
                if (npc.StateFrame >= 30) then
                    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE;
                    spr:Play("Teleport");
                    SFXManager():Play(SoundEffect.SOUND_HELL_PORTAL1);
                end
            else
                if (spr:IsFinished("Teleport")) then
                    npc:Remove();
                end
            end
        end
    end
end
Keeper:AddCallback(ModCallbacks.MC_NPC_UPDATE, Keeper.PostNPCUpdate, Keeper.Type);


function Keeper:PostUpdate()
    if (PlayerItems) then
        Keeper:ClearCache();
    end
end
Keeper:AddCallback(ModCallbacks.MC_POST_UPDATE, Keeper.PostUpdate);

function Keeper:PostNPCRender(npc, offset)
    if (npc.Variant == Keeper.Variant) then
        if (npc.State ~= Keeper.States.STATE_DEALT) then
            local pos = Screen.GetEntityOffsetedRenderPosition(npc, offset, Vector(0, -60), true);
            local data = Keeper:GetKeeperData(npc, true);
            if (not data.Sprite) then
                data.Sprite = Keeper:GetSprite(npc.State, npc.SubType);
            end
            data.Sprite:Render(pos);
        end
    end
end
Keeper:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, Keeper.PostNPCRender, Keeper.Type);

function Keeper:PostPlayerCollision(player, other, low)
    if (other.Type == Keeper.Type and other.Variant == Keeper.Variant) then
        local npc = other:ToNPC();
        if (npc.State ~= Keeper.States.STATE_DEALT) then

            local sfx = SFXManager();
            local function NiceDeal(player)
                sfx:Play(SoundEffect.SOUND_THUMBSUP);
                npc.StateFrame = 0;
                npc.State = Keeper.States.STATE_DEALT;
                npc.SubType = Keeper.InvalidSubType;
                other:GetSprite():Play("Dealt");
            end 

            local function Cannot()
                if (not sfx:IsPlaying(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)) then
                    sfx:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ);
                end
            end 
            if (npc.State == Keeper.States.STATE_COLLECTIBLE) then
                if (player:HasCollectible(npc.SubType, true)) then
                    player:RemoveCollectible(npc.SubType, true);
                    NiceDeal(player)
                else
                    Cannot()
                end
            elseif (npc.State == Keeper.States.STATE_TRINKET) then
                if (player:HasTrinket(npc.SubType, true) and player:TryRemoveTrinket(npc.SubType)) then
                    NiceDeal(player)
                else
                    Cannot()
                end
            end
        end
    end
end
Keeper:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, CallbackPriority.LATE, Keeper.PostPlayerCollision);


-- function Trader:PostTraderKill(trader)
--     if (trader.Variant ==Trader.Variant) then
--         trader:ToNPC():Morph(trader.Type, trader.Variant, trader.SubType, 0);
--     end
-- end
-- Trader:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Trader.PostTraderKill, Trader.Type);

return Keeper;