AddCSLuaFile()
AddCSLuaFile("hive365/cl_init.lua")
if SERVER then
    include("hive365/command.lua")
	include("hive365/init.lua")
elseif CLIENT then
	include("hive365/cl_init.lua")
end