local Math = CuerLib.Math;
local Lib = CuerLib;

local Explosion = {};
Explosion.ExplosionParams = {};

local expMetadata = {
    __call = function()
        local new = {
            Flags = DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR, 
            Damage = 100, 
            PlayerDamage = 2, 
            Scale = 1, 
            Sound = SoundEffect.SOUND_BOSS1_EXPLOSIONS, 
            Spawner = nil
        }
        setmetatable(new, ExplosionParams);
        return new;
    end
}

setmetatable(Explosion.ExplosionParams, expMetadata);

function Explosion.PushToBridge(center, gridIndex)
    local room = THI.Game:GetRoom();
    local pos = center;
    local index = gridIndex;

    -- Make Bridge.
    local gridEntity = room:GetGridEntity(index);
    if (gridEntity and (gridEntity:ToRock() or gridEntity:ToPoop())) then
        local width = room:GetGridWidth();
        local size = room:GetGridSize();
        local gridPos = gridEntity.Position;

        local angle = (gridPos - center):GetAngleDegrees();
        local direction = Math.GetDirectionByAngle(angle);

        local pit;
        if (direction == Direction.RIGHT) then
            if (index % width ~= 0) then
                local right = room:GetGridEntity(index + 1);
                if (right and right:ToPit()) then
                    pit = right;
                end
            end
        elseif (direction == Direction.DOWN) then
            local downIndex = index + width;
            if (downIndex >= 0 and downIndex <= size) then
                local down = room:GetGridEntity(downIndex);
                if (down and down:ToPit()) then
                    pit = down;
                end
            end
        elseif (direction == Direction.LEFT) then
            if ((index - 1) % 15 ~= 0) then
                local left = room:GetGridEntity(index - 1);
                if (left and left:ToPit()) then
                    pit = left;
                end
            end
        elseif (direction == Direction.UP) then
            local upIndex = index - width;
            if (upIndex >= 0 and upIndex <= size) then
                local up = room:GetGridEntity(upIndex);
                if (up and up:ToPit()) then
                    pit = up;
                end
            end
        end
        room:TryMakeBridge (pit, gridEntity)
    end
end

function Explosion.CustomExplode(position, params)
    -- Params.
    local flags = params.Flags;
    local damage = params.Damage;
    local playerDamage = params.PlayerDamage;
    local scale = params.Scale;
    local sound = params.Sound;
    local spawner = params.Spawner;
    local player = THI.Game:GetPlayer(0);
    local volume = math.min(1, 1 - math.max(0, position:Distance(player.Position)/1000));
    local room = THI.Game:GetRoom();
    local roomWidth = room:GetGridWidth();
    local roomHeight = room:GetGridHeight();
    local radius = 100 * scale;


    -- Destroy rocks.
    local centerIndex = room:GetGridIndex (position);
    local centerX = centerIndex % roomWidth;
    local centerY = math.floor(centerIndex / roomWidth);
    local gridRadius = math.ceil(radius / 40);
    for x = -gridRadius, gridRadius do 
        for y = -gridRadius, gridRadius do
            local indexX = centerX + x;
            local indexY = centerY + y;
            if (indexX >= 0 and indexX < roomWidth and indexY >= 0 and indexY < roomHeight) then
                local index = indexY * roomWidth + indexX;
                local range = room:GetGridPosition(index):Distance(position);
                if (range <= radius) then
                    room:DestroyGrid(index, false);
        
                    Explosion.PushToBridge(position, index);
                end
            end
        end
    end


    -- Create Effect.
    local exp = Isaac.Spawn(1000, 1, 0, position, Vector(0, 0), familiar):ToEffect();
    exp.Scale = scale;
    exp.SpriteScale = Vector(scale, scale);

    -- Play Sound.
    local sfx = THI.SFXManager;
    --sfx:Stop(SoundEffect.SOUND_BOSS1_EXPLOSIONS);
    --sfx:Play(sound, volume);

    -- Deal Damage.
    for _, ent in pairs(Isaac.GetRoomEntities()) do 
        if (position:Distance(ent.Position) - ent.Size < radius) then
            local dmg = damage;
            if (ent.Type == EntityType.ENTITY_PLAYER) then
                dmg = playerDamage;
            end
            if (dmg > 0) then
                ent:TakeDamage(dmg, flags, EntityRef(spawner), 0);
            end
        end
    end
end

return Explosion;