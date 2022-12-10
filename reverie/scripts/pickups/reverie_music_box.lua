local Entities = CuerLib.Entities;
local Box = ModEntity("Reverie Music Box", "REVERIE_MUSIC_BOX");
Box.SubType = 582;

local function GetBottleData(bottle, create)
    return Box:GetTempData(bottle, create, function()
        return {
            LastTouched = false,
            Touched = false,
            TouchPlayer = nil,
            Disappearing = false,
            DisappearTimeout = -1
        }
    end)
end


local function PostPickupInit(mod, pickup)
    if (pickup.SubType == Box.SubType) then
        pickup.DepthOffset = 30;
    end
end
Box:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, PostPickupInit, Box.Variant);

function Box:GotoReverieRoom(player)
    local Note = THI.Bosses.ReverieNote;
    THI.GotoRoom("s.library."..Note.Room.Variant);
    player:PlayExtraAnimation("DeathTeleport");
    Game():StartRoomTransition (-3, Direction.NO_DIRECTION, RoomTransitionAnim.PIXELATION, player);
end

local function PostPickupUpdate(mod, pickup)
    if (pickup.SubType == Box.SubType) then
        local data = GetBottleData(pickup, false);
        local spr = pickup:GetSprite();
        if (data) then

            if (data.Disappearing) then
                spr:Play("Idle");
                if (data.DisappearTimeout < 0) then
                    pickup:Remove();
                else
                    data.DisappearTimeout = data.DisappearTimeout - 1;
                    local c= pickup.Color;
                    pickup.Color = Color(c.R,c.G,c.B, data.DisappearTimeout / 30, c.RO,c.GO,c.BO);
                end
            else

                if (data.LastTouched ~= data.Touched) then
                    
                    data.LastTouched = data.Touched;
                    if (data.Touched) then
                        spr:Play("Play");
                    else
                        spr:Play("Restore");
                    end
                end
                if (data.Touched) then
                    local player = data.TouchPlayer;

                    for i = 1, 7 do
                        if (spr:IsEventTriggered("Play"..i)) then
                            local pitch = 2 ^ (i/12);
                            SFXManager():Play(THI.Sounds.SOUND_MUSIC_BOX_C4, 1, 0, false, pitch);
                        end
                    end

                    local Note = THI.Bosses.ReverieNote;
                    local isBossRoom = Note:IsBossRoom()
                    local started = Note:IsBossFightStarted();

                    if (spr:IsFinished("Play") and player) then
                        spr:Play("Idle");

                        if (isBossRoom) then
                            if (not started) then
                                Note:StartOpeningAnimation();
                                data.Disappearing = true;
                                data.DisappearTimeout = 30;
                            end
                        else
                            Box:GotoReverieRoom(player);
                        end
                    end

                    if (not isBossRoom) then
                        if (not player or player.Position:Distance(pickup.Position) > player.Size + pickup.Size + 5) then
                            data.Touched = false;
                            data.TouchPlayer = nil;
                        end
                    end
                end
            end
        end
        if (spr:IsFinished("Restore")) then
            spr:Play("Idle");
        end
    end
end
Box:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, PostPickupUpdate, Box.Variant);

local function PrePickupCollision(mod, pickup, other, low)
    if (pickup.SubType == Box.SubType) then
        if (other.Type == EntityType.ENTITY_PLAYER and other.Variant == 0) then
            local player = other:ToPlayer();
            if (not player:IsCoopGhost()) then
                local data = GetBottleData(pickup, true);
                data.Touched = true;
                data.TouchPlayer = player;
                return true;
            end
        end
    end
end
Box:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, PrePickupCollision, Box.Variant)


return Box;