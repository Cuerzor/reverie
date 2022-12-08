local CompareEntity = CuerLib.Entities.CompareEntity;
local ViciousCurse = ModItem("Vicious Curse", "DamoclesCurse");

function ViciousCurse:PostGainCurse(player, item, count, touched)
    if (not touched) then
        if (not player:HasCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE, true)) then
            player:AddCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE);
        end
        local game = THI.Game;
        local Seija = THI.Players.Seija;
        if (Seija:WillPlayerBuff(player)) then
            THI.SFXManager:Play(SoundEffect.SOUND_HOLY);
            player:AddSoulHearts(2);
        else
            game:ShakeScreen(10);
            THI.SFXManager:Play(SoundEffect.SOUND_DEATH_BURST_LARGE);
            game:SpawnParticles (player.Position, EffectVariant.BLOOD_PARTICLE, 10, 5);
            player:TakeDamage(2 * count, DamageFlag.DAMAGE_INVINCIBLE, EntityRef(nil), 0);
        end
    end
end
ViciousCurse:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_GAIN_COLLECTIBLE, ViciousCurse.PostGainCurse, ViciousCurse.Item);

function ViciousCurse:PostPlayerEffect(player)
    local Seija = THI.Players.Seija;
    if (player:HasCollectible(ViciousCurse.Item)) then
        if (not Seija:WillPlayerBuff(player)) then
            for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.DAMOCLES)) do
                if (CompareEntity(ent:ToFamiliar().Player, player)) then
                    for i = 2, 2 do
                        ent:Update();
                    end
                end
            end
        end
    end
end
ViciousCurse:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, ViciousCurse.PostPlayerEffect);

local function PostFamiliarUpdate(mod, familiar)
    local player = familiar.Player;
    local Seija = THI.Players.Seija;
    if (player and player:HasCollectible(ViciousCurse.Item) and Seija:WillPlayerBuff(player)) then
        
        local spr = familiar:GetSprite();
        if (spr:GetAnimation() == "Fall" and spr:GetFrame() >= 14) then
            Game():ShakeScreen(10);
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player);
            poof:GetSprite():Load("gfx/293.000_UltraGreedCoins.anm2", true);
            poof:GetSprite():Play("CrumbleNoDebris");

            player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER);

            SFXManager():Play(SoundEffect.SOUND_GOLD_HEART);
            SFXManager():Play(SoundEffect.SOUND_ROCK_CRUMBLE);
            Game():SpawnParticles (player.Position, EffectVariant.ROCK_PARTICLE, 10, 5, Color(1,1,1,1,0.5,0.5,0.5));
            SFXManager():Play(SoundEffect.SOUND_SUPERHOLY);
            familiar:Remove();
            player:RemoveCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE)
        end
    end
end
ViciousCurse:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PostFamiliarUpdate, FamiliarVariant.DAMOCLES);


local function PreTakeDamage(mod, tookDamage, amount, flags, source, countdown)
    if (source.Type == EntityType.ENTITY_FAMILIAR and source.Variant == FamiliarVariant.DAMOCLES) then
        local player = tookDamage:ToPlayer();
        local Seija = THI.Players.Seija;
        if (player:HasCollectible(ViciousCurse.Item) and Seija:WillPlayerBuff(player)) then
            return false;
        end
    end
end
ViciousCurse:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_ENTITY_TAKE_DMG, PreTakeDamage, EntityType.ENTITY_PLAYER);

-- local function PostPlayerKill(mod, ent)
--     ent:ToPlayer():Revive();
-- end
-- ViciousCurse:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostPlayerKill, EntityType.ENTITY_PLAYER);

return ViciousCurse;