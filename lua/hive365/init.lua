local pref = "[Hive365]"
local version = "1.1"

CreateConVar("hive_start_tuned", 0, {FCVAR_ARCHIVE})
CreateConVar("gmod_hive365radio_version", version, {FCVAR_REPLICATED,FCVAR_NOTIFY,FCVAR_DONTRECORD}, "Hive365 Radio Plugin Version");

CreateConVar("hive_last_song", "")
local hive_last_song = ""
CreateConVar("hive_last_dj", "")
local hive_last_dj = ""

util.AddNetworkString("sendstuff")

function enc(dat)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = dat..""
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function SendChat(ply, text)
    ply:PrintMessage(HUD_PRINTTALK, pref .. " " .. text)
end

function BroadChat (text)
    for key,ply in pairs(player:GetHumans()) do
        if ply:GetInfo("hive_ignore")!="true" then
            SendChat(ply, text)
        end
    end
end

local commands = {
Command.new({"!tune"}, "!tune (toggle radio on or off)",
    function(ply, params)
        ply:ConCommand("hive_tune")
        
        return true
    end
),
Command.new({"!choon", "!ch"}, "!choon (choon the current song)",
    function(ply, params)
        if ply:GetInfo("last_rated_song")!=song then
            ply:ConCommand("last_rated_song \""..song.."\"")
            
            HiveRequest("song_rate", ply:GetName(), 3)
            BroadChat(ply:GetName() .. " thinks that " .. song .. " is a banging Choon!")
        else
            SendChat(ply, "You have already rated this song")
        end
        
        return true
    end
),
Command.new({"!poon", "!po"}, "!poon (poon the current song)",
    function(ply, params)
        if ply:GetInfo("last_rated_song")!=song then
            ply:ConCommand("last_rated_song \""..song.."\"")
            
            HiveRequest("song_rate", ply:GetName(), 4)
            BroadChat(ply:GetName() .. " thinks that " .. song .. " is a bit of a naff Poon!")
        else
            SendChat(ply, "You have already rated this song")
        end
            
        return true
    end
),
Command.new({"!djftw", "!ftw"}, "!djftw (Give the current DJ a FTW!)",
    function(ply, params)
       if ply:GetInfo("last_rated_dj")!=dj then
            ply:ConCommand("last_rated_dj " .. dj)
            
            HiveRequest("djrate", ply:GetName(), dj)
            BroadChat(ply:GetName() .. " thinks " .. dj .. " is a banging DJ!")
        else
            SendChat(ply, "You have already rated this DJ");
        end
        return true
    end
),
Command.new({"!shoutout", "!shout"}, "!shoutout <message> (Send a shoutout to the current DJ)",
    function(ply, params)
        pts = string.Explode(" ", params)
        if table.Count(pts) > 1 then
            x = select(2, string.find(params, " ", 1, false))
            shout = string.sub(params, x, string.len(params))
            ptime = tonumber(ply:GetInfo("time_shout"))
            ntime = ptime+60*3
            if os.time() > ntime then
                ply:ConCommand("time_shout "..os.time())
                HiveRequest("shoutout", ply:GetName(), shout)
                SendChat(ply, "Your shoutout has been sent!")
            else
                SendChat(ply, "You can't send any shoutouts for "..ntime-os.time().." seconds");
            end
            return true
        else
            return false
        end
    end
),
Command.new({"!request", "!req"}, "!request <artist - song> (Request a song)",
    function(ply, params)
        pts = string.Explode(" ", params)
        if table.Count(pts) > 1 then
            x = select(2, string.find(params, " ", 1, false))
            req = string.sub(params, x, string.len(params))
            ptime = tonumber(ply:GetInfo("time_req"))
            ntime = ptime+60*3
            if os.time() > ntime then
                ply:ConCommand("time_req "..os.time())
                HiveRequest("request", ply:GetName(), req)
                SendChat(ply, "Your request has been sent!")
            else
                SendChat(ply, "You can't send any requests for "..ntime-os.time().." seconds");
            end
            return true
        else
            return false
        end
    end
),
Command.new({"!setvol", "!vol"}, "!setvol <volume (1-100)> (Change the volume of the radio)",
    function(ply, params)
        pts = string.Explode(" ", params)
        if table.Count(pts) ==2 then
            vol = tonumber(pts[2])
            
            if (vol!=nil && vol>=1) && (vol<= 100) then
                ply:ConCommand("hive_volume " .. vol)
                return true
            else
                return false
            end
        else
            return false
        end
    end
),
Command.new({"!radiohelp"}, "!radiohelp (Shows this help)",
    function(ply, params)
        ShowHelp(ply)
        
        return true
    end
),
Command.new({"!radio"}, "!radio (Opens the Hive365 menu)",
    function(ply, params)
        ply:ConCommand("hive_menu")
        
        return true
    end
),
Command.new({"!rignore"}, "!rignore (Toggle radio messages)",
    function(ply, params)
        if ply:GetInfo("hive_ignore")=="false" then
            SendChat(ply, "You are now ignoring all radio messages, use !rignore again to re-enable this")
            ply:ConCommand("hive_ignore true")
        else
            ply:ConCommand("hive_ignore false")
            SendChat(ply, "You enabled radio messages")
        end
        return true
    end
)
}

function ShowHelp(ply)
    for key,command in pairs(commands) do
        SendChat(ply, command.help)
    end
end

function chatCommand( ply, text, public )
    if string.sub(text, 1, 1)=="!" then
        pts = string.Explode(" ", text)
        
        for key,command in pairs(commands) do
            if command:isComm(pts[1]) then
                command:execute(ply, text)
                return false
            end
        end
        
    end
end

net.Receive("sendstuff", function(length, ply)
    chatCommand(ply, net.ReadString(), false)
end)

function FirstSpawn( ply )
    SendChat(ply, "This server is running Hive365 Radio type !radiohelp for Help!")
    
    if GetConVar("hive_start_tuned"):GetBool() then
        ply:ConCommand("hive_tune")
    end
end

function UpdateInfo()
    http.Fetch("http://data.hive365.co.uk/stream/info.php",
        function (body, len, headers, code)
            data = util.JSONToTable(body)
            if data != nil then
                temp_song = string.Trim(string.Replace(data.info.artist_song, "&amp;", "&"))
                temp_dj = string.Trim(string.Replace(data.info.title, "&amp;", "&"))
                
                song = GetConVar("hive_last_song"):GetString()
                dj = GetConVar("hive_last_dj"):GetString()
                
				new_dj = !((temp_dj =="") || (temp_dj == hive_last_dj) || (temp_dj == dj))
				new_song = !((temp_song =="") || (temp_song == hive_last_song) || (temp_song == song))
				
                if new_dj then
                    RunConsoleCommand("hive_last_dj", temp_dj)
                    BroadChat("New DJ: " .. temp_dj)
					hive_last_dj = temp_dj;
                end
                
                if new_song then
                    RunConsoleCommand("hive_last_song", temp_song)
                    BroadChat("New song: " .. temp_song)
					hive_last_song = temp_song;
                end
            end
        end,
        nil
    )
end

hook.Add( "PlayerSay", "chatCommand", chatCommand )
hook.Add( "PlayerInitialSpawn", "playerInitialSpawn", FirstSpawn )

function HiveRequest(req_type, user, data)
	server_name = enc(GetHostName())
	username = enc(user)
	
	
	url = ""
	
	if req_type == "song_rate" then
		url = "http://hive365.co.uk/plugin/" ..
				req_type .. ".php?" ..
				"n=" .. username ..
				"&t=" .. data ..
				"&host=" .. server_name
	else
		dat = enc(data)
		url = "http://hive365.co.uk/plugin/" ..
				req_type .. ".php?" ..
				"n=" .. username ..
				"&s=" .. dat ..
				"&host=" .. server_name
	end
	
	http.Fetch(url, nil, nil)
end

function HiveInfo()
    BroadChat("This server is running Hive365 Radio type !radiohelp for Help!")
end

timer.Create( "info_updater", 5, 0, function()  UpdateInfo() end )
timer.Create( "hive_info", 60*15, 0, function()  HiveInfo() end )

print("Initialized Hive365 gmod plugin")
