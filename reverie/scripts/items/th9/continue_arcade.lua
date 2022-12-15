local Revive = CuerLib.Revive;
local Players = CuerLib.Players;

local ContinueArcade = ModItem("Continue?", "ContinueArcade");

function ContinueArcade.GetPlayerData(player, init)
    return ContinueArcade:GetData(player, init, function() return {
        ReviveCost = 3
    } end);
end

local effectRNG = RNG();
function ContinueArcade.SpawnDroppedCoin(rng, path, position, spawner, sprPath)
    local v = RandomVector()*(rng:RandomFloat()*2+2); 
    local poof = Isaac.Spawn(1000,15,100,position,v,spawner);
    local spr = poof:GetSprite();
    spr:Load(path, true);
    if (sprPath) then
        spr:ReplaceSpritesheet(0, sprPath);
        spr:LoadGraphics()
    end
    spr:Play("Appear");
end


---@type ReviveCallback
local function PostRevive(player, reviver)
    player:AnimateCollectible(ContinueArcade.Item, "UseItem")

    local data = ContinueArcade.GetPlayerData(player, true);
    local cost = data.ReviveCost;
    reviver:AddCoins(-cost);

    local dollarCount = math.floor(cost / 100);
    cost = cost - 100 * dollarCount;
    local quarterCount = math.floor(cost % 100 / 25);
    cost = cost - 25 * quarterCount;
    local dimeCount = math.floor(cost % 25 / 10);
    cost = cost - 10 * dimeCount;
    local nickelCount = math.floor(cost % 10 / 5);
    cost = cost - 5 * nickelCount;
    local pennyCount = math.floor(cost % 5);
    cost = cost - 1 * pennyCount;

    for i = 1, dollarCount do
        ContinueArcade.SpawnDroppedCoin(effectRNG, "gfx/005.350_Trinket.anm2", reviver.Position, reviver, "gfx/items/collectibles/collectibles_018_adollar.png");
    end
    for i = 1, quarterCount do
        ContinueArcade.SpawnDroppedCoin(effectRNG, "gfx/005.350_Trinket.anm2", reviver.Position, reviver, "gfx/items/collectibles/collectibles_074_aquarter.png");
    end
    for i = 1, dimeCount do
        ContinueArcade.SpawnDroppedCoin(effectRNG, "gfx/005.023_dime.anm2", reviver.Position, reviver);
    end
    for i = 1, nickelCount do
        ContinueArcade.SpawnDroppedCoin(effectRNG, "gfx/005.022_nickel.anm2", reviver.Position, reviver);
    end
    for i = 1, pennyCount do
        ContinueArcade.SpawnDroppedCoin(effectRNG, "gfx/005.021_penny.anm2", reviver.Position, reviver);
    end

    THI.SFXManager:Play(SoundEffect.SOUND_CASH_REGISTER);
    data.ReviveCost = data.ReviveCost * 3;
    local playerType = player:GetPlayerType();
    if (playerType == PlayerType.PLAYER_BLUEBABY or playerType == PlayerType.PLAYER_BLUEBABY_B or 
    playerType == PlayerType.PLAYER_BETHANY_B or playerType == PlayerType.PLAYER_THEFORGOTTEN_B or 
    playerType == PlayerType.PLAYER_THESOUL) then
        local currentHeart = player:GetSoulHearts();
        Players.AddRawSoulHearts(player, 6 - currentHeart);
    elseif (playerType == PlayerType.PLAYER_JUDAS_B or playerType == PlayerType.PLAYER_BLACKJUDAS) then
        local currentHeart = player:GetSoulHearts();
        player:AddBlackHearts(4 - currentHeart);
    elseif (playerType == PlayerType.PLAYER_THEFORGOTTEN) then
        local currentHeart = player:GetBoneHearts();
        player:AddBoneHearts(3 - currentHeart);
        player:AddHearts(6);
    else
        local targetHealth = player:GetEffectiveMaxHearts();
        local currentHeart = player:GetHearts();
        player:AddHearts(targetHealth - currentHeart);
    end
end

local function PreRevive(mod, player)
    if (player:HasCollectible(ContinueArcade.Item)) then
        local cost = 3;
        local data = ContinueArcade.GetPlayerData(player, false);
        if (data) then
            cost = data.ReviveCost or 3;
        end
        if (player:GetNumCoins() >= cost) then
            return {
                BeforeVanilla = false,
                Callback = PostRevive
            }
        end
    end
end
ContinueArcade:AddCallback(CuerLib.Callbacks.CLC_PRE_REVIVE, PreRevive);


return ContinueArcade;