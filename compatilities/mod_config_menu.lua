local MCM = ModConfigMenu;
local Mod = THI;
local ModName = Mod.Name;
local Version = Mod:GetVersionString();

if (MCM) then
    MCM.AddSpace(ModName, "Info");
    MCM.AddText(ModName, "Info", function() return ModName end)
    MCM.AddSpace(ModName, "Info")
    MCM.AddText(ModName, "Info", function() return "Version " .. Version end)
    MCM.AddSpace(ModName, "Info")
    MCM.AddText(ModName, "Info", function() return "By Cuerzor" end)

    
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
    local onChange = boolean.OnChange;
    boolean.OnChange = function(currentValue) 
        onChange(currentValue);
        THI.SetLunatic(currentValue);
    end
end