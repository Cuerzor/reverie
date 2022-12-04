local Dream = GensouDream;
local Detection = CuerLib.Detection;
local Choice = {
    Type = Isaac.GetEntityTypeByName("Doremy Nightmare Choice"),
    Variant = Isaac.GetEntityVariantByName("Doremy Nightmare Choice"),
    SubType = 0
}
Choice.Color = Color(0.53, 0.65, 0.79, 1, 0, 0 ,0)

local function PostEffectInit(mod, effect)
    effect:SetColor(Choice.Color, -1, 0);
    effect.TargetPosition = effect.Position;
    local spr = effect:GetSprite();
    spr:Play(Dream:GetAnimationNameBySpellID(effect.SubType));
    effect:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE);
end
Dream:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, Choice.Variant);

function Choice:OnTouch(effect)
    Dream:StartSpellCard(effect.SubType);
    
    local parent = effect.Parent;
    for i, ent in ipairs(Isaac.FindByType(Choice.Type, Choice.Variant)) do
        if (not Detection.CompareEntity(ent, effect) and Detection.CompareEntity(ent.Parent, effect.Parent)) then
            ent:ToEffect().State = 2;
        end
    end

    -- Make Dream Catcher Red.
    if (parent) then
        local DreamCatcher = Dream.Effects.DreamCatcher;
        DreamCatcher:TurnRed(parent);
    end

    Game():ShakeScreen(30);

    effect:Remove();
    local Star = Dream.Effects.DreamStar;
    for i = 1, 10 do
        local vel = RandomVector() * (Random() % 100 / 100 * 20 + 20);
        local star = Isaac.Spawn(Star.Type, Star.Variant, Star.SubType, effect.Position, vel, effect):ToEffect();
        local starData = star:GetData();
        starData.StarAcceleration = 0.9;
        star.SpriteOffset = effect.SpriteOffset;
    end
    SFXManager():Play(THI.Sounds.SOUND_TOUHOU_CHARGE_RELEASE);
end

local function PostEffectUpdate(mod, effect)
    local y = math.sin(math.rad(effect.FrameCount * 3));
    y = y * 5 - 10;
    if (effect.State == 0) then
        effect.SpriteOffset = Vector(0, y);

        local touched = false;
        for _, ent in ipairs(Isaac.FindInRadius(effect.Position, effect.Size, EntityPartition.PLAYER)) do
            local player = ent:ToPlayer();
            -- Avoid Tainted Forgotten from touching this.
            if (player:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN_B) then
                touched = true;
                break;
            end
        end
        local choiceCount = 0;
        for i, ent in ipairs(Isaac.FindByType(Choice.Type, Choice.Variant)) do
            if (Detection.CompareEntity(ent.Parent, effect.Parent)) then
                choiceCount = choiceCount + 1;
            end
        end
        if (touched or choiceCount <= 1) then
            Choice:OnTouch(effect);
        end

    elseif (effect.State == 1) then


        local offset = Vector(0, effect.SpriteOffset.Y);
        offset.Y = (offset.Y - y) * 0.9 + y;
        effect.SpriteOffset = offset;
        if (math.abs(offset.Y - y) < 1) then
            effect.State = 0;
        end
    elseif (effect.State == 2) then
        local scale = Vector(effect.SpriteScale.X * 0.8, effect.SpriteScale.Y * 1.2);
        effect.SpriteScale = scale;
        if (effect.SpriteScale.X <= 0.05) then
            effect:Remove();
        end
    end


    local frame = 45 - effect.FrameCount;
    local pos = effect.TargetPosition;
    if (frame >= 0) then
        local center = effect.Position;
        if (effect.Parent) then
            center = effect.Parent.Position;
        end
        local targetPos = effect.TargetPosition;
        local target2Center = targetPos - center;
        local angle = target2Center:GetAngleDegrees();
        local dis = target2Center:Length();
        angle = angle - (frame / 2) ^ 2;

        pos = center + Vector.FromAngle(angle) * dis;
    end
    effect.Velocity = pos - effect.Position;

    local data = effect:GetData();
    if (not data.StarRNG) then
        local rng = RNG();
        rng:SetSeed(effect.InitSeed, 1);
        data.StarRNG = rng;
    end
    if (effect:IsFrame(10,0)) then
        local rng = data.StarRNG;
        local Star = Dream.Effects.DreamStar;
        local vel = Vector.FromAngle(rng:RandomFloat() * 360) * (rng:RandomFloat() * 5 + 5);
        local star = Isaac.Spawn(Star.Type, Star.Variant, Star.SubType, effect.Position, vel, effect):ToEffect();
        local seed = star.InitSeed;
        local starData = star:GetData();
        starData.StarRotation = rng:RandomFloat() * 8;
        star.SpriteOffset = effect.SpriteOffset;
    end
end
Dream:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, Choice.Variant);


return Choice;