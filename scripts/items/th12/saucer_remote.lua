local CompareEntity = CuerLib.Detection.CompareEntity;
local Actives = CuerLib.Actives;
local SaucerRemote = ModItem("Saucer Remote", "SaucerRemote");


function SaucerRemote:UseRemote(item, rng, player, flags, slot, varData)
    if (flags & UseFlag.USE_CARBATTERY > 0) then
        return {Discharge = false, ShowAnim = false};
    end

    local game = THI.Game;
    local room = game:GetRoom();
    local ufo = THI.Monsters.BonusUFO;
    local variant = ufo.Variant;


    local i;
    -- Wisps.player:GetCollectibleNum(ShanghaiDoll.Item) +
    local redWisp = THI.Collectibles.DarkRibbon.Item;
    local blueWisp = THI.Collectibles.MaidSuit.Item;
    local greenWisp = THI.Collectibles.DYSSpring.Item;
    -- Cost Wisps.
    local discharge = true;
    local reds = {};
    local blues = {};
    local greens = {};
    local costs;
    local enough = false;
    -- Search for wisps.
    for _, wisp in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP)) do
        local familiar = wisp:ToFamiliar();
        if (familiar.Player and CompareEntity(familiar.Player, player)) then
            if (wisp.SubType == redWisp) then
                table.insert(reds, familiar);
            elseif (wisp.SubType == blueWisp) then
                table.insert(blues, familiar);
            elseif (wisp.SubType == greenWisp) then
                table.insert(greens, familiar);
            end

            if (#reds >= 3) then
                costs = reds;
                i = 0;
                enough = true;
            elseif (#blues >= 3) then
                costs = blues;
                i = 1;
                enough = true; 
            elseif (#greens >= 3) then
                costs = greens;
                i = 2;
                enough = true; 
            elseif (#reds >= 1 and #blues >= 1 and #greens >= 1) then
                costs = {};
                table.insert(costs, reds[1]);
                table.insert(costs, blues[1]);
                table.insert(costs, greens[1]);
                i = 3;
                enough = true; 
            end
            if (enough) then
                break;
            end
        end
    end

    if (enough) then
        for _, cost in pairs(costs) do
            cost:Kill();
        end
        discharge = false;
    else
        i = rng:RandomInt(4);
    end

    if (i == 1) then
        variant = ufo.BlueVariant;
    elseif (i == 2) then
        variant = ufo.GreenVariant;
    elseif (i == 3) then
        variant = ufo.RainbowVariant;
    end

    local spawned = Isaac.Spawn(ufo.Type, variant, 0, room:GetCenterPos(), Vector.Zero, player);
    local data = ufo.GetUFOData(spawned, true);
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)) then
        data.BonusTimes = 3;
    else
        data.BonusTimes = 2;
    end

    -- Music.
    local musicManager = MusicManager();
    local curMusic = musicManager:GetCurrentMusicID ( );
    if (curMusic ~= THI.Music.UFO) then
        musicManager:Play(THI.Music.UFO, 0);
        musicManager:UpdateVolume();
        musicManager:Queue(curMusic);
    end
    

    if (discharge and Actives.CanSpawnWisp(player, flags)) then
        -- These wisps are attached to passive items.
        local wispType = i;
        if (i == 3) then
            local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES);
            wispType = rng:RandomInt(3);
        end
        local type = redWisp;

        if (wispType == 1) then
            type = blueWisp;
        elseif (wispType == 2) then
            type = greenWisp;
        end
        player:AddWisp(type, player.Position);
    end

    for slot = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
        local door = room:GetDoor(slot);
        if (door) then
            door:Close();
        end
    end
    return {ShowAnim = true, Discharge = discharge};
end
SaucerRemote:AddCallback(ModCallbacks.MC_USE_ITEM, SaucerRemote.UseRemote, SaucerRemote.Item);

return SaucerRemote;