local Lib = {
    Mod = nil,
    DataName = nil,
    Loaded = {},
    Version = {1,0,0},
    Inited = false,
}

function Lib.IsLaterVersion(version, other)
    for i, ver in ipairs(version) do
        if (ver > other[i]) then
            return true;
        end
    end
    return false;
end
function Lib.CloneVersion(version)
    local new = {};
    for i, ver in ipairs(version) do
        new[i] = ver;
    end
    return new;
end
function Lib:GetVersionString()
    local str = "";
    for i, ver in ipairs(self.Version) do
        if (i > 1) then
            str= str..".";
        end
        str = str..tostring(ver);
    end
    return str;
end

function Lib:GetSingleton()
    return CuerLib_Singleton;
end

function Lib:CreateSingleton()
    local singleton = include("cuerlib/singletons/main");
    singleton.Version = self.CloneVersion(self.Version);
    return singleton;
end

if (not CuerLib_Singleton or Lib.IsLaterVersion(Lib.Version, CuerLib_Singleton.Version)) then
    CuerLib_Singleton = Lib:CreateSingleton();
end


function Lib.Require(filename)
    if (not Lib.Loaded[filename]) then
        local file = include(filename);
        Lib.Loaded[filename] = file;
        return file;
    end
    return Lib.Loaded[filename];
end
local Require = Lib.Require;

local LibMetatable = {
    __index = function(self, key)
        -- Require the file if target file is not loaded.
        local path = self.ClassPaths[key];
        if (path) then
            local class = Lib.Require("cuerlib/class/"..path);
            if (class) then
                self[key] = class;
                return class;
            end
        end
        local singleton = self:GetSingleton();
        return singleton[key];
    end
}
setmetatable(Lib, LibMetatable);

function Lib:Init(mod, dataName)
    if (not self.Inited) then
        self.Inited= true;
        
        LIB = Lib;
        self.Mod = mod;
        self.DataName = dataName or mod.Name;

        Require("cuerlib/classes");
        Require("cuerlib/callbacks");
        Require("cuerlib/data");
        for k,v in pairs(Lib.ClassPaths) do
            local class = Require("cuerlib/class/"..v);
            Lib[k] = class;
            class:Register();
        end

        LIB = nil
    end
end

return Lib;