local Consts = CuerLib.Consts;
local Entities = CuerLib.Entities;
local Familiars = CuerLib.Familiars;
local Screen = CuerLib.Screen;
local Math = CuerLib.Math;
local Tears = CuerLib.Tears;
local PsycheEye = ModEntity("Psyche Eye Familiar", "PsycheEye");
local CompareEntity = Entities.CompareEntity;
local EntityExists = Entities.EntityExists;

PsycheEye.FriendlyLimit = 5;
PsycheEye.TearColor = Color(1, 0, 1, 1, 0, 0, 0);
PsycheEye.VesselVariant = Isaac.GetEntityVariantByName("Psyche Eye Vessel");
PsycheEye.MaxCharge = 75;
PsycheEye.WaveColor = Color(1,1,1,1,0,0,0);
PsycheEye.WaveColor:SetColorize(1,0,1,1);
-- PsycheEye.WaveRange = 60;

local function GetPlayerData(player, init)
    return PsycheEye:GetData(player, init, function() return {
        EyeCount = 0,
        ControlledCount = 0,
        WaveKills = 0,
    } end);
end

local function GetNPCData(npc, init)
    return PsycheEye:GetTempData(npc, init, function() return {
        WaveKillPlayer = nil,
        WaveKillTimeout = -1
    } end);
end

local function GetFamiliarTempData(familiar, init)
    return PsycheEye:GetTempData(familiar, init, function() 
        
        local chargeBar = Sprite();
        chargeBar:Load("gfx/chargebar.anm2", true)
        chargeBar:Play("Charging");
        return {
            Index = 0,
            VesselLeft = nil,
            VesselRight = nil,
            MindBlastCharge = 0,
            -- MindBlastCooldown = 0,
            MindControlCharge = 0,
            ChargeBarSprite = chargeBar;
        } 
    end);
end


function PsycheEye:GetVesselPosition(familiar, player, right)
    local player2Fam = familiar.Position - player.Position;
    local angle = -90;
    if (right) then
        angle = 90;
    end
    local offset = player2Fam:Rotated(angle):Normalized() * 8;
    return (familiar.Position + familiar.Velocity + player.Velocity + player.Position) / 2 + offset;
end

PsycheEye.GetPlayerData = GetPlayerData;
PsycheEye.GetFamiliarTempData = GetFamiliarTempData;

-- Mind Control Tear.
Tears:RegisterModTearFlag("Mind Control");
function PsycheEye:AddMindControlTear(tear)
    local flags = Tears:GetModTearFlags(tear, true);
    flags:Add(Tears.TearFlags["Mind Control"]);
end

function PsycheEye:IsMindControlTear(tear)
    local flags = Tears:GetModTearFlags(tear, false);
    return flags and flags:Has(Tears.TearFlags["Mind Control"]);
end

function PsycheEye:IsOverLimit()
    local friendlyCount = 0;
    local eyeCount = #Isaac.FindByType(PsycheEye.Type, PsycheEye.Variant);
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if (ent:IsActiveEnemy() and ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            friendlyCount = friendlyCount + 1;
            if (friendlyCount >= PsycheEye.FriendlyLimit * eyeCount) then
                return true;
            end
        end
    end
    return false;
end
function PsycheEye:UpdateEyeState(familiar)
    if (PsycheEye:IsOverLimit()) then
        familiar.State = 1;
    else
        familiar.State = 0;
    end
end

function PsycheEye:CanControl(entity)
    if (entity and entity:Exists() and entity:IsActiveEnemy() and entity:CanShutDoors()and not entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then 
        local EntityTags = THI.Shared.EntityTags;
        local isFly = EntityTags:EntityFits(entity, "ConvertToBlueFlies");
        local isSpider = EntityTags:EntityFits(entity, "ConvertToBlueSpiders");

        return true;
    end
    return false;
end


function PsycheEye:ControlEntity(target, source)
    if (target:IsBoss() or target.Type == EntityType.ENTITY_THE_HAUNT or target.Type == EntityType.ENTITY_EXORCIST) then
        target:AddCharmed( EntityRef(source), 150);
    else
        local EntityTags = THI.Shared.EntityTags;
        local isFly = EntityTags:EntityFits(target, "ConvertToBlueFlies");
        local isSpider = EntityTags:EntityFits(target, "ConvertToBlueSpiders");
        local player = source:ToPlayer();
        if (isFly) then
            target:Remove();
            if (player) then
                player:AddBlueFlies (1, target.Position, nil)
            else
                Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0, target.Position, Vector.Zero, source);
            end
        elseif (isSpider) then
            target:Remove();
            if (player) then
                player:AddBlueSpider(target.Position)
            else
                Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER, 0, target.Position, Vector.Zero, source);
            end
        else
            target:AddCharmed( EntityRef(source), -1);
            self:AddControlCount(source, 1);
        end

        THI.SFXManager:Play(THI.Sounds.SOUND_MIND_CONTROL);
    end
end

function PsycheEye:SpawnWave(pos, source, range)
    for i = 1, 3 do
        local wave = Isaac.Spawn(1000, 151, 10, pos, Vector.Zero, nil):ToEffect();
        wave:SetColor(PsycheEye.WaveColor, -1, 0)
        wave.SpriteScale = Vector.Zero;
        wave.CollisionDamage = 0;
        wave.State = 1;
        wave.Scale = 1; 
        wave.MaxRadius = range / 3;
        wave.MinRadius = 0;
        wave.TargetPosition = pos;
        wave.DepthOffset = 400;
        wave.LifeSpan = i * 10;
        wave.Timeout = wave.LifeSpan;
    end
end

function PsycheEye:SetControlCount(player, count)
    local data = GetPlayerData(player, true)
    data.ControlledCount = count;
    local p = player:ToPlayer();
    if (p) then
        p:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE)
        p:EvaluateItems();
    end
end
function PsycheEye:GetControlCount(player)
    local data = GetPlayerData(player, false)
    return (data and data.ControlledCount) or 0;
end
function PsycheEye:AddControlCount(player, count)
    self:SetControlCount(player, self:GetControlCount(player) + count)
end


function PsycheEye:SetWaveKills(player, count)
    local data = GetPlayerData(player, true)
    data.WaveKills = count;
    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE)
    player:EvaluateItems();
end
function PsycheEye:GetWaveKills(player)
    local data = GetPlayerData(player, false)
    return (data and data.WaveKills) or 0;
end
function PsycheEye:AddWaveKills(player, count)
    self:SetWaveKills(player, self:GetWaveKills(player) + count)
end
function PsycheEye:MarkWaveKill(npc, player)
    local npcData = GetNPCData(npc, true);
    npcData.WaveKillTimeout = 2;
    npcData.WaveKillPlayer = player;
end


function PsycheEye:SetWaveKillDecay(player, count)
    local data = GetPlayerData(player, true)
    data.WaveKillDecay = count;
end
function PsycheEye:GetWaveKillDecay(player)
    local data = GetPlayerData(player, false)
    return (data and data.WaveKillDecay) or 0;
end
function PsycheEye:AddWaveKillDecay(player, count)
    self:SetWaveKillDecay(player, self:GetWaveKillDecay(player) + count)
end

function PsycheEye.SpawnVessel(familiar, player, right)
    local pos = PsycheEye:GetVesselPosition(familiar, player, right);
    local vessel = Isaac.Spawn(EntityType.ENTITY_EFFECT, PsycheEye.VesselVariant, 0, pos, Vector.Zero, familiar);
    vessel.Parent = player;
    vessel.Child = familiar;
    vessel:GetSprite():Play("Vessel");
    if (not right) then
        vessel.FlipX = true;
    end
    vessel:AddEntityFlags(EntityFlag.FLAG_PERSISTENT);
    return vessel;
end

function PsycheEye:PostFamiliarUpdate(familiar)
    local player = familiar.Player;
    local data = GetFamiliarTempData(familiar, true);
    local dir = player:GetFireDirection();
    
    familiar.PositionOffset = Vector(0, -3);
    
    local headDirection = player:GetHeadDirection();
    local facingVector = Consts.DirectionVectors[headDirection];
    local controllerIndex = player.ControllerIndex;
    local holdingDrop = Input.IsActionPressed(ButtonAction.ACTION_DROP, controllerIndex);
    local shooting = player:GetShootingJoystick():Length() > 0.1 or player:AreOpposingShootDirectionsPressed ( );

    if (not holdingDrop or not shooting) then
        data.MindBlastCharge = 0;
    end
    -- if (data.MindBlastCooldown >= 0) then
    --     data.MindBlastCooldown = data.MindBlastCooldown - 1;
    -- end
    if (holdingDrop) then
        -- if (shooting and data.MindBlastCooldown < 0) then
        if (shooting) then
            data.MindBlastCharge = data.MindBlastCharge +1;
            if (data.MindBlastCharge == 15) then
                SFXManager():Play(THI.Sounds.SOUND_TOUHOU_CHARGE)
                local Wave = THI.Effects.SpellCardWave;
                local wave = Isaac.Spawn(Wave.Type, Wave.Variant, 0, familiar.Position, Vector.Zero, familiar);
                wave.Parent = familiar;
                wave:SetColor(Color(1,0,1,1,0,0,0),-1,0);
            end
            if (data.MindBlastCharge == 45) then
                SFXManager():Play(THI.Sounds.SOUND_TOUHOU_CHARGE_RELEASE)
                Game():ShakeScreen(30);
                for _, ent in ipairs(Isaac.GetRoomEntities()) do
                    if (not ent:IsDead() and ent:IsActiveEnemy() and ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and not ent:HasEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)) then
                        
                        PsycheEye:MarkWaveKill(ent, player);
                        ent:Kill();
                        ent:BloodExplode();
                        -- if (not ent:IsBoss()) then
                        --     PsycheEye:MarkFountain(ent);
                        -- end
                    else
                        local distance = ent.Position:Distance(familiar.Position);
                        if (ent.Type ~= EntityType.ENTITY_PLAYER and ent.Type ~= EntityType.ENTITY_LASER and ent.Type ~= EntityType.ENTITY_EFFECT and  distance <= 240) then
                            ent:AddVelocity((ent.Position - familiar.Position):Resized((240 - distance) / 240 * 50));
                        end

                        if (ent:IsActiveEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                            ent:AddConfusion(EntityRef(familiar), 90);
                        end
                    end
                end
                -- data.MindBlastCooldown = 90;

                local Wave = THI.Effects.SpellCardWave;
                for i = 1, 3 do
                
                    local wave = Isaac.Spawn(Wave.Type, Wave.Variant, Wave.SubTypes.BURST, familiar.Position, Vector.Zero, familiar);
                    wave:SetColor(Color(1,0,1,1,0,0,0),-1,0);
                    wave.SpriteScale = Vector(i, i);
                end
            end
        end
    end

    -- Update State.
    if (familiar:IsFrame(15, 0)) then
        PsycheEye:UpdateEyeState(familiar)
    end

    -- Charge.
    local barSpr = data.ChargeBarSprite;
    if (player:IsExtraAnimationFinished()) then
        
        if (not holdingDrop and shooting and familiar.State ~= 1) then
            if(data.MindControlCharge < PsycheEye.MaxCharge) then
                data.MindControlCharge = data.MindControlCharge + 1;
            end
            local charge = data.MindControlCharge;
            if(data.MindControlCharge < PsycheEye.MaxCharge) then
                barSpr:SetFrame("Charging", math.floor(charge / PsycheEye.MaxCharge * 100));
            else
                local anim = "Charged";
                if (not barSpr:IsFinished("StartCharged") and not barSpr:IsPlaying("Charged")) then
                    anim = "StartCharged"
                end
                
                barSpr:Play(anim);
            end
        else


            if (not holdingDrop) then
                
                if(data.MindControlCharge >= PsycheEye.MaxCharge) then
                    data.MindControlCharge = 0;

                    local range = player.TearRange / 4;
                    -- Spawn Wave.
                    PsycheEye:SpawnWave(familiar.Position, familiar, range);
                    SFXManager():Play(SoundEffect.SOUND_MAW_OF_VOID);
                    SFXManager():Play(THI.Sounds.SOUND_MIND_WAVE);
                    -- Game():ShakeScreen(10);

                    for _, ent in ipairs(Isaac.FindInRadius(familiar.Position, range, EntityPartition.ENEMY)) do
                        if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                            PsycheEye:ControlEntity(ent, player);
                        end
                    end

                    PsycheEye:UpdateEyeState(familiar);
                end
            end

            data.MindControlCharge = 0;
            barSpr:Play("Disappear");
        end
    end
    barSpr:Update();

    -- Animation.
    if (holdingDrop or shooting or familiar.State == 1) then 
        Familiars.PlayShootAnimation(familiar, headDirection);
    else
        
        Familiars.PlayNormalAnimation(familiar, headDirection);
    end

    -- Position Update.
    if (player) then
        local playerData = GetPlayerData(player, false);
        local angle = (data.Index - 1) * 15;
        if (playerData) then
            angle = angle - (playerData.EyeCount - 1) * 7.5;
        end
        local playerPos = player.Position;
        local offset = facingVector:Rotated(angle);
        local player2Familiar = familiar.Position - playerPos;
        local nextAngle = player2Familiar:GetAngleDegrees() + Math.GetIncludedAngle(player2Familiar, offset) / 2;

        local nextPos = playerPos + Vector.FromAngle(nextAngle) * 20;
        local targetVelocity = nextPos - familiar.Position;
        familiar.Velocity = familiar.Velocity + (targetVelocity - familiar.Velocity) / 2;

        
        -- Vessel
        if (not EntityExists(data.VesselLeft)) then
            data.VesselLeft = PsycheEye.SpawnVessel(familiar, player, false)
        end

        if (not EntityExists(data.VesselRight)) then
            data.VesselRight = PsycheEye.SpawnVessel(familiar, player, true)
        end
    end

end
PsycheEye:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PsycheEye.PostFamiliarUpdate, PsycheEye.Variant)


local function PostPlayerUpdate(mod, player)
    if (player:IsFrame(14, 0)) then
        
        local decay = PsycheEye:GetWaveKillDecay(player);
        if (decay > 0) then
            local kills = PsycheEye:GetWaveKills(player);
            if (kills > 0) then
                PsycheEye:SetWaveKills(player, math.max(0, kills - decay));
            else
                PsycheEye:SetWaveKillDecay(player, 0);
            end
        end
    end
end
PsycheEye:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate)

local function PostFamiliarRender(mod, familiar, offset)
    if (Game():GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT) then
        local data = GetFamiliarTempData(familiar, false);
        if (data) then
            local barSpr = data.ChargeBarSprite;
            local charge = (data and data.MindControlCharge) or 0;
            local xOffset = 24;
            if (familiar.Position.X < familiar.Player.Position.X and math.abs(familiar.Position.Y- familiar.Player.Position.Y) < 16) then
                xOffset = - xOffset;
            end
            local pos = Screen.GetEntityOffsetedRenderPosition(familiar, offset, familiar.PositionOffset + Vector(xOffset * familiar.SpriteScale.X, -24 * familiar.SpriteScale.Y));
            barSpr:Render(pos, Vector.Zero, Vector.Zero);
        end
    end
end
PsycheEye:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, PostFamiliarRender, PsycheEye.Variant)


local function PostVesselUpdate(mod, effect)
    local parent = effect.Parent;
    local child = effect.Child;
    if (parent and child) then
        local pos = PsycheEye:GetVesselPosition(child, parent, not effect.FlipX);
        effect.PositionOffset = Vector(0, -15);
        effect.DepthOffset = -3;
        effect.Friction = 1;
        effect.Position = pos;
        effect.Velocity = parent.Velocity;
        effect.SpriteRotation = (parent.Position - child.Position):GetAngleDegrees() + 90;
        if (effect.FlipX) then
            effect.SpriteRotation = - effect.SpriteRotation;
        end
    else
        effect:Remove();
    end
end
PsycheEye:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostVesselUpdate, PsycheEye.VesselVariant)

local function PreTearCollision(mod, tear, other, low)
    if (other:IsVulnerableEnemy()) then
        if (PsycheEye:IsMindControlTear(tear) and PsycheEye:CanControl(other)) then
            local spawner = tear.SpawnerEntity;
            PsycheEye:ControlEntity(other, spawner);
            if (not tear:HasTearFlags(TearFlags.TEAR_PIERCING)) then
                tear:Die();
            end
        end
    end
end
PsycheEye:AddPriorityCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, CallbackPriority.LATE, PreTearCollision)


local function PostNPCUpdate(mod, npc)
    local npcData = GetNPCData(npc, false);
    if (npcData and npcData.WaveKillTimeout >= 0) then
        npcData.WaveKillTimeout = npcData.WaveKillTimeout - 1;
        if (npcData.WaveKillTimeout < 0) then
            npcData.WaveKillTimeout = -1;
            npcData.WaveKillPlayer = nil
        end
    end
end
PsycheEye:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostNPCUpdate)


local function PostEntityRemove(mod, entity)
    if (entity:IsActiveEnemy(true)) then
        
        if (entity:IsDead()) then
            local npcData = GetNPCData(entity, false);
            if (npcData and npcData.WaveKillPlayer) then
                PsycheEye:AddWaveKills(npcData.WaveKillPlayer, 100);
                PsycheEye:AddWaveKillDecay(npcData.WaveKillPlayer, 5);
            end
        end
    end
end
PsycheEye:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, PostEntityRemove)





return PsycheEye;