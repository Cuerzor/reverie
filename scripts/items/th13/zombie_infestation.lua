local Detection = CuerLib.Detection;
local Tears = CuerLib.Tears;
local Zombie = ModItem("Zombie Infestation", "Z_INFEST");

Zombie.ItemPlayer = nil;



function Zombie:IsZombie(npc)
    local tryTimes = 0;
    repeat
        
        if (npc.SpawnerType == 58115310 and npc.SpawnerVariant == Zombie.Item) then
            return true;
        end
        npc = npc.SpawnerEntity;
        tryTimes = tryTimes + 1;
    until not npc or tryTimes > 16;
    return false;
end

function Zombie:ClearZombie()
    for _, ent in pairs(Isaac.GetRoomEntities()) do
        if (Zombie:IsZombie(ent)) then
            ent:ClearEntityFlags(EntityFlag.FLAG_FRIENDLY);
            ent:Remove();
        end
    end
end

do
    local function PostUpdate(mod)
        Zombie.ItemPlayer = nil;
        for p, player in Detection.PlayerPairs() do
            if (player:HasCollectible(Zombie.Item)) then
                Zombie.ItemPlayer = player;
                if (player:IsFrame(2, 0)) then
                    if (Random() % 3 == 1) then
                        local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, player.Position, Vector.Zero, player);
                        local scale = 0.5 + Random() % 0.5
                        splat.SpriteScale = Vector(scale, scale);
                    end
                end
                break;
            end
        end
    end
    Zombie:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);

    local function PostNPCUpdate(mod, npc)
        local spawner = Zombie.ItemPlayer;
        local canSpawn = true;
        if (THI.IsLunatic()) then
            canSpawn = npc.InitSeed % 100 < 50 ;
        end
        if (spawner and canSpawn and npc:IsDead() and npc:Exists() and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and npc:IsActiveEnemy(true) and not npc:IsBoss()) then
            local new = Isaac.Spawn(npc.Type, npc.Variant, npc.SubType, npc.Position, Vector.Zero, spawner);
            new.SpawnerType = 58115310;
            new.SpawnerVariant = Zombie.Item;
            new:AddCharmed(EntityRef(spawner), -1);
            local champion = npc:GetChampionColorIdx ( );
            if (champion >= 0) then
                new:ToNPC():MakeChampion(new.InitSeed, champion, true);
            end
        end
    end
    Zombie:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostNPCUpdate);

    local function PostFireTear(mod, tear)
        local player;
        local spawner = tear.SpawnerEntity;
        if (spawner) then
            player = spawner:ToPlayer();
        end
        if (player and player:HasCollectible(Zombie.Item)) then
            local bloodVariant = Tears:GetBloodVariant(tear.Variant);
            if (bloodVariant >= 0) then
                tear:ChangeVariant(bloodVariant);
            end
        end
    end
    Zombie:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, PostFireTear);
    
    local function PostNewRoom(mod)
        Zombie:ClearZombie()
    end
    Zombie:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom);

    
    local function PreExit(mod, shouldSave)
        Zombie:ClearZombie()
    end
    Zombie:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, PreExit);

    local function PostGainZombie(mod, player, item, count, touched)
        local playerType= player:GetPlayerType();
        if (playerType ~= PlayerType.PLAYER_KEEPER and playerType ~= PlayerType.PLAYER_KEEPER_B) then
            local redHearts = player:GetHearts();
            player:AddHearts(-redHearts);
            player:AddRottenHearts(redHearts);
        end
    end
    Zombie:AddCustomCallback(CLCallbacks.CLC_POST_GAIN_COLLECTIBLE, PostGainZombie, Zombie.Item);
end

return Zombie;