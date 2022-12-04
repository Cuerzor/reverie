---@class KeystoneData
---@field QuakeCountdown integer @How long does it take to start an earthquake?
---@field QuakeTimeout integer @How long will this earthquake last?

local Keystone = ModItem("Keystone", "KEYSTONE");

---@param create boolean
---@return KeystoneData data
local function GetTempGlobalData(create)
    return Keystone:GetTempGlobalData(create, function()
        return {
            QuakeCountdown = -1,
            QuakeTimeout = -1,
            QuakeReleaser = nil
        }
    end)
end

--- Get the countdown which the earthquake occurs after this.
---@return integer Countdown.
function Keystone:GetEarthquakeCountdown()
    local data = GetTempGlobalData(false);
    return (data and data.QuakeCountdown) or -1;
end
--- Set the countdown which the earthquake occurs after this.
---@param value integer Countdown.
function Keystone:SetEarthquakeCountdown(value)
    local data = GetTempGlobalData(true);
    data.QuakeCountdown = value;
end

--- Get the timeout which the earthquake lasts.
---@return integer Timeout.
function Keystone:GetEarthquakeTimeout()
    local data = GetTempGlobalData(false);
    return (data and data.QuakeTimeout) or -1;
end
--- Set the timeout which the earthquake lasts.
---@param value integer Timeout.
function Keystone:SetEarthquakeTimeout(value)
    local data = GetTempGlobalData(true);
    data.QuakeTimeout = value;
end


--- Get the player who released the earthquake.
---@return EntityPlayer Earthquake releaser.
function Keystone:GetEarthquakeReleaser()
    local data = GetTempGlobalData(false);
    return (data and data.QuakeReleaser) or nil;
end
--- Set the player who released the earthquake..
---@param player EntityPlayer Earthquake releaser.
function Keystone:SetEarthquakeReleaser(player)
    local data = GetTempGlobalData(true);
    data.QuakeReleaser = player;
end

local function PostUseKeyStone(mod, item, rng, player, flags, slot, varData)
    Keystone:SetEarthquakeCountdown(30);

    local timeout = Keystone:GetEarthquakeTimeout()
    Keystone:SetEarthquakeTimeout(timeout + 120);
    Keystone:SetEarthquakeReleaser(player);

    THI.SFXManager:Play(SoundEffect.SOUND_ROCK_CRUMBLE);
    Game():ShakeScreen(20);
    return {ShowAnim = true}
end
Keystone:AddCallback(ModCallbacks.MC_USE_ITEM, PostUseKeyStone, Keystone.Item);

local function PostUpdate(mod)
    local countdown = Keystone:GetEarthquakeCountdown();
    local timeout = Keystone:GetEarthquakeTimeout();

    if (countdown >= 0) then
        countdown = countdown - 1
        Keystone:SetEarthquakeCountdown(countdown);
    else
        if (timeout >= 0) then

            if (not THI.SFXManager:IsPlaying(THI.Sounds.SOUND_EARTHQUAKE)) then
                THI.SFXManager:Play(THI.Sounds.SOUND_EARTHQUAKE, 1, 0, true);
            end
            local player = Keystone:GetEarthquakeReleaser();

            Game():ShakeScreen(10);

            -- Break Rocks.
            local room = Game():GetRoom();
            local frameCount = room:GetFrameCount();
            local width = room:GetGridWidth();
            local height = room:GetGridHeight();
            for x = 0, width do
                for y = 0, height do
                    local index = y * width + x;
                    local gridEnt = room:GetGridEntity(index);
                    if (gridEnt) then
                        
                        local type = gridEnt:GetType();
                        if (type == GridEntityType.GRID_DOOR or 
                        type == GridEntityType.GRID_POOP or 
                        type == GridEntityType.GRID_ROCK or 
                        type == GridEntityType.GRID_ROCK_ALT or
                        type == GridEntityType.GRID_ROCK_ALT2 or 
                        type == GridEntityType.GRID_ROCK_BOMB or
                        type == GridEntityType.GRID_ROCK_GOLD or 
                        type == GridEntityType.GRID_ROCK_SPIKED or
                        type == GridEntityType.GRID_ROCK_SS or 
                        type == GridEntityType.GRID_ROCKT or 
                        type == GridEntityType.GRID_TNT) then
                            local seed = gridEnt.Desc.SpawnSeed;
                            if (seed % 100 < math.min(frameCount, 100 - timeout)) then
                                gridEnt:Destroy(false);
                            end
                        end
                    end
                end
            end

            -- Fall Rocks.
            local tearPos = room:GetRandomPosition(20);
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.ROCK, 0, tearPos, Vector.Zero, player):ToTear();
            tear.CollisionDamage = player.Damage;
            tear.Height = -400;
            tear.FallingAcceleration = 5;
            local TearEffects = THI.Shared.TearEffects;
            TearEffects:SetTearRain(tear, true);

            -- Damage Monsters.
            if (timeout % 5 == 0) then
                for i, ent in pairs(Isaac.GetRoomEntities()) do
                    local EntityTags = THI.Shared.EntityTags;
                    local canDamage = ent:IsActiveEnemy() and not ent:IsFlying() or EntityTags:EntityFits(ent, "DiggerEnemies");

                    if (canDamage) then
                        local damage = ent.HitPoints * 0.02;
                        ent:TakeDamage(damage, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0);
                    end
                end
            end


            timeout = timeout - 1;
            Keystone:SetEarthquakeTimeout(timeout);
            if (timeout < 0) then
                THI.SFXManager:Stop(THI.Sounds.SOUND_EARTHQUAKE);
            end
        end
    end
end
Keystone:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);

return Keystone;