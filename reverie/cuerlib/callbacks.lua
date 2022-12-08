local Callbacks = LIB:NewClass();
Callbacks.Functions = {
    CanCollect = {},
    PreRevive = {},
    PostRevive = {},
    PostPickupCollectible = {},
    PostPickupTrinket = {},
    PostPickUpCard = {},
    PostGainCollectible = {},
    PostLoseCollectible = {},
    PostChangeCollectibles = {},
    NewStage = {},
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
    PreGetCollectible = {},
    TryUseItem = {},
    PostSave = {},
    PostRestart = {},
    PostLoad = {},
    PostExit = {},
    EvaluatePoolBlacklist = {},
}

LIB.CLCallbacks = {
    CLC_CAN_COLLECT = "CanCollect",
    --Check if the player `player` can revives from death.
    --Return a ReviveInfo table for revive the player.
    ---@param player EntityPlayer
    ---@return ReviveInfo info
    CLC_PRE_REVIVE = "PreRevive",
    --Called after player `player` revives from death with ReviveInfo `info`.
    ---@param player EntityPlayer
    ---@param info ReviveInfo
    CLC_POST_REVIVE = "PostRevive",
    CLC_POST_PICKUP_COLLECTIBLE = "PostPickupCollectible",
    CLC_POST_PICKUP_TRINKET = "PostPickupTrinket",
    --Params: (player, card)
    CLC_POST_PICK_UP_CARD = "PostPickUpCard",
    --Params: (player, item, count, touched)
    CLC_POST_GAIN_COLLECTIBLE = "PostGainCollectible",
    CLC_POST_LOSE_COLLECTIBLE = "PostLoseCollectible",
    --Params: (player, item, diff)
    CLC_POST_CHANGE_COLLECTIBLES = "PostChangeCollectibles",
    CLC_POST_NEW_GREED_WAVE = "PostNewGreedWave",
    CLC_POST_GREED_WAVE_END = "PostGreedWaveEnd",
    CLC_NEW_STAGE = "NewStage",
    CLC_POST_PLAYER_COLLISION = "PostPlayerCollision",
    CLC_PRE_ENTITY_TAKE_DMG = "PreEntityTakeDamage",
    CLC_POST_ENTITY_TAKE_DMG = "PostEntityTakeDamage",
    CLC_PRE_PICKUP_COLLISION = "PrePickupCollision",
    CLC_POST_PICKUP_COLLECTED = "PostPickupCollected",
    CLC_PRE_RELEASE_HOLDING_ACTIVE = "PreReleaseHoldingActive",
    CLC_POST_RELEASE_HOLDING_ACTIVE = "PostReleaseHoldingActive",
    --Params: (curses)
    CLC_EVALUATE_CURSE = "EvaluateCurse",
    --Params: (pool, decrease, seed, loopCount)
    CLC_PRE_GET_COLLECTIBLE = "PreGetCollectible",
    ---Called after player `player` trying to use the active item `item` at slot `slot`.
    ---Return true to use this active item.
    ---@param item integer
    ---@param player EntityPlayer
    ---@param slot integer
    ---@return boolean shouldUse
    CLC_TRY_USE_ITEM = "TryUseItem",
    CLC_POST_SAVE = "PostSave",
    CLC_POST_RESTART = "PostRestart",
    CLC_POST_LOAD = "PostLoad",
    CLC_POST_EXIT = "PostExit",
    CLC_EVALUATE_POOL_BLACKLIST = "EvaluatePoolBlacklist"
}

function Callbacks:AddCallback(callbackId, func, opt, priority)
    priority = priority or 0;
    local info = { Mod = self.Lib.Mod, Func = func, OptionalArg = opt, Priority = priority};
    local tbl = self.Functions[callbackId];
    table.insert(tbl, info);
    table.sort(tbl, function (a, b) return a.Priority > b.Priority end);
end

function Callbacks:RemoveCallback(callbackId, func)
    for i, info in pairs(self.Functions[callbackId]) do
        if (info.Mod == self.Lib.Mod and info.Func == func) then
            table.remove(self.Functions[callbackId], i);
            return;
        end
    end
end

return Callbacks;