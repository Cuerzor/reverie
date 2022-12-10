local Players = CuerLib.Players;

local JarOfFireflies = ModItem("Jar of Fireflies", "JarOfFireflies");

local OnfireFly = {
    Type = Isaac.GetEntityTypeByName("Onfire Fly"),
    Variant = Isaac.GetEntityVariantByName("Onfire Fly")
}


local function SpawnFly(player, position)
    position = position or player.Position;
    local fly = Isaac.Spawn(OnfireFly.Type, OnfireFly.Variant, 0, position, Vector.Zero, player);
    fly:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM);
    fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
    fly.CollisionDamage = player.Damage;
    return fly;
end

function JarOfFireflies:PostChangeJar(player, item, diff)
    THI:EvaluateCurses();
end
JarOfFireflies:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_CHANGE_COLLECTIBLES, JarOfFireflies.PostChangeJar, JarOfFireflies.Item);

function JarOfFireflies:EvaluateCurse(curses)
    for i, player in Players.PlayerPairs(true, true) do
        local effects = player:GetEffects();
        if (player:HasCollectible(JarOfFireflies.Item)) then
            return curses & ~LevelCurse.CURSE_OF_DARKNESS;    
        end
    end
end
JarOfFireflies:AddCustomCallback(CuerLib.CLCallbacks.CLC_EVALUATE_CURSE, JarOfFireflies.EvaluateCurse, 0, -100);

function JarOfFireflies:onUseJar(item,rng,player,flags,slot,data)	
    for i = 1, 8 do
        SpawnFly(player);
    end
    return {ShowAnim = true}
end
JarOfFireflies:AddCallback(ModCallbacks.MC_USE_ITEM, JarOfFireflies.onUseJar, JarOfFireflies.Item);

local function Explode(firefly)
    THI.Game:BombExplosionEffects (firefly.Position, 20, TearFlags.TEAR_NORMAL, Color.Default, firefly, 1, true, false, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR)
end

function JarOfFireflies:onFireflyUpdate(firefly)
    if (firefly.Variant == OnfireFly.Variant) then
        if (firefly.Target) then
            local targetPos = firefly.Target.Position + firefly.Target.Velocity;
            local dir = (targetPos - firefly.Position):Normalized();
            local length = firefly.Position:Distance(targetPos);
            local speed = math.min(1,length / 50);
            firefly.Velocity = firefly.Velocity + dir * speed;
        end
    end
end
JarOfFireflies:AddCallback(ModCallbacks.MC_NPC_UPDATE, JarOfFireflies.onFireflyUpdate, OnfireFly.Type);

function JarOfFireflies:postFireflyCollision(firefly, collider, low)
    if (firefly.Variant == OnfireFly.Variant) then
        local canExplode = false;
        if (firefly:HasEntityFlags(EntityFlag.FLAG_CHARM)) then
            if (collider:ToNPC() and not collider:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                canExplode = true;
            end
        else
            if (collider:ToPlayer()) then
                canExplode = true;
            end
        end
        if (canExplode) then
            firefly:Kill();
        end
    end
end
JarOfFireflies:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_COLLISION, CallbackPriority.LATE, JarOfFireflies.postFireflyCollision, OnfireFly.Type);

function JarOfFireflies:onFireflyKill(firefly)
    if (firefly.Variant == OnfireFly.Variant) then
        Explode(firefly);
    end
end
JarOfFireflies:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, JarOfFireflies.onFireflyKill, OnfireFly.Type);

function JarOfFireflies:onFamiliarKilled(familiar)
    if (familiar.Variant == FamiliarVariant.WISP and familiar.SubType == JarOfFireflies.Item) then
        
        SpawnFly(familiar:ToFamiliar().Player, familiar.Position);
    end
end
JarOfFireflies:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, JarOfFireflies.onFamiliarKilled, EntityType.ENTITY_FAMILIAR);

return JarOfFireflies;