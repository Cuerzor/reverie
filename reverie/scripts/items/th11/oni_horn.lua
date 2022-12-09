local Detection = CuerLib.Detection;
local Stats = CuerLib.Stats;
local Horn = ModItem("Oni Horn", "ONI_HORN");

local function GetPlayerTempData(player, create)
    local function getter()
        return {
            DamagedCounter = 0,
        }
    end
    return Horn:GetData(player, create, getter);
end

function Horn:GetDamagedCount(player)
    local data = GetPlayerTempData(player, false);
    return (data and data.DamagedCounter) or 0;
end


function Horn:SetDamagedCount(player, value)
    local data = GetPlayerTempData(player, true);
    data.DamagedCounter = value;
end
function Horn:ClearDamagedCount(player)
    local data = GetPlayerTempData(player, false);
    if (data) then
        data.DamagedCounter = 0;
    end
end

local function EvaluateCache(mod, player, flag)
    if (player:HasCollectible(Horn.Item) and flag == CacheFlag.CACHE_DAMAGE) then
        Stats:AddDamageUp(player, player:GetCollectibleNum(Horn.Item) * 1);
    end
end
Horn:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache);

local function PostPlayerTakeDamage(mod, tookDamage, amount, flags, source, countdown)
    local player = tookDamage:ToPlayer();
    if (player and player:HasCollectible(Horn.Item) and source.Type ~= EntityType.ENTITY_SLOT) then
        local damagedCount = Horn:GetDamagedCount(player);
        local game = Game();
        if (damagedCount == 0) then
            local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, player.Position, Vector.Zero, player):ToEffect();
            wave:SetRadii(40,40);
            wave.Parent = player;
            wave.Timeout = 1;
            game:MakeShockwave(player.Position, 0.035, 0.01, 5);
        elseif (damagedCount == 1) then
            local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, player.Position, Vector.Zero, player):ToEffect();
            wave:SetRadii(40,120);
            wave.Parent = player;
            wave.Timeout = 10;
            game:MakeShockwave(player.Position, 0.05, 0.02, 10);
            game:BombExplosionEffects (player.Position, 100, TearFlags.TEAR_NORMAL, Color.Default, player, 1, true, false, DamageFlag.DAMAGE_EXPLOSION );
        elseif (damagedCount == 2) then
            local room = game:GetRoom();
            local width = room:GetGridWidth();
            local height = room:GetGridHeight();
            for x = 1, width - 1 do
                for y = 1, height - 1 do
                    local index = x + y * width;
                    local pos = room:GetGridPosition(index);
                    if (room:IsPositionInRoom (pos, 0)) then
                        local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE_RANDOM, 0, pos, Vector.Zero, player):ToEffect();
                        wave:SetRadii(10,10);
                        wave.Parent = player;
                        wave.Timeout = 2;
                    end
                end
            end
            room:MamaMegaExplosion (player.Position);
        end
        Horn:SetDamagedCount(player, (damagedCount + 1) % 3);
    end
end
Horn:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_ENTITY_TAKE_DMG, PostPlayerTakeDamage, EntityType.ENTITY_PLAYER)

local function PostNewRoom()
    for p, player in Detection.PlayerPairs(true, true) do
        Horn:ClearDamagedCount(player)
    end
end
Horn:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom);
return Horn;