local Detection = CuerLib.Detection;
local Chopper = ModItem("Yamanba's Chopper", "YAMANBAS_CHOPPER");

Chopper.GfxFileName = Isaac.GetItemConfig():GetCollectible(Chopper.Item).GfxFileName;

do
    local function PostPickupUpdate(mod, pickup)
        if (pickup.FrameCount < 2 and pickup.SubType == Chopper.Item) then
            local spr = pickup:GetSprite();
            spr:ReplaceSpritesheet(1, Chopper.GfxFileName);
            spr:LoadGraphics();
        end
    end
    Chopper:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, PostPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE);

    local function PostPlayerTakeDamage(mod, tookDamage, amount, flags, source, countdown)
        local player = tookDamage:ToPlayer();
        if (player:HasCollectible(Chopper.Item)) then
            local chance = math.max(0.25, player.Luck / 4);
            local times = math.floor(chance);
            local extraChance = chance - times;
            local value = Random() % 100 / 100;
            if (value < extraChance) then
                times = times + 1;
            end
            for i=1, times do
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, player.Position,RandomVector(),player);
            end
        end
    end
    Chopper:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_ENTITY_TAKE_DMG, PostPlayerTakeDamage, EntityType.ENTITY_PLAYER);

    local function PostEntityKill(mod, entity)
        if (entity:IsActiveEnemy(true)) then
            for p, player in Detection.PlayerPairs() do
                if (player:HasCollectible(Chopper.Item)) then
                    local chance = math.min(0.2, 1 / math.max(5, 18 - player.Luck));
                    local value = Random() % 100 / 100;
                    if (value < chance) then
                        local playerType = player:GetPlayerType();
                        if (playerType == PlayerType.PLAYER_KEEPER or playerType == PlayerType.PLAYER_KEEPER_B) then
                            player:AddBlueFlies (1, player.Position, nil);
                        else
                            player:AddHearts(1);  
                        end
                        Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.HEART, 0, player.Position, Vector.Zero, player);
                        THI.SFXManager:Play(SoundEffect.SOUND_VAMP_GULP);
                    end
                end

            end
        end
    end
    Chopper:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostEntityKill);
end

return Chopper;