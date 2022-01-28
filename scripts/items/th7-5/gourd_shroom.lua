local SaveAndLoad = CuerLib.SaveAndLoad;
local Explosion = CuerLib.Explosion;
local Stats = CuerLib.Stats;


local GourdShroom = ModItem("Gourd-Shroom", "GourdShroom")
function GourdShroom.GetDefaultPlayerData()
    return {
        Mode = -1,
    };
end

function GourdShroom.GetPlayerData(player, init)
    init = init or true;
    return GourdShroom:GetData(player, init, GourdShroom.GetDefaultPlayerData);
end


local function GetMinisaacsBack(player, count)
    count = count or 5;
    local c = count;
    for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.MINISAAC)) do
        if (ent.SpawnerEntity.InitSeed == player.InitSeed) then
            ent:Remove();
            c = c - 1;
            if (c <= 0) then
                return;
            end
        end
    end
end

local function SwitchMode(player, mode)
    local playerData = GourdShroom.GetPlayerData(player);
    playerData.Mode = mode;
    if (mode == 1) then
        GetMinisaacsBack(player);
    elseif (mode == 0) then
        for i = 1, 5 do 
            player:AddMinisaac(player.Position);
        end
    end
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player);
    player:AddCacheFlags(CacheFlag.CACHE_SIZE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE);
    player:EvaluateItems();
end

local function onPlayerEffect(mod, player)
    if (SaveAndLoad.GameStarted) then
        if (player:HasCollectible(GourdShroom.Item)) then
            local playerData = GourdShroom.GetPlayerData(player);
            if (playerData.Mode ~= 0 and playerData.Mode ~= 1) then
                SwitchMode(player, 1);
            end

            if (playerData.Mode == 1) then
                -- Crush rocks.
                local room = THI.Game:GetRoom();
                local centerPos = player.Position + player:GetMovementJoystick() * 12;
                for i=0, 3 do 
                    local angle = i * 90;
                    local pos = Vector.FromAngle(angle) * player.Size + centerPos;
                    local index = room:GetGridIndex(pos);
                    local gridEntity = room:GetGridEntity(index);
                    if (gridEntity) then
                        local solid = (gridEntity:ToRock() or gridEntity:ToPoop() or gridEntity:GetType() == GridEntityType.GRID_STATUE) and gridEntity.CollisionClass == GridCollisionClass.COLLISION_SOLID;
                        local tnt = gridEntity:ToTNT();
                        if (solid or tnt) then
                            room:DestroyGrid (index, false)
                            room:DamageGrid (index, 10000);
                            
                            Explosion.PushToBridge(player.Position, index);
                        end
                    end
                end
            end
        else
            
            local playerData = GourdShroom.GetPlayerData(player);
            if (playerData.Mode >= 0) then
                SwitchMode(player, -1);
            end
        end
    end
end
GourdShroom:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, onPlayerEffect);


local function onPlayerTakeDamage(mod, tookDamage, amount, source, flags, countdown)
    local player = tookDamage:ToPlayer();
    if (player:HasCollectible(GourdShroom.Item)) then
        local playerData = GourdShroom.GetPlayerData(player);
        
        if (playerData.Mode == 0) then
            SwitchMode(player, 1);
        else
            SwitchMode(player, 0);
        end
    end
end
GourdShroom:AddCustomCallback(CLCallbacks.CLC_POST_ENTITY_TAKE_DMG, onPlayerTakeDamage, EntityType.ENTITY_PLAYER);

local function onEvaluateCache(mod, player, flag)
    if (player:HasCollectible(GourdShroom.Item)) then
        local playerData = GourdShroom.GetPlayerData(player, false);
        if (playerData) then
            if (playerData.Mode == 0) then
                if (flag == CacheFlag.CACHE_SIZE) then
                    --player.Size = player.Size * 0.5;
                    player.SpriteScale = player.SpriteScale * 0.75;
                elseif (flag == CacheFlag.CACHE_FIREDELAY) then
                    Stats:AddTearsModifier(player, function(tears)
                        return tears * 1.5;
                    end)
                elseif (flag == CacheFlag.CACHE_SPEED) then
                    player.MoveSpeed = player.MoveSpeed + 0.5;
                end
            else
                if (flag == CacheFlag.CACHE_SIZE) then
                    player.SpriteScale = player.SpriteScale * 1.5;
                elseif (flag == CacheFlag.CACHE_DAMAGE) then
                    --player.Damage = player.Damage * 1.35;
                    Stats:MultiplyDamage(player, 1.35);
                elseif (flag == CacheFlag.CACHE_RANGE) then
                    player.TearHeight = player.TearHeight - 5;
                    player.TearRange = player.TearRange + 150;
                end
            end
        end
    end
end

GourdShroom:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onEvaluateCache);

return GourdShroom;