local Lib = LIB;
local Callbacks = Lib.Callbacks;

local ModComponents = Lib:NewClass();
----------------
-- Mod Part
----------------
local ModPart = {}
do
    ModComponents.ModPart = ModPart;
    ModPart.ClassName = "ModPart";

    function ModPart:NewChild()
        local instance = setmetatable({}, {
            __index = self
        });

        return instance;
    end

    function ModPart:New(name, dataName)
        local new = setmetatable({}, {
            __index = self
        });
        new.Name = name;
        new.DataName = dataName;
        return new;
    end

    local function GetData(self, entity, init, defaultGetter, temp)
        
        local dataName = self.DataName;
        local className = self.ClassName;
        if (not dataName) then
            local name = self.Name or "nil";
            error("DataName of "..className.." \""..name.."\" is not set.");
        end

        local data = Lib:GetEntityModData(entity, temp);
        if (init == nil) then
            init = true;
        end
        if (init) then
            if (not data[dataName]) then
                local default;
                if (type(defaultGetter) == "function") then
                    default = defaultGetter();
                else
                    print("Trying to pass a table to "..className..":GetData. DataName is \""..dataName.."\".");
                    default = defaultGetter or {};
                end
                data[dataName] = default;
            end
        end
        return data[dataName];
    end

    local function SetData(self, entity, value, temp)
        
        local dataName = self.DataName
        local className = self.ClassName;
        if (not dataName) then
            local name = self.Name or "nil";
            error("DataName of "..className.." \""..name.."\" is not set.");
        end

        local data = Lib:GetEntityModData(entity,temp);
        data[dataName] = value;
    end

    function ModPart:GetData(entity, init, defaultGetter)
        return GetData(self, entity, init, defaultGetter, false);
    end

    function ModPart:SetData(entity, value)
        SetData(self, entity, value, false);
    end

    function ModPart:GetTempData(entity, init, defaultGetter)
        return GetData(self, entity, init, defaultGetter, true);
    end

    function ModPart:SetTempData(entity, value)
        SetData(self, entity, value, true);
    end

    function ModPart:GetMod()
        return Lib.Mod;
    end

    local function GetGlobalData(self, temp, create, defaultGetter)
        
        local dataName = self.DataName
        local className = self.ClassName;
        if (not dataName) then
            local name = self.Name or "nil";
            error("DataName of "..className.." \""..name.."\" is not set.");
        end

        local globalData = Lib:GetGlobalModData(temp);
        if (create) then
            local default;
            if (type(defaultGetter) == "function") then
                default = defaultGetter();
            else
                print("Trying to pass a table to "..className..":GetGlobalData. DataName is \""..dataName.."\".");
                default = defaultGetter;
            end
            globalData[dataName] = globalData[dataName] or default;
        end
        return globalData[dataName];
    end

    
    local function SetGlobalData(self, temp, value)
        
        local dataName = self.DataName
        local className = self.ClassName;
        if (not dataName) then
            local name = self.Name or "nil";
            error("DataName of "..className.." \""..name.."\" is not set.");
        end

        local globalData = Lib:GetGlobalModData(temp);
        globalData[dataName] = value;
    end

    function ModPart:GetGlobalData(init, defaultGetter)
        return GetGlobalData(self, false, init, defaultGetter)
    end
    function ModPart:GetTempGlobalData(init, defaultGetter)
        return GetGlobalData(self, true, init, defaultGetter)
    end
    
    function ModPart:SetGlobalData(value)
        SetGlobalData(self, false, value)
    end
    function ModPart:SetTempGlobalData(value)
        SetGlobalData(self, true, value)
    end

    function ModPart:AddCallback(callback, func, optional)
        local function fncall(mod, ...)
            return func(self, ...);
        end
        self:GetMod():AddCallback(callback, fncall, optional);
    end

    function ModPart:AddCustomCallback(callback, func, optional, priority)
        local function fncall(mod, ...)
            return func(self, ...);
        end
        Callbacks:AddCallback(callback, fncall, optional, priority);
    end
end

----------------
-- Mod Item
----------------
do 
    local ModItem = ModPart:NewChild();
    ModItem.Item = -1;
    ModItem.Name = nil;
    ModItem.DataName = nil;
    ModItem.ClassName = "ModItem";

    ModComponents.ModItem = ModItem;

    function ModItem:New(name, dataName)
        local new = setmetatable({}, {
            __index = self
        });
        new.Item = Isaac.GetItemIdByName(name);
        new.Name = name;
        new.DataName = dataName;
        return new;
    end
end

----------------
-- Mod Trinket
----------------
do 
    local ModTrinket = ModPart:NewChild();
    ModTrinket.Trinket = -1;
    ModTrinket.Name = nil;
    ModTrinket.DataName = nil;
    ModTrinket.ClassName = "ModTrinket";

    ModComponents.ModTrinket = ModTrinket;

    function ModTrinket:New(name, dataName)
        local new = setmetatable({}, {
            __index = self
        });
        new.Trinket = Isaac.GetTrinketIdByName(name);
        new.Name = name;
        new.DataName = dataName;
        return new;
    end
end

----------------
-- Mod Challenge
----------------
do 
    local ModChallenge = ModPart:NewChild();
    ModChallenge.Id = -1;
    ModChallenge.Name = nil;
    ModChallenge.DataName = nil;
    ModChallenge.ClassName = "ModChallenge";

    ModComponents.ModChallenge = ModChallenge;

    function ModChallenge:New(name, dataName)
        local new = setmetatable({}, {
            __index = self
        });
        new.Id = Isaac.GetChallengeIdByName(name);
        new.Name = name;
        new.DataName = dataName;
        return new;
    end
end

----------------
-- Mod Entity
----------------
do 
    local ModEntity = ModPart:NewChild();
    ModEntity.Type = 0;
    ModEntity.Variant = 0;
    ModEntity.SubType = 0;
    ModEntity.Name = nil;
    ModEntity.DataName = nil;
    ModEntity.ClassName = "ModEntity";

    ModComponents.ModEntity = ModEntity;

    function ModEntity:New(name, dataName)
        local new = setmetatable({}, {
            __index = self
        });
        new.Type = Isaac.GetEntityTypeByName(name);
        new.Variant = Isaac.GetEntityVariantByName(name);
        new.Name = name;
        new.DataName = dataName;
        return new;
    end
end

----------------
-- Mod Card
----------------
do 
    local ModCard = ModPart:NewChild();
    ModCard.ID = -1;
    ModCard.Name = nil;
    ModCard.DataName = nil;
    ModCard.ClassName = "ModCard";

    ModComponents.ModCard = ModCard;

    function ModCard:New(name, dataName)
        local new = setmetatable({}, {
            __index = self
        });
        new.ID = Isaac.GetCardIdByName (name)
        new.Name = name;
        new.DataName = dataName;
        return new;
    end
end
----------------
-- Mod Pill
----------------
do 
    local ModPill = ModPart:NewChild();
    ModPill.ID = -1;
    ModPill.Name = nil;
    ModPill.DataName = nil;
    ModPill.ClassName = "ModPill";

    ModComponents.ModPill = ModPill;

    function ModPill:New(name, dataName)
        local new = setmetatable({}, {
            __index = self
        });
        new.ID = Isaac.GetPillEffectByName (name);
        new.Name = name;
        new.DataName = dataName;
        return new;
    end
end

----------------
-- Mod Player
----------------
do 
    local ModPlayer = ModPart:NewChild();
    ModPlayer.Type = 0;
    ModPlayer.Name = nil;
    ModPlayer.DataName = nil;
    ModPlayer.ClassName = "ModPlayer";

    ModComponents.ModPlayer = ModPlayer;

    function ModPlayer:New(name, tainted, dataName)
        local new = setmetatable({}, {
            __index = self
        });
        new.Type = Isaac.GetPlayerTypeByName(name, tainted)
        new.Name = name;
        new.DataName = dataName;
        return new;
    end
end


return ModComponents;