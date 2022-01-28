local Screen = CuerLib.Screen;
local Consts = CuerLib.Consts;
local Math = CuerLib.Math;
local Familiars = CuerLib.Familiars
local Detection = CuerLib.Detection;
local Head = ModItem("Sekibanki's Head", "SEKIBANKIS_HEAD")

local HeadSprite = Sprite();
HeadSprite:Load("gfx/003.5821_sekibanki head.anm2", true);
HeadSprite:Play("IdleDown");
Head.ItemConfig = Isaac.GetItemConfig():GetCollectible(Head.Item);

function Head.GetPlayerData(player, init)
    local function getter ()
        return {
            ScissorHeads = 0
        }
    end
    return Head:GetData(player, init, getter);
end

function Head.GetBodyData(body, init)
    local function getter ()
        return {
            Possessed = false,
            ShootDirection = Direction.NO_DIRECTION,
            HeadFrameDelay = -1,
            FireDelay = 0,
        }
    end
    return Head:GetData(body, init, getter);
end


function Head.HasSekibankiHead(player)
    local effects = player:GetEffects();
    if (player:HasCollectible(Head.Item) or effects:HasCollectibleEffect(Head.Item)) then
        return true;
    end
    return false;
end

function Head.GetSekibankiHeadNum(player)
    local effects = player:GetEffects();
    return player:GetCollectibleNum(Head.Item) + effects:GetCollectibleEffectNum(Head.Item);
end

do
    local function EvaluateCache(mod, player, flags)
        if (flags == CacheFlag.CACHE_FAMILIARS) then 
            local playerData = Head.GetPlayerData(player, false);
            local effects = player:GetEffects();
            local guillitineCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_GUILLOTINE) + 
            effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_GUILLOTINE);
            
            local count = Head.GetSekibankiHeadNum(player);
            count = count * (1 + guillitineCount);
            if (playerData) then
                count = count + playerData.ScissorHeads;
            end
            local Familiar = THI.Familiars.SekibankiHead;
            player:CheckFamiliar(Familiar.Variant, count, RNG(), Head.ItemConfig);
        end
    end
    Head:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache);

    -- The Pinking Shears    
    local DirectionAnimations = {
        [Direction.LEFT] = "Side",
        [Direction.UP] = "Up",
        [Direction.RIGHT] = "Side",
        [Direction.DOWN] = "Down"
    }
    local BodyHeadOffset = Vector(0, -14);
    local function PostBodyUpdate(mod, body)
        local player = body.Player;

        if (player and Head.HasSekibankiHead(player)) then
            local data = Head.GetBodyData(body, true)
            data.Possessed = true;

            if (data.FireDelay < 0) then
                data.ShootDirection = -1;

                -- Detect Enemies in a line.
                local bodyPos = body.Position;
                local width = 20;
                local dirEnemyCounts = {};
                -- Find Enemies.
                for i, ent in pairs(Isaac.GetRoomEntities()) do
                    if (ent:IsVulnerableEnemy() and ent:IsActiveEnemy()) then
                        local entPos = ent.Position;
                        local entSizeVec = ent.Size * ent.SizeMulti;
                        -- Check each direction's enemies.
                        for dir = 0, 3 do
                            local horizontal = dir % 2 == 0;

                            local inDir = false;
                            if (dir == Direction.LEFT) then
                                inDir = entPos.X <= bodyPos.X;
                            elseif (dir == Direction.UP) then
                                inDir = entPos.Y <= bodyPos.Y;
                            elseif (dir == Direction.RIGHT) then
                                inDir = entPos.X >= bodyPos.X;
                            elseif (dir == Direction.DOWN) then
                                inDir = entPos.Y >= bodyPos.Y;
                            end
                            if (not inDir) then
                                goto continue;
                            end

                            -- Width Intersect.
                            local intersect = false;
                            if (horizontal) then
                                local min = bodyPos.Y - width;
                                local max = bodyPos.Y + width;
                                local entMin = entPos.Y - entSizeVec.Y;
                                local entMax = entPos.Y + entSizeVec.Y;
                                intersect = math.max(min, entMin) <= math.min(max, entMax);
                            else
                                local min = bodyPos.X - width;
                                local max = bodyPos.X + width;
                                local entMin = entPos.X - entSizeVec.X;
                                local entMax = entPos.X + entSizeVec.X;
                                intersect = math.max(min, entMin) <= math.min(max, entMax);
                            end
                            if (not intersect) then
                                goto continue;
                            end

                            dirEnemyCounts[dir] = (dirEnemyCounts[dir] or 0) + 1;

                            ::continue::
                        end
                    end
                end

                local maxCountDir = -1;
                local maxCount = 0;
                for dir, count in pairs(dirEnemyCounts) do
                    if (count > maxCount) then
                        maxCount = count;
                        maxCountDir = dir;
                    end
                end
                if (maxCount > 0) then
                    local Familiar = THI.Familiars.SekibankiHead;
                    data.FireDelay = 10;
                    data.ShootDirection = maxCountDir;
                    data.HeadFrameDelay = 5;
                    Familiar.FireLasers(body, maxCountDir, Consts.GetDirectionVector(maxCountDir), BodyHeadOffset);
                end
            else
                data.FireDelay = Familiars.RunFireDelay(body, data.FireDelay)
            end

            
            if (data.HeadFrameDelay >= 0) then
                data.HeadFrameDelay = Familiars.RunFireDelay(body, data.HeadFrameDelay)
            end
        else
            local data = Head.GetBodyData(body, false)
            if (data) then
                data.Possessed = false;
                data.FireDelay = 0;
                data.ShootDirection = -1;
                data.HeadFrameDelay = -1;
            end
        end
    end
    Head:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PostBodyUpdate, FamiliarVariant.ISAACS_BODY);

    local function PostBodyRender(mod, body, offset)
        local data = Head.GetBodyData(body, false);
        if (data and data.Possessed) then
            local spr = HeadSprite;

            local animDir = data.ShootDirection;
            local animPrefix = "Idle";
            local frame = 0;

            if (data.HeadFrameDelay >= 0) then
                animPrefix = "Shoot";
                frame = 2;
            end

            
            if (animDir < 0) then
                animDir = Direction.DOWN;
            end
            local anim = animPrefix..DirectionAnimations[animDir];
            spr.FlipX = animDir == Direction.LEFT;
            spr:SetFrame(anim, frame);

            local pos = Screen.GetEntityOffsetedRenderPosition(body, offset, BodyHeadOffset);
            spr:Render(pos, Vector.Zero, Vector.Zero);
        end
    end
    Head:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, PostBodyRender, FamiliarVariant.ISAACS_BODY);

    -- Scissors
    local function PostUseScissors(mod, item, rng, player, flags, slot, varData)
        local num = Head.GetSekibankiHeadNum(player);
        if (num > 0) then
            local Familiar = THI.Familiars.SekibankiHead;
            local angleInterval = 360 / num;
            local playerData = Head.GetPlayerData(player, true);
            for i = 1, num do
                local angle = i * angleInterval + 90;
                local vec = Vector.FromAngle(angle) * 30;
                playerData.ScissorHeads = (playerData.ScissorHeads or 0) + 1; 
                local head = Isaac.Spawn(Familiar.Type, Familiar.Variant, Familiar.SubType, player.Position + vec, Vector.Zero, player);
                
                Familiar.SetMode(head, Familiar.Mode.FIXED);
            end
        end
    end
    Head:AddCallback(ModCallbacks.MC_USE_ITEM, PostUseScissors, CollectibleType.COLLECTIBLE_SCISSORS);

    local function PostNewRoom(mod)
        for p, player in Detection.PlayerPairs() do
            local playerData = Head.GetPlayerData(player, false);
            if (playerData) then
                playerData.ScissorHeads = 0;
            end
        end
    end
    Head:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom);


end
return Head;