local Callbacks = CuerLib.Callbacks;
local Detection = CuerLib.Detection;

local SongOfNightbird = ModItem("Song of Nightbird", "SongOfNightbird");
SongOfNightbird.ConfusionRadius = 160

-- local function CheckCurse()
-- end

-- function SongOfNightbird:onNewRoom()
--     THI:EvaluateCurses();
-- end
-- SongOfNightbird:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SongOfNightbird.onNewRoom);

function SongOfNightbird:onPlayerUpdate(player)
    if (player:HasCollectible(SongOfNightbird.Item)) then
        for _, ent in pairs(Isaac.GetRoomEntities()) do
            if (ent:ToNPC()) then
                if (not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and not ent:HasEntityFlags(EntityFlag.FLAG_CONFUSION)) then
                    if (ent.Position:Distance(player.Position) >= SongOfNightbird.ConfusionRadius) then
                        ent:AddConfusion(EntityRef(player), 30, false);
                    end
                end
            end
        end
    end
end
SongOfNightbird:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, SongOfNightbird.onPlayerUpdate);



function SongOfNightbird:EvaluateCurse(curses)
    
    local game = THI.Game;
    local hasSong = false;
    local hasBlackCandle = false;
    for p, player in Detection.PlayerPairs() do
        if (player:HasCollectible(SongOfNightbird.Item)) then
            hasSong = true;
        end
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) or
            player:HasCollectible(CollectibleType.COLLECTIBLE_NIGHT_LIGHT)) then
            hasBlackCandle = true;
            goto checkCurse;
        end
    end


    ::checkCurse::
    if (hasSong and not hasBlackCandle) then
        return curses | LevelCurse.CURSE_OF_DARKNESS;
    end
end
SongOfNightbird:AddCustomCallback(CuerLib.CLCallbacks.CLC_EVALUATE_CURSE, SongOfNightbird.EvaluateCurse, 0, 0);

local damageLock = false;
function SongOfNightbird:onTakeDamage(tookDamage, amount, flags, source, countdown)
    
    if (tookDamage:ToNPC() and not damageLock) then
        
        if (flags & DamageFlag.DAMAGE_CLONES <= 0) then
            local allPlayersFarAway = true;
            local hasSong = false;
            for p, player in Detection.PlayerPairs() do
                
                if (player:HasCollectible(SongOfNightbird.Item)) then
                    hasSong = true;
                end

                if (tookDamage.Position:Distance(player.Position) < SongOfNightbird.ConfusionRadius) then
                    allPlayersFarAway = false;
                    goto checkDamage;
                end
            end

            ::checkDamage::
            
            if (hasSong and allPlayersFarAway) then
                damageLock = true;
                tookDamage:TakeDamage(amount * 1.5, flags, source, 0)
                damageLock = false;
                return false;
            end
        end
    end
end
SongOfNightbird:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_ENTITY_TAKE_DMG, SongOfNightbird.onTakeDamage);


function SongOfNightbird:postChange(player, item, diff)
    THI:EvaluateCurses();
end
SongOfNightbird:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_CHANGE_COLLECTIBLES, SongOfNightbird.postChange);

return SongOfNightbird;