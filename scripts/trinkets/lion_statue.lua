local Stats = CuerLib.Stats;
local Detection = CuerLib.Detection;
local LionStatue = ModTrinket("Lion Statue", "LionStatue");

function LionStatue:PostNewRoom()
    local game = THI.Game;
    local room = game:GetRoom();
    if (room:IsFirstVisit()) then
        local multiplier = 0;
        for i, player in Detection.PlayerPairs() do
            multiplier = multiplier + player:GetTrinketMultiplier(LionStatue.Trinket);
        end

        if (multiplier > 0) then
            local width = room:GetGridWidth();
            local size = room:GetGridSize();
            local statues = {};
            for i = 0, size - 1 do
                local gridEnt = room:GetGridEntity(i);
                if (gridEnt and gridEnt:GetType() == GridEntityType.GRID_STATUE and gridEnt:GetVariant() == 1) then
                    table.insert(statues, i);
                end
            end

            
            for _, index in pairs(statues) do
                local times = multiplier;
                local x = index % width;
                for dir = 1, 4 do
                    local offset = 0;
                    if (dir == 1) then
                        offset = -width;
                    elseif (dir == 2) then
                        offset = width;
                    elseif (dir == 3) then
                        offset = 1
                        if (x < width / 2) then
                            offset = -1
                        end
                    elseif (dir == 4) then
                        offset = -1
                        if (x < width / 2) then
                            offset = 1
                        end
                    end


                    local sideGridIdx = index + offset;
                    local sideGridEnt = room:GetGridEntity(sideGridIdx);
                    if (not sideGridEnt or 
                    sideGridEnt:GetType() == GridEntityType.GRID_DECORATION or 
                    sideGridEnt:GetType() == GridEntityType.GRID_SPIDERWEB) then
                        if (room:SpawnGridEntity (sideGridIdx, GridEntityType.GRID_STATUE, 1, Random(), 0)) then
                            times = times - 1;
                            if (times <= 0) then
                                goto nextStatue;
                            end
                        end
                    end
                end
                ::nextStatue::
            end
        end
    end
end
LionStatue:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, LionStatue.PostNewRoom);

return LionStatue;