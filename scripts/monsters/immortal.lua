local Screen = CuerLib.Screen;
local Detection = CuerLib.Detection;
local Immortal = ModEntity("The Immortal", "THE_IMMORTAL");

do
    local sprites = {
        "Right",
        "Down",
        "Left",
        "Up",
    }
    local maxTrailCount = 10;
    local MaxChargeCooldown = 150;
    local ChargeSpeed = 15;

    local function GetImmortalData(immortal, init)
        local function getter()
            return {
                Charging = false,
                ChargeCooldown = MaxChargeCooldown,
                TrailPositions = {}
            }
        end
        return Immortal:GetData(immortal,init, getter);
    end


    local function PostImmortalUpdate(mod, immortal)
        if (immortal.Variant == Immortal.Variant) then
            local maxSpeed = 2;
            local target = immortal:GetPlayerTarget();
            local target2This = target.Position - immortal.Position;
            local game = Game();
            local room = game:GetRoom();
            local beforeVel = immortal.Velocity;
            local canSeeTarget = room:CheckLine(immortal.Position, target.Position, 0);

            local data = GetImmortalData(immortal, true);
            data.TrailPositions = data.TrailPositions  or {};
            if (data.ChargeCooldown > 0) then
                data.ChargeCooldown = data.ChargeCooldown - 1;
            end



            if (canSeeTarget and target.Position:Distance(immortal.Position) < 100) then
                -- Target is near immortal.
                if (data.ChargeCooldown <= 0) then
                    -- Start Charging.
                    data.Charging = true;
                    data.ChargeCooldown = MaxChargeCooldown;
                    immortal.Velocity = target2This:Resized(ChargeSpeed);
                    THI.SFXManager:Play(SoundEffect.SOUND_MONSTER_YELL_A)
                end
            end
            if (data.Charging) then
                maxSpeed = ChargeSpeed;
                immortal.Velocity = immortal.Velocity:Resized(ChargeSpeed);
                if (immortal:CollidesWithGrid()) then
                    data.Charging = false;
                    game:ShakeScreen(15);
                    THI.SFXManager:Play(SoundEffect.SOUND_ROCK_CRUMBLE);
                end
                
                -- Add Trail Position.
                table.insert(data.TrailPositions, 1, immortal.Position);
            else
                if (immortal:IsFrame(5, 0)) then
                    
                    immortal.Target = target;
                    if (canSeeTarget) then
                        -- No Obstacles.
                        local acceleration = target2This:Normalized() * 1;
                        immortal.Velocity = beforeVel + acceleration;
                    else
                        local pathfinder = immortal.Pathfinder;
                        pathfinder:FindGridPath (target.Position, 1, 0, true);
                        local acceleration = immortal.Velocity:Normalized() * maxSpeed;
                        immortal.Velocity = beforeVel + acceleration;
                    end
                end
            end
            if (#data.TrailPositions > maxTrailCount or not data.Charging) then
                table.remove(data.TrailPositions, #data.TrailPositions);
            end

            local vel = immortal.Velocity;
            local length = vel:Length();
            length = maxSpeed + (length - maxSpeed) * 1;
            immortal.Velocity = vel:Resized(length);
            immortal:MultiplyFriction(0.9);

            
            local angle = immortal.Velocity:GetAngleDegrees();
            local spriteIndex = math.floor((angle + 45) % 360 / 90) + 1;
            immortal:GetSprite():Play("Walk"..sprites[spriteIndex]);

        end
    end
    Immortal:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostImmortalUpdate, Immortal.Type)

    local function PostProjectileUpdate(mod, proj)
        
        
        -- Kill touched projectiles.
        if (not proj:IsDead()) then
            
            for i, enemy in pairs(Isaac.FindInRadius(proj.Position, proj.Size * 5, EntityPartition.ENEMY)) do
                if (enemy.Type == Immortal.Type and enemy.Variant == Immortal.Variant and Detection.CheckCollision(enemy, proj)) then
                    proj:Die();
                end
            end
        end
    end
    Immortal:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, PostProjectileUpdate);

    local function PreImmortalCollision(mod, npc, other, low)
        if (npc.Variant == Immortal.Variant) then
            local player = other:ToPlayer();
            if (player) then
                local data = GetImmortalData(npc, false);
                if (data and data.Charging) then
                    data.Charging = false;
                    Game():ShakeScreen(15);
                    THI.SFXManager:Play(SoundEffect.SOUND_PUNCH);
                    local vel = (player.Position - npc.Position):Resized(ChargeSpeed);
                    --other.Velocity = other.Velocity + vel;
                    player.Velocity = vel:Resized(50);
                    -- npc:AddVelocity(-vel);
                end
            end
        end
    end
    Immortal:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, PreImmortalCollision, Immortal.Type)

    
    local function PostImmortalRender(mod, npc, offset)
        if (npc.Variant == Immortal.Variant) then
            local data = GetImmortalData(npc, false);
            if (data) then
                local spr = npc:GetSprite();
                local sc = spr.Color;
                local startColor = Color(sc.R, sc.G, sc.B, sc.A, sc.RO,sc.GO, sc.BO);
                for i, pos in pairs(data.TrailPositions) do
                    spr.Color = Color(sc.R, sc.G, sc.B, sc.A - (i + maxTrailCount - #data.TrailPositions) /maxTrailCount, sc.RO,sc.GO, sc.BO);
                    local renderPos = Screen.GetOffsetedRenderPosition(pos, offset);
                    spr:Render(renderPos,Vector.Zero, Vector.Zero);
                end
                spr.Color = startColor;
            end
        end
    end
    Immortal:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, PostImmortalRender, Immortal.Type)
end


return Immortal;