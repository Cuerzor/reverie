local Revive = CuerLib.Revive;
local Damages = CuerLib.Damages;
local Screen = CuerLib.Screen;

local AshOfPheonix = ModItem("Ash of Pheonix", "AshOfPheonix");
AshOfPheonix.AshGFX = {
    [PlayerType.PLAYER_ISAAC] = "gfx/characters/costumes/ash_of_pheonix/isaac.png",
    [PlayerType.PLAYER_MAGDALENA] = "gfx/characters/costumes/ash_of_pheonix/maggy.png",
    [PlayerType.PLAYER_CAIN] = "gfx/characters/costumes/ash_of_pheonix/cain.png",
    [PlayerType.PLAYER_JUDAS] = "gfx/characters/costumes/ash_of_pheonix/judas.png",
    [PlayerType.PLAYER_XXX] = "gfx/characters/costumes/ash_of_pheonix/bluebaby.png",
    [PlayerType.PLAYER_EVE] = "gfx/characters/costumes/ash_of_pheonix/eve.png",
    [PlayerType.PLAYER_SAMSON] = "gfx/characters/costumes/ash_of_pheonix/samson.png",
    [PlayerType.PLAYER_AZAZEL] = "gfx/characters/costumes/ash_of_pheonix/azazel.png",
    [PlayerType.PLAYER_LAZARUS] = "gfx/characters/costumes/ash_of_pheonix/lazarus.png",
    [PlayerType.PLAYER_EDEN] = "gfx/characters/costumes/ash_of_pheonix/eden.png",
    [PlayerType.PLAYER_THELOST] = "gfx/characters/costumes/ash_of_pheonix/lost.png",
    [PlayerType.PLAYER_LAZARUS2] = "gfx/characters/costumes/ash_of_pheonix/lazarus2.png",
    [PlayerType.PLAYER_BLACKJUDAS] = "gfx/characters/costumes/ash_of_pheonix/dark_judas.png",
    [PlayerType.PLAYER_LILITH] = "gfx/characters/costumes/ash_of_pheonix/lilith.png",
    [PlayerType.PLAYER_KEEPER] = "gfx/characters/costumes/ash_of_pheonix/keeper.png",
    [PlayerType.PLAYER_APOLLYON] = "gfx/characters/costumes/ash_of_pheonix/apollyon.png",
    [PlayerType.PLAYER_THEFORGOTTEN] = "gfx/characters/costumes/ash_of_pheonix/forgotten.png",
    [PlayerType.PLAYER_THESOUL] = "gfx/characters/costumes/ash_of_pheonix/forgotten_soul.png",
    [PlayerType.PLAYER_BETHANY] = "gfx/characters/costumes/ash_of_pheonix/bethany.png",
    [PlayerType.PLAYER_JACOB] = "gfx/characters/costumes/ash_of_pheonix/jacob.png",
    [PlayerType.PLAYER_ESAU] = "gfx/characters/costumes/ash_of_pheonix/esau.png",

    [THI.Players.Eika.Type] = "gfx/characters/costumes/ash_of_pheonix/eika.png",
    
    [PlayerType.PLAYER_ISAAC_B] = "gfx/characters/costumes/ash_of_pheonix/isaac_b.png",
    [PlayerType.PLAYER_MAGDALENA_B] = "gfx/characters/costumes/ash_of_pheonix/maggy_b.png",
    [PlayerType.PLAYER_CAIN_B] = "gfx/characters/costumes/ash_of_pheonix/cain_b.png",
    [PlayerType.PLAYER_JUDAS_B] = "gfx/characters/costumes/ash_of_pheonix/judas_b.png",
    [PlayerType.PLAYER_XXX_B] = "gfx/characters/costumes/ash_of_pheonix/bluebaby_b.png",
    [PlayerType.PLAYER_EVE_B] = "gfx/characters/costumes/ash_of_pheonix/eve_b.png",
    [PlayerType.PLAYER_SAMSON_B] = "gfx/characters/costumes/ash_of_pheonix/samson_b.png",
    [PlayerType.PLAYER_AZAZEL_B] = "gfx/characters/costumes/ash_of_pheonix/azazel_b.png",
    [PlayerType.PLAYER_LAZARUS_B] = "gfx/characters/costumes/ash_of_pheonix/lazarus_b.png",
    [PlayerType.PLAYER_EDEN_B] = "gfx/characters/costumes/ash_of_pheonix/eden_b.png",
    [PlayerType.PLAYER_THELOST_B] = "gfx/characters/costumes/ash_of_pheonix/lost_b.png",
    [PlayerType.PLAYER_LILITH_B] = "gfx/characters/costumes/ash_of_pheonix/lilith_b.png",
    [PlayerType.PLAYER_KEEPER_B] = "gfx/characters/costumes/ash_of_pheonix/keeper_b.png",
    [PlayerType.PLAYER_APOLLYON_B] = "gfx/characters/costumes/ash_of_pheonix/apollyon_b.png",
    [PlayerType.PLAYER_THEFORGOTTEN_B] = "gfx/characters/costumes/ash_of_pheonix/forgotten_b.png",
    [PlayerType.PLAYER_BETHANY_B] = "gfx/characters/costumes/ash_of_pheonix/bethany_b.png",
    [PlayerType.PLAYER_JACOB_B] = "gfx/characters/costumes/ash_of_pheonix/jacob_b.png",
    [PlayerType.PLAYER_LAZARUS2_B] = "gfx/characters/costumes/ash_of_pheonix/lazarus2_b.png",
    [PlayerType.PLAYER_JACOB2_B] = "gfx/characters/costumes/ash_of_pheonix/jacob2_b.png",
    [PlayerType.PLAYER_THESOUL_B] = "gfx/characters/costumes/ash_of_pheonix/forgotten_soul.png",
    
    [THI.Players.EikaB.Type] = "gfx/characters/costumes/ash_of_pheonix/eika_b.png",
}
AshOfPheonix.AshSprites = {};

for k ,v in pairs(AshOfPheonix.AshGFX) do
    local spr = Sprite();
    spr:Load("gfx/characters/isaacs_ash.anm2", true);
    spr:ReplaceSpritesheet(0, v);
    spr:LoadGraphics();
    spr:Play("Idle");
    AshOfPheonix.AshSprites[k] = spr
end
local function GetShieldSprite()
    local spr = Sprite();
    spr:Load("gfx/characters/058_book of shadows.anm2", true);
    spr:SetAnimation("WalkDown");
    spr.PlaybackSpeed = 0.5;
    return spr;
end

function AshOfPheonix:GetPlayerData(player, init)
    return AshOfPheonix:GetData(player, init, function() return {
        Ashed = false,
        AshTime = 0,
        NoTrigger = false,
        SetCooldown = false,
        ShieldSprite = GetShieldSprite()
    } end);
end

function AshOfPheonix:IsAsh(player)
    local data = AshOfPheonix:GetPlayerData(player, false);
    return data and data.Ashed;
end

local function RenderPlayerAsh(player, offset)
    local playerType = player:GetPlayerType();
    local spr = AshOfPheonix.AshSprites[playerType];
    if (not spr) then
        spr = AshOfPheonix.AshSprites[PlayerType.PLAYER_ISAAC];
    end
    local pos = Screen.GetEntityOffsetedRenderPosition(player, offset);
    spr:Render(pos, Vector.Zero, Vector.Zero);

    
end


function AshOfPheonix:PostPlayerTakeDamage(entity, amount, flags, source, countdown)
    local player = entity:ToPlayer();
    if (player:HasCollectible(AshOfPheonix.Item)) then
        local ivBag = Damages.IsSelfDamage(entity, flags, source);
        local data = AshOfPheonix:GetPlayerData(player, true);
        data.NoTrigger = ivBag;
    end
    
    local data = AshOfPheonix:GetPlayerData(player, false);
    if (data and data.Ashed and not player:IsDead()) then
        
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player);
        player:Kill();
        data.AshTime = 1;

        local renderRNG = RNG();
        renderRNG:SetSeed(Random(), 0);
        for i = 1, 4 do
            local dust = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.DUST_CLOUD,0, player.Position, Vector.FromAngle(renderRNG:RandomFloat() * 360) * renderRNG:RandomFloat() * 5, player); 
            
            local e = dust:ToEffect(); 
            e.LifeSpan = math.floor(renderRNG:RandomFloat() * 10 + 20);
            e.Timeout = e.LifeSpan;
        end
    end
end
AshOfPheonix:AddCustomCallback(CLCallbacks.CLC_POST_ENTITY_TAKE_DMG, AshOfPheonix.PostPlayerTakeDamage, EntityType.ENTITY_PLAYER, 32);

-- function AshOfPheonix:PostPlayerKill(entity)
--     local player = entity:ToPlayer();
--     if (player:HasCollectible(AshOfPheonix.Item)) then
--         local data = AshOfPheonix:GetPlayerData(player, true);
--         if (not data.Ashed and not data.NoTrigger) then
--             THI.SFXManager:Play(SoundEffect.SOUND_ISAACDIES);
--             player:Revive();
--             data.AshTime = 120;
--             data.Ashed = true;
--             data.SetCooldown = true;
--             Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player);
        
--             -- Create Dusts.
            
--             local renderRNG = RNG();
--             renderRNG:SetSeed(Random(), 0);
--             Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.FIRE_JET,0, player.Position, Vector.Zero, player); 
--             for i = 1, 4 do
--                 local waveEnt = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.FIRE_WAVE,0, player.Position, Vector.Zero, player);  
--                 local wave = waveEnt:ToEffect();
--                 wave.Rotation = i * 90;

--                 local dust = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.DUST_CLOUD,0, player.Position, Vector.FromAngle(renderRNG:RandomFloat() * 360) * renderRNG:RandomFloat() * 5, player); 
                
--                 local e = dust:ToEffect(); 
--                 e.LifeSpan = math.floor(renderRNG:RandomFloat() * 10 + 20);
--                 e.Timeout = e.LifeSpan;
--             end
--         end
--     end
-- end
-- AshOfPheonix:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, AshOfPheonix.PostPlayerKill, EntityType.ENTITY_PLAYER);

function AshOfPheonix:PostPlayerUpdate(player)
    local data = AshOfPheonix:GetPlayerData(player, false);
    if (data and data.Ashed) then
        if (not player:IsDead()) then
            data.NoTrigger = false;
        end
        player.Velocity = Vector.Zero;
        player:SetColor(Color(0,0,0,0,0,0,0), 2, 0, false, true);
        player.ControlsEnabled = false;

        if (data.SetCooldown) then
            data.SetCooldown = false;
            player:ResetDamageCooldown();
            player:SetMinDamageCooldown(90);
        end
        -- If has shield 
        local shieldEffect = player:GetEffects():GetCollectibleEffect(58);
        if (shieldEffect) then
            local spr = data.ShieldSprite;
            data.AshTime = 60;

            if (shieldEffect.Cooldown > 90) then
                if (not spr:IsPlaying("WalkDown")) then
                    spr:Play("WalkDown");
                end
            else
                if (not spr:IsPlaying("Blink")) then
                    spr:Play("Blink");
                end
            end
            spr:Update();
        end
        
        if (not player:IsDead() and data.AshTime > 0) then
            data.AshTime = data.AshTime - 1;
            if (data.AshTime <= 0) then
                data.Ashed = false;
                data.AshTime = 0;
                player.ControlsEnabled = true;
                player:SetMinDamageCooldown(45);
                Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.FIRE_JET,0, player.Position, Vector.Zero, player);
                for i = 1, 4 do
                    local waveEnt = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.FIRE_WAVE,0, player.Position, Vector.Zero, player);  
                    local wave = waveEnt:ToEffect();
                    wave.Rotation = i * 90;
                end
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player);
            end 
        end
    end
end
AshOfPheonix:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, AshOfPheonix.PostPlayerUpdate);

function AshOfPheonix:PostPlayerRender(player, offset)
    local data = AshOfPheonix:GetPlayerData(player, false);
    if (data and data.Ashed and not player:IsDead()) then
        RenderPlayerAsh(player, offset);

        
        -- If has shield 
        local shieldEffect = player:GetEffects():GetCollectibleEffect(58);
        if (shieldEffect) then
            local spr = data.ShieldSprite;
            if (spr) then
                local pos = Screen.GetEntityOffsetedRenderPosition(player, offset, Vector(0, 12));
                
                spr:Render(pos, Vector.Zero, Vector.Zero);
            end
        end
    end
end
AshOfPheonix:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, AshOfPheonix.PostPlayerRender);


local function CanRevive(player)
    
    if (player:HasCollectible(AshOfPheonix.Item)) then
        local data = AshOfPheonix:GetPlayerData(player, false);
        if (data and not data.Ashed and not data.NoTrigger) then
            return true;
        end
    end
    return false;
end
local function PostRevive(player, reviver)
    local data = AshOfPheonix:GetPlayerData(player, false);
    THI.SFXManager:Play(SoundEffect.SOUND_ISAACDIES);
    player:Revive();
    data.AshTime = 120;
    data.Ashed = true;
    data.SetCooldown = true;
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player);

    -- Create Dusts.
    
    local renderRNG = RNG();
    renderRNG:SetSeed(Random(), 0);
    Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.FIRE_JET,0, player.Position, Vector.Zero, player); 
    for i = 1, 4 do
        local waveEnt = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.FIRE_WAVE,0, player.Position, Vector.Zero, player);  
        local wave = waveEnt:ToEffect();
        wave.Rotation = i * 90;

        local dust = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.DUST_CLOUD,0, player.Position, Vector.FromAngle(renderRNG:RandomFloat() * 360) * renderRNG:RandomFloat() * 5, player); 
        
        local e = dust:ToEffect(); 
        e.LifeSpan = math.floor(renderRNG:RandomFloat() * 10 + 20);
        e.Timeout = e.LifeSpan;
    end
end
Revive.AddReviveInfo(true, 1, nil, CanRevive, PostRevive, false);

return AshOfPheonix;