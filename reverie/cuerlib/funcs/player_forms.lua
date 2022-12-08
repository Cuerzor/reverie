local Lib = LIB;
local Callbacks = Lib.Callbacks;
local Entities = Lib.Entities;

local PlayerForms = Lib:NewClass();
PlayerForms.CustomForms = {
}

local sfx = SFXManager();
local game = Game();
local config = Isaac.GetItemConfig();

function PlayerForms:GetPlayerData(player)
    local data = Lib:GetEntityLibData(player);
    data.CustomForms = data.CustomForms or {
        PreparedText = nil,
        CollectibleCount = 0,
        QueueingItem = -1,
        FormItemCount = {},
        GotForms = {}
    }
    return data.CustomForms;
end

function PlayerForms:IsFormCollectible(id)
    for form, value in pairs(self.CustomForms) do
        local count = 0;
        local pool = value.Pool;
        for _, poolItem in pairs(pool) do
            if (id == poolItem) then
                return true;
            end
        end
    end
    return false;
end

function PlayerForms:HasPlayerForm(player, id)
    local data = self:GetPlayerData(player);
    local got = data.GotForms;
    return got[id] == true;
end

function PlayerForms:GainForm(player, id) 
    local data = self:GetPlayerData(player);
    local got = data.GotForms;
    got[id] = true;
    local form = self.CustomForms[id];
    player:AddNullCostume(form.CostumeId);
    local getter = form.NameGetter;
    data.PreparedText = getter(Options.Language);
    SFXManager():Play(SoundEffect.SOUND_POWERUP_SPEWER);
end

function PlayerForms:LoseForm(player, id)
    local data = self:GetPlayerData(player);
    local got = data.GotForms;
    
    player:TryRemoveNullCostume(self.CustomForms[id].CostumeId);
    got[id] = false;
end

function PlayerForms:UpdateForm(player, form) 
    local data = self:GetPlayerData(player);
    local count = data.FormItemCount[form] or 0;

    if (count >= 3) then
        if (not self:HasPlayerForm(player, form)) then
            self:GainForm(player, form);
        end
    else
        if (self:HasPlayerForm(player, form)) then
            self:LoseForm(player, form);
        end
    end
end

function PlayerForms:onPlayerEffect(player)
    local data = PlayerForms:GetPlayerData(player);

    if (data.PreparedText ~= nil) then
        Game():GetHUD():ShowItemText(data.PreparedText);
        data.PreparedText = nil;
    end
end
PlayerForms:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PlayerForms.onPlayerEffect);

function PlayerForms:onPickCollectible(player, item, count, touched)
    -- if this collectible is not touched.
    if (not touched and player.Variant == 0) then
        local data = PlayerForms:GetPlayerData(player);

        -- Add 1 to counters of all forms including this item.
        for form, value in pairs(PlayerForms.CustomForms) do
            for _, poolItem in pairs(value.Pool) do
                if (poolItem == item) then
                    data.FormItemCount[form] = (data.FormItemCount[form] or 0) + count;
                    goto nextCycle;
                end
            end
            ::nextCycle::
            
            PlayerForms:UpdateForm(player, form);
        end
    end
end
PlayerForms:AddCustomCallback(Lib.CLCallbacks.CLC_POST_GAIN_COLLECTIBLE, PlayerForms.onPickCollectible)

function PlayerForms:onLoseCollectible(player, item, count)
    local collectible = config:GetCollectible(item);

    -- if this item is not an active.
    if (collectible.Type ~= ItemType.ITEM_ACTIVE and player.Variant == 0) then
        local data = PlayerForms:GetPlayerData(player);

        -- Remove 1 from counters of all forms including this item.
        for form, value in pairs(PlayerForms.CustomForms) do
            for _, poolItem in pairs(value.Pool) do
                if (poolItem == item) then
                    data.FormItemCount[form] = data.FormItemCount[form] - count;
                    goto nextCycle;
                end
            end
            ::nextCycle::
            
            PlayerForms:UpdateForm(player, form);
        end
    end
end
PlayerForms:AddCustomCallback(Lib.CLCallbacks.CLC_POST_LOSE_COLLECTIBLE, PlayerForms.onLoseCollectible)


return PlayerForms;