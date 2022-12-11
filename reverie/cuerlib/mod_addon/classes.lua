return function(Addon)

    local classMetatable = {
        Addon = Addon
    }
    classMetatable.__index = classMetatable;

    function Addon:NewClass()
        local class = {};
        setmetatable(class, classMetatable);
        class.Callbacks = {};
        function class:AddCallback(callback, func, param)
            Addon.Mod:AddCallback(callback, func, param);
        end
        function class:AddPriorityCallback(callback, priority, func, param)
            Addon.Mod:AddPriorityCallback(callback, priority, func, param);
        end
        return class;
    end
end