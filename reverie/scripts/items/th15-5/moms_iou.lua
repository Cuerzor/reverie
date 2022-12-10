
local Screen = CuerLib.Screen;
local Players = CuerLib.Players;
local MomsIOU = ModItem("Mom's IOU", "MomsIOU");


local config = Isaac.GetItemConfig();
local maxItemId = config:GetCollectibles().Size;
local repayRNG = RNG();

local RepayStrings = {
    Normal = "#REPAY_NOT_FINISHED",
    Finished = "#REPAY_FINISHED",
}

function MomsIOU.GetPlayerTempData(player, init)
    local data = player:GetData();
    if (init) then
        data._MOMSIOU = data._MOMSIOU or {
            Time = 0,
            Alpha = 0,
            Repayment = 0
        }
    end
    return data._MOMSIOU;
end

function MomsIOU.GetPlayerData(player, init)
    return MomsIOU:GetData(player, init, function() return {
        Borrowed = 0,
        Debt = 0
    } end)
end

function MomsIOU.RepayItems(player, repay) 
    local ownedItems = {};
    local totalCount = 0;
    for id = 1, maxItemId do
        if (id ~= MomsIOU.Item) then
            local num = player:GetCollectibleNum(id, true);
            if (num > 0) then
                local col = config:GetCollectible(id);
                if (col and not col:HasTags(ItemConfig.TAG_QUEST)) then
                    ownedItems[id] = num;
                    totalCount = totalCount + num;
                end
            end
        end
    end

    local repayedCoins = 0;
    local effectRNG = RNG();
    local repayedNum = math.ceil(repay / 15);
    for r = 1, repayedNum do
        if (totalCount > 0) then
            local random = repayRNG:RandomInt(totalCount);
            for id, num in pairs(ownedItems) do
                random = random - num;
                if (random <= 0) then
                    player:RemoveCollectible(id, true);
                    
                    local v = RandomVector()*(effectRNG:RandomFloat()*2+2); 
                    local poof = Isaac.Spawn(1000,15,100,player.Position,v,player);
                    local spr = poof:GetSprite();
                    spr:Load("gfx/005.350_Trinket.anm2", true);
                    spr:Play("Appear");
                    local col = config:GetCollectible(id);
                    spr:ReplaceSpritesheet(0, col.GfxFileName);
                    spr:LoadGraphics();

                    ownedItems[id] = num - 1;
                    totalCount = totalCount - 1;
                    if (ownedItems[id] <= 0) then
                        ownedItems[id] = nil;
                    end
                    break;
                end
            end
            repayedCoins = repayedCoins + 15;
        end
    end
    return repayedCoins;
end

function MomsIOU:PostGainCollectible(player, item, count, touched)
    if (not touched) then
        local beforeCoins = player:GetNumCoins();
        player:AddCoins(9999);
        local coins = player:GetNumCoins();
        local added = coins - beforeCoins;
        local data = MomsIOU.GetPlayerData(player, true);
        data.Borrowed = data.Borrowed + added;
        data.Debt = data.Debt + math.ceil(added * 1.2);
    end
end
MomsIOU:AddCallback(CuerLib.Callbacks.CLC_POST_GAIN_COLLECTIBLE, MomsIOU.PostGainCollectible, MomsIOU.Item);


function MomsIOU:PostPlayerEffect(player)
    
    local tempData = MomsIOU.GetPlayerTempData(player, false);
    if (tempData) then
        if (tempData.Time > 0) then
            tempData.Time = tempData.Time - 1;
            tempData.Alpha = math.min(1, tempData.Alpha + 0.1);
        else
            tempData.Alpha = math.max(0, tempData.Alpha - 0.1);
        end
    end
end
MomsIOU:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MomsIOU.PostPlayerEffect);


function MomsIOU:PostNewStage()
    local game = THI.Game;
    if (game:GetFrameCount() <= 1) then
        return;
    end

    for p, player in Players.PlayerPairs() do
        local data = MomsIOU.GetPlayerData(player, false);
        if (data and data.Debt > 0) then
            local coins = player:GetNumCoins();
            local totalRepayed = 0;
            local repayment = math.min(math.ceil(data.Borrowed / 5), data.Debt);
            player:AddCoins(-repayment);
            totalRepayed = totalRepayed + math.min(repayment, coins);

            THI.SFXManager:Play(SoundEffect.SOUND_CASH_REGISTER);

            -- if player cannot repay by coins
            if (totalRepayed < repayment) then
                -- Remove a random item for repaying.
                totalRepayed = totalRepayed + MomsIOU.RepayItems(player, repayment - coins);
            end

            -- if player cannot repay by items
            if (totalRepayed < repayment) then
                -- Remove hearts for repaying.
                local flags = DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_PENALTIES;
                local repayHalfHearts = math.ceil((repayment - totalRepayed) / 3) * 2;
                local remainRepay = repayHalfHearts;
                -- Soul Hearts.
                local repayingHalfHearts = math.min(player:GetSoulHearts(), remainRepay);
                Players:AddRawSoulHearts(player, -repayingHalfHearts);
                remainRepay = remainRepay - repayingHalfHearts;

                -- Eternal Hearts.
                local repayingHalfHearts = math.min(player:GetEternalHearts(), remainRepay);
                player:GetEternalHearts(-repayingHalfHearts);
                remainRepay = remainRepay - repayingHalfHearts;
            
                -- Red Hearts.
                local repayingHalfHearts = math.min(player:GetHearts(), remainRepay);
                player:AddHearts(-repayingHalfHearts);
                remainRepay = remainRepay - repayingHalfHearts;

                -- Rotten Hearts.
                local repayingHalfHearts = math.min(player:GetRottenHearts(), remainRepay);
                player:AddRottenHearts(-repayingHalfHearts);
                remainRepay = remainRepay - repayingHalfHearts;

                -- Bone Hearts.
                local repayingHalfHearts = math.min(player:GetBoneHearts(), remainRepay);
                player:AddBoneHearts(-repayingHalfHearts);
                remainRepay = remainRepay - repayingHalfHearts;

                local repayedHearts = repayHalfHearts - remainRepay;
                totalRepayed = totalRepayed + math.floor(repayedHearts / 2 * 3);

                player:TakeDamage(0, flags, EntityRef(player), 0);
            end
            data.Debt = data.Debt - totalRepayed;

            local tempData = MomsIOU.GetPlayerTempData(player, true);
            tempData.Repayment = totalRepayed;
            tempData.Time = 120;

            if (data.Debt <= 0) then
                data.Borrowed = 0;
                data.Debt = 0;
                for i = 1, player:GetCollectibleNum(MomsIOU.Item, true) do
                    player:RemoveCollectible(MomsIOU.Item, true);
                end
            end
        end
    end
end
MomsIOU:AddCallback(CuerLib.Callbacks.CLC_POST_NEW_STAGE, MomsIOU.PostNewStage);

function MomsIOU:PostPlayerRender(player, offset)
    if (not Screen.IsReflection()) then
        local game = THI.Game;
        local data = MomsIOU.GetPlayerData(player, false);
        local tempData = MomsIOU.GetPlayerTempData(player, false);
        if (data and tempData and tempData.Alpha > 0) then
            local color = KColor(1,1,1,tempData.Alpha);

            local repayStrings = RepayStrings;
            local key;
            if (data.Debt > 0) then
                key = repayStrings.Normal;
            else
                key = repayStrings.Finished;
            end
            local str = THI.GetText(THI.StringCategories.DEFAULT, key);
            str = string.gsub(str, "{REPAYMENT}", tostring(tempData.Repayment));
            str = string.gsub(str, "{REMAINED}", tostring(data.Debt));
            local renderPos = Screen.GetEntityOffsetedRenderPosition(player, offset + Vector(0, -48));
            local font = THI.GetFont("REPAY");
            local width = font:GetStringWidthUTF8(str);
            font:DrawStringUTF8(str, renderPos.X, renderPos.Y, color, math.floor(width / 2), false);
        end
    end
end
MomsIOU:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, MomsIOU.PostPlayerRender);

function MomsIOU:EvaluateCache(player, cache)
    if (cache == CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck - player:GetCollectibleNum(MomsIOU.Item) * 3;
    end
end
MomsIOU:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, MomsIOU.EvaluateCache)


return MomsIOU;