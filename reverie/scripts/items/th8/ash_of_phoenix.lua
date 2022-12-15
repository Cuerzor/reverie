local Revive = CuerLib.Revive;
local Damages = CuerLib.Damages;
local Screen = CuerLib.Screen;
local Players = CuerLib.Players;

local AshOfPhoenix = ModItem("Ash of Phoenix", "AshOfPhoenix");

-- local rootPath = "gfx/reverie/characters/costumes/ash_of_phoenix/";
-- AshOfPhoenix.AshGFX = {
--     [PlayerType.PLAYER_ISAAC] = rootPath.."isaac.png",
--     [PlayerType.PLAYER_MAGDALENA] = rootPath.."maggy.png",
--     [PlayerType.PLAYER_CAIN] = rootPath.."cain.png",
--     [PlayerType.PLAYER_JUDAS] = rootPath.."judas.png",
--     [PlayerType.PLAYER_XXX] = rootPath.."bluebaby.png",
--     [PlayerType.PLAYER_EVE] = rootPath.."eve.png",
--     [PlayerType.PLAYER_SAMSON] = rootPath.."samson.png",
--     [PlayerType.PLAYER_AZAZEL] = rootPath.."azazel.png",
--     [PlayerType.PLAYER_LAZARUS] = rootPath.."lazarus.png",
--     [PlayerType.PLAYER_EDEN] = rootPath.."eden.png",
--     [PlayerType.PLAYER_THELOST] = rootPath.."lost.png",
--     [PlayerType.PLAYER_LAZARUS2] = rootPath.."lazarus2.png",
--     [PlayerType.PLAYER_BLACKJUDAS] = rootPath.."dark_judas.png",
--     [PlayerType.PLAYER_LILITH] = rootPath.."lilith.png",
--     [PlayerType.PLAYER_KEEPER] = rootPath.."keeper.png",
--     [PlayerType.PLAYER_APOLLYON] = rootPath.."apollyon.png",
--     [PlayerType.PLAYER_THEFORGOTTEN] = rootPath.."forgotten.png",
--     [PlayerType.PLAYER_THESOUL] = rootPath.."forgotten_soul.png",
--     [PlayerType.PLAYER_BETHANY] = rootPath.."bethany.png",
--     [PlayerType.PLAYER_JACOB] = rootPath.."jacob.png",
--     [PlayerType.PLAYER_ESAU] = rootPath.."esau.png",

--     [THI.Players.Eika.Type] = rootPath.."eika.png",
--     [THI.Players.Satori.Type] = rootPath.."satori.png",
    
--     [PlayerType.PLAYER_ISAAC_B] = rootPath.."isaac_b.png",
--     [PlayerType.PLAYER_MAGDALENA_B] = rootPath.."maggy_b.png",
--     [PlayerType.PLAYER_CAIN_B] = rootPath.."cain_b.png",
--     [PlayerType.PLAYER_JUDAS_B] = rootPath.."judas_b.png",
--     [PlayerType.PLAYER_XXX_B] = rootPath.."bluebaby_b.png",
--     [PlayerType.PLAYER_EVE_B] = rootPath.."eve_b.png",
--     [PlayerType.PLAYER_SAMSON_B] = rootPath.."samson_b.png",
--     [PlayerType.PLAYER_AZAZEL_B] = rootPath.."azazel_b.png",
--     [PlayerType.PLAYER_LAZARUS_B] = rootPath.."lazarus_b.png",
--     [PlayerType.PLAYER_EDEN_B] = rootPath.."eden_b.png",
--     [PlayerType.PLAYER_THELOST_B] = rootPath.."lost_b.png",
--     [PlayerType.PLAYER_LILITH_B] = rootPath.."lilith_b.png",
--     [PlayerType.PLAYER_KEEPER_B] = rootPath.."keeper_b.png",
--     [PlayerType.PLAYER_APOLLYON_B] = rootPath.."apollyon_b.png",
--     [PlayerType.PLAYER_THEFORGOTTEN_B] = rootPath.."forgotten_b.png",
--     [PlayerType.PLAYER_BETHANY_B] = rootPath.."bethany_b.png",
--     [PlayerType.PLAYER_JACOB_B] = rootPath.."jacob_b.png",
--     [PlayerType.PLAYER_LAZARUS2_B] = rootPath.."lazarus2_b.png",
--     [PlayerType.PLAYER_JACOB2_B] = rootPath.."jacob2_b.png",
--     [PlayerType.PLAYER_THESOUL_B] = rootPath.."forgotten_soul.png",
    
--     [THI.Players.EikaB.Type] = rootPath.."eika_b.png",
--     [THI.Players.SatoriB.Type] = rootPath.."satori_b.png",
-- }
-- AshOfPhoenix.AshSprites = {};
-- for k ,v in pairs(AshOfPhoenix.AshGFX) do
--     local spr = Sprite();
--     spr:Load("gfx/reverie/characters/isaacs_ash.anm2", true);
--     spr:ReplaceSpritesheet(0, v);
--     spr:LoadGraphics();
--     spr:Play("Idle");
--     AshOfPhoenix.AshSprites[k] = spr
-- end

local rootPath = "gfx/reverie/characters/";
AshOfPhoenix.AshSubfix = {
    [PlayerType.PLAYER_MAGDALENA] = "maggy",
    [PlayerType.PLAYER_CAIN] = "cain",
    [PlayerType.PLAYER_JUDAS] = "judas",
    --[PlayerType.PLAYER_XXX] = "bluebaby",
    [PlayerType.PLAYER_EVE] = "eve",
    [PlayerType.PLAYER_SAMSON] = "samson",
    [PlayerType.PLAYER_AZAZEL] = "azazel",
    [PlayerType.PLAYER_LAZARUS] = "lazarus",
    [PlayerType.PLAYER_EDEN] = "eden",
    [PlayerType.PLAYER_THELOST] = "lost",
    [PlayerType.PLAYER_LAZARUS2] = "lazarus2",
    --[PlayerType.PLAYER_BLACKJUDAS] = "dark_judas",
    --[PlayerType.PLAYER_LILITH] = "lilith",
    --[PlayerType.PLAYER_KEEPER] = "keeper",
    --[PlayerType.PLAYER_APOLLYON] = "apollyon",
    --[PlayerType.PLAYER_THEFORGOTTEN] = "forgotten",
    --[PlayerType.PLAYER_THESOUL] = "forgotten_soul",
    [PlayerType.PLAYER_BETHANY] = "bethany",
    [PlayerType.PLAYER_JACOB] = "jacob",
    [PlayerType.PLAYER_ESAU] = "esau",

    --[THI.Players.Eika.Type] = "eika",
    --[THI.Players.Satori.Type] = "satori",
    
    [PlayerType.PLAYER_ISAAC_B] = "isaac_b",
    [PlayerType.PLAYER_MAGDALENA_B] = "maggy_b",
    [PlayerType.PLAYER_CAIN_B] = "cain_b",
    [PlayerType.PLAYER_JUDAS_B] = "judas_b",
    [PlayerType.PLAYER_XXX_B] = "bluebaby_b",
    [PlayerType.PLAYER_EVE_B] = "eve_b",
    [PlayerType.PLAYER_SAMSON_B] = "samson_b",
    [PlayerType.PLAYER_AZAZEL_B] = "azazel_b",
    [PlayerType.PLAYER_LAZARUS_B] = "lazarus_b",
    [PlayerType.PLAYER_EDEN_B] = "eden_b",
    [PlayerType.PLAYER_THELOST_B] = "lost_b",
    --[PlayerType.PLAYER_LILITH_B] = "lilith_b",
    [PlayerType.PLAYER_KEEPER_B] = "keeper_b",
    [PlayerType.PLAYER_APOLLYON_B] = "apollyon_b",
    [PlayerType.PLAYER_THEFORGOTTEN_B] = "forgotten_b",
    [PlayerType.PLAYER_BETHANY_B] = "bethany_b",
    [PlayerType.PLAYER_JACOB_B] = "jacob_b",
    [PlayerType.PLAYER_LAZARUS2_B] = "lazarus2_b",
    [PlayerType.PLAYER_JACOB2_B] = "jacob2_b",
    [PlayerType.PLAYER_THESOUL_B] = "forgotten_soul",
    
    --[THI.Players.EikaB.Type] = "eika_b",
    --[THI.Players.SatoriB.Type] = "satori_b",
}
AshOfPhoenix.AshCostumes = {};

AshOfPhoenix.AshCostumes[0] = Isaac.GetCostumeIdByPath(rootPath.."costume_isaacs_ash.anm2");
for k, v in pairs(AshOfPhoenix.AshSubfix) do
    AshOfPhoenix.AshCostumes[k] = Isaac.GetCostumeIdByPath(rootPath.."costume_isaacs_ash_"..v..".anm2");
end

-- local function GetShieldSprite()
--     local spr = Sprite();
--     spr:Load("gfx/characters/058_book of shadows.anm2", true);
--     spr:SetAnimation("WalkDown");
--     spr.PlaybackSpeed = 0.5;
--     return spr;
-- end


function AshOfPhoenix:GetPlayerData(player, init)
    return AshOfPhoenix:GetTempData(player, init, function() return {
        Ashed = false,
        AshTime = 0,
        NoTrigger = false,
        SetDamageCooldown = false,
        --ShieldSprite = GetShieldSprite()
    } end);
end

function AshOfPhoenix:IsAsh(player)
    local data = AshOfPhoenix:GetPlayerData(player, false);
    return data and data.Ashed;
end

function AshOfPhoenix:GetAshCostume(playerType)
    local costume = self.AshCostumes[playerType];
    if (costume and costume > 0) then
        return costume;
    end
    return self.AshCostumes[0];
end

function AshOfPhoenix:IntoAsh(player)
    local data = AshOfPhoenix:GetPlayerData(player, true);
    if (not data.Ashed) then
        data.Ashed = true;
        data.AshTime = 120;
        data.SetDamageCooldown = true;

        local playerType = player:GetPlayerType();
        local effects = player:GetEffects();
        effects:AddNullEffect(self:GetAshCostume(playerType));
    end
end

function AshOfPhoenix:EndAsh(player)
    local data = AshOfPhoenix:GetPlayerData(player, true);
    if (data.Ashed) then
        data.Ashed = false;
        data.AshTime = 0;
        data.SetDamageCooldown = false;

        local playerType = player:GetPlayerType();
        local effects = player:GetEffects();
        for k, v in pairs(self.AshCostumes) do
            if (v and v > 0) then
                effects:RemoveNullEffect(v, -1);
            end
        end
    end
end

-- local function RenderPlayerAsh(player, offset)
--     local playerType = player:GetPlayerType();
--     local spr = AshOfPhoenix.AshSprites[playerType];
--     if (not spr) then
--         spr = AshOfPhoenix.AshSprites[PlayerType.PLAYER_ISAAC];
--     end
--     local pos = Screen.GetEntityOffsetedRenderPosition(player, offset);
--     spr:Render(pos, Vector.Zero, Vector.Zero);

    
-- end


function AshOfPhoenix:PostPlayerTakeDamage(entity, amount, flags, source, countdown)
    local player = entity:ToPlayer();
    if (player:HasCollectible(AshOfPhoenix.Item)) then
        local ivBag = Damages.IsSelfDamage(entity, flags, source);
        local data = AshOfPhoenix:GetPlayerData(player, true);
        data.NoTrigger = ivBag;
    end
    
    local data = AshOfPhoenix:GetPlayerData(player, false);
    if (data and data.Ashed and not Players.IsDead(player)) then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player);
        player:Kill();
        data.AshTime = 1;
    end
end
AshOfPhoenix:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, AshOfPhoenix.PostPlayerTakeDamage, EntityType.ENTITY_PLAYER, 32);

local function PostPlayerKill(mod, entity)
    local data = AshOfPhoenix:GetPlayerData(entity, false);
    if (data and data.Ashed) then
        local renderRNG = RNG();
        renderRNG:SetSeed(Random(), 0);
        for i = 1, 4 do
            local dust = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.DUST_CLOUD,0, entity.Position, Vector.FromAngle(renderRNG:RandomFloat() * 360) * renderRNG:RandomFloat() * 5, entity); 
            
            local e = dust:ToEffect(); 
            e.LifeSpan = math.floor(renderRNG:RandomFloat() * 10 + 20);
            e.Timeout = e.LifeSpan;
        end
    end
end
AshOfPhoenix:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostPlayerKill, EntityType.ENTITY_PLAYER);

function AshOfPhoenix:PostPlayerUpdate(player)
    local data = AshOfPhoenix:GetPlayerData(player, false);
    if (data and data.Ashed) then
        if (not Players.IsDead(player)) then
            data.NoTrigger = false;
        end
        player.Velocity = Vector.Zero;
        --player:SetColor(Color(0,0,0,0,0,0,0), 2, 0, false, true);
        player.ControlsCooldown = math.max(player.ControlsCooldown, 1);

        if (data.SetDamageCooldown) then
            data.SetDamageCooldown = false;
            player:ResetDamageCooldown();
            player:SetMinDamageCooldown(90);
        end

        local effects = player:GetEffects();
        -- -- If has shield 
        -- local shieldEffect = effects:GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS);
        -- if (shieldEffect) then
        --     local spr = data.ShieldSprite;
        --     data.AshTime = 60;

        --     if (shieldEffect.Cooldown > 90) then
        --         if (not spr:IsPlaying("WalkDown")) then
        --             spr:Play("WalkDown");
        --         end
        --     else
        --         if (not spr:IsPlaying("Blink")) then
        --             spr:Play("Blink");
        --         end
        --     end
        --     spr:Update();
        -- end
        local hasShield = effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS);
        if (hasShield) then
            effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, -1);
        end
        
        if (not Players.IsDead(player) and data.AshTime > 0) then
            data.AshTime = data.AshTime - 1;
            if (data.AshTime <= 0) then
                AshOfPhoenix:EndAsh(player)
                
                player:SetMinDamageCooldown(45);
                Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.FIRE_JET,0, player.Position, Vector.Zero, player);
                for i = 1, 4 do
                    local waveEnt = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.FIRE_WAVE,0, player.Position, Vector.Zero, player);  
                    local wave = waveEnt:ToEffect();
                    wave.Rotation = i * 90;
                end
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player);
            end 
        else
            AshOfPhoenix:EndAsh(player)
        end
    else
        local effects = player:GetEffects();
    end
end
AshOfPhoenix:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, AshOfPhoenix.PostPlayerUpdate);

-- function AshOfPhoenix:PostPlayerRender(player, offset)
--     local data = AshOfPhoenix:GetPlayerData(player, false);
--     if (data and data.Ashed and not Players.IsDead(player)) then
--         RenderPlayerAsh(player, offset);

        
--         -- If has shield 
--         local shieldEffect = player:GetEffects():GetCollectibleEffect(58);
--         if (shieldEffect) then
--             local spr = data.ShieldSprite;
--             if (spr) then
--                 local pos = Screen.GetEntityOffsetedRenderPosition(player, offset, Vector(0, 12));
                
--                 spr:Render(pos, Vector.Zero, Vector.Zero);
--             end
--         end
--     end
-- end
-- AshOfPhoenix:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, AshOfPhoenix.PostPlayerRender);

local function PrePickupCollision(mod, pickup, other, low)
    if (other.Type == EntityType.ENTITY_PLAYER) then
        local data = AshOfPhoenix:GetPlayerData(other, false);
        if (data and data.Ashed) then
            return true;
        end
    end
end
AshOfPhoenix:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PrePickupCollision);


local function PreRevive(mod, player)
    if (player:HasCollectible(AshOfPhoenix.Item)) then
        local data = AshOfPhoenix:GetPlayerData(player, false);
        if (not data or not data.Ashed and not data.NoTrigger) then
            
            ---@type ReviveCallback
            local function PostRevive(player, reviver)
                AshOfPhoenix:IntoAsh(player);

                -- Create Dusts.
                THI.SFXManager:Play(SoundEffect.SOUND_ISAACDIES);
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player);
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

            return {
                Name = "AshOfPhoenix",
                BeforeVanilla = true,
                ReviveFrame = 1,
                Callback = PostRevive
            };
        end
    end
end
AshOfPhoenix:AddPriorityCallback(CuerLib.Callbacks.CLC_PRE_REVIVE, -100, PreRevive)

local function PostRevive(mod, player, info)
    -- 以其他形式复活后清除状态。
    if (info.Name ~= "AshOfPhoenix") then
        AshOfPhoenix:EndAsh(player);
    end
end
AshOfPhoenix:AddCallback(CuerLib.Callbacks.CLC_POST_REVIVE, PostRevive)



return AshOfPhoenix;