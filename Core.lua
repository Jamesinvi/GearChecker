local slots={
INVTYPE_AMMO		= 0,
INVTYPE_HEAD 		= 1, INVTYPE_FIRST_EQUIPPED = INVTYPE_HEAD,
INVTYPE_NECK		= 2,
INVTYPE_SHOULDER	= 3,
INVTYPE_BODY		= 4,
INVTYPE_CHEST		= 5,
INVTYPE_WAIST		= 6,
INVTYPE_LEGS		= 7,
INVTYPE_FEET		= 8,
INVTYPE_WRIST		= 9,
INVTYPE_HAND		= 10,
INVTYPE_FINGER1		= 11,
INVTYPE_FINGER2		= 12,
INVTYPE_TRINKET1	= 13,
INVTYPE_TRINKET2	= 14,
INVTYPE_BACK		= 15,
INVTYPE_MAINHAND	= 16,
INVTYPE_OFFHAND		= 17,
INVTYPE_RANGED		= 18,
INVTYPE_TABARD		= 19,
};


--IMPORTANT VARIABLES 
local lootTable={};
local f;
local clearLoot;
local scrollContainer;
local scroll;

--LIBRARY STUFF
CustomTooltip=CreateFrame("GameTooltip", "Tooltip", nil, "GameTooltipTemplate" );
GearChecker = LibStub("AceAddon-3.0"):NewAddon("GearChecker", "AceConsole-3.0", "AceEvent-3.0");

local AceGUI= LibStub("AceGUI-3.0");
local icon = LibStub("LibDBIcon-1.0");


local GearCheckerLDB = LibStub("LibDataBroker-1.1"):NewDataObject("GearChecker", {
    type = "data source",
    text = "GearChecker",
    icon = "Interface\Icons\INV_Chest_Cloth_17",
    OnClick = function() 
        if f:IsShown() then
            f:Hide();
            f:ReleaseChildren();
            collectgarbage("collect") -- Force garbage collection

        else
            f:ReleaseChildren();
            scroll:ReleaseChildren();
            GearChecker:CreateBaseFrame();
            RedrawButtons();
            collectgarbage("collect") -- Force garbage collection

        end
    end,
    })
    


function GearChecker:CreateBaseFrame()
    -- Create a container frame
    f = AceGUI:Create("Frame")
    f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)
    f:SetTitle("GearChecker")
    f:SetStatusText("Status Bar")
    f:SetLayout("Flow")
    
    scrollContainer = AceGUI:Create("SimpleGroup");-- "InlineGroup" is also good
    scrollContainer:SetFullWidth(true);
    scrollContainer:SetFullHeight(true); -- probably?
    scrollContainer:SetLayout("Fill"); -- important!


    scroll = AceGUI:Create("ScrollFrame");
    scroll:SetLayout("Flow"); -- probably?
    scrollContainer:AddChild(scroll);


    clearLoot=AceGUI:Create("Button");
    clearLoot:SetText("ClearLoot");
    clearLoot:SetCallback("OnClick", ClearLootTable);
    dumpLoot=AceGUI:Create("Button");
    dumpLoot:SetText("Dump Loot Table to chat");
    dumpLoot:SetCallback("OnClick", function()             
        for btn, val in ipairs(lootTable) do
            GearCheck:Print(val.link);
        end
    end);
    f:AddChild(clearLoot);
    f:AddChild(dumpLoot);
    f:AddChild(scrollContainer);



end
--ADDON EVENT HANDLERS
function GearChecker:OnInitialize()
    -- Called when the addon is loaded
    GearChecker:RegisterEvent("CHAT_MSG_LOOT");
    GearChecker:CreateBaseFrame();
    self.db = LibStub("AceDB-3.0"):New("GearCheckerDB", { profile = { minimap = { hide = false, }, }, });
    icon:Register("GearChecker", GearCheckerLDB, self.db.profile.minimap) self:RegisterChatCommand("gc", "OnChatCommand");
end
function GearChecker:OnChatCommand()
    self.db.profile.minimap.hide = not self.db.profile.minimap.hide 
    if self.db.profile.minimap.hide then 
        icon:Hide("GearChecker") else icon:Show("GearChecker!") 
    end 
end
function GearChecker:OnEnable()
    -- Called when the addon is enabled
end

function GearChecker:OnDisable()
    -- Called when the addon is disabled
end



--LOOT HANDLER, when somebody loots, request data then create a button
function GearChecker:CHAT_MSG_LOOT(...)
    local _, lootstring, player, _,player2 =...;
    local itemLink = string.match(lootstring,"(|H(.+)|h)");
    local _, ID = strsplit(":", itemLink);
    local item = Item:CreateFromItemID(tonumber(ID));
    
    item:ContinueOnItemLoad(function()
        local name, link, _, ilvl, _, _, _, _, itemSlot, texture=GetItemInfo(itemLink);
        CreateButton(player,name,link,ilvl,itemSlot,texture,true);
    end)
end
--clears the loot table and redraws all buttons
function ClearLootTable()
    scroll:ReleaseChildren();
    GearChecker:Print("Cleared Loot Table");
    for k in pairs (lootTable) do
        lootTable [k] = nil
    end
    RedrawButtons();
end
--CREATES BUTTON and adds it to the frame, also handles tooltips
function CreateButton(player, name, link, ilvl, itemSlot, texture, insertFlag)
    local btn = AceGUI:Create("Icon");


    btn:SetWidth(64);
    btn:SetImage(texture);
    btn:SetImageSize(64,64);
    btn:SetLabel(player);
    btn:SetCallback("OnClick", function()
        local slot=slots[itemSlot];
        GearChecker:Print("Item slot: ",slot);
        GearChecker:Print("Currently Equipped: ",GetInventoryItemLink("player",slot));
    end);
    btn:SetCallback("OnEnter", function(self)
        CustomTooltip:SetOwner(btn.frame, "ANCHOR_TOPRIGHT"); --Set our button as the tooltip's owner and attach it to the top right corner of the button.
        CustomTooltip:SetHyperlink(link); --Set the tooltip's text using the default RGBA values (fully opaque gold text) with text wrapping on.
        members= GetNumGroupMembers();
        if members>0 then
            for i=1,members do
                local name, _, _, _, class=GetRaidRosterInfo(i);
                CustomTooltip:AddLine(name ..  "score: " ..10);
            end
        else
            CustomTooltip:AddLine("You are not in a group " .. UnitName("player") .. " :" .. 10);
        end
        CustomTooltip:Show(); --Show the tooltip
    end);
    btn:SetCallback("OnLeave", function(self)
        CustomTooltip:Hide();
    end)





    scroll:AddChild(btn);
    itemToStore={
        player=player,
        name=name,
        link=link,
        ilvl=ilvl,
        itemSlot=itemSlot,
        texture=texture
    }
    if(insertFlag==true) then 
        table.insert(lootTable, itemToStore);
    end
end

--REDRAWS ALL BUTTONS
function RedrawButtons()
    for btn, val in ipairs(lootTable) do
        CreateButton(val.player, val.name, val.link, val.ilvl, val.itemSlot, val.texture,false);
    end
end

