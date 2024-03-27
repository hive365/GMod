GMod
====

Listen and interact with Hive365 radio 

cvars: 
hive_start_tuned (1 or 0) - start radio on join (default 0) 

con commands: 
hive_menu - opens the radio menu 
hive_tune - toggle radio on/off 
hive_volume (1-100) - change radio volume 

chat commands: 
!tune - toggle radio 
!choon - choon current song 
!poon - poon current song 
!djftw - give the current dj a ftw 
!request <request> - request a song 
!shoutout <shoutout> - send a shoutout 
!setvol <1-100> - set radio volume 
!radio - opens the hive365 radio menu 
!radiohelp - shows all commands with help 
!rignore - toggle radio messages on/off

installation:
1 put the lua folder in the zip file in your garrysmod folder (overwrite all)
2 change map
3 type "gmod_hive365radio_version" in console/rcon to check install
4 done!

https://hive365.radio

changelog
1.0 initial release
1.1
 - menu slider fix
 - & sign fix
 - remember more things on mapchange
 - no more multiple open menus
 - hit return to send shout/req
2.0
 - Music will no longer break after a map cleanup
3.0
 - Move to hive365.radio domain endpoints for stream data and player
3.1
 - Move to new backend for interaction endpoints
