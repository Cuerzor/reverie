local MCM = ModConfigMenu;
local Mod = THI;
local ModName = Mod.Name;
local Version = Mod:GetVersionString();

if (MCM) then
    MCM.SetCategoryInfo(ModName, "A mod that contains Touhou character's items, trinkets, and bosses.")
    MCM.AddSpace(ModName, "Info");
    MCM.AddText(ModName, "Info", ModName)
    MCM.AddSpace(ModName, "Info")
    MCM.AddText(ModName, "Info", function() return "Version " .. Version end)
    MCM.AddSpace(ModName, "Info")
    MCM.AddText(ModName, "Info", "By Cuerzor")

    do  -- Lunatic.
        local boolean = MCM.AddBooleanSetting(
            ModName, 
            "Gameplay", --category
            "Lunatic", --attribute in table
            THI.IsLunatic(), --default value
            "Lunatic Mode", --display text
            { --value display text
                [true] = "On",
                [false] = "Off"
            },
            "Some items get nerfed in Lunatic mode.$newlineSee descriptions in EID for more infomation."
        );
        local setLunatic = THI.SetLunatic;
        THI.SetLunatic = function(value)
            setLunatic(value);
            MCM.Config[ModName]["Lunatic"] = value;
        end

        local onChange = boolean.OnChange;
        boolean.OnChange = function(currentValue) 
            onChange(currentValue);
            THI.SetLunatic(currentValue);
        end
    end

    do  -- Announcer
        local boolean = MCM.AddBooleanSetting(
            ModName, 
            "Gameplay", --category
            "Announcer", --attribute in table
            THI.AnnouncerEnabled(), --default value
            "Announcer", --display text
            { --value display text
                [true] = "On",
                [false] = "Off"
            },
            "Should game play announcer voice for mod's custom pocket items?"
        );
        local setAnnouncer = THI.SetAnnouncerEnabled;
        THI.SetAnnouncerEnabled = function(value)
            setAnnouncer(value);
            MCM.Config[ModName]["Announcer"] = value;
        end

        local onChange = boolean.OnChange;
        boolean.OnChange = function(currentValue) 
            onChange(currentValue);
            THI.SetAnnouncerEnabled(currentValue);
        end
    end

    do  -- Bosses
        -- Force Custom Boss.
        local boolean = MCM.AddBooleanSetting(
            ModName, 
            "Bosses", --category
            "ForceAltBosses", --attribute in table
            THI.Lib.Bosses:IsForceCustomBosses(), --default value
            "Force Alt Bosses", --display text
            { --value display text
                [true] = "Enabled",
                [false] = "Disabled"
            },
            "Should the game force alt-floor bosses to appear?"
        );

        local onChange = boolean.OnChange;
        boolean.OnChange = function(currentValue) 
            onChange(currentValue);
            THI.Lib.Bosses:SetForceCustomBosses(currentValue);
        end

        -- Enables.
        MCM.AddSpace(ModName, "Bosses")
        MCM.AddTitle(ModName, "Bosses", "Enables")
        for _, name in ipairs(THI.BossBlacklist.BossList) do
        
            local key = "Boss/"..name
            local boolean = MCM.AddBooleanSetting(
                ModName, 
                "Bosses", --category
                key, --attribute in table
                THI.IsBossEnabled(), --default value
                name, --display text
                { --value display text
                    [true] = "Enabled",
                    [false] = "Disabled"
                },
                "Should the boss \""..name.."\" appears?"
            );
            local setEnabled = THI.SetBossEnabled;
            THI.SetBossEnabled = function(name, value)
                setEnabled(name, value);
                local key = "Boss/"..name
                MCM.Config[ModName][key] = value;
            end
    
            local onChange = boolean.OnChange;
            boolean.OnChange = function(currentValue) 
                onChange(currentValue);
                THI.SetBossEnabled(name, currentValue);
            end
        end
    end


    if MCM.i18n == "Chinese" then
        MCM.SetCategoryNameTranslate(ModName, "幻想曲")
        MCM.SetSubcategoryNameTranslate(ModName, "Info","信息")
        MCM.SetSubcategoryNameTranslate(ModName, "Gameplay","游戏")
        MCM.SetSubcategoryNameTranslate(ModName, "Bosses","头目")
        
        MCM.SetCategoryInfoTranslate(ModName, "一个包含东方Project中人物道具、饰品和BOSS的MOD。")
        MCM.TranslateOptionsDisplayTextWithTable(ModName, "Info", {
            [ModName] = "幻想曲",
            ["By Cuerzor"] = "Cuerzor制作"
        })
        MCM.TranslateOptionsDisplayWithTable(ModName, "Info", {
            {"Version", "版本"}
        })
        MCM.TranslateOptionsDisplayWithTable(ModName, "Gameplay", {
            { "Lunatic Mode", "疯狂模式"},
            { "Announcer", "卡牌符文语音"},
            { "On", "开"},
            { "Off", "关"},
        })
        MCM.TranslateOptionsInfoTextWithTable(ModName, "Gameplay",{
            ["Some items get nerfed in Lunatic mode.$newlineSee descriptions in EID for more infomation."] = 
            "一些道具会在疯狂模式被削弱。$newline更多信息请见EID图鉴MOD。",
            ["Should game play announcer voice for mod's custom pocket items?"] = 
            "是否在使用MOD自定义卡牌、符文时播放语音？",
        });

        local bossChineseNames = {
            ["The Abandoned"] = "遗忘伞",
            ["Necrospyder"] = "尸变蛛",
            ["The Centipede"] = "大百足",
            ["Pyroplume"] = "火羽",
            ["The Summoner"] = "召唤者",
            ["Devilcrow"] = "恶魔鸦",
            ["Guppet"] = "嗝屁猫偶",
            ["Reverie"] = "幻想曲",
            ["Doremy"] = "哆来咪"
        }
        MCM.TranslateOptionsDisplayTextWithTable(ModName, "Bosses", {
            ["Enables"] = "启用",
        })
        local bossDisplayTranslationTable = {
            {"Enabled", "启用"},
            {"Disabled","禁用"},
            {"Force Alt Bosses","强制支线头目"},
        }
        for key, name in pairs(bossChineseNames) do
            table.insert(bossDisplayTranslationTable, {key, name});
        end
        MCM.TranslateOptionsDisplayWithTable(ModName, "Bosses", bossDisplayTranslationTable)

        local bossInfoTranslationTable = {
            ["Should the game force alt-floor bosses to appear?"] = 
            "是否强制支线层的MOD头目出现?"
        }
        for key, name in pairs(bossChineseNames) do
            local descKey = "Should the boss \""..key.."\" appears?"
            local descName = "是否出现头目\""..name.."\"?"
            bossInfoTranslationTable[descKey] = descName;
        end
        MCM.TranslateOptionsInfoTextWithTable(ModName, "Bosses", bossInfoTranslationTable);
    end

    
    local function PostGameStarted(mod, continued)
        THI.Lib.Bosses:SetForceCustomBosses(MCM.Config[ModName]["ForceAltBosses"]);
    end
    THI:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, PostGameStarted)
end