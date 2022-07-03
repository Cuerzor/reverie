local Synergies = CuerLib.Synergies;
local Tears = CuerLib.Tears;
local Detection = CuerLib.Detection;
local Stats = CuerLib.Stats;
local Ear = ModItem("Mountain Ear", "MOUNTAIN_EAR");
Ear.EchoVariant = Isaac.GetEntityVariantByName("Echo Tear");
Ear.EchoBloodVariant = Isaac.GetEntityVariantByName("Echo Blood Tear");

Ear.DecayTime = 300;
Ear.DecayInterval = 7;
local HitColor = Color(1,1,1,1,0,0.5,0.5);
local function GetTearData(tear, create)
    local function getter()
        return {
            OutOfSpawner = false
        }
    end
    return Ear:GetData(tear, create, getter);
end

local function GetPlayerData(player, init)
    local function getter()
        return {
            DamageUp = 0,
            DamageDecay = 0
        }
    end
    return Ear:GetData(player, init, getter);
end

Tears:RegisterModTearFlag("ReverieEcho");
local EchoTearFlag = Tears.TearFlags.ReverieEcho;

function Ear.TearHasEcho(tear)
    local flags = Tears.GetModTearFlags(tear, false)
    if (flags) then
        return flags:Has(EchoTearFlag);
    end
    -- local data = GetTearData(tear, false);
    -- if (data) then
    --     return data.Echo;
    -- end
    return false;
end

function Ear.SetTearEcho(tear, value)
    -- local data = GetTearData(tear, true);
    -- data.Echo = value;
    local flags = Tears.GetModTearFlags(tear, true)
    return flags:Add(EchoTearFlag);
end

function Ear.IsTearEcho(tear)
    return tear.Variant == Ear.EchoVariant or tear.Variant == Ear.EchoBloodVariant;
end

function Ear.AddEchoDamage(player, damage, decayTime)
    local data = GetPlayerData(player, true);
    data.DamageUp = (data.DamageUp or 0) + damage;
    data.DamageDecay = (data.DamageDecay or 0) + damage / decayTime * Ear.DecayInterval;
end

do 
    local function PostFireTear(mod, tear)
        local player = nil;
        if (tear.SpawnerEntity) then
            player = tear.SpawnerEntity:ToPlayer();
        end
        if (player) then
            if (player:HasCollectible(Ear.Item)) then
                local rng = player:GetCollectibleRNG(Ear.Item);
                local luck = player.Luck;
                
                local range = 1 / math.max(1, 9 - luck);
                if (rng:RandomInt(100) < range * 100) then
                    if (not Ear.TearHasEcho(tear)) then
                        Ear.SetTearEcho(tear, true);
                        tear:AddTearFlags(TearFlags.TEAR_BOUNCE);
                    end
                    
                    if (not Ear.IsTearEcho(tear)) then
                                
                        local variant = Ear.EchoVariant;
                        if (Tears:IsTearVariantBlood(tear.Variant)) then
                            variant = Ear.EchoBloodVariant;
                        end
                        if (Tears:CanOverrideVariant(variant, tear.Variant)) then
                            tear:ChangeVariant(variant);
                            tear.Scale = tear.Scale + 0.5;
                        end
                    end
                end
            end
        end
    end
    Ear:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, PostFireTear);
    
    local function PostPlayerEffect(mod, player)
        if (player:IsFrame(Ear.DecayInterval, 0)) then
            local data = GetPlayerData(player, false);
            if (data)then
                data.DamageUp = data.DamageUp or 0;
                data.DamageDecay = data.DamageDecay or 0;
                if (data.DamageUp > 0) then
                    data.DamageUp = data.DamageUp - data.DamageDecay;
                    if (data.DamageUp <= 0) then
                        data.DamageUp = 0;
                        data.DamageDecay = 0;
                    end
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
                    player:EvaluateItems();
                end
            end
        end
    end
    Ear:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect);

    local function EvaluateCache(mod, player, flag)
        if (flag == CacheFlag.CACHE_DAMAGE) then
            local data = GetPlayerData(player, false);
            if (data and data.DamageUp > 0) then
                Stats:AddDamageUp(player, data.DamageUp);
            end
        end
    end
    Ear:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache);

    local function PostTearUpdate(mod, tear)
        if (Ear.TearHasEcho(tear)) then
            tear.FallingSpeed = 0;
            if (tear.FrameCount > 150) then
                tear:Die();
            end
            local tearData = GetTearData(tear, true);
            if (tearData.OutOfSpawner) then
                if (tear:IsFrame(2, 0) and not tear:IsDead()) then
                    for p, player in Detection.PlayerPairs() do
                        if (tear.Position:Distance(player.Position) <= player.Size + tear.Size) then
                            tear:Die();
                            player:SetColor(HitColor, 20, 1, true, false);
                            Ear.AddEchoDamage(player, math.min(1, tear.CollisionDamage), Ear.DecayTime);
                            break;
                        end
                    end
                end
            else
                local spawner = tear.SpawnerEntity;
                
                if (not spawner or tear.Position:Distance(spawner.Position) > spawner.Size + tear.Size) then
                    tearData.OutOfSpawner = true;
                end
            end
        end


        local isBlood = tear.Variant == Ear.EchoBloodVariant;
        if (tear.Variant == Ear.EchoVariant or isBlood) then
            local animPrefix = "RegularTear";
            if (isBlood) then
                animPrefix = "BloodTear";
            end
            local anim = animPrefix ..Tears.GetTearAnimationIndexByScale(tear.Scale);
            tear:GetSprite():Play(anim)
            tear.SpriteRotation = tear.Velocity:GetAngleDegrees();

            if (tear:IsDead()) then
                
                local variant = EffectVariant.TEAR_POOF_A;
                if (isBlood) then
                    variant = EffectVariant.BULLET_POOF;
                end
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, variant, 0, tear.Position, Vector.Zero, tear);
                poof.PositionOffset = tear.PositionOffset;
                poof.SpriteScale = Vector(tear.Scale, tear.Scale) * 0.8;
                poof:SetColor(tear:GetColor(), 0, 0);
                THI.SFXManager:Play(SoundEffect.SOUND_TEARIMPACTS);
            end 
        end
    end
    Ear:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, PostTearUpdate);

end

return Ear;