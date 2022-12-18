CuerLib = RegisterMod("CuerLib", 1);
local Lib = CuerLib;
Lib.Version = {1,3,0};
Lib.Loaded = {};

function Lib:GetVersionString()
    local str = "";
    for i, ver in ipairs(Lib.Version) do
        if (i > 1) then
            str= str..".";
        end
        str = str..tostring(ver);
    end
    return str;
end

function Lib:Require(filename)
    if (not Lib.Loaded[filename]) then
        Lib.Loaded[filename] = include(filename);
    end
    return Lib.Loaded[filename];
end

local metatable = {
    __index = function(self, key)
        -- Require the file if target file is not loaded.
        local path = self.ClassPaths[key];
        if (path) then
            local class = self:Require("cuerlib/class/"..path);
            if (class) then
                self[key] = class;
                return class;
            end
        end
    end
}
setmetatable(Lib, metatable);

LIB = Lib;
Lib:Require("cuerlib/callbacks");
Lib:Require("cuerlib/data");
Lib:Require("cuerlib/classes");
for key, path in pairs(Lib.ClassPaths) do
    local class = Lib:Require("cuerlib/class/"..path);
    Lib[key] = class;
    class:Register();
end
LIB = nil;

CuerLib.InitMod = include("cuerlib/mod_addon/main");

print("CuerLib "..CuerLib:GetVersionString().." Loaded.")

return Lib;