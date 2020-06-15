--[[ LCARS widget for use with Conky
	V1.0 by Moob (12-10-2015 <moobvda@gmail.com>)
	This widget draws a LCARS interface to display system information

	Start conky with '-q' to get rid of conky statfs64 messages when a usb stick/disk is unmounted.

	Prerequisites : fonts 'Swiss911 XCm BT' and 'Swiss911 UCm BT'
			lm-sensors

	Changelog v1.1
	18-10-2016	Added compatibility with conky 1.10.x
			Change network display
			Changed own_preexec function to prevent running out of file handles
			Added check for presence eth1 and wlan1

	Changelog v1.0	Fixed temperture alerts
	12-10-2015	Added better device selection for temperature monitoring
			Added option to show the general cpu speed
			Added *REDALERT* when thresholds are exceeded

	Changelog v0.9	Fixed wireless data throughput display
	12-10-2015	Fixed maximum CPU bar display
			Fixed RPM alarm display

	Changelog v0.8  Removed the EFI disk/partition from the list of harddrives as it is only the boot part of the OS
	10-10-2015	Changed fan sensor detection
			Limit number of CPU/disk/.. items to 10 due to height constrictions

	Changelog v0.7  Added total amount of network data incoming and outgoing
	10-9-2015	Put only CPU display behind the 'updates>5' safety so the rest of the interface is directly visible on start, not 5 cycles later.

	Changelog v0.6	Removed unused functions
	24-8-2015	added cpu reset variable which reset the maximum cpu values displayed every x cycles

	Changelog v0.5	changed temperature and fan rpm display
	23-8-2014	see 'system_temperatures_and_fan explanation' below

	Changelog v0.4 	added fan rpm alert
	22-8-2015	made disk i/o display generic
			border is automatically adjusted to the number of items visible
			changed grid to fixed height
			LCARS interface tweaks
			battery and device detection tweaks

	Changelog v0.3 	made it generic, number of cpu cores, harddisks/usb and NICs are now automatically detected
	21-8-2015	added battery display for laptops
			grid height now automatically adjust

	Changelog v0.2  added alerts for CPU/GPU temperature threshold
	20-8-2015	added alert for top one process CPU threshold
			added nvidia temperature and cpu speed info
			added user parameters to change things
			changed lcars color from orange to blue
			added IP information
			general clean-up

	Changelog v0.1 start coding
]]

-- user parameters, change them if you want.
use_red_alert = "yes"		-- use 'RED ALERT' to display threshold alerts
squash_cpu_cores = "no"	-- display overall cpu speed, not per core
cpu_high_proccess_alert = 25	-- threshold alert for running proccesses
nvidia_temperature_alert = 80	-- works only when a nvidia videocard is detected
battery_low_alert = 10		-- low battery level alert, for laptops.
minimum_fan_speed_alert = 900	-- alert when below this RPM level
show_system_temperatures_and_fans = "no"
system_temperatures_and_fans_temp1 = "none"
system_temperatures_and_fans_temp1_alert ="0"
system_temperatures_and_fans_temp1_interface = "0"
system_temperatures_and_fans_temp2 = "none"
system_temperatures_and_fans_temp2_alert ="0"
system_temperatures_and_fans_temp2_interface = "0"
system_temperatures_and_fans_temp3 = "none"
system_temperatures_and_fans_temp3_alert ="0"
system_temperatures_and_fans_temp3_interface = "0"
system_temperatures_and_fans_temp4 = "none"
system_temperatures_and_fans_temp4_alert ="0"
system_temperatures_and_fans_temp4_interface = "0"
system_temperatures_and_fans_temp5 = "none"
system_temperatures_and_fans_temp5_alert ="0"
system_temperatures_and_fans_temp5_interface = "0"
system_temperatures_and_fans_temp6 = "none"
system_temperatures_and_fans_temp6_alert ="0"
system_temperatures_and_fans_temp6_interface = "0"
system_temperatures_and_fans_temp7 = "none"
system_temperatures_and_fans_temp7_alert ="0"
system_temperatures_and_fans_temp7_interface = "0"
system_temperatures_and_fans_temp8 = "none"
system_temperatures_and_fans_temp8_alert ="0"
system_temperatures_and_fans_temp8_interface = "0"
system_temperatures_and_fans_temp9 = "none"
system_temperatures_and_fans_temp9_alert ="0"
system_temperatures_and_fans_temp9_interface = "0"
system_temperatures_and_fans_temp10 = "none"
system_temperatures_and_fans_temp10_alert ="0"
system_temperatures_and_fans_temp10_interface = "0"
system_temperatures_and_fans_fan1 = "none"
system_temperatures_and_fans_fan2 = "none"
system_temperatures_and_fans_fan3 = "none"
system_temperatures_and_fans_fan4 = "none"
--------------- system_temperatures_and_fan explanation ----------------
-- The problem is that you cannot easily see which sensor belongs to what
-- device, aka cpu, fan or otherwise.
-- This has to do with the type of chipset in your computer, they differ
-- per system.
-- So, you have to set the correct sensors yourself.
-- You can use the command 'sensors' to see which sensors your system has.
-- Then you have to set the one you want to display in the table above
--
-- Therefore, displaying of temperature and fan information is
-- disabled per default !!!
-- If you enable this and Conky refuses to start or give errors. First
-- check the sensors on your system !!!
--
-- You can check the location /sys/class/hwmon/hwmon# or subdirectory device
-- for the presence of temp1_ and fan1_ files. (where # can be 0 or 1)
--
-- For finding temperatures you can use the command 'grep "" /sys/class/hwmon/hwmon[0-1]/*_label'
-- This shows the contents of the _label files and the names you see should
-- corespond with the names in the first column of the sensors command output
-- If you want to show the temp4_label temperature. Set the *_temp4_* variables
-- If you mis one, just set the table reference for it to "none"
--
-- system_temperatures_and_fans_temp1 = "none" ; displays the label text. When 'none' nothing will be displayed
-- system_temperatures_and_fans_temp1_alert ="0" ; alert threshold, when above this value, raise alert.
-- system_temperatures_and_fans_temp1_interface = "0" ; hwmon# interface to look for. Can be 0 or 1
--
-- Only cpu and fan thresholds are shown
------------------------------------------------------------------------

------------------------------------------------------------------------
-- nothing exciting beyond here, trust me ;-)
------------------------------------------------------------------------

-- RED ALERT UI Layout , names correspond to function names
-- |       |
-- |       |-- ui_b #sys
-- |-------|
-- |_______|-- ui_b #1c
-- |       |-- ui_cbl #1  ui_b #1           ui_b #1a
-- \       \_____ ___________|_____            _|_
--  \____________|_________________|          |___|
--   ____________ _________________  /blabla/  ___
--  /       _____|_________________|          |___|
-- / ______/-- ui_ctl #1    |                    |
-- |       |            ui_b #2              ui_b #2a
-- |_______|-- ui_b #2c
--
--
-- / items /
-- ________
-- |       |-- manual rectangle, no function
-- |_______|
-- |       |-- ui_cbl #2  ui_b #4
-- \       \_____ ___________|____________________
--  \____________|________________________________|
--
-----------------------------------------------------------------------


require 'cairo'

-- globale variabelen
info = {}
info.memmax = 1
info.swapmax = 1
info.cpumax = {} -- maximum cpu value storage per cycle
info.sx = 84 -- start x coordinate of the grid
info.barheight = 28 -- height of horizontal bars within the grid
info.infoheight = 32 -- height of item blocks
info.scalefactor = 0 -- storage for calculated scalefactor
info.blokwidth = 80  -- width of item blocks
info.vspacer = 4 -- vertical space between blocks
info.cpualert = cpu_high_proccess_alert -- blink when above this cpu%
info.cpualerttrigger = 1 -- show atleast once
info.cputemptrigger = 1 -- show atleast once
info.fanspeed = minimum_fan_speed_alert
info.fanspeedtrigger = 1
info.iface = ""
info.nvidiacard = "no"
info.gputemp = nvidia_temperature_alert
info.gputemptrigger = 1
info.battalert = battery_low_alert
info.battalerttrigger = 1
info.systemp = show_system_temperatures_and_fans
info.resetmaxcpuvalues = 300 -- reset cpu maximum values every x conky interval cycles
info.scpu = squash_cpu_cores
info.ra = use_red_alert
info.cpualerts={0,0,0,0,0,0,0,0,0,0}  -- when adding systemp[x] records, add a zero field

systemp={}
systemp[1]=system_temperatures_and_fans_temp1
systemp[2]=system_temperatures_and_fans_temp2
systemp[3]=system_temperatures_and_fans_temp3
systemp[4]=system_temperatures_and_fans_temp4
systemp[5]=system_temperatures_and_fans_temp5
systemp[6]=system_temperatures_and_fans_temp6
systemp[7]=system_temperatures_and_fans_temp7
systemp[8]=system_temperatures_and_fans_temp8
systemp[9]=system_temperatures_and_fans_temp9
systemp[10]=system_temperatures_and_fans_temp10
sysfan={}
sysfan[1]=system_temperatures_and_fans_fan1
sysfan[2]=system_temperatures_and_fans_fan2
sysfan[3]=system_temperatures_and_fans_fan3
sysfan[4]=system_temperatures_and_fans_fan4
syshwm={}
syshwm[1]=system_temperatures_and_fans_temp1_interface
syshwm[2]=system_temperatures_and_fans_temp2_interface
syshwm[3]=system_temperatures_and_fans_temp3_interface
syshwm[4]=system_temperatures_and_fans_temp4_interface
syshwm[5]=system_temperatures_and_fans_temp5_interface
syshwm[6]=system_temperatures_and_fans_temp6_interface
syshwm[7]=system_temperatures_and_fans_temp7_interface
syshwm[8]=system_temperatures_and_fans_temp8_interface
syshwm[9]=system_temperatures_and_fans_temp9_interface
syshwm[10]=system_temperatures_and_fans_temp10_interface
sysalrm={}
sysalrm[1]=tonumber(system_temperatures_and_fans_temp1_alert)
sysalrm[2]=tonumber(system_temperatures_and_fans_temp2_alert)
sysalrm[3]=tonumber(system_temperatures_and_fans_temp3_alert)
sysalrm[4]=tonumber(system_temperatures_and_fans_temp4_alert)
sysalrm[5]=tonumber(system_temperatures_and_fans_temp5_alert)
sysalrm[6]=tonumber(system_temperatures_and_fans_temp6_alert)
sysalrm[7]=tonumber(system_temperatures_and_fans_temp7_alert)
sysalrm[8]=tonumber(system_temperatures_and_fans_temp8_alert)
sysalrm[9]=tonumber(system_temperatures_and_fans_temp9_alert)
sysalrm[10]=tonumber(system_temperatures_and_fans_temp10_alert)

-- vars below are filled by conky_detect_hardware
cpucores={} 	-- number of detected cpu cores
cpumax={}	-- maximum values per core
cpumax[1]=1
hddmax={}	-- maximum values per disk
fsnames={}	-- full path to disk aka /media/data1
disknames={}	-- last part of path aka data1
diskdevicenames={}	-- devicename aka sda etc
hardware={}
hardware.flag=1
hardware.cpucores=0
hardware.numofhdd=0
hardware.battery="none"
hardware.fan=0

function conky_main()

-- width of the bar displaying grid
local grid_width = 480

if conky_window == nil then return end
local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
cr = cairo_create(cs)

-- detect hardware
conky_detect_hardware()

local updates=tonumber(conky_parse('${updates}'))
-- .806,.807,.996 - lichtblauw
-- .61,.61,1 - iets blauwer
-- .8,.4,.4 - bruinachtig
-- .568,.403,.737 - paars
-- .996,.6,0 - oranje
-- 1,.619,.388 -licht oranje
-- 0.8,0.4,0.6 (cc6699) helder paars
-- 1,0.4,0.6 (ffcc99) licht oranje
-- .6,.6,.8 (9999cc) light blauw

-- system information
local kolom1=100
local startrow=23
local fs=16 --font size
conky_lctext(kolom1,startrow,"Hostname : "..conky_parse("$nodename"),16,"X",.9,.9,.9)
conky_lctext(kolom1,startrow+fs,"Kernel : "..conky_parse("$sysname $kernel $machine"),16,"X",.9,.9,.9)
conky_lctext(kolom1,startrow+(2*fs),"Uptime : "..conky_parse("$uptime"),16,"X",.9,.9,.9)

if info.nvidiacard == "yes" then
	conky_lctext(kolom1,startrow+(3*fs),"GPU Frequency : "..conky_parse("${nvidia gpufreq}").."MHz",16,"X",.9,.9,.9)
	startrow=startrow+fs
end

conky_lctext(kolom1,startrow+(3*fs),"CPU Frequency: "..conky_parse("$freq_g").."GHz",16,"X",.9,.9,.9)
conky_lctext(kolom1,startrow+(4*fs),"Total memory: "..conky_parse("$memmax"),16,"X",.9,.9,.9)
conky_lctext(kolom1,startrow+(5*fs),"Total swap: "..conky_parse("$swapmax"),16,"X",.9,.9,.9)
conky_lctext(kolom1,startrow+(6*fs),"Network: "..info.iface.."",16,"X",.9,.9,.9)
conky_lctext(kolom1,startrow+(7*fs),"up/down: "..conky_parse("${upspeed "..info.iface.."}").." / "..conky_parse("${downspeed "..info.iface.."}"),16,"X",.9,.9,.9)
startrow=startrow+fs
if hardware.battery ~= "none" then
	local batperc = tonumber(conky_parse("${battery_percent "..hardware.battery.."}"))
	local batload = string.find(conky_parse("${battery_short "..hardware.battery.."}"),"C",0)
	local batrema = conky_parse("${battery_time "..hardware.battery.."}")
	if batload ~= 1 and batperc < info.battalert then
		conky_lctext(kolom1,startrow+(7*fs),conky_parse("${blink Battery charge : "..batperc.."% - "..batrema.." left}"),16,"X",1,.2,.2)
		info.battalerttrigger = 2
	else
		info.battalerttrigger = 1
		if batload == 1 then
			conky_lctext(kolom1,startrow+(7*fs),conky_parse("Battery is ${battery "..hardware.battery.."}"),16,"X",1,1,1)
		else
			conky_lctext(kolom1,startrow+(7*fs),conky_parse("Battery charge : "..batperc.."% - "..batrema.." left"),16,"X",.9,.9,.9)
		end
	end
end

if info.nvidiacard == "yes" then
	if tonumber(conky_parse("${nvidia temp}")) >= info.gputemp and info.gputemptrigger >= 1 then
		info.gputemptrigger=2
		conky_lctext(kolom1,startrow+(8*fs),conky_parse("${blink GPU temp : ${nvidia temp} C}"),16,"X",1,.2,.2)
	else
		info.gputemptrigger=1
		conky_lctext(kolom1,startrow+(8*fs),"GPU temp : "..conky_parse("${nvidia temp}".." C"),16,"X",.9,.9,.9)
	end
end

if info.systemp ~= "no" then
	local co=0
	for i,v in ipairs(systemp) do
		if systemp[i] ~= "none" then
			local alv=tonumber(conky_parse("${hwmon "..syshwm[i].." temp "..i.."}"))
			if alv > sysalrm[i] then
			info.cpualerts[i]=1
			conky_lctext(kolom1,startrow+((8+i)*fs),conky_parse("${blink "..v.." temp : ${hwmon "..syshwm[i].." temp "..i.."} C}"),16,"X",1,.2,.2)
			else
			info.cpualerts[i]=0
			conky_lctext(kolom1,startrow+((8+i)*fs),v.." temp : "..conky_parse("${hwmon "..syshwm[i].." temp "..i.."} C"),16,"X",.9,.9,.9)

			end
		 co=co+1
		end
	end
	local cp=1 -- start below row (8+i)
	for i,v in ipairs(sysfan) do
		if sysfan[i] ~= "none" then
			if tonumber(conky_parse("${hwmon "..hardware.fan.." fan "..i.."}")) <= info.fanspeed and info.fanspeedtrigger >=1 then
			info.fanspeedtrigger=2
			conky_lctext(kolom1,startrow+((8+co+cp)*fs),conky_parse("${blink "..v.." fan speed : ${hwmon "..hardware.fan.." fan "..i.."} RPM}"),16,"X",1,.2,.2)
			else
			info.fanspeedtrigger=1
			conky_lctext(kolom1,startrow+((8+co+cp)*fs),v.." fan speed : "..conky_parse("${hwmon "..hardware.fan.." fan "..i.."} RPM"),16,"X",.9,.9,.9)
			end
		cp=cp+1
		end
	end

end
-- adjust for nvidia information displayed
if info.nvidiacard == "yes" then
	startrow=startrow-fs
end

-- running processes information
local kolom2,kolom3,kolom4,kolom5=300,400,450,500
conky_lctext(kolom2,startrow,"Name",16,"X",1,1,1)
conky_lctext(kolom3+8,startrow,"PID",16,"X",1,1,1)
conky_lctext(kolom4+5,startrow,"CPU%",16,"X",1,1,1)
conky_lctext(kolom5+3,startrow,"MEM%",16,"X",1,1,1)
if tonumber(conky_parse("${top cpu 1}")) >= info.cpualert and info.cpualerttrigger >= 1 then
info.cpualerttrigger = 2
conky_lctext(kolom2,startrow+fs,conky_parse("${blink ${top name 1}}"),16,"X",1,.2,.2)
conky_lctext(kolom3,startrow+fs,conky_parse("${blink ${top pid 1}}"),16,"X",1,.2,.2)
conky_lctext(kolom4,startrow+fs,conky_parse("${blink ${top cpu 1}}"),16,"X",1,.2,.2)
conky_lctext(kolom5,startrow+fs,conky_parse("${blink ${top mem 1}}"),16,"X",1,.2,.2)
else
info.cpualerttrigger = 1
conky_lctext(kolom2,startrow+fs,conky_parse("${top name 1}"),16,"X",.9,.9,.9)
conky_lctext(kolom3,startrow+fs,conky_parse("${top pid 1}"),16,"X",.9,.9,.9)
conky_lctext(kolom4,startrow+fs,conky_parse("${top cpu 1}"),16,"X",.9,.9,.9)
conky_lctext(kolom5,startrow+fs,conky_parse("${top mem 1}"),16,"X",.9,.9,.9)
end
conky_lctext(kolom2,startrow+(2*fs),conky_parse("${top name 2}"),16,"X",.9,.9,.9)
conky_lctext(kolom3,startrow+(2*fs),conky_parse("${top pid 2}"),16,"X",.9,.9,.9)
conky_lctext(kolom4,startrow+(2*fs),conky_parse("${top cpu 2}"),16,"X",.9,.9,.9)
conky_lctext(kolom5,startrow+(2*fs),conky_parse("${top mem 2}"),16,"X",.9,.9,.9)
conky_lctext(kolom2,startrow+(3*fs),conky_parse("${top name 3}"),16,"X",.9,.9,.9)
conky_lctext(kolom3,startrow+(3*fs),conky_parse("${top pid 3}"),16,"X",.9,.9,.9)
conky_lctext(kolom4,startrow+(3*fs),conky_parse("${top cpu 3}"),16,"X",.9,.9,.9)
conky_lctext(kolom5,startrow+(3*fs),conky_parse("${top mem 3}"),16,"X",.9,.9,.9)
conky_lctext(kolom2,startrow+(4*fs),conky_parse("${top name 4}"),16,"X",.9,.9,.9)
conky_lctext(kolom3,startrow+(4*fs),conky_parse("${top pid 4}"),16,"X",.9,.9,.9)
conky_lctext(kolom4,startrow+(4*fs),conky_parse("${top cpu 4}"),16,"X",.9,.9,.9)
conky_lctext(kolom5,startrow+(4*fs),conky_parse("${top mem 4}"),16,"X",.9,.9,.9)
conky_lctext(kolom2,startrow+(5*fs),conky_parse("${top name 5}"),16,"X",.9,.9,.9)
conky_lctext(kolom3,startrow+(5*fs),conky_parse("${top pid 5}"),16,"X",.9,.9,.9)
conky_lctext(kolom4,startrow+(5*fs),conky_parse("${top cpu 5}"),16,"X",.9,.9,.9)
conky_lctext(kolom5,startrow+(5*fs),conky_parse("${top mem 5}"),16,"X",.9,.9,.9)

conky_lctext(kolom2,startrow+(7*fs),"IP Address : ",16,"X",.9,.9,.9)
conky_lctext(kolom2+55,startrow+(7*fs),conky_parse("${addr "..info.iface.."}"),16,"X",.9,.9,.9)
conky_lctext(kolom2,startrow+(8*fs),"Gateway : ",16,"X",.9,.9,.9)
conky_lctext(kolom2+55,startrow+(8*fs),conky_parse("${gw_ip}"),16,"X",.9,.9,.9)

-- total network traffic
conky_lctext(kolom4,startrow+(7*fs),"Data in : "..conky_parse("${totaldown "..info.iface.."}"),16,"X",.9,.9,.9)
conky_lctext(kolom4,startrow+(8*fs),"Data out : "..conky_parse("${totalup "..info.iface.."}"),16,"X",.9,.9,.9)

-- display disk i/o
conky_lctext(kolom2,startrow+(10*fs),"Disk I/O : ",16,"X",.9,.9,.9)
local step=0
for i,disk in ipairs(diskdevicenames) do
	conky_lctext(kolom2+step,startrow+(11*fs),string.upper(disk),16,"X",.9,.9,.9)
	conky_lctext(kolom2+step,startrow+(12*fs),conky_parse("${diskio /dev/"..disk.."}"),16,"X",.9,.9,.9)
	step=step+42
end

-- begin y positie
local starty=310

-- display cpu cores
local crupdates=tonumber(conky_parse("${updates}"))
if info.scpu == "yes" then
	starty=conky_display_cpu(1,starty,0,crupdates)
else
	for i,cpu in ipairs(cpucores) do
		if crupdates % info.resetmaxcpuvalues == 0 then
			info.cpumax[i]=1
		end
		starty=conky_display_cpu(1,starty,cpu,crupdates)
	end
end

-- internal memory info
conky_horizontal_bar(1,starty,info.blokwidth,info.infoheight,.568,.403,.737,1)
conky_lctexta(info.blokwidth,starty+info.infoheight-4,"MEMORY",16,"X",0,0,0)
local mem_perc_bar=tonumber(conky_parse("${memperc}"))
conky_horizontal_bar(info.sx, starty+2, mem_perc_bar*info.scalefactor,info.barheight,.2,.2,.6,1)
if (info.sx+(mem_perc_bar*info.scalefactor)) > info.memmax then
	info.memmax=info.sx+(mem_perc_bar*info.scalefactor)
end
conky_max_bar(info.memmax,starty+2,6,info.barheight)
starty=starty+info.infoheight+info.vspacer

-- swap info
conky_horizontal_bar(1,starty,info.blokwidth,info.infoheight,.568,.403,.737,1)
conky_lctexta(info.blokwidth,starty+info.infoheight-4,"SWAP",16,"X",0,0,0)
local swap_perc_bar=tonumber(conky_parse("${swapperc}"))
conky_horizontal_bar(info.sx, starty+2, swap_perc_bar*info.scalefactor,info.barheight,.7,.2,.6,1)
if (info.sx+(swap_perc_bar*info.scalefactor)) > info.swapmax then
	info.swapmax=info.sx+(swap_perc_bar*info.scalefactor)
end
conky_max_bar(info.swapmax,starty+2,6,info.barheight)
starty=starty+info.infoheight+info.vspacer

-- display harddisks
for i,hdd in ipairs(fsnames) do
	starty=conky_display_hdd(1,starty,hdd,i)
end

-- show REDALERT and fill up after last item
if info.ra == "yes" and (conky_check_cpualerts() == 1 or info.fanspeedtrigger == 2 or info.cpualerttrigger == 2 or info.gputemptrigger == 2 or info.battalerttrigger == 2) then
	conky_red_alert()
	conky_lctext(337,259,"SYSTEM ANALYSIS",48,"U",1,1,1)
	conky_lctexta(info.blokwidth,165,"SYSTEM",16,"X",0,0,0)
	line_width=1
	line_cap=CAIRO_LINE_CAP_BUTT
	cairo_set_source_rgba (cr,1,0,0,1)
	cairo_rectangle(cr,0,starty,81,(714-starty)+info.vspacer+9)
	cairo_fill(cr)
else
	conky_lctext(337,259,"SYSTEM ANALYSIS",48,"U",.806,.807,.996)
	conky_lctexta(info.blokwidth,165,"SYSTEM",16,"X",0,0,0)
	line_width=1
	line_cap=CAIRO_LINE_CAP_BUTT
	cairo_set_source_rgba (cr,.611,.619,1,1)
	-- 714 voor desktop
	cairo_rectangle(cr,0,starty,81,(714-starty)+info.vspacer+9)
	cairo_fill(cr)
end

-- bar grid
-- scale factor wordt automatisch aangepast aan de breedte van het grid
-- 415 voor desktop
conky_grid(info.sx,300,grid_width,415)

-- destroy graphic instance
cairo_destroy(cr)
cairo_surface_destroy(cs)
cr=nil

end-- end main function

-- UI functions
function conky_ui_b(sx,sy,width,height,r,g,b)
	line_width=1
	line_cap=CAIRO_LINE_CAP_BUTT
	cairo_set_source_rgba (cr,r,g,b,1)
	cairo_rectangle(cr,sx,sy,width,height)
	cairo_fill(cr)
end -- conky_ui_b

-- corner bottom left
--- lx and ly are the topleft coordinates of the corner
--- width is the width of the vertical column
--- the rest of the corner is automatically calculated
function conky_ui_cbl(lx,ly,width,r,g,b)
	line_width=1
	line_cap=CAIRO_LINE_CAP_BUTT
	cairo_set_source_rgba (cr,r,g,b,1)
	-- left to right
	cairo_move_to(cr,lx,ly)
	cairo_line_to(cr,lx+width,ly)
	cairo_line_to(cr,lx+width,ly+10)
	-- inner corner
	cairo_curve_to(cr,lx+width,ly+10,lx+width+4,ly+27,lx+width+45,ly+24)
	-- inner corner down to bottom
	cairo_line_to(cr,lx+width+45,ly+25+14)
	-- right outer coord to left outer corner
	cairo_line_to(cr,lx+23,ly+25+14)
	-- outer corner
	cairo_curve_to(cr,lx+23,ly+25+14,lx+7,ly+37,lx,ly+20)
	-- outer corner straight up to lx/ly
	cairo_line_to(cr,lx,ly)
	cairo_fill(cr)
end

-- corner top left
--- lx and ly are the lowerleft coordinates of the corner
--- width is the width of the vertical column
--- the rest of the corner is automatically calculated
function conky_ui_ctl(lx,ly,width,r,g,b)
	line_width=1
	line_cap=CAIRO_LINE_CAP_BUTT
	cairo_set_source_rgba (cr,r,g,b,1)
	-- left to right
	cairo_move_to(cr,lx,ly)
	cairo_line_to(cr,lx+width,ly)
	cairo_line_to(cr,lx+width,ly-10)
	-- inner corner
	cairo_curve_to(cr,lx+width,ly-10,lx+width+5,ly-26,lx+width+45,ly-23)
	-- inner corner up to top
	cairo_line_to(cr,lx+width+45,ly-25-13)
	-- right outer coord to left outer corner
	cairo_line_to(cr,lx+23,ly-25-13)
	-- outer corner
	cairo_curve_to(cr,lx+23,ly-25-12,lx+7,ly-37,lx,ly-20)
	-- outer corner straight down to lx/ly
	cairo_line_to(cr,lx,ly)
	cairo_fill(cr)
end

-- check if a sensor, fan or cpu, crosed a threshold
function conky_check_cpualerts()
	local retval=0
	for i,v in ipairs(info.cpualerts) do
		if v == 1 then
			retval=1
		end
	end
	return retval
end

-- change to RED ALERT scheme
function conky_red_alert()
	-- ui_b #sys
	conky_ui_b(-1,4,82,165,1,1,1)
	-- ui_b #1c
	conky_ui_b(-1,174,82,26,1,0,0)
	-- ui_b #1
	conky_ui_b(124,224,208,15,1,0,0)
	-- ui_b #2
	conky_ui_b(124,246,208,15,1,0,0)
	-- ui_b #1a
	conky_ui_b(557,224,16,15,1,0,0)
	-- ui_b #2a
	conky_ui_b(557,246,16,15,1,0,0)
	-- ui_b #4
	conky_ui_b(124,737,450,15,1,0,0)
	-- ui_cbl #2
	conky_ui_cbl(-1,713,info.blokwidth+1,1,0,0)
	-- ui_cbl #1
	conky_ui_cbl(0,200,info.blokwidth+1,1,0,0)
	-- uit_ctl #1
	conky_ui_ctl(0,284,info.blokwidth+1,1,0,0)
	-- ui_b #2c
	conky_ui_b(0,284,info.blokwidth+1,22,1,0,0)
end

-- generic text function
function conky_lctext(sx,sy,tekst,fontsize,ftype,r,g,b)
	cairo_select_font_face (cr, "Swiss911 "..ftype.."Cm BT", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
	cairo_set_font_size (cr, fontsize)
	cairo_set_source_rgba (cr,r,g,b,1)
	cairo_move_to (cr,sx,sy)
	cairo_show_text (cr,tekst)
end -- conky_lctext

-- berekend de lengte van de tekst en past dan het sx coordinaat aan
function conky_lctexta(sx,sy,tekst,fontsize,ftype,r,g,b)
	local txt_ext = cairo_text_extents_t:create()
	cairo_select_font_face (cr, "Swiss911 "..ftype.."Cm BT", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
	cairo_set_font_size (cr, fontsize)
	cairo_set_source_rgba (cr,r,g,b,1)
	cairo_text_extents(cr, tekst, txt_ext)
	cairo_move_to (cr,sx-txt_ext.width-info.vspacer,sy)
	cairo_show_text (cr,tekst)
end -- conky_lctexta

-- displays the bar
function conky_horizontal_bar(sx, sy, width,height,r,g,b,a)
	line_width=1
	line_cap=CAIRO_LINE_CAP_BUTT
	cairo_set_source_rgba (cr,r,g,b,a)
	cairo_rectangle(cr,sx,sy,width,height)
	cairo_fill(cr)
end -- conky_horizontal_bar

-- displays the maximum value
function conky_max_bar(sx, sy, width,height)
	line_width=1
	line_cap=CAIRO_LINE_CAP_BUTT
	cairo_set_source_rgba (cr,1,1,1,1)
	cairo_rectangle(cr,sx,sy,width,height)
	cairo_fill(cr)
end -- conky_max_bar

-- displays the grid with vertical percent bars
function conky_grid(sx,sy,width,height)
	info.scalefactor=width/100
	local percentage = {"10","20","30","40","50","60","70","80","90","100"}
	for i,v in ipairs(percentage) do
		conky_grid_part(v,sx+(info.scalefactor*v),sy,width,height)
	end

end -- conky_grid

-- displays the vertical bars and text in the grid
function conky_grid_part(tekst,sx,sy,width,height)
font="Swiss911 XCm BT"
font_size=16
red,green,blue,alpha=1,1,1,.9
font_slant=CAIRO_FONT_SLANT_NORMAL
font_face=CAIRO_FONT_WEIGHT_NORMAL
-- de -9 nodig is nodig voor de juiste uitlijning
-- als je het font "Swiss911 XCm BT" gebruikt.
-- bij Mono font moet het weggehaald worden
font_length=(string.len(tekst)*font_size)-9
if string.len(tekst) > 2 then
font_length=(string.len(tekst)*font_size)-font_size+font_size/2-9
end
if tonumber(tekst) > 80 then
	red,green,blue,alpha=1,.4,0,1
end
if tonumber(tekst) > 50 and tonumber(tekst) < 90 then
	red,green,blue,alpha=.97,.64,.02,1
end
if tonumber(tekst) > 30 and tonumber(tekst) < 60 then
	red,green,blue,alpha=.81,.51,.98,1
end
if tonumber(tekst) >= 10 and tonumber(tekst) < 40 then
	red,green,blue,alpha=.61,.61,1,1
end

cairo_select_font_face (cr, font, font_slant, font_face);
cairo_set_font_size (cr, font_size)
cairo_set_source_rgba (cr,red,green,blue,alpha)
cairo_move_to (cr,sx-font_length,sy)
cairo_show_text (cr,tekst)
line_width=1
line_cap=CAIRO_LINE_CAP_BUTT
--startpunt line
cairo_move_to (cr,sx,sy+2)
cairo_line_to (cr,sx,sy+height)
cairo_stroke (cr)
cairo_rectangle (cr,sx-7,sy-6,8,8)
cairo_rectangle (cr,sx-7,sy+height,8,8)
cairo_fill (cr)
end -- conky_grid_part

-- display cpu core
function conky_display_cpu(sx,sy,cpu,updates)

	conky_horizontal_bar(sx,sy,info.blokwidth,info.infoheight,.8,.4,.4,1)
	-- show general cpu or per core
	if cpu == 0 then
		conky_lctexta(info.blokwidth,sy+info.infoheight-4,"CPU",16,"X",0,0,0)
	else
		conky_lctexta(info.blokwidth,sy+info.infoheight-4,"CPU"..cpu,16,"X",0,0,0)
	end
if updates>5 then
	local cpu_perc_bar=tonumber(conky_parse("${cpu cpu"..cpu.."}"))
	if cpu > 0 and cpu % 2 == 0 then
		conky_horizontal_bar(info.sx, sy+2, cpu_perc_bar*info.scalefactor,info.barheight,.5,.5,1,1)
	else
		conky_horizontal_bar(info.sx, sy+2, cpu_perc_bar*info.scalefactor,info.barheight,.5,.1,1,1)
	end

	local xval=info.sx+(cpu_perc_bar*info.scalefactor)
	-- random value for general cpu as 0 cannot be used as index
	if cpu == 0 then
		cpu=1111
		cpumax[1111]=1
	end
	--  initialize cpumax value
	if info.cpumax[cpu] == nil then
		info.cpumax[cpu]=1
	end
	if (info.sx+(cpu_perc_bar*info.scalefactor)) > info.cpumax[cpu] then
		info.cpumax[cpu]=xval
	end
	conky_max_bar(info.cpumax[cpu],sy+2,6,info.barheight)
end
	-- volgende start y coordinaat berekenen en teruggeven
	sy=sy+info.infoheight+info.vspacer
	return sy
end -- conky_display_cpu

-- display harddisk
function conky_display_hdd(sx,sy,hdd,max)
-- 81,.61,.81

	-- show no more then 10 items
	if sy < 667 then
		local name=string.upper(disknames[max])
		local disk1_perc_bar=conky_parse("${if_mounted "..hdd.."}${fs_used_perc "..hdd.."}${endif}")
		if name == "/" then
			name = "ROOT"
			conky_horizontal_bar(info.sx, sy+2, disk1_perc_bar*info.scalefactor,info.barheight,1,.8,0,1)
		else
			conky_horizontal_bar(info.sx, sy+2, disk1_perc_bar*info.scalefactor,info.barheight,.81,.61,.81,1)
		end
		conky_horizontal_bar(sx,sy,info.blokwidth,info.infoheight,.806,.807,.996,1)
		conky_lctexta(info.blokwidth,sy+info.infoheight-4,name,16,"X",0,0,0)
		if (info.sx+(disk1_perc_bar*info.scalefactor)) > hddmax[max] then
			hddmax[max]=info.sx+(disk1_perc_bar*info.scalefactor)
		end
		conky_max_bar(hddmax[max],sy+2,6,info.barheight)
		sy=sy+info.infoheight+info.vspacer
	end
	return sy
end -- conky_display_hdd

-- Conky version 1.10.0 does not support ${pre_exec} anymore. Maybe in the future, who knows.
-- That is were this function comes in, as a replacement for ${pre_exec}
-- Keep in mind that 1.10.0 is an unstable conky version as per their maintainers
function conky_ownpreexec(command)
	local file
	fp = assert(io.popen(command, 'r'))
	file = fp:read('*a')
	io.close(fp)

      return file
end

-- detect if a nvidia videocard is present
function conky_check_nvidia()
	info.nvidiacard="yes"
	return ""
end

-- check which network interface is used
function conky_check_network_interfaces(iface)

	local address =	conky_parse("${addr "..iface.."}")
	if iface == "eth0" then
		if address ~= "No Address" then
			info.iface = "eth0"
		end
	end
	if iface == "eth1" then
		if address ~= "No Address" then
			info.iface = "eth1"
		end
	end
	if iface == "wlan0" then
		if address ~= "No Address" then
			info.iface = "wlan0"
		end
	end
	if iface == "wlan1" then
		if address ~= "No Address" then
			info.iface = "wlan1"
		end
	end

	if iface == "wlp3s0" then
		if address ~= "No Address" then
			info.iface = "wlp3s0"
		end
	end
	return ""
end

function conky_check_battery(flag)
	if tonumber(flag) == 0 and hardware.battery == "none" then
		hardware.battery = "BAT0"
	end
	if tonumber(flag) == 1 and hardware.battery == "none" then
		hardware.battery = "BAT1"
	end
	if tonumber(flag) == 2 and hardware.battery == "none" then
		hardware.battery = "C1BC"
	end

	return ""
end

-- Check if the fan sensor is located at hwmon0 or hwmon1
function conky_check_fan(flag)
	if tonumber(flag) == 0 and hardware.fan == 0 then
		hardware.fan = 0
	end
	if tonumber(flag) == 1 and hardware.fan == 0 then
		hardware.fan = 1
	end
	return ""
end

-- check if a disk is mountend/umounted and adjust number of disks
function conky_check_for_disk_change()
	local fs=conky_ownpreexec("df -h | grep ^/dev/s | sort |grep -o '[^ ]*$' | grep -v 'efi'")
	local numofhdd=0
	for w in string.gfind(fs.."\n", "\n") do
		numofhdd=numofhdd+1
	end
	return tonumber(numofhdd)
end

-- detect what kind of hardware is present at startup or ondemand
function conky_detect_hardware()
	local debug = true

	local adjust=0
	adjust=conky_check_for_disk_change()
	if adjust ~= hardware.numofhdd then
		hardware.flag = 1
		if debug == true then
		print("Adjusting...")
		end
	end

	if hardware.flag == 1 then
		-- only perform on conky startup, not every cycle
		hardware.flag = 2
		if debug == true then
			print("in hardware detect functie")
		end

		-- check for battery location
		conky_parse("${if_existing /proc/acpi/battery/BAT0}${lua_parse check_battery 0}${endif}")
		conky_parse("${if_existing /proc/acpi/battery/BAT1}${lua_parse check_battery 1}${endif}")
		conky_parse("${if_existing /sys/class/power_supply/C1BC}${lua_parse check_battery 2}${endif}")
		conky_parse("${if_existing /sys/class/power_supply/BAT1}${lua_parse check_battery 1}${endif}")
		conky_parse("${if_existing /sys/class/power_supply/BAT0}${lua_parse check_battery 0}${endif}")
		if debug == true then
			print("battery found : "..hardware.battery)
		end

		-- which network interface to display
		conky_parse("${if_up eth0}${lua_parse check_network_interfaces eth0}${endif}")
		conky_parse("${if_up eth1}${lua_parse check_network_interfaces eth1}${endif}")
		conky_parse("${if_up wlan0}${lua_parse check_network_interfaces wlan0}${endif}")
		conky_parse("${if_up wlan1}${lua_parse check_network_interfaces wlan1}${endif}")
		conky_parse("${if_up wlp3s0}${lua_parse check_network_interfaces wlp3s0}${endif}")
		if debug == true then
		print("network interface "..info.iface.." is being used")
		end

		-- were are the fan inputs
		conky_parse("${if_existing /sys/class/hwmon/hwmon0/fan1_input}${lua_parse check_fan 0}${endif}")
		conky_parse("${if_existing /sys/class/hwmon/hwmon1/fan1_input}${lua_parse check_fan 1}${endif}")
		if debug == true then
		print("fans is located at "..hardware.fan)
		end

		-- nvidia videocard
		conky_parse("${if_existing /proc/devices nvidia}${lua_parse check_nvidia}${endif}")
		if debug == true then
		print("nvidia card present, "..info.nvidiacard)
		end

		-- number of cpu cores
		hardware.cpucores = conky_ownpreexec("cat /proc/cpuinfo | grep 'core id' | wc -l")

		local i
		for i=1,tonumber(hardware.cpucores) do
			cpucores[i]=i
			cpumax[i]=1
		end
		if debug == true then
		print(hardware.cpucores.." cpu cores found")
		end

		-- disk names
		local fs=conky_ownpreexec("df -h | grep ^/dev/s | sort |grep -o '[^ ]*$' | grep -v 'efi'")
		-- add the final newline
		--fs=fs.."\n"
		if debug == true then
		print(fs.."were the harddisks found")
		end
		-- number of disks
		hardware.numofhdd=0
		for w in string.gfind(fs, "\n") do
			hardware.numofhdd=hardware.numofhdd+1
		end
		if debug == true then
		print(hardware.numofhdd.." harddisks in total")
		end
		-- convert string to table
		local t,s,i=1,0,0
		for i=1, hardware.numofhdd do
			s=string.find(fs,"\n",t)
			fsnames[i]=string.sub(fs,t,s-1)
			t=s+1
		end
		-- fill hdd max values
		for i=1,hardware.numofhdd do
			hddmax[i]=1
		end
		-- add disknames for displaying purposes
		local r,key,value,name
		for i,v in ipairs(fsnames) do
			r=string.match(v,"^.*()/")
			if r == 1 then
				disknames[i] = "/"
			else
				key,value,name=string.find(v,"(.*)",r+1)
				disknames[i] = name
			end
		end
		-- get disk device names
		local df=conky_ownpreexec("df -h | grep ^/dev/s | sort | grep -v 'efi' | grep -o 'sd[^ ]'")
		-- add the final newline
		df=df.."\n"
		if debug == true then
		print(df.."were the disk devices found")
		end
		-- convert string to table
		local t,s,i=1,0,0
		for i=1, hardware.numofhdd do
			s=string.find(df,"\n",t)
			diskdevicenames[i]=string.sub(df,t,s-1)
			t=s+1
		end

		if debug == true then
			for i,v in ipairs(disknames) do
			print ("disk name "..i.." is "..v)
			end
			for i,v in ipairs(fsnames) do
			print ("fs name "..i.." is "..v)
			end
			print("num of hdd is "..hardware.numofhdd)
			print("hardware fs is \n"..fs)
		end

		-- when usb drive/stick removed, adjust the number of disks
		local dcount,fcount,dncount = 0,0,0
  		for _ in ipairs(disknames) do dcount = dcount + 1 end
  		for _ in ipairs(fsnames) do fcount = fcount + 1 end
  		for _ in ipairs(diskdevicenames) do dncount = dncount + 1 end
		if dcount ~= hardware.numofhdd or fcount ~= hardware.numofhdd or dncount ~= hardware.numofhdd then
			fsnames[fcount]=nil
			disknames[dcount]=nil
			diskdevicenames[dncount]=nil
		end

	end
end
