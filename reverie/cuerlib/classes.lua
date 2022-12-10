local Lib = LIB;
Lib.ClassPaths = {
    ModComponents = "mod_components",
    SaveAndLoad = "save_and_load",
    RewindAddon = "rewind_addon",
}
local classMetatable = {
    Lib = Lib
}
classMetatable.__index = classMetatable;

function Lib:NewClass()
    local class = {};
    setmetatable(class, classMetatable);
    class.Callbacks = {};
    function class:AddCallback(callback, func, param)
        self:AddPriorityCallback(callback, CallbackPriority.DEFAULT, func, param)
    end
    function class:AddPriorityCallback(callback, priority, func, param)
        table.insert(self.Callbacks, {Mod = Lib.Mod, Callback = callback, Priority = priority, Function = func, Param = param})
    end
    function class:Register()
        for _, callback in pairs(self.Callbacks) do
            callback.Mod:AddPriorityCallback(callback.Callback, callback.Priority, callback.Function, callback.Param);
        end
    end
    function class:Unregister()
        for _, callback in pairs(self.Callbacks) do
            callback.Mod:RemoveCallback(callback.Callback, callback.Function);
        end
    end
    return class;
end