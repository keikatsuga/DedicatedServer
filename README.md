This repo is for setting up Archlinux on Online.net dedicated server.(Tested this on dedibox XC).
This is modified from jcleneveu/archlinux-autodedibox script because his script are a bit outdated.

Steps are (from when you got the server)

	1. Install debian OS 64bit using console.online.net
		1a. Set up the partition how you like your server there. you could make
			* / and swap only	(the rest, 1G)
			* /boot, /, swap      	(200M,the rest, 1G)
			* /boot, /, /home, swap (200M,20G,the rest, 1G)
			* /, home, swap  	(20G,the rest, 1G) <- what I'm gonna use.
			* or any other variation
	2. Boot it rescue mode. Use Ubuntu, not Windows please.
	3. Type "wget https://github.com/keikatsuga/DedicatedServer/blob/master/archSetup.sh"
	4. Check the script first and change what you like. Highlight of what you need to check
		* airootfs.sfs mirror if somehow ovh is slow or down
		* disk configuration part, make sure it reflected the partition you make earlier
		* disk mounting part, same as above
		* pacstrap part if you want another shell as default
		* hostname part, change to what you like 
		* locale part, change what language you want to use. If you use different keymap, please refer archwiki for more information
		* localtime part, what time you want your server to display
		* configuring bootloader part, make sure it reflected the partition you make earlier
		* creating user part. Change onlineUser to what you like 
	5. Type "sh archSetup.sh". I think it will prompt you for root password and user password
	6. Maybe you need to undo the rescue mode on console.online.net before you reboot.
	7. Reboot your server. (Type "reboot")
	
