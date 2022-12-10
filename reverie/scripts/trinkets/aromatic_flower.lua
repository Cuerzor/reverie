local Revive = CuerLib.Revive;

local AromaticFlower = ModTrinket("Aromatic Flower", "AromaticFlower");

local function PostRevive(player, reviver)
    player:AnimateTrinket(AromaticFlower.Trinket, "UseItem")

    local multiplier = reviver:GetTrinketMultiplier(AromaticFlower.Trinket);
    
    local type = player:GetPlayerType();
    reviver:TryRemoveTrinket(AromaticFlower.Trinket);
    local maxHearts = player:GetMaxHearts() + player:GetBoneHearts() * 2;
    local currentHeart = player:GetHearts();

    
    local targetHealth = maxHearts / 2;
    if (multiplier >= 2) then
        targetHealth = maxHearts;
        player:AddSoulHearts((multiplier - 2) * 4);
    end
    -- If player is Keeper
    if (type == PlayerType.PLAYER_KEEPER or type == PlayerType.PLAYER_KEEPER_B) then
        targetHealth = math.ceil(targetHealth / 2) * 2;
    end
    player:AddHearts(targetHealth - currentHeart);
end

local function PreRevive(mod, player)
    if (player:HasTrinket(AromaticFlower.Trinket)) then
        return {
            Callback = PostRevive
        }
    end
end

AromaticFlower:AddCallback(CuerLib.CLCallbacks.CLC_PRE_REVIVE, PreRevive);

return AromaticFlower;