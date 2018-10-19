---------------------------------------------
--  Sim Innovations - All rights reserved  --
--  Bendix/King KAP 140 Autopilot System   --
---------------------------------------------
-- Global variables --
local gbl_power				= false
local gbl_autopilot_mode	= 0
local gbl_ap_altitude		= 0
local gbl_ap_vs_mode		= false
-- Barometric pressure variables	
local gbl_baro_time			= 0
local gbl_bar_set_time		= 2
local gbl_baro_off_time		= 4
-- Vertical speed variables	
local gbl_vs_time			= 0
local gbl_vs_off_time		= 5
local gbl_vs_visible		= false
-- Persistence
persist_baro_desig			= persist_add("baro_desig", "INT", 0) -- inHg: 0	HPA: 1

-- Images --
img_add_fullscreen("background.png")
img_led = img_add("led.png", 23, 46, nil, nil)
img_ap = img_add("ap_light.png", 200, 36, nil, nil)
img_a_box = img_add("ap_box.png", 200, 36, nil, nil)
img_arm_l = img_add("arm_light.png", 184, 63, nil, nil)
img_yd = img_add("yd.png", 200, 65, nil, nil)
img_arm_r = img_add("arm_light.png", 309, 63, nil, nil)
img_trim_up = img_add("pt_up.png", 340, 35, nil, nil)
img_trim_dn = img_add("pt_dn.png", 340, 35, nil, nil)
img_comma = img_add("komma.png", 421, 60, nil, nil)
img_alert = img_add("alert_light.png", 381, 70, nil, nil)
img_fpm = img_add("fpm.png", 435, 70, nil, nil)
img_ft = img_add("ft_light.png", 470, 70, nil, nil)
img_hpa = img_add("hpa.png", 400, 88, nil, nil)
img_inhg = img_add("inhg.png", 447, 88, nil, nil)

-- Text --
txt_item1 = txt_add("HDG", "-fx-font-size:44px; -fx-fill: #ff5a00; -fx-text-alignment:right;", 105, 28, 70, 45)
txt_item2 = txt_add("VS", "-fx-font-size:44px; -fx-fill: #ff5a00; -fx-text-alignment:right;", 230, 28, 70, 45)
txt_item3 = txt_add("00", "-fx-font-size:44px; -fx-fill: #ff5a00; -fx-text-alignment:right;", 361, 28, 60, 45)
txt_item4 = txt_add("000", "-fx-font-size:44px; -fx-fill: #ff5a00; -fx-text-alignment:right;", 340, 28, 150, 45)

txt_item5 = txt_add("REV", "-fx-font-size:44px; -fx-fill: #ff5a00; -fx-text-alignment:right;", 105, 65, 70, 45)
txt_item6 = txt_add("ALT", "-fx-font-size:44px; -fx-fill: #ff5a00; -fx-text-alignment:right;", 230, 65, 70, 45)

-- Window image --
img_add("window.png", 100, 22, nil, nil)

-- Item group --
item_group = group_add(txt_item1, txt_item2, txt_item3, txt_item4, txt_item5, txt_item6)		   

-- Buttons and dials functions --
function big_dial_callback(direction)

	-- First stop all running timers to switch to altitude mode
	if timer_running(timer_baro) then
		timer_stop(timer_baro)
	end
	
	if timer_running(timer_vs) then
		timer_stop(timer_vs)
	end
	
	-- Then write the required altitude (+-1000ft)
	if direction == 1 and gbl_ap_altitude <= 29000 and gbl_power then
		xpl_dataref_write("sim/cockpit/autopilot/altitude", "FLOAT", gbl_ap_altitude + 1000)
	elseif direction == -1 and gbl_ap_altitude >= 1000 and gbl_power then
		xpl_dataref_write("sim/cockpit/autopilot/altitude", "FLOAT", gbl_ap_altitude - 1000)
	end

end

function small_dial_callback(direction)

	-- First stop all running timers to switch to altitude mode
	if timer_running(timer_baro) then
		timer_stop(timer_baro)
	end
	
	if timer_running(timer_vs) then
		timer_stop(timer_vs)
	end
	
	-- Then write the required altitude (+-100ft)
	if direction == 1 and gbl_ap_altitude <= 29900 and gbl_power then
		xpl_dataref_write("sim/cockpit/autopilot/altitude", "FLOAT", gbl_ap_altitude + 100)
	elseif direction == -1 and gbl_ap_altitude >= 100 and gbl_power then
		xpl_dataref_write("sim/cockpit/autopilot/altitude", "FLOAT", gbl_ap_altitude - 100)
	end

end

function api_callback()

	-- Writing the default X-Plane autopilot mode dataref does not work for the Airfoil Labs Cessna 172, so we have to write that one too
	if gbl_autopilot_mode == 0 and gbl_power then
		xpl_dataref_write("sim/cockpit/autopilot/autopilot_mode", "INT", 2)
		xpl_dataref_write("172/autopilot/atp_auto_main_mode", "INT", 1)
	elseif gbl_autopilot_mode == 2 and gbl_power then
		xpl_dataref_write("sim/cockpit/autopilot/autopilot_mode", "INT", 0)
		xpl_dataref_write("172/autopilot/atp_auto_main_mode", "INT", 2)
	else
		xpl_dataref_write("sim/cockpit/autopilot/autopilot_mode", "INT", 0)
		xpl_dataref_write("172/autopilot/atp_auto_main_mode", "INT", 0)
	end

end

function hdg_callback()

	-- Autopilot heading-hold
	xpl_command("sim/autopilot/heading")

end

function nav_callback()

	-- Autopilot VOR/LOC arm
	xpl_command("sim/autopilot/NAV")

end

function apr_callback()

	-- Autopilot approach
	xpl_command("sim/autopilot/approach")

end

function rev_callback()

	-- Autopilot back-course
	xpl_command("sim/autopilot/back_course")

end

function alt_callback()

	-- Autopilot altitude select or hold
	xpl_command("sim/autopilot/altitude_hold")

end

function up_callback()

	-- Start the timer if it's not running. If it is already running then reset the time
	if timer_running(timer_vs) and gbl_autopilot_mode == 2 then
		gbl_vs_time = gbl_vs_off_time
		timer_stop(timer_baro)
	elseif gbl_autopilot_mode == 2 then
		gbl_vs_time = gbl_vs_off_time
		timer_stop(timer_baro)
		timer_vs = timer_start(0,1000, timer_vs_callback)
	end
	
	-- The first press will only show the selected VS, the second press will increase the VS.
	-- If not in vertical speed mode, the vertical speed mode will be turned on. If it is in vertical speed mode already, it will only increase the vertical speed.
	if gbl_vs_visible and gbl_autopilot_mode == 2 and gbl_ap_vs_fpm < 5000 and not gbl_ap_vs_mode then
		xpl_command("sim/autopilot/vertical_speed")
		xpl_command("sim/autopilot/vertical_speed_up")
	elseif gbl_vs_visible and gbl_autopilot_mode == 2 and gbl_ap_vs_fpm < 5000 and gbl_ap_vs_mode then
		xpl_command("sim/autopilot/vertical_speed_up")
	end
	
	-- Starts as false, set to true when the vertical speed is visible
	if not gbl_vs_visible and timer_running(timer_vs) and gbl_autopilot_mode == 2 then
		gbl_vs_visible = true
	end

end

function dn_callback()

	-- Start the timer if it's not running. If it is already running then reset the time
	if timer_running(timer_vs) and gbl_autopilot_mode == 2 then
		gbl_vs_time = gbl_vs_off_time
		timer_stop(timer_baro)
	elseif gbl_autopilot_mode == 2 then
		gbl_vs_time = gbl_vs_off_time
		timer_stop(timer_baro)
		timer_vs = timer_start(0,1000, timer_vs_callback)
	end
	
	-- The first press will only show the selected VS, the second press will decrease the VS
	-- If not in vertical speed mode, the vertical speed mode will be turned on. If it is in vertical speed mode already, it will only decrease the vertical speed.
	if gbl_vs_visible and gbl_autopilot_mode == 2 and gbl_ap_vs_fpm > -5000 and not gbl_ap_vs_mode then
		xpl_command("sim/autopilot/vertical_speed")
		xpl_command("sim/autopilot/vertical_speed_down")
	elseif gbl_vs_visible and gbl_autopilot_mode == 2 and gbl_ap_vs_fpm > -5000 and gbl_ap_vs_mode then
		xpl_command("sim/autopilot/vertical_speed_down")
	end
	
	-- Starts as false, set to true when the vertical speed is visible
	if not gbl_vs_visible and timer_running(timer_vs) and gbl_autopilot_mode == 2 then
		gbl_vs_visible = true
	end

end

function arm_callback()

	-- Autopilot altitude-hold ARM
	xpl_command("sim/autopilot/altitude_arm")

end

function bar_callback_press()

	-- Start the timer if it's not running. If it is already running then reset the time
	if timer_running(timer_baro) then
		gbl_baro_time = gbl_baro_off_time
		timer_stop(timer_vs)
	else
		gbl_baro_time = gbl_baro_off_time
		timer_stop(timer_vs)
		timer_baro = timer_start(0,1000, timer_baro_callback)
		gbl_bar_set_time = 2
		timer_bar_set = timer_start(0,1000, timer_baro_setting_callback)
	end
	
end

function bar_callback_release()

	-- Stops the timer on button release. If this timer would have reached 2 seconds, it would have switched the barometric designator.
	timer_stop(timer_bar_set)

end

-- Functions --
function new_xpl_data(bus_volts, avionics_on, autopilot_mode, autopilot_state, ap_altitude, ap_trim_up, ap_trim_down, approach_status, altitude_hold_status, 
					  baro_inhg, ap_vs_fpm, time_running, nav_status, atp_alt_alert, yaw_damper_on)

	-- Determine the power state of the autopilot system
	gbl_power = fif(bus_volts[1] > 14 and avionics_on == 1, true, false)
	group_visible(item_group, gbl_power)
	-- Write global variables
	gbl_autopilot_mode	= autopilot_mode
	gbl_ap_vs_fpm		= ap_vs_fpm
	gbl_ap_altitude		= ap_altitude
	if bit32.extract(autopilot_state , 4) == 1 then
		gbl_ap_vs_mode = true
	else
		gbl_ap_vs_mode = false
	end
	
	-- Prepare autopilot system altitude for writing to text items
	ap_altitude_item3 = var_cap((ap_altitude / 1000) % 100, 0, 99)
	ap_altitude_item4 = var_cap(ap_altitude % 1000, 0, 999)
	
	-- Set text items
	-- Text item 1
	if ((bit32.extract(autopilot_state , 4) == 1 and bit32.extract(autopilot_state , 1) == 0) or bit32.extract(autopilot_state , 2) == 1) and nav_status < 2 and gbl_power and autopilot_mode == 2 then
		txt_set(txt_item1, "ROL")
	elseif bit32.extract(autopilot_state , 1) == 1 and nav_status < 2 and gbl_power and autopilot_mode == 2 then
		txt_set(txt_item1, "HDG")
	elseif nav_status == 2 and gbl_power and autopilot_mode == 2 then
		txt_set(txt_item1, "NAV")
	else
		txt_set(txt_item1, " ")
	end
	
	-- Text item 2
	if bit32.extract(autopilot_state , 4) == 1 and gbl_power and autopilot_mode == 2 then
		txt_set(txt_item2, "VS")
	elseif altitude_hold_status == 2 and gbl_power and autopilot_mode == 2 then
		txt_set(txt_item2, "ALT")
	else
		txt_set(txt_item2, " ")
	end
	
	-- Text item 3
	baro_hpa = var_format(baro_inhg * 33.8638866667, 0)
	
	if gbl_power and not timer_running(timer_baro) and not timer_running(timer_vs) then
		txt_set(txt_item3, string.format("%01d", ap_altitude_item3) )
	elseif gbl_power and timer_running(timer_baro) and persist_get(persist_baro_desig) == 0 and not timer_running(timer_vs) then
		txt_set(txt_item3, var_format(baro_inhg, 0) )
	elseif gbl_power and timer_running(timer_baro) and persist_get(persist_baro_desig) == 1 and not timer_running(timer_vs) then
		txt_set(txt_item3, string.format("%01d", baro_hpa / 1000) )
	elseif gbl_power and gbl_autopilot_mode == 2 and timer_running(timer_vs) and not timer_running(timer_baro) then
		if ap_vs_fpm > -1000 and ap_vs_fpm < 0 then
			txt_set(txt_item3, "-0" )
		else
			txt_set(txt_item3, string.format("%01d", ap_vs_fpm / 1000) )
		end
	else
		txt_set(txt_item3, " ")
	end

	-- Text item 4
	if gbl_power and not timer_running(timer_baro) and not timer_running(timer_vs) then
		txt_set(txt_item4, string.format("%03d", ap_altitude_item4) )
	elseif gbl_power and timer_running(timer_baro) and persist_get(persist_baro_desig) == 0 and not timer_running(timer_vs) then
		if string.sub(baro_inhg, 4) == "" then
			txt_set(txt_item4, "00 " )
		else
			txt_set(txt_item4, string.sub(baro_inhg,4 ,5) .. " " )
		end
	elseif gbl_power and timer_running(timer_baro) and persist_get(persist_baro_desig) == 1 and not timer_running(timer_vs) then
		txt_set(txt_item4, string.format("%03d", baro_hpa%100) )
	elseif gbl_power and gbl_autopilot_mode == 2 and timer_running(timer_vs) and not timer_running(timer_baro) and ap_vs_fpm > 0 then
		txt_set(txt_item4, string.format("%03d", ap_vs_fpm % 1000) )
	elseif gbl_power and gbl_autopilot_mode == 2 and timer_running(timer_vs) and not timer_running(timer_baro) then
		if ap_vs_fpm == 0.0 then
			txt_set(txt_item4, "000" )
		else
			txt_set(txt_item4, string.sub(ap_vs_fpm, -3) )
		end
	else
		txt_set(txt_item4, " ")
	end
	
	-- Text item 5 and ARM item left
	if bit32.extract(autopilot_state , 8) == 1 and approach_status == 0 and nav_status == 1 and gbl_power and autopilot_mode == 2 then
		txt_set(txt_item5, "NAV")
		visible(img_arm_l, true)
	elseif bit32.extract(autopilot_state , 8) == 1 and approach_status >= 1 and gbl_power and autopilot_mode == 2 then
		txt_set(txt_item5, "APR")
		visible(img_arm_l, true)
	else
		txt_set(txt_item5, " ")
		visible(img_arm_l, false)
	end	
	
	-- Text item 6 and ARM item right
	if altitude_hold_status == 1 and gbl_power and autopilot_mode == 2 then
		txt_set(txt_item6, "ALT")
		visible(img_arm_r, true)
	else
		txt_set(txt_item6, "")
		visible(img_arm_r, false)
	end
	
	-- Turn on/off boxed AP item
	visible(img_a_box, autopilot_mode == 2 and gbl_power)
	visible(img_ap, autopilot_mode == 2 and gbl_power)
	
	-- Alert item when dialed in altitude is lower than 1000 ft and higher than 11400 ft
	visible(img_alert, atp_alt_alert == 1 and gbl_power and autopilot_mode == 2)
	
	-- Autopilot system trim lights
	visible(img_trim_up, ap_trim_up == 1 and autopilot_mode == 2 and gbl_power)
	visible(img_trim_dn, ap_trim_down == 1 and autopilot_mode == 2 and gbl_power)
	
	-- Turn on/off the comma for the vertical speed or altitude
	visible(img_comma, gbl_power)
	
	-- Switch between HPA and inHG item when the BARO button is pressed
	visible(img_hpa, gbl_power and timer_running(timer_baro) and persist_get(persist_baro_desig) == 1)
	visible(img_inhg, gbl_power and timer_running(timer_baro) and persist_get(persist_baro_desig) == 0)
	
	-- Switch between FPM and FT item
	visible(img_ft, gbl_power and not timer_running(timer_vs) and not timer_running(timer_baro))
	visible(img_fpm, gbl_power and autopilot_mode == 2 and timer_running(timer_vs) and not timer_running(timer_baro))
	
	-- Show the yaw damper light
	visible(img_yd, gbl_power and autopilot_mode == 2 and yaw_damper_on == 1)
	
	-- IHS
	-- Show the AP on mode light
	visible(img_led, gbl_power and autopilot_mode == 2)

end 	
	
-- Buttons and dials --
dial_big = dial_add("big_dial.png", 559,46,136,136, big_dial_callback)
dial_click_rotate(dial_big, 2)
mouse_setting(dial_big , "CURSOR_LEFT", "large_cursor_left.png")
mouse_setting(dial_big , "CURSOR_RIGHT", "large_cursor_right.png")
dial_small = dial_add("small_dial.png", 584,71,86,86, small_dial_callback)
dial_click_rotate(dial_small, 2)
mouse_setting(dial_small , "CURSOR_LEFT", "cursor_left.png")
mouse_setting(dial_small , "CURSOR_RIGHT", "cursor_right.png")

button_api = button_add("ap_up.png",  "ap_dn.png",  19,136,46,30,  api_callback)
button_hdg = button_add("hdg_up.png", "hdg_dn.png", 114,136,46,30, hdg_callback)
button_nav = button_add("nav_up.png", "nav_dn.png", 194,136,46,30, nav_callback)
button_apr = button_add("apr_up.png", "apr_dn.png", 274,136,46,30, apr_callback)
button_rev = button_add("rev_up.png", "rev_dn.png", 354,136,46,30, rev_callback)
button_alt = button_add("alt_up.png", "alt_dn.png", 434,136,46,30, alt_callback)

button_up = button_add("up_up.png", "up_dn.png", 510,79,46,30,	up_callback)
button_dn = button_add("dn_up.png", "dn_dn.png", 510,131,46,30,	dn_callback)

button_arm = button_add("arm_up.png", "arm_dn.png", 558,17,46,30,	arm_callback)
button_bar = button_add("baro_up.png", "baro_dn.png", 630,17,46,30,	bar_callback_press, bar_callback_release)

-- Timer functions --
-- Timer for the barometric pressure
function timer_baro_callback()

	if gbl_baro_time >= 1 then
		gbl_baro_time = gbl_baro_time - 1
	else
		timer_stop(timer_baro)
	end
	
end

-- Timer for the barometric pressure designator setting
function timer_baro_setting_callback()

	if gbl_bar_set_time >= 1 then
		gbl_bar_set_time = gbl_bar_set_time - 1
	else
		timer_stop(timer_bar_set)
		gbl_bar_set_time = 2
		-- When you've pressed the BARO button for 2 seconds or longer, it'll switch between designator, this setting is stored.
		-- inHg: 0	HPA: 1
		if persist_get(persist_baro_desig) == 0 then
			gbl_baro_time = gbl_baro_off_time
			persist_put(persist_baro_desig, 1)
		else
			gbl_baro_time = gbl_baro_off_time
			persist_put(persist_baro_desig, 0)
		end
	end

end

-- Timer for the vertical speed
function timer_vs_callback()

	if gbl_vs_time >= 1 then
		gbl_vs_time = gbl_vs_time - 1
	else
		timer_stop(timer_vs)
		gbl_vs_visible = false
	end
	
end

-- Data subscription --
xpl_dataref_subscribe("sim/cockpit2/electrical/bus_volts", "FLOAT[6]", 
					  "sim/cockpit/electrical/avionics_on", "INT", 
					  "sim/cockpit/autopilot/autopilot_mode", "INT", 
					  "sim/cockpit/autopilot/autopilot_state", "INT", 
					  "sim/cockpit/autopilot/altitude", "FLOAT", 
					  "sim/cockpit/warnings/annunciators/autopilot_trim_up", "INT",
					  "sim/cockpit/warnings/annunciators/autopilot_trim_down", "INT", 
					  "sim/cockpit2/autopilot/approach_status", "INT", 
					  "sim/cockpit2/autopilot/altitude_hold_status", "INT", 
					  "sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot", "FLOAT", 
					  "sim/cockpit/autopilot/vertical_velocity", "FLOAT", 
					  "sim/time/total_running_time_sec", "FLOAT", 
					  "sim/cockpit2/autopilot/nav_status", "INT", 
					  "172/autopilot/atp_alt_alert", "INT", 
					  "sim/cockpit/switches/yaw_damper_on", "INT", new_xpl_data)