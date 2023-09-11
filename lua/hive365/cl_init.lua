local streamUrl = "https://stream.hive365.radio/listen/hive365/radio.mp3"
local Music

local last_rated_song = CreateClientConVar("last_rated_song", "none", true, true)
local last_rated_dj = CreateClientConVar("last_rated_dj", "none", true, true)
local time_shout = CreateClientConVar("time_shout", "0", true, true)
local time_req = CreateClientConVar("time_req", "0", true, true)

local hive_ignore = CreateClientConVar("hive_ignore", "false", true, true)
local hive_tuned = CreateClientConVar("hive_tuned", "false", false, true)
local hive_volume = CreateClientConVar("hive_volume", "20", false, false)

local RPanel

function HiveMenu()
    if RPanel == nil then
        RPanel = vgui.Create( "DFrame" ) -- Creates the frame itself
        RPanel:SetSize( 300, 400 ) -- Size of the frame
        RPanel:SetTitle( "Hive365" ) -- Title of the frame
        RPanel:SetVisible( true )
        RPanel:SetDraggable( true ) -- Draggable by mouse?
        RPanel:ShowCloseButton( true ) -- Show the close button?
        RPanel:MakePopup() -- Show the frame
        RPanel:Center()
        RPanel:MakePopup()
        RPanel:SetDeleteOnClose(false)
        
        local PropertySheet = vgui.Create( "DPropertySheet" )
        PropertySheet:SetParent( RPanel )
        PropertySheet:SetPos( 10, 30 )
        PropertySheet:SetSize( RPanel:GetWide() - 20, RPanel:GetTall() - 40 )

        local SheetItem = vgui.Create( "DPanel" )
        SheetItem:SetPos( 0, 0 )
        SheetItem:SetSize( PropertySheet:GetWide() - 4, PropertySheet:GetTall() - 22 )
        SheetItem.Paint = function() -- Paint function
        surface.SetDrawColor( 50, 50, 50, 255 ) -- Set our rect color below us; we do this so you can see items added to this panel
        surface.DrawRect( 0, 0, SheetItem:GetWide(), SheetItem:GetTall() ) -- Draw the rect
        end
        
        PropertySheet:AddSheet( "Settings", SheetItem, "icon16/sound.png", false, false, "Radio settings" )
        
        local VolumeSlide = vgui.Create( "DNumSlider", SheetItem )
        VolumeSlide:SetSize( 275, 50 ) -- Keep the second number at 100
        VolumeSlide:SetPos(1, 0)
        VolumeSlide:SetText( "Stream Volume" )
        VolumeSlide:SetMin( 0 ) -- Minimum number of the slider
        VolumeSlide:SetMax( 100 ) -- Maximum number of the slider
        VolumeSlide:SetDecimals( 0 ) -- Sets a decimal. Zero means it's a whole number
        
        VolumeSlide:SetConVar("hive_volume")
        -- VolumeSlide:SetValue(volume)
        -- VolumeSlide.ValueChanged = function(pSelf, fValue)
            -- RunConsoleCommand("hive_volume",fValue)
            -- pSelf:SetValue(fValue)
        -- end
        
        
        width = SheetItem:GetWide()
        local TuneButton = vgui.Create( "DButton", SheetItem)
        TuneButton:SetSize(width, 30)
        TuneButton:SetPos(1, 50)
        
        if hive_tuned:GetBool() then
            TuneButton:SetText( "Tune out" )
        else
            TuneButton:SetText( "Tune in" )
        end
        TuneButton.DoClick = function(button)
            RunConsoleCommand("hive_tune")
            if !hive_tuned:GetBool() then
                button:SetText( "Tune out" )
            else
                button:SetText( "Tune in" )
            end
        end
        
        y = 80
        width = SheetItem:GetWide()/2
        height = 30
        local CButton = vgui.Create( "DButton", SheetItem)
        CButton:SetSize(width, height)
        CButton:SetPos(1, y)
        CButton:SetText("Choon")
        CButton.DoClick = function(button)
            net.Start("sendstuff")
            net.WriteString("!choon")
            net.SendToServer()
        end
        local PButton = vgui.Create( "DButton", SheetItem)
        PButton:SetSize(width, height)
        PButton:SetPos(width, y)
        PButton:SetText("Poon")
        PButton.DoClick = function(button)
            net.Start("sendstuff")
            net.WriteString("!poon")
            net.SendToServer()
        end
        y = y + height
        
        height = 25
        width = 50
        
        RFunc = function(entry)
            ntime = time_req:GetInt()+60*3
            if entry:GetValue()!="" then
                net.Start("sendstuff")
                net.WriteString("!request "..entry:GetValue())
                net.SendToServer()
                if os.time()>ntime then
                    entry:SetValue("")
                end
            end
        end
        SFunc = function(entry)
            ntime = time_shout:GetInt()+60*3
            if entry:GetValue()!="" then
                net.Start("sendstuff")
                net.WriteString("!shoutout "..entry:GetValue())
                net.SendToServer()
                if os.time()>ntime then
                    entry:SetValue("")
                end
            end
        end
        
        local REntry = vgui.Create( "DTextEntry", SheetItem )	-- create the form as a
        REntry:SetPos( width, y )
        REntry:SetSize(SheetItem:GetWide()-width, height)
        REntry:SetEnterAllowed(true)
        REntry.OnEnter = function()
            RFunc(REntry)
        end
        local RButton = vgui.Create( "DButton", SheetItem)
        RButton:SetSize(width, height)
        RButton:SetPos(1, y)
        RButton:SetText("Request")
        RButton.DoClick = function(button)
            RFunc(REntry)
        end
        
        y = y + height
        
        local SEntry = vgui.Create( "DTextEntry", SheetItem )	-- create the form as a
        SEntry:SetPos( width, y )
        SEntry:SetSize(SheetItem:GetWide()-width, height)
        SEntry:SetEnterAllowed(true)
        SEntry.OnEnter = function()
            SFunc(SEntry)
        end
        local SButton = vgui.Create( "DButton", SheetItem)
        SButton:SetSize(width, height)
        SButton:SetPos(1, y)
        SButton:SetText("Shoutout")
        SButton.DoClick = function(button)
            SFunc(SEntry)
        end
        
        y = y + height
        
        width = SheetItem:GetWide()
        local FTWButton = vgui.Create( "DButton", SheetItem)
        FTWButton:SetSize(width, 30)
        FTWButton:SetPos(1, y)
        FTWButton:SetText("Dj FTW")
        FTWButton.DoClick = function(button)
            net.Start("sendstuff")
            net.WriteString("!djftw")
            net.SendToServer()
        end
    else
        RPanel:SetVisible(true)
    end
end

function rValid()
    ret = false;
    if Music != nil then
        if Music:IsValid() then
            ret = true
        end
    end
    
    return ret
end

function TuneIn ()
    if rValid() then
        Music:Stop()
    end
    
    sound.PlayURL(streamUrl,"play",
        function(chan)
            if chan !=nil then
                Music = chan
                Music:SetVolume(hive_volume:GetInt() / 100)
            end
        end
    )
    
    RunConsoleCommand("hive_tuned", 1)
    
    chat.AddText("You are now tuned in =D")
end

function TuneOut ()
    if rValid() then
        Music:Stop();
    end
    RunConsoleCommand("hive_tuned", 0)
    
    chat.AddText("You are now tuned out :(")
end

cvars.AddChangeCallback( "hive_volume", function( convar_name, value_old, value_new )
    vol = tonumber(value_new)
    if (vol!=nil && vol>=1) && (vol<= 100) then
    
        if rValid() then
            Music:SetVolume(vol / 100)
        end
        
    end
end )

function HiveTune(ply, command, args)
    if hive_tuned:GetBool() then
        TuneOut()
    else
        TuneIn()
    end
end

concommand.Add("hive_tune", HiveTune)
concommand.Add("hive_menu", HiveMenu)

if hive_tuned:GetBool() then
    TuneIn()
end

-- local function KeyPress()
    -- if input.IsKeyDown(KEY_F3) then
        -- RunConsoleCommand("hive_menu")
    -- end
-- end
 
-- hook.Add("Think","BM - Clients - Key",KeyPress)


hook.Add("PostCleanupMap", "CleanupFix", function()
    if hive_tuned:GetBool() then
        if rValid() then
            Music:Play()
        else
            sound.PlayURL(streamUrl, "play", function(chan)
                if chan !=nil then
                    Music = chan
                    Music:SetVolume(hive_volume:GetInt() / 100)
                end
            end)
        end
    end
end)
