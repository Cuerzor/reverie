local Inputs = CuerLib.Inputs;
local Detection = CuerLib.Detection;
local EntityExists = Detection.EntityExists;
local CompareEntity = Detection.CompareEntity;
local Umbrella = ModEntity("Scaring Umbrella", "SCARING_UMBRELLA");

local fearInterval = 300;
local maxScareTime = 900;
function Umbrella.GetUmbrellaData(umbrella, init)
    return Umbrella:GetData(umbrella, init, function() return {
        Fired = false,
        ScareTime = maxScareTime,
        ChangeCollectible = false,
        CollectibleChangeTime = 0,
        ChangedCollectible = nil,
        LaughTime = 0
    } end);
end

function Umbrella:PostUmbrellaUpdate(umbrella)
    local player = umbrella.Player;

    -- Block Tears.
    

    if (player) then
        local umbrellaData = Umbrella.GetUmbrellaData(umbrella, true)

        
        -- Sprite.
        local spr = umbrella:GetSprite();
        local moveDir = player:GetMovementDirection ( )
        local anim = "Idle";
        local posOffset = Vector(-9 * player.SpriteScale.X, 1);
        if (moveDir == Direction.NO_DIRECTION) then
            if (umbrellaData.ChangeCollectible or EntityExists(umbrellaData.ChangedCollectible)) then
                anim = "Tricking";
            else
                anim = "Idle";
            end
        elseif (moveDir == Direction.DOWN) then
            anim = "WalkDown";
        elseif (moveDir == Direction.LEFT) then
            anim = "WalkLeft";
            posOffset = Vector(8 * player.SpriteScale.X, 1);
        elseif (moveDir == Direction.UP) then
            anim = "WalkUp";
            posOffset = Vector(9 * player.SpriteScale.X, 1);
        elseif (moveDir == Direction.RIGHT) then
            anim = "WalkRight";
            posOffset = Vector(-8 * player.SpriteScale.X, 1);
        end
        if (spr:GetAnimation() ~= "Laugh") then
            spr:Play(anim);
        end
        -- Movement.
        local targetPos = player.Position + posOffset;
        umbrella.SpriteScale = player.SpriteScale;
        umbrella.PositionOffset = Vector(0, -10 * player.SpriteScale.Y) + player.PositionOffset + player:GetFlyingOffset();

        umbrella.DepthOffset = 5;
        umbrella.Velocity = (targetPos - umbrella.Position) / 2 + player.Velocity;

        -- Block Projectiles
        for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
            if (ent.Position:Distance(player.Position) <= 25 * umbrella.SpriteScale.X) then
                local proj = ent:ToProjectile();
                if (proj) then
                    local height = -proj.Height;
                    local nextHeight = height - proj.FallingSpeed;
                    if (nextHeight <= umbrella.SpriteScale.Y * 50 and height > 35) then
                        proj:Die();
                    end
                end
            end
        end

        -- Drop Rains.
        if (Inputs.GetRawShootingVector(player):Length() > 0.1 and player:IsExtraAnimationFinished()) then
            umbrellaData.Fired = true;
        end
        
        if (Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex)) then
            umbrellaData.Fired = false;
        end
        local game = THI.Game;
        local room = game:GetRoom();
        if (umbrellaData.Fired) then
            if (game:GetFrameCount() % 2 == 0) then
                local pos = room:GetRandomPosition(0);
                local nearEnemies = Isaac.FindInRadius(pos, 80, EntityPartition.ENEMY);
                if (#nearEnemies > 0) then
                    pos = nearEnemies[1].Position;
                end
                local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, pos, Vector.Zero, player):ToTear();
                
                local TearEffects = THI.Shared.TearEffects;
                TearEffects:SetTearRain(tear, true);

                tear.Height = -400;
                tear.FallingAcceleration = 5;
            end
        end

        -- Fear Enemies.
        if (umbrella.FrameCount % fearInterval == fearInterval - 1) then
            local nearEnemies = Isaac.FindInRadius(player.Position, 160, EntityPartition.ENEMY);
            for _, ent in pairs(nearEnemies) do
                if (Detection.IsValidEnemy(ent)) then
                    ent:AddFear(EntityRef(player), 120);
                end
            end
        end

        -- Scare Player.
        if (room:GetAliveEnemiesCount() > 0 or not room:IsClear()) then
            umbrellaData.ScareTime = maxScareTime;
        else
            -- Change Collectible to Missing No.
            if (room:GetFrameCount() == 1) then
                if (Random() % 100 < 20) then
                    local collectibles = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE);
                    for i, ent in pairs(collectibles) do
                        if (ent.SubType > 0) then
                            umbrellaData.ChangeCollectible = true;
                            break;
                        end
                    end
                end
            end

            if (umbrellaData.ChangeCollectible) then
                local collectibles = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE);
                for _, ent in pairs(collectibles) do
                    if ((player.Position + player.Velocity * 3):Distance(ent.Position) < 40) then
                        local sprite = ent:GetSprite();
                        sprite:ReplaceSpritesheet(1, "gfx/items/collectibles/collectibles_258_missingno.png");
                        sprite:LoadGraphics();
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, nil);
                        umbrellaData.ChangeCollectible = false;
                        umbrellaData.CollectibleChangeTime = 0;
                        umbrellaData.ChangedCollectible = ent:ToPickup();
                    end
                end
                umbrellaData.ScareTime = maxScareTime;
            end

            local changedPickup = umbrellaData.ChangedCollectible;
            if (changedPickup) then
                umbrellaData.CollectibleChangeTime = (umbrellaData.CollectibleChangeTime or 0) + 1;
                if (not changedPickup:Exists() or changedPickup.SubType <= 0) then
                    umbrellaData.CollectibleChangeTime = 0;
                    umbrellaData.ChangedCollectible = nil;
                    umbrellaData.LaughTime = 60;
                elseif (umbrellaData.CollectibleChangeTime >= 30) then
                    local pickup = changedPickup;
                    local sprite = pickup:GetSprite();
                    local config = Isaac.GetItemConfig();
                    local col = config:GetCollectible(pickup.SubType);
                    sprite:ReplaceSpritesheet(1, col.GfxFileName);
                    sprite:LoadGraphics();
                    pickup:AppearFast();
                    umbrellaData.CollectibleChangeTime = 0;
                    umbrellaData.ChangedCollectible = nil;
                    umbrellaData.LaughTime = 60;
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil);
                end
            end

            -- Scare Player.
            umbrellaData.ScareTime = (umbrellaData.ScareTime or 0) - 1;
            if (umbrellaData.ScareTime <= 0) then
                umbrellaData.ScareTime = maxScareTime;
                local scare = Random() % 4;

                if (not player:IsExtraAnimationFinished()) then
                    if (scare == 1) then
                        scare = 0;
                    elseif (scare == 3) then
                        scare = 2;
                    end
                end

                if (scare == 0) then
                    game:ShowHallucination (30, room:GetBackdropType());
                    umbrellaData.LaughTime = 60;
                elseif (scare == 1) then
                    player:BloodExplode();
                    THI.SFXManager:Play(SoundEffect.SOUND_ISAAC_HURT_GRUNT);
                    THI.SFXManager:Play(SoundEffect.SOUND_ISAACDIES);
                    player:PlayExtraAnimation("Death");
                    umbrellaData.LaughTime = 60;
                elseif (scare == 2) then
                    for i = 0, room:GetGridSize(), 2 do
                        local pos = room:GetGridPosition(i);
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, pos, Vector.Zero, player);
                    end
                    umbrellaData.LaughTime = 20;
                elseif (scare == 3) then
                    local hud = game:GetHUD();
                    local config = Isaac.GetItemConfig();
                    THI.SFXManager:Play(SoundEffect.SOUND_POWERUP1);
                    hud:ShowItemText (player, config:GetCollectible(CollectibleType.COLLECTIBLE_TMTRAINER));
                    player:AnimateCollectible(CollectibleType.COLLECTIBLE_TMTRAINER);
                    umbrellaData.LaughTime = 45;
                end
            end

            
        end
        -- Laugh.
        if (umbrellaData.LaughTime > 0) then
            umbrellaData.LaughTime = umbrellaData.LaughTime - 1;
            if (umbrellaData.LaughTime <= 0) then
                THI.SFXManager:Play(THI.Sounds.SOUND_FAULT);
                spr:Play("Laugh");
            end
        end

        if (spr:IsFinished("Laugh")) then
            spr:Play("Idle");
        end
    end
end
Umbrella:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Umbrella.PostUmbrellaUpdate, Umbrella.Variant);


function Umbrella:PostNewRoom()
    local game = THI.Game;
    for _, ent in pairs(Isaac.FindByType(Umbrella.Type, Umbrella.Variant)) do
        local data = Umbrella.GetUmbrellaData(ent, true);
        data.Fired = false;
        data.ChangeCollectible = false;
    end
end
Umbrella:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Umbrella.PostNewRoom);


function Umbrella:PreProjectileCollision(proj, other, low)
    if (other.Type == EntityType.ENTITY_PLAYER) then
        local player = other:ToPlayer();
        for _, ent in pairs(Isaac.FindByType(Umbrella.Type, Umbrella.Variant)) do
            if (CompareEntity(ent:ToFamiliar().Player, player)) then
                if (-(proj.Height - proj.FallingSpeed) > 35) then
                    proj:Die();
                    return true;
                end
            end
        end
    end
end
Umbrella:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, Umbrella.PreProjectileCollision);

return Umbrella;