-- Collins Rockwell EFIS 84 EADI --
---------------------------------------------
--        Load and display images          --
---------------------------------------------
img_horizon1 = img_add("Horizon1.png", 0, 0, 1200, 1800)
img_horizon = img_add("Horizon.png", 0, 0, 600, 900)
img_pitchAtt = img_add("Pitch_Attitude.png", 0, 0, 600, 900)
--img_hViewport = img_add("viewport.png", -150, -150, 900, 900)
img_skypoint = img_add_fullscreen("Skypointer.png")
img_rollAtt = img_add_fullscreen("Roll_Attitude.png")
img_fltDir = img_add_fullscreen("Director.png")
img_add_fullscreen("Aircraft_Bars.png")
img_add_fullscreen("CRT_border.png")
img_pitch_up = img_add_fullscreen("Pitch_Up.png")
img_pitch_down = img_add_fullscreen("Pitch_Down.png")
img_om = img_add_fullscreen("OM.png")
img_mm = img_add_fullscreen("MM.png")
img_cdi = img_add("CDI.png", 0, -150, 600, 900)
img_glidepath = img_add("Glidepath.png", 0, -150, 600, 900)
img_GSvertpath = img_add("GSvertpath.png", 0, 0, 600, 900)
img_LLZhorpath = img_add("LLZhorpath.png", 0, -150, 600, 900)

txt_radio_minima = txt_add(" ", "-fx-font-family: arial; -fx-font-size:17px; -fx-fill: cyan; -fx-font-weight:normal; -fx-text-alignment: LEFT;", 460, 500, 200, 200)
txt_dh = txt_add(" ", "-fx-font-family: arial; -fx-font-size:25px; -fx-fill: yellow; -fx-font-weight:normal; -fx-text-alignment: LEFT;", 180, 235, 200, 200)
--visible(txt_radio_minima, false)
blink = true

txt_active_lateral = txt_add(" ", "-fx-font-family: arial; -fx-font-size:17px; -fx-fill: lightgreen; -fx-font-weight:normal; -fx-text-alignment: RIGHT;", 65, 65, 200, 200)
txt_active_vertical = txt_add(" ", "-fx-font-family: arial; -fx-font-size:17px; -fx-fill: lightgreen; -fx-font-weight:normal; -fx-text-alignment: LEFT;", 330, 65, 200, 200)
txt_second_arm_vertical = txt_add(" ", "-fx-font-family: arial; -fx-font-size:17px; -fx-fill: white; -fx-font-weight:normal; -fx-text-alignment: LEFT;", 450, 80, 200, 200)
txt_autopilot = txt_add(" ", "-fx-font-family: arial; -fx-font-size:17px; -fx-fill: white; -fx-font-weight:normal; -fx-text-alignment: LEFT;", 90, 95, 200, 200)
txt_yawdamper = txt_add(" ", "-fx-font-family: arial; -fx-font-size:17px; -fx-fill: white; -fx-font-weight:normal; -fx-text-alignment: LEFT;", 90, 110, 200, 200)




---------------
-- Functions --
---------------

function new_attitude(roll, pitch, dRoll, dPitch, dMode)

-- Roll outer ring and background
   -- roll = var_cap(roll, -90, 90)
        
-- Roll horizon
    img_rotate(img_horizon1  , roll * -1)
    img_rotate(img_horizon  , roll * -1)
	img_rotate(img_pitchAtt, roll * -1)
	--img_rotate(img_hViewport, roll * -1)
	img_rotate(img_skypoint, roll * -1)
    
-- Move horizon pitch
    pitch = var_cap(pitch, -90, 90)
    radial = math.rad(roll * -1)
    x = -(math.sin(radial) * pitch * 5) --3
    y = (math.cos(radial) * pitch * 5)
	img_move(img_horizon1, -300, y-600, nil, nil)
    img_move(img_horizon, x, y-150, nil, nil)
	img_move(img_pitchAtt, x, y-150, nil, nil)
	viewport_rect(img_pitchAtt, 200, 225, 200, 150)
	--img_move(img_hViewport, x-150, y-150, nil, nil)
	
-- Pull up//Pitch down arrows
   img_rotate(img_pitch_down, roll * -1)
   img_rotate(img_pitch_up, roll * -1)

if pitch >= 30 then
   visible(img_pitch_down, true)
   else
   visible(img_pitch_down, false)
   end
   
if pitch <= -20 then
   visible(img_pitch_up, true)
   else
   visible(img_pitch_up, false)
   end
	
-- Move director
   dPitch = var_cap(dPitch, -90, 90)
   dRadial = math.rad(dRoll * -1)
   dX = (math.sin(dRadial) * (dPitch - pitch) * 5)
   dY = (math.cos(dRadial) * (pitch - dPitch) * 5)
   img_rotate(img_fltDir, (dRoll * 1) - roll)
   img_move(img_fltDir, nil, dY, nil, nil)
   
-- Director Mode
   if dMode == 0 then
   visible(img_fltDir, false)
   else
   visible(img_fltDir, true)
   end
   
	
	
end

function new_attitude_fsx(roll, pitch)
	
	new_attitude(roll * -57, pitch * -37)

end

function new_marker_beacons(outer_marker, middle_marker, inner_marker)

if outer_marker == 1 then
   visible(img_om, true)
   else
   visible(img_om, false)
   end
   
if middle_marker == 1 then
   visible(img_mm, true)
   else
   visible(img_mm, false)
end

end

txt_add("DH", "-fx-font-size:17px; -fx-font-family:Arial; -fx-fill: cyan; -fx-font-weight:normal; -fx-text-alignment:left;", 425, 500, 150, 100)
txt_radio_height = txt_add(" ", "-fx-font-family: arial; -fx-font-size:30px; -fx-fill: cyan; -fx-font-weight:normal; -fx-text-alignment: LEFT;", 458, 470, 200, 200)

timer = timer_start(0, 100, timer_blink)

function timer_blink()

blink = not blink

end

function new_radio_height(radalt, radio_minima)

txt_set(txt_radio_minima, radio_minima)

--DH annunciation

if ((radalt - radio_minima) <= 0) then
txt_set(txt_dh, "DH")
visible(txt_dh, true)

else
visible(txt_dh, false)
  end



if ((radalt - radio_minima) <= 50) then

visible(txt_radio_height, blink)
radalt = var_round(radalt,-1)

end
 
 if ((radalt - radio_minima) > 50 and (radalt - radio_minima) < 2500) then

visible(txt_radio_minima, true)
radalt = var_round(radalt,-2)

end

if radalt > 2500 then

visible(txt_radio_height, false)

else

--visible(txt_radio_height, true)

end

txt_set(txt_radio_height, radalt)

end

function lateral_mode(hsi_mode, hdg_mode, nav_mode, fd_mode, yd_mode)


--visible(txt_active_lateral, false)

if hdg_mode == 0 and nav_mode == 0 then

visible(txt_active_lateral, false)

  end
  
if hdg_mode == 2 then
txt_set(txt_active_lateral, "HDG")
visible(txt_active_lateral, true)

end

if nav_mode == 2 and hsi_mode == 0 then
txt_set(txt_active_lateral, "NAV1")
visible(txt_active_lateral, true)

  end
  
if nav_mode == 2 and hsi_mode == 1 then
txt_set(txt_active_lateral, "NAV2")
visible(txt_active_lateral, true)

  end
  
if nav_mode == 2 and hsi_mode == 2 then

txt_set(txt_active_lateral, "GPS")
visible(txt_active_lateral, true)

  end
  
  if fd_mode == 0 then
  visible(txt_active_vertical, false)
  
  end
  
if fd_mode == 0 or 1 then
visible(txt_autopilot, false)
  end
  
if fd_mode == 2 then
txt_set(txt_autopilot, "AP")
visible(txt_autopilot, true)

  end
  
if yd_mode == 0 then
visible(txt_yawdamper, false)
  end
  
if yd_mode == 1 then
txt_set(txt_yawdamper, "YD")
visible(txt_yawdamper, true)

  end

end

function vertical_mode(gs_mode, alt_mode, vs_mode, ias_mode, ga_mode, pitch_mode)

if gs_mode and alt_mode and vs_mode and ias_mode and ga_mode and pitch_mode == 0 then

visible(txt_active_vertical, false)

end

if alt_mode == 1 then

txt_set(txt_second_arm_vertical, "ALT ARM")
visible(txt_second_arm_vertical, true)
else
visible(txt_second_arm_vertical, false)


  end
  
 if gs_mode == 2 then

txt_set(txt_active_vertical, "GS")
visible(txt_active_vertical, true) 

elseif alt_mode == 2 then

txt_set(txt_active_vertical, "ALT")
visible(txt_active_vertical, true)

  
elseif vs_mode == 2 then

txt_set(txt_active_vertical, "VS")
visible(txt_active_vertical, true)

  --end
  
elseif ias_mode == 2 then

txt_set(txt_active_vertical, "IAS")
visible(txt_active_vertical, true)

  --end
  
elseif ga_mode == 2 then

txt_set(txt_active_vertical, "GA")
visible(txt_active_vertical, true)

  --end
  
elseif pitch_mode == 2 then

txt_set(txt_active_vertical, "PTCH")
visible(txt_active_vertical, true)

  --end

  else 
  visible(txt_active_vertical, false)

end
end

function vertHorPath(gFlag, glideFlagMove, vFlag, cdiFlagMove)

if gFlag == 1 then
img_visible(img_GSvertpath, true)
gY = (glideFlagMove * 28) - 150
img_move(img_GSvertpath, nil, gY, nil, nil)
  end
  
if gFlag == 0 then
img_visible(img_GSvertpath, false)
end
  
if vFlag == 1 then

img_visible(img_LLZhorpath, true)
gX = cdiFlagMove * 41
img_move(img_LLZhorpath, gX, nil, nil, nil)
  else
img_visible(img_LLZhorpath, false)

  end

end






-------------------
-- Bus subscribe --
-------------------
xpl_dataref_subscribe("sim/cockpit2/gauges/indicators/roll_AHARS_deg_pilot", "FLOAT",
					  "sim/cockpit2/gauges/indicators/pitch_AHARS_deg_pilot", "FLOAT",
					  "sim/cockpit2/autopilot/flight_director_roll_deg", "FLOAT",
					  "sim/cockpit2/autopilot/flight_director_pitch_deg", "FLOAT",
					  "sim/cockpit2/autopilot/flight_director_mode", "INT", new_attitude)
					  
fsx_variable_subscribe("ATTITUDE INDICATOR BANK DEGREES", "Radians",
					   "ATTITUDE INDICATOR PITCH DEGREES", "Radians", new_attitude_fsx)
					   
			--		   xpl_dataref_subscribe("sim/flightmodel/position/phi", "FLOAT",
			--		  "sim/flightmodel/position/theta", "FLOAT", new_attitude)
			
xpl_dataref_subscribe("sim/cockpit2/radios/indicators/outer_marker_lit", "INT",
					  "sim/cockpit2/radios/indicators/middle_marker_lit", "INT",
					  "sim/cockpit2/radios/indicators/inner_marker_lit", "INT", new_marker_beacons)
					  
xpl_dataref_subscribe("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot", "FLOAT",
                      "sim/cockpit/misc/radio_altimeter_minimum", "FLOAT",	new_radio_height)
					  
xpl_dataref_subscribe("sim/cockpit2/radios/actuators/HSI_source_select_pilot", "INT", -- 0 = nav1, 1 = nav2, 2 = GNSS
					  "sim/cockpit2/autopilot/heading_status", "INT", -- Autopilot Heading Status. 0=off,1=armed,2=captured
					  "sim/cockpit2/autopilot/nav_status", "INT",     -- Autopilot Nav status
					  "sim/cockpit/autopilot/autopilot_mode", "INT", -- The autopilot master mode (off=0, flight director=1, on=2)
					  "sim/cockpit/switches/yaw_damper_on", "INT",
					   lateral_mode)
					   
xpl_dataref_subscribe("sim/cockpit2/autopilot/glideslope_status", "INT",
					  "sim/cockpit2/autopilot/altitude_hold_status", "INT",
                      "sim/cockpit2/autopilot/vvi_status", "INT",
					  "sim/cockpit2/autopilot/speed_status", "INT",
					  "sim/cockpit2/autopilot/TOGA_status", "INT",
					  "sim/cockpit2/autopilot/pitch_status", "INT",
					  vertical_mode)
					  
xpl_dataref_subscribe("sim/cockpit2/radios/indicators/hsi_display_vertical_pilot", "INT",
                      --"sim/cockpit2/radios/indicators/hsi_flag_glideslope_pilot", "INT",
                      "sim/cockpit2/radios/indicators/hsi_vdef_dots_pilot", "FLOAT",
					  "sim/cockpit2/radios/indicators/hsi_display_horizontal_pilot", "INT",
					  "sim/cockpit2/radios/indicators/hsi_hdef_dots_pilot", "FLOAT",
					  vertHorPath)