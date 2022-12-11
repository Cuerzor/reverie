CuerLib.Callbacks = {
    CLC_CAN_PICKUP_COLLECT = "CUERLIB_CAN_PICKUP_COLLECT",
    CLC_POST_PICKUP_COLLECTED = "CUERLIB_POST_PICKUP_COLLECTED",
    --Params: (player, card)
    CLC_POST_PICK_UP_CARD = "CUERLIB_POST_PICK_UP_CARD",

    -- Called before player `player` revives from death.
    -- Return a ReviveInfo to register a revive event.
    --- @param EntityPlayer player
    --- @param ReviveInfo info
    CLC_PRE_REVIVE = "CUERLIB_PRE_REVIVE",

    -- Called after player `player` revives from death with ReviveInfo `info`.
    --- @param EntityPlayer player
    --- @param ReviveInfo info
    CLC_POST_REVIVE = "CUERLIB_POST_REVIVE",

    CLC_POST_PICK_UP_COLLECTIBLE = "CUERLIB_POST_PICK_UP_COLLECTIBLE",
    CLC_POST_PICK_UP_TRINKET = "CUERLIB_POST_PICK_UP_TRINKET",
    --Params: (player, item, count, touched)
    CLC_POST_GAIN_COLLECTIBLE = "CUERLIB_POST_GAIN_COLLECTIBLE",
    CLC_POST_LOSE_COLLECTIBLE = "CUERLIB_POST_LOSE_COLLECTIBLE",
    --Params: (player, item, diff)
    CLC_POST_CHANGE_COLLECTIBLES = "CUERLIB_POST_CHANGE_COLLECTIBLES",

    CLC_POST_NEW_GREED_WAVE = "CUERLIB_POST_NEW_GREED_WAVE",
    CLC_POST_GREED_WAVE_END = "CUERLIB_POST_GREED_WAVE_END",

    CLC_POST_NEW_STAGE = "CUERLIB_POST_NEW_STAGE",
    
    CLC_RELEASE_HOLDING_ACTIVE = "CUERLIB_RELEASE_HOLDING_ACTIVE",
    --Params: (curses)
    CLC_EVALUATE_CURSE = "CUERLIB_EVALUATE_CURSE",
    --Params: (pool, decrease, seed, loopCount)
    CLC_PRE_GET_COLLECTIBLE = "CUERLIB_PRE_GET_COLLECTIBLE",
    CLC_EVALUATE_POOL_BLACKLIST = "CUERLIB_EVALUATE_POOL_BLACKLIST",
    
    ---Called after player `player` trying to use the active item `item` at slot `slot`.
    ---Return true to use this active item.
    ---@param item integer
    ---@param player EntityPlayer
    ---@param slot integer
    ---@return boolean shouldUse
    CLC_TRY_USE_ITEM = "CUERLIB_TRY_USE_ITEM",

    CLC_POST_RESTART = "CUERLIB_POST_RESTART",
    CLC_POST_EXIT = "CUERLIB_POST_EXIT",

    CLC_POST_GRID_UPDATE = "CUERLIB_POST_GRID_UPDATE",
    CLC_POST_GRID_DESTROYED = "CUERLIB_POST_GRID_DESTROYED",

    CLC_GET_REWIND_DATA = "CUERLIB_GET_REWIND_DATA",
    CLC_SET_REWIND_DATA = "CUERLIB_SET_REWIND_DATA"
}