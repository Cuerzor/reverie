-- From External Item Descriptions.
local questionMarkSprite = Sprite()
questionMarkSprite:Load("gfx/005.100_collectible.anm2",true)
questionMarkSprite:ReplaceSpritesheet(1,"gfx/items/collectibles/questionmark.png")
questionMarkSprite:LoadGraphics()

function THI:CheckUnknownItem(pickup)

	local entitySprite = pickup:GetSprite()
	local name = entitySprite:GetAnimation()

	if name ~= "Idle" and name ~= "ShopIdle" then
		return false
	end
	
	questionMarkSprite:SetFrame(name,entitySprite:GetFrame())
	-- Quickly check some points in entitySprite to not need to check the whole sprite
	-- We check the range from Y -40 to 10 in 3 pixel steps and also X -1 to 1.  GetTexel() gets the color value of a sprite at a given location. the center of the sprite is here in the Pivot point of the sprite in the anm2 file. 
	-- therefore we go negative 40 pixels up to read the sprite as it is on a pedestal. We also look 10 pixel down to make comparing shop items more accurate
	for i = -1,1,1 do
		for j = -40,10,5 do
			local qcolor = questionMarkSprite:GetTexel(Vector(i,j),Vector.Zero,1,1)
			-- Used for chest item check.
			local chestcolor = questionMarkSprite:GetTexel(Vector(i,j + 5),Vector.Zero,1,1)
			local ecolor = entitySprite:GetTexel(Vector(i,j),Vector.Zero,1,1)
			if (qcolor.Red ~= ecolor.Red or qcolor.Green ~= ecolor.Green or qcolor.Blue ~= ecolor.Blue) and
				(chestcolor.Red ~= ecolor.Red or chestcolor.Green ~= ecolor.Green or chestcolor.Blue ~= ecolor.Blue) then
				-- it is not same with question mark sprite
				return false
			end
		end
	end
	return true
end


function THI:IsUnknownItem(pickup)
    local data = pickup:GetData();
    if (data._REVERIE_UNKNOWN_ITEM == nil) then
        data._REVERIE_UNKNOWN_ITEM = self:CheckUnknownItem(pickup);
    end
    return data._REVERIE_UNKNOWN_ITEM;
end



function THI:UnknownItemUpdate(pickup)
    if (pickup:IsFrame(45, 0)) then
        local data = pickup:GetData(); 
        if (data._REVERIE_UNKNOWN_ITEM) then
            data._REVERIE_UNKNOWN_ITEM = self:CheckUnknownItem(pickup);
        end
    end
end
THI:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, THI.UnknownItemUpdate, PickupVariant.PICKUP_COLLECTIBLE);


-- local testQuestionSpr = Sprite()
-- testQuestionSpr:Load("gfx/005.100_collectible.anm2",true)
-- testQuestionSpr:ReplaceSpritesheet(1,"gfx/items/collectibles/questionmark.png")
-- testQuestionSpr:LoadGraphics()

-- function THI:UnknownItemRenderTest(pickup, offset)
    
-- 	local entitySprite = pickup:GetSprite()
-- 	local name = entitySprite:GetAnimation()
-- 	questionMarkSprite:SetFrame(name,entitySprite:GetFrame())
-- 	entitySprite:Render(Isaac.WorldToScreen(pickup.Position + Vector(40, 0)) + offset);
-- 	questionMarkSprite:Render(Isaac.WorldToScreen(pickup.Position + Vector(80, 0)) + offset);
-- end
-- THI:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, THI.UnknownItemRenderTest, PickupVariant.PICKUP_COLLECTIBLE);