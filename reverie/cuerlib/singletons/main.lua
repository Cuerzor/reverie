local Singleton = RegisterMod("CuerLib Singleton", 1);

Singleton.Loaded = {};

function Singleton:GetVersionString()
    local str = "";
    for i, ver in ipairs(self.Version) do
        if (i > 1) then
            str= str..".";
        end
        str = str..tostring(ver);
    end
    return str;
end

function Singleton:Require(filename)
    if (not self.Loaded[filename]) then
        local file = include(filename);
        self.Loaded[filename] = file;
        return file;
    end
    return self.Loaded[filename];
end

local metatable = {
    __index = function(self, key)
        -- Require the file if target file is not loaded.
        local path = self.ClassPaths[key];
        if (path) then
            local class = self:Require("cuerlib/singletons/class/"..path);
            if (class) then
                self[key] = class;
                return class;
            end
        end
    end
}
setmetatable(Singleton, metatable);

local function Load()
    
    SINGLETON = Singleton;
    Singleton:Require("cuerlib/singletons/callbacks");
    Singleton:Require("cuerlib/singletons/data");
    Singleton:Require("cuerlib/singletons/classes");
    for key, path in pairs(Singleton.ClassPaths) do
        local class = Singleton:Require("cuerlib/singletons/class/"..path);
        Singleton[key] = class;
        class:Register();
    end
    SINGLETON = nil;
end
local function Unload()
    Singleton.Loaded = {};
    for key, _ in pairs(Singleton.ClassPaths) do
        local class = Singleton[key];
        class:Unregister();
        Singleton[key] = nil;
    end
end
function Singleton:Reload()
    Unload();
    Load();
end

Load();


return Singleton;