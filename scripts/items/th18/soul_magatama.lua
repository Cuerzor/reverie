local HoldingActive = CuerLib.HoldingActive;
local Screen = CuerLib.Screen;
local Magatama = ModItem("Soul Magatama", "SOUL_MAGATAMA");

function Magatama:SwapHP(ent1, ent2)
    local function GetHP(ent)
        local player = ent:ToPlayer();
        if (player) then
            local maxHearts = player:GetEffectiveMaxHearts();
            if (maxHearts > 0) then
                --local hearts = math.max(1, player:GetHearts());
                local hearts = player:GetHearts();
                return hearts/ maxHearts;
            else
                return nil;
            end
        else
            
            local maxHP = ent.MaxHitPoints;
            if (maxHP > 0) then
                return ent.HitPoints / maxHP;
            else
                return nil;
            end
        end
    end

    local function ApplyHP(ent, hp)
        local player = ent:ToPlayer();
        if (player) then
            local maxHearts = player:GetEffectiveMaxHearts();
            local targetHearts;
            
            if (hp) then 
                targetHearts = math.max(1, math.ceil(hp * maxHearts));
            else
                targetHearts = maxHearts;
            end

            local playerType = player:GetPlayerType();
            if (playerType == PlayerType.PLAYER_KEEPER or playerType == PlayerType.PLAYER_KEEPER_B) then
                targetHearts = math.ceil(targetHearts / 2) * 2;
            end
            
            local hearts = player:GetHearts();
            local diff = math.min(targetHearts - hearts, maxHearts);
            player:AddHearts(diff);
            return diff / 2;
        else
            local maxHP = ent.MaxHitPoints;
            local isBoss = ent:IsBoss();
            if (hp) then
                local targetHp = hp * maxHP;
                if (isBoss) then
                    targetHp = math.max(math.min(ent.HitPoints, maxHP * 0.25), targetHp);
                end
                local diff = targetHp - ent.HitPoints;
                ent.HitPoints = targetHp;
                return diff;
            else
                
                if (isBoss) then
                    --ent.HitPoints = maxHP;
                    --ent.HitPoints = math.min(maxHP, 404);
                    ent.HitPoints = math.min(ent.HitPoints, maxHP * 0.25);
                else
                    local npc = ent:ToNPC();
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, nil);
                    if (npc) then
                        -- npc:Remove();
                        -- Isaac.Spawn(EntityType.ENTITY_SHOPKEEPER, 2, 0, npc.Position, Vector.Zero, nil);
                        npc:Morph(EntityType.ENTITY_SHOPKEEPER, 2, 0, -1);
                        npc.FlipX = false;
                        npc.TargetPosition = npc.Position;
                        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY;
                    else
                        npc:Remove();
                    end
                end
                return nil;
            end
        end
    end

    local hp1 = GetHP(ent1);
    local hp2 = GetHP(ent2);
    local changed1 = ApplyHP(ent1, hp2);
    local changed2 = ApplyHP(ent2, hp1);
    return changed1, changed2, ent1, ent2;
end

do -- Tears.

    local MagatamaTear = ModEntity("Magatama Tear", "SOUL_MAGATAMA");
    Magatama.TearEntity = MagatamaTear;
    local MagatamaColor = Color(0,1,0,1,0,0,0);

    local function PreTearCollision(mod, tear, other, low)
        local spawner = tear.SpawnerEntity;
        if (spawner) then
            if (other:IsActiveEnemy() and other:IsVulnerableEnemy() and not other:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                local changed1, changed2 = Magatama:SwapHP(spawner, other);
                local LifeSwap = Magatama.LifeSwap;
                local swap = Isaac.Spawn(LifeSwap.Type, LifeSwap.Variant, LifeSwap.SubTypes.SWAP, spawner.Position, spawner.Velocity, spawner);
                swap.Parent = spawner;
                swap.Child = other;
                LifeSwap:UpdateSprite(swap)
                Game():ShakeScreen(15);

                local poofColor = Color(0.5,0,0.5, 0.5, 0, 0, 0);
                for e = 0 ,1 do
                    local changed = changed1;
                    local ent = spawner;
                    if (e == 1) then
                        changed = changed2;
                        ent = other;
                    end
                    for p = 0, 1 do
                        local subType = p + 1;
                        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, subType, ent.Position, Vector.Zero, ent);
                        poof:SetColor(poofColor, 0, 0);
                    end



                    local text = Isaac.Spawn(LifeSwap.Type, LifeSwap.Variant, LifeSwap.SubTypes.TEXT, ent.Position, Vector.Zero, ent);
                    local textEffect = text:ToEffect();
                    LifeSwap:SetTextValue(textEffect, changed);
                    textEffect.Timeout = 60;
                    textEffect.DepthOffset = 1;
                    textEffect.Parent = ent;
                end
                THI.SFXManager:Play(SoundEffect.SOUND_MAW_OF_VOID);
            end
        end
    end
    MagatamaTear:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, PreTearCollision, MagatamaTear.Variant);

    local function PostTearUpdate(mod, tear)
        tear.SpriteRotation = tear.Velocity:GetAngleDegrees();
        if (tear:IsDead()) then
            local impact = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, tear.Position + tear.PositionOffset, Vector.Zero, nil);
            impact:SetColor(MagatamaColor, 0, 0);
            Game():SpawnParticles (tear.Position, EffectVariant.NAIL_PARTICLE, 2, 5, MagatamaColor);
            THI.SFXManager:Play(SoundEffect.SOUND_POT_BREAK, 1, 0, false, 2);
        end
    end
    MagatamaTear:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, PostTearUpdate, MagatamaTear.Variant);
end

do -- Effects.
    
    local LifeSwap = ModEntity("Life Swap", "SOUL_MAGATAMA");
    LifeSwap.SubTypes = {
        SWAP = 0,
        TEXT = 1
    }
    Magatama.LifeSwap = LifeSwap;

    local function GetLifeSwapData(effect, create)
        local function getter()
            return {
                Value = nil
            }
        end
        return LifeSwap:GetData(effect, create, getter);
    end

    function LifeSwap:SetTextValue(effect, value)
        local data = GetLifeSwapData(effect, true)
        data.Value = value;
    end
    function LifeSwap:GetTextValue(effect)
        local data = GetLifeSwapData(effect, false)
        return (data and data.Value) or nil;
    end

    function LifeSwap:UpdateSprite(effect)
        local parent = effect.Parent;
        if (parent) then
            effect.Position = parent.Position;
            effect.Velocity = parent.Velocity;
        end

        local child = effect.Child;
        if (child) then
            local dir = child.Position - effect.Position;
            effect.SpriteRotation = dir:GetAngleDegrees();
            effect.SpriteScale = Vector(dir:Length() / 200, 1);
        end

        if (effect:GetSprite():IsFinished("Idle")) then
            effect:Remove();
        end
    end

    local function PostEffectInit(mod, effect)
        local subType = effect.SubType;
        if (subType == LifeSwap.SubTypes.SWAP) then
            local spr = effect:GetSprite();
            spr:Load("gfx/reverie/1000.5838_life swap.anm2", true);
            spr:Play("Idle");
        end
    end
    LifeSwap:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, LifeSwap.Variant)

    local function PostEffectUpdate(mod, effect)
        local subType = effect.SubType;
        if (subType == LifeSwap.SubTypes.SWAP) then
            LifeSwap:UpdateSprite(effect);
        elseif (subType == LifeSwap.SubTypes.TEXT) then
            
            local parent = effect.Parent;
            if (parent) then
                effect.Position = parent.Position;
                effect.Velocity = parent.Velocity;
            end

            effect.PositionOffset = effect.PositionOffset + Vector(0, -1);
            if (effect.Timeout == 0) then
                effect:Remove();
            end
        end
    end
    LifeSwap:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, LifeSwap.Variant)

    local TextFonts = {
        en = THI.Fonts.PFTempesta7,
        zh = THI.Fonts.Lanapixel
    }
    local function PostEffectRender(mod, effect, offset)
        local subType = effect.SubType;
        if (subType == LifeSwap.SubTypes.TEXT) then
            local room = Game():GetRoom();
            if (room:GetRenderMode() == RenderMode.RENDER_NORMAL) then
                local pos = Screen.GetEntityOffsetedRenderPosition(effect, offset);
                local alpha = math.min(1, effect.Timeout / 30)
                local color = KColor(1,0,0,alpha);
                local value = LifeSwap:GetTextValue(effect);
                local str;
                if (value == nil) then
                    str = THI.GetText(THI.StringCategories.DEFAULT, "#MAGATAMA_ERROR");
                else
                    if (value > 0) then
                        color = KColor(0,1,0,alpha);
                    elseif (value == 0) then
                        color = KColor(1,1,1,alpha);
                    end
                    str = string.format("%+.1f", value);
                end
                local font = TextFonts[Options.Language] or TextFonts.en;
                font:DrawStringUTF8(str, pos.X - 64, pos.Y, color, 128, true);
            end
        end
    end
    LifeSwap:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, PostEffectRender, LifeSwap.Variant)
end

function Magatama:FireMagatama(player, position, velocity)
    local tearInfo = Magatama.TearEntity;
    THI.SFXManager:Play(SoundEffect.SOUND_SHELLGAME);
    local tearEnt = Isaac.Spawn(tearInfo.Type, tearInfo.Variant, 0, position, velocity, player)
    local tear = tearEnt:ToTear();
    tear.CollisionDamage = 1;
end


do -- Active Item.
    local function PostUseMagatama(mod, item, rng, player, flags, slot, varData)
        if (flags & UseFlag.USE_CARBATTERY <= 0) then
            return HoldingActive:SwitchHolding(item, player, slot);
        end
        return {Discharge = false};
    end
    Magatama:AddCallback(ModCallbacks.MC_USE_ITEM, PostUseMagatama, Magatama.Item);

    local function PostPlayerEffect(mod, player)
        HoldingActive:ReleaseOnShoot(player, Magatama.Item)
    end
    Magatama:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect)

    local function PostReleaseMagatama(mod, player, item, direction)
        local velocity = direction * 10;
        velocity = velocity + player:GetTearMovementInheritance(velocity);
        local position = player.Position;
        Magatama:FireMagatama(player, position, velocity);
    end
    Magatama:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_RELEASE_HOLDING_ACTIVE, PostReleaseMagatama, Magatama.Item);
end

do -- Wisp.
    local function PostTakeDamage(mod, tookDamage, amount, flags, source, countdown)
        local sourceWisp = nil;
        local src = source.Entity;
        local hasTear = false;
        while (src) do
            if (hasTear) then
                if (src.Type == EntityType.ENTITY_FAMILIAR and src.Variant == FamiliarVariant.WISP and src.SubType == Magatama.Item) then
                    sourceWisp = src;
                    break;
                end
            else
                if (src.Type == EntityType.ENTITY_TEAR) then
                    hasTear = true;
                end
            end
            src = src.SpawnerEntity;
        end
        if (sourceWisp) then
            if (sourceWisp.HitPoints < sourceWisp.MaxHitPoints) then
                local diff = math.min(sourceWisp.MaxHitPoints - sourceWisp.HitPoints, amount)
                sourceWisp.HitPoints = sourceWisp.HitPoints + diff;
                local LifeSwap = Magatama.LifeSwap;
                local text = Isaac.Spawn(LifeSwap.Type, LifeSwap.Variant, LifeSwap.SubTypes.TEXT, sourceWisp.Position, Vector.Zero, sourceWisp) : ToEffect();
                text.DepthOffset = 1;
                text.Timeout = 60;
                LifeSwap:SetTextValue(text, diff);
                text.Parent = sourceWisp;
            end
        end
    end
    Magatama:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_ENTITY_TAKE_DMG, PostTakeDamage);
end

return Magatama;