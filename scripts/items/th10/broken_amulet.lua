local Screen = CuerLib.Screen;
local Detection = CuerLib.Detection;
local BrokenAmulet = ModItem("Broken Amulet", "BrokenAmulet");

function BrokenAmulet:GetTearData(tear, init)
    local data = tear:GetData();
    if (init) then
        if (not data._BROKEN_AMULET) then
            data._BROKEN_AMULET = {
                Devilhead = false,
                HaloSprite = nil,
                HaloDamage = 0,
                HaloScale = 0.5
            }
        end
    end
    return data._BROKEN_AMULET;
end

function BrokenAmulet:PostFireTear(tear)
    local player;
    local spawner = tear.SpawnerEntity;
    if (spawner) then
        player = spawner:ToPlayer();
    end

    if (player) then
        if (player:HasCollectible(BrokenAmulet.Item)) then
            local data = BrokenAmulet:GetTearData(tear, true);
            data.Devilhead = true;
            local spr = Sprite();
            spr:Load("gfx/unfortune_halo.anm2", true);
            spr:Play("Idle")
            local scale = math.min(1, math.max(0.5, 0.5 + player.Luck / -5 * 0.5));
            local damage = math.min(0.8, math.max(0.2, 0.2 + player.Luck / -5 * 0.6));
            data.HaloScale = scale;
            data.HaloDamage = player.Damage * damage;
            spr.Scale = Vector(tear.Scale * scale, tear.Scale * scale);
            data.HaloSprite = spr;
        end
    end
end
BrokenAmulet:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, BrokenAmulet.PostFireTear)

function BrokenAmulet:PostTearUpdate(tear)
    local data = BrokenAmulet:GetTearData(tear, false);
    if (data) then
        local scale = tear.Scale * data.HaloScale;
        if (data.HaloSprite) then
            data.HaloSprite:Update();
            data.HaloSprite.Scale = Vector(scale, scale);
        end

        
        if (data.Devilhead) then
            if (THI.Game:GetFrameCount() % 2 == 0) then
                
                local player;
                local spawner = tear.SpawnerEntity;
                if (spawner) then
                    player = spawner:ToPlayer();
                end
                local size = scale * 100;
                for i, ent in pairs(Isaac.GetRoomEntities()) do
                    if (Detection.IsValidEnemy(ent)) then
                        if (Detection.CheckCollisionInfo(tear.Position, size, Vector(1, 1), ent.Position, ent.Size, ent.SizeMulti)) then
                            ent:TakeDamage(data.HaloDamage, 0, EntityRef(player), 0);
                        end
                    end
                end
            end
        end
    end
end
BrokenAmulet:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, BrokenAmulet.PostTearUpdate)

function BrokenAmulet:PostTearRender(tear, offset)
    local data = BrokenAmulet:GetTearData(tear, false);
    if (data) then
        if (data.Devilhead) then
            local pos = Screen.GetEntityOffsetedRenderPosition(tear, offset);
            data.HaloSprite:Render(pos);
        end
    end
end
BrokenAmulet:AddCallback(ModCallbacks.MC_POST_TEAR_RENDER, BrokenAmulet.PostTearRender)


function BrokenAmulet:EvaluateCache(player, cache)
    if (cache == CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck - player:GetCollectibleNum(BrokenAmulet.Item) * 3;
    end
end
BrokenAmulet:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BrokenAmulet.EvaluateCache)

return BrokenAmulet;