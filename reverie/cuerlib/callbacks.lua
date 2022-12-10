local Lib = LIB;
Lib.Callbacks = {
    CLC_POST_SAVE = {},
    CLC_POST_LOAD = {},
}
setmetatable(Lib.Callbacks, {
    __index = function(self, key)
        return Lib:GetSingleton().Callbacks[key];
    end
})
