local Callbacks = {
    Functions = {
        CanCollect = {},
        PostPickupCollectible = {},
        PostPickupTrinket = {},
        PostGainCollectible = {},
        PostLoseCollectible = {},
        PostChangeCollectibles = {},
        NewStage = {},
        PrePlayerCollision = {},
        PostPlayerCollision = {},
        PreEntityTakeDamage = {},
        PostEntityTakeDamage = {},
        PrePickupCollision = {},
        PostPickupCollected = {},
        PreReleaseHoldingActive = {},
        PostReleaseHoldingActive = {},
        PostNewGreedWave = {},
        PostGreedWaveEnd = {},
        EvaluateCurse = {},
    }
}

CLCallbacks = {
    CLC_CAN_COLLECT = "CanCollect",
    CLC_POST_PICKUP_COLLECTIBLE = "PostPickupCollectible",
    CLC_POST_PICKUP_TRINKET = "PostPickupTrinket",
    --Params: (player, item, count, touched)
    CLC_POST_GAIN_COLLECTIBLE = "PostGainCollectible",
    CLC_POST_LOSE_COLLECTIBLE = "PostLoseCollectible",
    CLC_POST_CHANGE_COLLECTIBLES = "PostChangeCollectibles",
    CLC_POST_NEW_GREED_WAVE = "PostNewGreedWave",
    CLC_POST_GREED_WAVE_END = "PostGreedWaveEnd",
    CLC_NEW_STAGE = "NewStage",
    CLC_PRE_PLAYER_COLLISION = "PrePlayerCollision",
    CLC_POST_PLAYER_COLLISION = "PostPlayerCollision",
    CLC_PRE_ENTITY_TAKE_DMG = "PreEntityTakeDamage",
    CLC_POST_ENTITY_TAKE_DMG = "PostEntityTakeDamage",
    CLC_PRE_PICKUP_COLLISION = "PrePickupCollision",
    CLC_POST_PICKUP_COLLECTED = "PostPickupCollected",
    CLC_PRE_RELEASE_HOLDING_ACTIVE = "PreReleaseHoldingActive",
    CLC_POST_RELEASE_HOLDING_ACTIVE = "PostReleaseHoldingActive",
    CLC_EVALUATE_CURSE = "EvaluateCurse"
}

function Callbacks:AddCallback(mod, callbackId, func, opt, priority)
    priority = priority or 0;
    local info = { Mod = mod, Func = func, OptionalArg = opt, Priority = priority};
    local tbl = self.Functions[callbackId];
    table.insert(tbl, info);
    table.sort(tbl, function (a, b) return a.Priority > b.Priority end);
end

function Callbacks:RemoveCallback(mod, callbackId, func)
    for i, info in pairs(self.Functions[callbackId]) do
        if (info.Mod == mod and Func == func) then
            table.remove(self.Functions[callbackId], i);
            return;
        end
    end
end

return Callbacks;