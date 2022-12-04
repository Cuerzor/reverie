local HoldingActive = CuerLib.HoldingActive;
local Math = CuerLib.Math
local Mallet = ModItem("Miracle Mallet Replica", "Miracle Mallet Replica")



local Hammer80Mode = false;
function Mallet:Hammer(player, direction)
    THI.SFXManager:Play(SoundEffect.SOUND_SHELLGAME);
    if (Hammer80Mode) then
        THI.SFXManager:Play(THI.Sounds.SOUND_HAMMER_80);
    end
    local subType = Math.GetDirectionByAngle(direction:GetAngleDegrees());
    local pos = player.Position+ direction * 40;
    local Effect = THI.Effects.MiracleMalletReplica;
    local mallet = Isaac.Spawn(Effect.Type, Effect.Variant, subType, pos, Vector.Zero, player);
    mallet.Parent = player;
end
Mallet:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_RELEASE_HOLDING_ACTIVE, function(mod, player, item, direction)
    Mallet:Hammer(player, direction)
end, Mallet.Item)


local function UseMallet(mod, item, rng, player, flags, slot, varData)
    if (flags & UseFlag.USE_CARBATTERY <= 0) then
        return HoldingActive:SwitchHolding(item, player, slot, flags);
    end
    return {Discharge = false}
end
Mallet:AddCallback(ModCallbacks.MC_USE_ITEM, UseMallet, Mallet.Item);

local function PostPlayerEffect(mod, player)
    HoldingActive:ReleaseOnShoot(player, Mallet.Item);
end
Mallet:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect);

local function PostFamiliarKill(mod, ent)
    if (ent.Variant == FamiliarVariant.WISP and ent.SubType == Mallet.Item) then
        local familiar = ent:ToFamiliar()
        if (familiar) then
            local player = familiar.Player;
            local shockwave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, ent.Position, Vector.Zero, player);
            shockwave.Parent = player;
        end
    end
end
Mallet:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostFamiliarKill, EntityType.ENTITY_FAMILIAR);


local function ExecuteCommand(mod, cmd, param)
    if (cmd == "thsecret") then
        if (param == "hammer80") then
            Hammer80Mode = not Hammer80Mode;
            if (Hammer80Mode) then
                print("[Reverie] Miracle Mallet Replica's secret is now on!")
            else
                print("[Reverie] Miracle Mallet Replica's secret is now off!")
            end
        end
    end
end
Mallet:AddCallback(ModCallbacks.MC_EXECUTE_CMD, ExecuteCommand);


local function PostGameStarted(mod, isContinued)
    Hammer80Mode = false;
end
Mallet:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, PostGameStarted);


return Mallet;