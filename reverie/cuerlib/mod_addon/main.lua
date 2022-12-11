local Loaded = {}
local function Require(filename)
    if (not Loaded[filename]) then
        local file = include(filename);
        Loaded[filename] = file;
        return file;
    end
    return Loaded[filename];
end


local ClassPaths = {
    SaveAndLoad = "save_and_load",
    --RewindAddon = "rewind_addon",
    ModComponents = "mod_components",
}
local classesInit = Require("cuerlib/mod_addon/classes");
local dataInit = Require("cuerlib/mod_addon/data");
local classFunctions = {};
for k,v in pairs(ClassPaths) do
    local func = Require("cuerlib/mod_addon/class/"..v);
    classFunctions[k] = func;
end

return function(self, name, apiversion, dataName)
    local Addon = {
        Mod = nil,
        DataName = nil,
    }
    
    
    local mod = RegisterMod(name, apiversion);
    mod.CuerlibAddon = Addon;
    Addon.Mod = mod;
    Addon.DataName = dataName or mod.Name;
    Addon.ClassPaths = ClassPaths;

    local LibMetatable = {
        __index = function(self, key)
            -- Require the file if target file is not loaded.
            local path = Addon.ClassPaths[key];
            if (path) then
                local class = Addon.Require("cuerlib/mod_addon/class/"..path);
                if (class) then
                    Addon[key] = class;
                    return class;
                end
            end
        end
    }
    setmetatable(Addon, LibMetatable);
    
    Addon.Callbacks = {
        CLC_POST_SAVE = {},
        CLC_POST_LOAD = {},
    }
    classesInit(Addon);
    dataInit(Addon);
    for k, v in pairs(classFunctions) do
        Addon[k] = v(Addon);
    end

    return mod;
end