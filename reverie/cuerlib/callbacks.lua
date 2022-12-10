local Callbacks = LIB:NewClass();
LIB.CLCallbacks = {
    CLC_CAN_PICKUP_COLLECT = {},
    CLC_POST_PICKUP_COLLECTED = {},
    --Params: (player, card)
    CLC_POST_PICK_UP_CARD = {},

    --Check if the player `player` can revives from death.
    --Return a ReviveInfo table for revive the player.
    ---@param player EntityPlayer
    ---@return ReviveInfo info
    CLC_PRE_REVIVE = {},
    --Called after player `player` revives from death with ReviveInfo `info`.
    ---@param player EntityPlayer
    ---@param info ReviveInfo
    CLC_POST_REVIVE = {},

    CLC_POST_PICK_UP_COLLECTIBLE = {},
    CLC_POST_PICK_UP_TRINKET = {},
    --Params: (player, item, count, touched)
    CLC_POST_GAIN_COLLECTIBLE = {},
    CLC_POST_LOSE_COLLECTIBLE = {},
    --Params: (player, item, diff)
    CLC_POST_CHANGE_COLLECTIBLES = {},

    CLC_POST_NEW_GREED_WAVE = {},
    CLC_POST_GREED_WAVE_END = {},

    CLC_POST_NEW_STAGE = {},
    
    CLC_RELEASE_HOLDING_ACTIVE = {},
    --Params: (curses)
    CLC_EVALUATE_CURSE = {},
    --Params: (pool, decrease, seed, loopCount)
    CLC_PRE_GET_COLLECTIBLE = {},
    CLC_EVALUATE_POOL_BLACKLIST = {},
    
    ---Called after player `player` trying to use the active item `item` at slot `slot`.
    ---Return true to use this active item.
    ---@param item integer
    ---@param player EntityPlayer
    ---@param slot integer
    ---@return boolean shouldUse
    CLC_TRY_USE_ITEM = {},


    CLC_POST_SAVE = {},
    CLC_POST_RESTART = {},
    CLC_POST_LOAD = {},
    CLC_POST_EXIT = {},

    CLC_POST_GRID_UPDATE = {},
    CLC_POST_GRID_DESTROYED = {},

}

-- function Callbacks:AddCallback(callbackId, func, opt, priority)
--     priority = priority or 0;
--     local info = { Mod = self.Lib.Mod, Func = func, OptionalArg = opt, Priority = priority};
--     local tbl = self.Functions[callbackId];
--     table.insert(tbl, info);
--     table.sort(tbl, function (a, b) return a.Priority > b.Priority end);
-- end

-- function Callbacks:RemoveCallback(callbackId, func)
--     for i, info in pairs(self.Functions[callbackId]) do
--         if (info.Mod == self.Lib.Mod and info.Func == func) then
--             table.remove(self.Functions[callbackId], i);
--             return;
--         end
--     end
-- end

return Callbacks;