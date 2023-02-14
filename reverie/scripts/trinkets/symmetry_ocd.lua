local ItemPools = CuerLib.ItemPools;
local Players = CuerLib.Players;
local SymmetryOCD = ModTrinket("Symmetry OCD", "SYMMETRY_OCD")
SymmetryOCD.Whitelist = {
    [2]=true,[5]=true,[6]=true,[8]=true,[9]=true,[10]=true,[11]=true,[12]=true,[13]=true,[14]=true,[20]=true,[21]=true,[27]=true,[33]=true,[34]=true,[35]=true,[44]=true,[47]=true,[48]=true,[50]=true,[51]=true,[52]=true,[53]=true,[55]=true,[57]=true,[58]=true,[60]=true,[62]=true,[63]=true,[65]=true,[66]=true,[67]=true,[69]=true,[70]=true,[71]=true,[73]=true,[74]=true,[75]=true,[78]=true,[82]=true,[84]=true,[87]=true,[88]=true,[89]=true,[93]=true,[94]=true,[95]=true,[96]=true,[97]=true,[98]=true,[99]=true,[101]=true,[107]=true,[108]=true,[112]=true,[113]=true,[118]=true,[123]=true,[126]=true,[127]=true,[128]=true,[130]=true,[131]=true,[143]=true,[145]=true,[146]=true,[149]=true,[150]=true,[151]=true,[153]=true,[154]=true,[157]=true,[158]=true,[159]=true,[161]=true,[162]=true,[163]=true,[167]=true,[168]=true,[174]=true,[178]=true,[179]=true,[181]=true,[184]=true,[185]=true,[188]=true,[189]=true,[192]=true,[194]=true,[208]=true,[211]=true,[213]=true,[214]=true,[215]=true,[221]=true,[222]=true,[225]=true,[230]=true,[231]=true,[233]=true,[234]=true,[240]=true,[242]=true,[243]=true,[248]=true,[249]=true,[254]=true,[264]=true,[267]=true,[268]=true,[269]=true,[271]=true,[272]=true,[274]=true,[275]=true,[283]=true,[284]=true,[285]=true,[286]=true,[290]=true,[292]=true,[299]=true,[300]=true,[304]=true,[309]=true,[311]=true,[313]=true,[315]=true,[316]=true,[318]=true,[319]=true,[320]=true,[323]=true,[325]=true,[330]=true,[331]=true,[333]=true,[334]=true,[335]=true,[340]=true,[345]=true,[348]=true,[349]=true,[350]=true,[351]=true,[360]=true,[361]=true,[363]=true,[364]=true,[368]=true,[372]=true,[373]=true,[375]=true,[380]=true,[382]=true,[385]=true,[386]=true,[387]=true,[389]=true,[392]=true,[402]=true,[403]=true,[406]=true,[408]=true,[410]=true,[411]=true,[414]=true,[415]=true,[417]=true,[418]=true,[419]=true,[420]=true,[422]=true,[425]=true,[426]=true,[427]=true,[429]=true,[431]=true,[433]=true,[434]=true,[435]=true,[437]=true,[439]=true,[442]=true,[450]=true,[457]=true,[459]=true,[461]=true,[462]=true,[463]=true,[465]=true,[466]=true,[468]=true,[470]=true,[471]=true,[472]=true,[473]=true,[475]=true,[478]=true,[486]=true,[489]=true,[490]=true,[492]=true,[493]=true,[496]=true,[497]=true,[498]=true,[499]=true,[502]=true,[510]=true,[511]=true,[516]=true,[528]=true,[536]=true,[539]=true,[545]=true,[546]=true,[550]=true,[551]=true,[552]=true,[555]=true,[556]=true,[561]=true,[567]=true,[568]=true,[569]=true,[572]=true,[574]=true,[575]=true,[576]=true,[577]=true,[579]=true,[583]=true,[584]=true,[588]=true,[590]=true,[591]=true,[592]=true,[596]=true,[597]=true,[598]=true,[600]=true,[607]=true,[608]=true,[625]=true,[629]=true,[633]=true,[637]=true,[640]=true,[649]=true,[651]=true,[653]=true,[656]=true,[659]=true,[661]=true,[665]=true,[670]=true,[672]=true,[673]=true,[675]=true,[678]=true,[679]=true,[685]=true,[687]=true,[688]=true,[691]=true,[692]=true,[703]=true,[709]=true,[711]=true,[712]=true,[715]=true,[720]=true,[723]=true,[730]=true
}
SymmetryOCD.ScanConfigs = {
    AllowedEmptyColumns = 1,
    DifferenceThresold = 6
}

local checkSprite = Sprite();
checkSprite:Load("gfx/reverie/symmetry_check.anm2", true);
checkSprite:SetFrame("Idle", 0);

function THI:ScanHorizontalSymmtrical(gfx)
    checkSprite:SetFrame("Idle", 0);
    checkSprite:ReplaceSpritesheet(0, gfx);
    checkSprite:ReplaceSpritesheet(1, gfx);
    checkSprite:LoadGraphics();

    local leftDots = {};
    local rightDots = {};
    local leftCount = 0;
    local rightCount = 0;
    local maxHeight = 0;
    local currentTop = 0;
    local currentBottom = 31;
    local coincidedCount = 0;
    local emptyColumns = 0;

    local function ScanPixel(x, y)
        local index = x * 32 + y;
        if (not leftDots[index] and not rightDots[index]) then
            local color = checkSprite:GetTexel(Vector(x, y),Vector(0,0), 1, -1);
            if (color.Alpha > 0) then
                if (y > currentBottom) then
                    currentBottom = y;
                end
                if (y < currentTop) then
                    currentTop = y;
                end
                if (color.Red > 0.9) then
                    local reversedIndex = (29 - x) * 32 + y;
                    rightDots[index] = color;
                    rightCount = rightCount + 1;
                elseif (color.Green > 0.9) then
                    leftDots[index] = color;
                    leftCount = leftCount + 1;
                    
                    local color = checkSprite:GetTexel(Vector(x, y),Vector(0,0), 1, 1);
                    if (color.Alpha > 0) then
                        rightDots[index] = color;
                        rightCount = rightCount + 1;
                        coincidedCount = coincidedCount + 1;
                        
                    end
                end
                return true;
            end
            return false;
        else
            return true;
        end
    end

    for x = 14, 0, -1 do
        local firstColorY;
        local lastColorY;
        for y = 0, 31 do
            if (y >= currentTop and y <= currentBottom) then
                local hasColor = ScanPixel(x, y);
                local value = leftCount + rightCount - coincidedCount * 2 - maxHeight;
                if (value > SymmetryOCD.ScanConfigs.DifferenceThresold) then
                    return false, value
                end
                if (hasColor) then
                    if (x < 15) then
                        if (y == currentTop) then
                            repeat
                                local colored = ScanPixel(x, currentTop - 1);
                                local value = leftCount + rightCount - coincidedCount * 2 - maxHeight;
                                if (value > SymmetryOCD.ScanConfigs.DifferenceThresold) then
                                    return false, value
                                end
                                if (colored) then
                                    currentTop = currentTop - 1;
                                else
                                    break;
                                end
                            until(currentTop <= 0)
                        end
                        if (y == currentBottom) then
                            repeat
                                local colored = ScanPixel(x, currentBottom + 1);
                                local value = leftCount + rightCount - coincidedCount * 2 - maxHeight;
                                if (value > SymmetryOCD.ScanConfigs.DifferenceThresold) then
                                    return false, value
                                end
                                if (colored) then
                                    currentBottom = currentBottom + 1;
                                else
                                    break;
                                end
                            until(currentBottom >= 31)
                        end
                    end
                    if (not firstColorY) then
                        firstColorY = y;
                    end
                    lastColorY = y;
                end
            end
        end
        if (firstColorY and lastColorY) then
            currentBottom = lastColorY;
            currentTop = firstColorY;
        end
        local height = currentBottom - currentTop;
        maxHeight = math.max(height, maxHeight);
        local value = leftCount + rightCount - coincidedCount * 2 - maxHeight;
        if (value > SymmetryOCD.ScanConfigs.DifferenceThresold) then
            return false, value
        end
        if (height <= 0 and leftCount + rightCount > 0) then
            emptyColumns = emptyColumns + 1;
            if (emptyColumns > SymmetryOCD.ScanConfigs.AllowedEmptyColumns and SymmetryOCD.ScanConfigs.AllowedEmptyColumns >= 0) then
                break;
            end
        end
    end
    return true, leftCount + rightCount - coincidedCount * 2 - maxHeight;
end

function SymmetryOCD:AddWhitelist(id)
    SymmetryOCD.Whitelist[id] = true;
end
function SymmetryOCD:RemoveWhitelist(id)
    SymmetryOCD.Whitelist[id] = false;
end
function SymmetryOCD:AddWhitelistMultiple(tbl)
    for _, id in pairs(tbl) do
        self:AddWhitelist(id)
    end
end
function SymmetryOCD:RemoveWhitelistMultiple(tbl)
    for _, id in pairs(tbl) do
        self:RemoveWhitelist(id)
    end
end


function SymmetryOCD:IsWhitelist(id)
    return not not SymmetryOCD.Whitelist[id];
end

-- local itemConfig = Isaac.GetItemConfig();
-- local maxCollectible = itemConfig:GetCollectibles().Size;
-- for id = CollectibleType.NUM_COLLECTIBLES, maxCollectible do
--     local config = itemConfig:GetCollectible(id);
--     if (config) then
--         -- Check Horizontal Symmtrical.
--         local symmetrical = THI:ScanHorizontalSymmtrical(config.GfxFileName);
--         if (symmetrical) then
--             Isaac.DebugString(config.Name);
--         end
--     end
-- end

local HasOCD = false;
local DisableOCD = false;

local function PostUpdate(mod)
    HasOCD = false;
    for p, player in Players.PlayerPairs() do
        if (player:GetTrinketMultiplier(SymmetryOCD.Trinket) > 0) then
            HasOCD = true;
            break;
        end
    end
end
SymmetryOCD:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)

local function PostGameStarted(mod, isContinued)
    HasOCD = false;
end
SymmetryOCD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, PostGameStarted)

local function PreGetCollectible(mod, pool, decrease, seed, loopCount)
    if (HasOCD and Game():GetFrameCount() > 0 and loopCount <= 1) then
        local itemPool = Game():GetItemPool();
        ItemPools:EvaluateRoomBlacklist();
        local result = itemPool:GetCollectible(pool, decrease, seed, CollectibleType.COLLECTIBLE_BREAKFAST);
        DisableOCD = true;
        ItemPools:EvaluateRoomBlacklist();
        DisableOCD = false;
        if (result ~= CollectibleType.COLLECTIBLE_BREAKFAST) then
            return result;
        end
    end
end
SymmetryOCD:AddPriorityCallback(CuerLib.Callbacks.CLC_PRE_GET_COLLECTIBLE, CallbackPriority.LATE + 100, PreGetCollectible)

local function EvaluateRoomBlacklist(mod, id, config)
    if (HasOCD and not DisableOCD) then
        return not SymmetryOCD:IsWhitelist(id);
    end
end
SymmetryOCD:AddCallback(CuerLib.Callbacks.CLC_EVALUATE_POOL_BLACKLIST, EvaluateRoomBlacklist)

return SymmetryOCD;