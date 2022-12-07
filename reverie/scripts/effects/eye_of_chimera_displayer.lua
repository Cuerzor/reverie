local Screen = CuerLib.Screen;
local Displayer = ModEntity("Eye of Chimera Displayer", "CHIMERA_DISPLAYER");
function Displayer:GetSprite()
    local spr = Sprite();
    spr:Load("gfx/reverie/ui/tag_icons.anm2", true);
    return spr;
end
Displayer.Sprite = Displayer:GetSprite();

function Displayer:PostEffectInit(effect)
    effect:SetColor(Color(1,1,1,0,0,0,0), 5, 0, true, true);
end
Displayer:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, Displayer.PostEffectInit, Displayer.Variant);

function Displayer:PostEffectUpdate(effect)
    local parent = effect.Parent;
    if (parent and parent.Type == EntityType.ENTITY_PICKUP and parent.Variant == PickupVariant.PICKUP_COLLECTIBLE and parent.SubType ~= 0) then
        effect.SubType = parent.SubType;
        if (parent.Position.X <= 320) then
            effect.TargetPosition = parent.Position --+ Vector(80, 0);
        else
            effect.TargetPosition = parent.Position --- Vector(80, 0);
        end
        effect.Velocity = (effect.TargetPosition - effect.Position) * 0.3

        effect.Timeout = 10;
        if (not THI:IsUnknownItem(parent)) then
            effect.Timeout = 5;
            effect.Parent = nil;
        end

    else
        if (effect.Timeout > 0) then
            effect.Timeout = effect.Timeout - 1;
            effect:SetColor(Color(1,1,1,math.min(1, effect.Timeout / 5),0,0,0), 5, 0, true, true);
        else
            effect:Remove();
        end
    end
end
Displayer:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Displayer.PostEffectUpdate, Displayer.Variant);


function Displayer:PostEffectRender(effect, offset)
    local room = Game():GetRoom();
    if (room:GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT) then
        local data = effect:GetData();
        local exists = false;
        local quality = 0;
        local charges = 0;
        local chargeType = nil;
        local itemType = nil;
        local tags = nil;

        local cache = data._REVERIE_CHIMERA_EYE_CACHE;
        if (cache and cache.ID == effect.SubType) then
            exists = true;
            quality = cache.Quality;
            tags = cache.Tags;
            charges = cache.Charges or 0;
            chargeType = cache.ChargeType;
            itemType = cache.ItemType or ItemType.ITEM_PASSIVE;
        else
            local itemConfig = Isaac.GetItemConfig();
            local config = itemConfig:GetCollectible(effect.SubType);
            if (config) then
                quality = config.Quality;
                tags = {};
                local tagFlags = config.Tags;
                local tagId = 0;
                while (tagFlags > 0) do
                    if (tagFlags & 1 > 0) then
                        if (tagId ~= 26) then
                            table.insert(tags, tagId);
                        end
                    end
                    tagId = tagId + 1;
                    tagFlags = tagFlags >> 1;
                end
                charges = config.MaxCharges;
                chargeType = config.ChargeType;
                itemType = config.Type;

                data._REVERIE_CHIMERA_EYE_CACHE = data._REVERIE_CHIMERA_EYE_CACHE or {};
                local cache = data._REVERIE_CHIMERA_EYE_CACHE;
                cache.Quality = quality;
                cache.Tags = tags;
                cache.Charges = charges;
                cache.ChargeType = chargeType;
                cache.ItemType = itemType;
                cache.ID = effect.SubType;
                exists = true;
            end
        end

        if (exists) then
            
            local center = Screen.GetEntityOffsetedRenderPosition(effect, offset + effect.SpriteOffset,Vector.Zero , false);
            local spr = self.Sprite;
            spr.Color = effect:GetColor();

            local qualityPos = center + Vector(0, -20);
            if (itemType == ItemType.ITEM_ACTIVE or itemType == ItemType.ITEM_FAMILIAR) then
                qualityPos = qualityPos + Vector(-6, 0);
            end
            spr:SetFrame("Qualities", quality)
            spr:Render(qualityPos, Vector.Zero, Vector.Zero);

            local typePos = qualityPos + Vector(12, 0) 
            if (itemType == ItemType.ITEM_ACTIVE) then
                if (chargeType == ItemConfig.CHARGE_NORMAL) then
                    spr:SetFrame("Charges", charges)
                elseif (chargeType == ItemConfig.CHARGE_TIMED) then
                    spr:SetFrame("Charges", 14)
                else
                    spr:SetFrame("Charges", 13)
                end
                spr:Render(typePos, Vector.Zero, Vector.Zero);
            elseif (itemType == ItemType.ITEM_FAMILIAR) then
                spr:SetFrame("Familiar", 0)
                spr:Render(typePos, Vector.Zero, Vector.Zero);
            end

            local tagsPos = center + Vector(0, 0);
            local tagCount = #tags;
            for i, tag in ipairs(tags) do
                local index = i - 1;
                local row = math.floor(index / 3);
                local column = index % 3;
                local columnsThisRow = 3;
                if (row >= math.floor(tagCount / 3))  then
                    columnsThisRow = tagCount % 3;
                end
                local x = (column - (columnsThisRow - 1) / 2) * 16;
                local y = row * 16;
                local tagPos = tagsPos + Vector(x, y)
                spr:SetFrame("Tags", tag);
                spr:Render(tagPos, Vector.Zero, Vector.Zero);
            end
        end
    end
end
Displayer:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, Displayer.PostEffectRender, Displayer.Variant);

return Displayer;