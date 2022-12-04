local Detection = CuerLib.Detection;
local PlagueLord = ModItem("Plague Lord", "PLAGUE_LORD");

PlagueLord.HasItemPlayer = nil;
do
    local function PostUpdate(mod)
        PlagueLord.HasItemPlayer = nil;
        for p, player in Detection.PlayerPairs() do
            if (player:HasCollectible(PlagueLord.Item)) then
                PlagueLord.HasItemPlayer = player;
                break;
            end
        end
    end
    PlagueLord:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);

    local function PostPlayerEffect(mod, player)
        if (player:HasCollectible(PlagueLord.Item)) then
            if (player:IsFrame(7, 0)) then
                for _, ent in pairs(Isaac.GetRoomEntities()) do
                    if (ent:IsVulnerableEnemy() and ent:IsActiveEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                        local time = 30;
                        if (ent:IsBoss()) then
                            time = 150
                        end
                        local distance = ent.Position:Distance(player.Position);
                        if (distance < 100) then
                            ent:AddPoison(EntityRef(player), time, 1)
                        end
                    end
                end
            end
        end
    end
    PlagueLord:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect);

    
    local function PostEntityKill(mod, entity)
        if (PlagueLord.HasItemPlayer and entity:HasEntityFlags(EntityFlag.FLAG_POISON) and entity:IsEnemy()) then
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, entity.Position, Vector.Zero, PlagueLord.HasItemPlayer) : ToEffect();
            effect.Timeout = 300;
            effect.LifeSpan = 300;
        end
    end
    PlagueLord:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostEntityKill);
end
return PlagueLord;