local Lib = _TEMP_CUERLIB;
local Tears = Lib:NewClass();

Tears.Animation = {
    REGULAR = 0,
    ROTATE = 1
}

local TearAnimationIndexs = {
    [Tears.Animation.REGULAR] = {
        0.3,
        0.55,
        0.675,
        0.8,
        0.925,
        1.05,
        1.175,
        1.425,
        1.675,
        1.925,
        2.175,
        2.55,
    },
    [Tears.Animation.ROTATE] = {
        0.556,
        1,
        1.333,
        1.667,
        2.5
    }
}

function Tears.GetTearAnimationIndexByScale(scale, tearAnimation)
    tearAnimation = tearAnimation or Tears.Animation.REGULAR;
    local animations = TearAnimationIndexs[tearAnimation];
    if (animations) then
        for i, sc in pairs(animations) do
            if (scale <= sc) then
                return i;
            end
        end
        return #animations + 1;
    end
    return 1;
end


Tears.TearFlags = {

}
Tears.TearFlagNum = 0;

do -- Tear Flags Set.

    local TearFlagsSet = {}
    setmetatable(TearFlagsSet, {
        __call = function()
            local new = {
                Flags = {}
            };
            TearFlagsSet.__index = TearFlagsSet
            setmetatable(new, TearFlagsSet);
            return new;
        end
    })
    function TearFlagsSet:Add(id)
        local index = math.floor(id / 64) + 1;
        local offset = id % 64;
        local value = 1 << offset;
        self.Flags[index] = (self.Flags[index] or 0) | value
    end
    function TearFlagsSet:Remove(id)
        local index = math.floor(id / 64) + 1;
        local offset = id % 64;
        local value = 1 << offset;
        self.Flags[index] = (self.Flags[index] or 0) & ~value
    end
    function TearFlagsSet:Has(id)
        local index = math.floor(id / 64) + 1;
        local offset = id % 64;
        local value = 1 << offset;
        return (self.Flags[index] or 0) & value > 0
    end
    function TearFlagsSet:Union(set)
        for i = 1, #set.Flags do
            self.Flags[i] = (self.Flags[i] or 0) | set.Flags[i]
        end
    end
    function TearFlagsSet:Intersect(set)
        local max = math.max(#self.Flags, #set.Flags);
        for i = 1, max do
            self.Flags[i] = (self.Flags[i] or 0) & (set.Flags[i] or 0)
        end
    end
    function TearFlagsSet:Reverse()
        for i, flag in pairs(self.Flags) do
            self.Flags[i] = ~(flag or 0);
        end
    end
    function TearFlagsSet:Clone()
        local new = TearFlagsSet();
        new:Union(self);
        return new;
    end
    Tears.TearFlagsSet = TearFlagsSet;
end

function Tears:RegisterModTearFlag(key)
    local id = Tears.TearFlags[key]
    if (not id) then
        id = Tears.TearFlagNum;
        Tears.TearFlags[key] = id;
        Tears.TearFlagNum = id + 1;
    end
    return id;
end

local function GetTearData(tear, create)
    local data = Lib:GetLibData(tear, true);
    if (create) then
        data._TEARS = data._TEARS or {
            TearFlags = {}
        }
    end
    return data._TEARS;
end

function Tears.GetModTearFlags(tear, create, modId)
    modId = modId or Lib.ModInfo.DataName;
    local tearData = GetTearData(tear, create);
    if (tearData) then
        if (create) then
            tearData[modId] = tearData[modId] or Tears.TearFlagsSet();
        end
        return tearData[modId];
    end
    return nil;
end

do -- Variants

    Tears.KindFlags = {
        BLUE = 1,
        BLOOD = 1 << 1
    }
    
    Tears.TearVariantInfos = {
        [TearVariant.BLUE] = {
            KindFlags = Tears.KindFlags.BLUE,
            Priority = 0,
            BloodVariant = TearVariant.BLOOD,
        },
        [TearVariant.BLOOD] = {
            KindFlags = Tears.KindFlags.BLOOD,
            Priority = 0,
            BlueVariant = TearVariant.BLUE,
        },
        [TearVariant.CUPID_BLUE] = {
            KindFlags = Tears.KindFlags.BLUE,
            Priority = 1,
            BloodVariant = TearVariant.CUPID_BLOOD,
        },
        [TearVariant.CUPID_BLOOD] = {
            KindFlags = Tears.KindFlags.BLOOD,
            Priority = 1,
            BlueVariant = TearVariant.CUPID_BLUE,
        },
        [TearVariant.PUPULA] = {
            KindFlags = Tears.KindFlags.BLUE,
            Priority = 1,
            BloodVariant = TearVariant.PUPULA_BLOOD,
        },
        [TearVariant.PUPULA_BLOOD] = {
            KindFlags = Tears.KindFlags.BLOOD,
            Priority = 1,
            BlueVariant = TearVariant.PUPULA,
        },
        [TearVariant.GLAUCOMA] = {
            KindFlags = Tears.KindFlags.BLUE,
            Priority = 0,
            BloodVariant = TearVariant.GLAUCOMA,
        },
        [TearVariant.GLAUCOMA_BLOOD] = {
            KindFlags = Tears.KindFlags.BLOOD,
            Priority = 0,
            BlueVariant = TearVariant.GLAUCOMA_BLOOD,
        },
    }
    
    function Tears:CanOverrideVariant(override, variant)
        return variant == TearVariant.BLUE or variant == TearVariant.BLOOD or variant == TearVariant.CUPID_BLUE or variant ==
            TearVariant.CUPID_BLOOD or variant == TearVariant.PUPULA or variant == TearVariant.PUPULA_BLOOD or variant ==
            TearVariant.GLAUCOMA or variant == TearVariant.GLAUCOMA_BLOOD
            
             or variant == TearVariant.METALLIC;
    end
    function Tears:IsTearVariantBlood(variant)
        local info = Tears.TearVariantInfos[variant];
        if (info)then
            return info.KindFlags & Tears.KindFlags.BLOOD > 0;
        end
        return false;
    end
    
    function Tears:IsTearVariantBlue(variant)
        local info = Tears.TearVariantInfos[variant];
        if (info)then
            return info.KindFlags & Tears.KindFlags.BLUE > 0;
        end
        return false;
    end
    function Tears:GetBloodVariant(variant)
        local info = Tears.TearVariantInfos[variant];
        if (info)then
            return info.BloodVariant or -1;
        end
        return -1;
    end
end

local firstTears = {}
local firstTearFlags = {}
local function PostUpdate(mod)

    for i, tear in pairs(Isaac.FindByType(2)) do
        local initSeed = tostring(tear.InitSeed);
        if (tear.FrameCount <= 0) then
            local otherFlags = firstTearFlags[initSeed];
            if (otherFlags) then
                Tears.GetModTearFlags(tear, true):Union(otherFlags);
            end
        else
            if (not firstTears[initSeed]) then
                local flags = Tears.GetModTearFlags(tear, false);
                if (flags) then
                    firstTears[initSeed] = tear;
                    firstTearFlags[initSeed]= flags;
                end
            end
        end
    end
    for i, tear in pairs(firstTears) do
        if (not tear:Exists()) then
            firstTears[i] = nil;
            firstTearFlags[i] = nil
        end 
    end
end
Tears:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);


return Tears;