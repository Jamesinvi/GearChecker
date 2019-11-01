-- SLASH_RELOADUI1 ="/rl";
-- SlashCmdList.SLASH_RELOADUI=ReloadUI;
-- SLASH_FRAMESTK1="/fs"
-- SlashCmdList.FRAMESTK=fuction()
--   LoadAddOn("Blizzard_DebugTools");
--   FrameStackTooltip_Toggle()
-- end

-------------------------------------------------------


local CheckerUI=CreateFrame("Frame","GearCheckerFrame",UIParent,"BasicFrameTemplateWithInset", "MovableTemplate");


CheckerUI:SetSize(400,400);
CheckerUI:SetPoint("Right");
CheckerUI:SetMovable(true);

CheckerUI:RegisterEvent("ITEM_PUSH");
CheckerUI:RegisterEvent("BOSS_KILL");
CheckerUI:RegisterEvent('GET_ITEM_INFO_RECEIVED')
CheckerUI:RegisterEvent("CHAT_MSG_LOOT");
CheckerUI:RegisterEvent("LOOT_OPENED");
CheckerUI:RegisterEvent('PLAYER_ENTERING_WORLD')
CheckerUI:RegisterEvent('TRADE_ACCEPT_UPDATE')



--TITLE
CheckerUI.title=CheckerUI:CreateFontString(nil,"OVERLAY","GameFontHighlight");
CheckerUI.title:SetPoint("LEFT",CheckerUI.TitleBg,"LEFT",5,0);
CheckerUI.title:SetText("GearChecker");


-- CLOSE BUTTON
CheckerUI.cancelButton=CreateFrame("Button",nil,CheckerUI,"GameMenuButtonTemplate");
CheckerUI.cancelButton:SetPoint("BOTTOM",CheckerUI,"BOTTOM",0,15);
CheckerUI.cancelButton:SetSize(120,30);
CheckerUI.cancelButton:SetText("Close");
CheckerUI.cancelButton:SetNormalFontObject("GameFontNormalLarge");


lootButtons={};
index=0;

print(index);


MyGameTooltip=CreateFrame( "GameTooltip", "Tooltip", nil, "GameTooltipTemplate" ); -- Tooltip name cannot be nil

function eventHandler(self, event, ...)
    if event=="CHAT_MSG_LOOT" then
        local lootstring, _, _, _, player=...;
        local itemLink = string.match(lootstring,"(|H(.+)|h)");
        print(player .. " Got This: " .. itemLink);
        --local item1 = GetInventoryItemLink("player", GetInventorySlotInfo("TRINKET0SLOT"));
        --print(item1);
        CreateLootIcon(itemLink,index);
        --lootButton=CreateLootIcon(itemLink,index);
        index=index+1;
        print(index);


    end
end
function CreateLootIcon(item,index)
    --ITEM DROPPED CREATE A BUTTON
    local position=0+(index * 64);
    droppedItem=CreateFrame("Button",nil, CheckerUI, "GameMenuButtonTemplate");
    droppedItem:SetPoint("CENTER", CheckerUI, "CENTER", 0 + (index*64), (index*64));
    droppedItem:SetSize(64,64);
    droppedItem:SetNormalFontObject("GameFontNormalLarge");
    local name, link, _, ilvl, _, _, _, _, _, texture=GetItemInfo(item);
    droppedItem:SetNormalTexture(texture);
    droppedItem:SetText(link);
    droppedItem:SetScript("OnEnter", function(self)
        MyGameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT"); --Set our button as the tooltip's owner and attach it to the top right corner of the button.
        MyGameTooltip:SetHyperlink(link); --Set the tooltip's text using the default RGBA values (fully opaque gold text) with text wrapping on.
        MyGameTooltip:Show(); --Show the tooltip
    end);
    droppedItem:SetScript("OnLeave", function(self)
        MyGameTooltip:Hide();
    end)
    return droppedItem;
end
function CreateButton(size,x,y,index)

end


CheckerUI:SetScript("OnEvent", eventHandler);
