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



    if MCM.i18n == "Chinese" then
        MCM.SetCategoryNameTranslate(ModName, "幻想曲")
        MCM.SetSubcategoryNameTranslate(ModName, "Info","信息")
        MCM.SetSubcategoryNameTranslate(ModName, "Gameplay","游戏")
        
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
    end
end