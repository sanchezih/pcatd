-- Global variables --
local persist_power = persist_add("power", "INT", 0)
local gbl_power  = 0
local gbl_dist1  = 0
local gbl_speed1 = 0
local gbl_dist2  = 0
local gbl_speed2 = 0
local dme_slave_source = 0
local dme_power = 0

-- Button functions --
function new_state(state, direction)
    
    -- Set the new state of the switch and remember this
	persist_put(persist_power, state + direction)
    switch_set_state(switch_state, persist_get(persist_power))
    update_gui()

end

-- Add images in Z-order --
img_add_fullscreen("BKKDI572.png")

-- Add text  in Z-order --
txt_load_font("GOST Common.ttf")

txt_naut = txt_add(" ", "-fx-font-size:60px; -fx-fill: #fb2c00; -fx-text-alignment: RIGHT;", 18, 45, 150, 150)
txt_nm = txt_add("NM", "-fx-font-size:20px; -fx-font-family:\"GOST Common\"; -fx-fill: #fb2c00; -fx-text-alignment: LEFT;", 175, 85, 50, 50)
txt_nav1 = txt_add("1", "-fx-font-size:20px; -fx-font-family:\"GOST Common\"; -fx-fill: #fb2c00; -fx-text-alignment: LEFT;", 190, 45, 50, 50)
txt_nav2 = txt_add("2", "-fx-font-size:20px; -fx-font-family:\"GOST Common\"; -fx-fill: #fb2c00; -fx-text-alignment: LEFT;", 190, 65, 50, 50)

txt_knots = txt_add(" ", "-fx-font-size:60px; -fx-fill: #fb2c00; -fx-text-alignment: RIGHT;", 200, 45, 150, 150)
txt_kt = txt_add("KT", "-fx-font-size:20px; -fx-font-family:\"GOST Common\"; -fx-fill: #fb2c00; -fx-text-alignment: LEFT;", 360, 85, 50, 50)

txt_mn = txt_add(" ", "-fx-font-size:60px; -fx-fill: #fb2c00; -fx-text-alignment: RIGHT;", 350, 45, 150, 150)
txt_min = txt_add("MIN", "-fx-font-size:20px; -fx-font-family:\"GOST Common\"; -fx-fill: #fb2c00; -fx-text-alignment: LEFT;", 510, 85, 50, 50)

-- Add a group --
group_text = group_add(txt_naut, txt_nm, txt_nav1, txt_nav2, txt_knots, txt_kt, txt_mn, txt_min)

-- Functions --
function update_gui()

	
	if dme_power == 0 then
		selected = 0
		switch_set_state(switch_state, 0)
	else
		if dme_slave_source == 0 then
			selected = 1
			switch_set_state(switch_state, 1)
		else
			selected = 2
			switch_set_state(switch_state, 2)
		end
	end
	

    -- Get the state of the power switch
 --  selected = persist_get(persist_power)
	
	
    
    -- Turn DME and off (make text visible and invisible)
    visible(group_text, gbl_power and selected > 0)

    -- Are we seeing data from DME1 or DME2?
    visible(txt_nav1, selected == 1 and gbl_power)
    visible(txt_nav2, selected == 2 and gbl_power)
    
    -- Set distance
    if selected == 1 then
        distance = var_cap(gbl_dist1, 0, 999.9)
    elseif selected == 2 then
        distance = var_cap(gbl_dist2, 0, 999.9)
    else
        distance = 0
    end

    if distance >= 10 then
        txt_set(txt_naut, var_format(distance, 1) )
    elseif distance < 10 and distance > 0 then
        txt_set(txt_naut, "0" .. var_format(distance, 1) )
	else
		txt_set(txt_naut, "00.0")
    end
    
    -- Set speed
    if selected == 1 then
        speed = var_cap(gbl_speed1, 0, 999)
    elseif selected == 2 then
        speed = var_cap(gbl_speed2, 0, 999)
    else
        speed = 0
    end
    
    speed = var_round(speed, 0)
    
    if speed >= 100 then
        txt_set(txt_knots, speed)
    elseif speed >= 10 then
        txt_set(txt_knots, "0" .. speed)
    elseif speed >= 1 then
        txt_set(txt_knots, "00" .. speed)
    else
        txt_set(txt_knots, "000")
    end
    
    -- Set time in minutes (dataref time is in seconds)
    if selected == 1 and speed > 0 then
        minutes = var_round(var_cap(gbl_dist1 / gbl_speed1 * 60, 0, 999), 0)
    elseif selected == 2 and speed > 0 then
        minutes = var_round(var_cap(gbl_dist2 / gbl_speed2 * 60, 0, 999), 0)
    else
        minutes = 0
    end
    
    if minutes >= 100 then
        txt_set(txt_mn, minutes)
    elseif minutes >= 10 then
        txt_set(txt_mn, "0" .. minutes)
    elseif minutes >= 1 then
        txt_set(txt_mn, "00" .. minutes)
    else
        txt_set(txt_mn, "000")
    end

end

function new_data_xpl(dist1, speed1, dist2, speed2, avionics, battery, generator, enginerunning, dmeslavesource, dmepower)

    -- Do we have power?
    gbl_power = fif((battery == 1 or (generator[1] == 1 and enginerunning[1] == 1) or (generator[2] == 1 and enginerunning[2] == 1)) and avionics == 1 and dmepower == 1, true, false)
    
    -- Make everything global
    gbl_dist1  = dist1
    gbl_speed1 = speed1
    gbl_dist2  = dist2
    gbl_speed2 = speed2
	dme_slave_source = dmeslavesource
	dme_power = dmepower
    
    update_gui()

end

function new_data_fsx(dist1, speed1, dist2, speed2, avionics, battery, generator_left, generator_right, ffleft, ffright)

    -- Do we have power?
    gbl_power = fif((battery or (generator_left and ffleft > 0) or (generator_right and ffright > 0)) and avionics, true, false)

    -- Make everything global
    gbl_dist1  = dist1
    gbl_speed1 = speed1
    gbl_dist2  = dist2
    gbl_speed2 = speed2
    
    update_gui()
    
end

-- Switch add --
switch_state = switch_add("kdi572off.png","kdi572n1.png","kdi572n2.png",264,143,82,84, new_state)
switch_set_state(switch_state, persist_get(persist_power))

-- Subscribe to data --
xpl_dataref_subscribe("sim/cockpit/radios/nav1_dme_dist_m", "FLOAT", 
					  "sim/cockpit/radios/nav1_dme_speed_kts", "FLOAT",
                      "sim/cockpit/radios/nav2_dme_dist_m", "FLOAT", 
					  "sim/cockpit/radios/nav2_dme_speed_kts", "FLOAT",
                      "sim/cockpit/electrical/avionics_on", "INT",
                      "sim/cockpit/electrical/battery_on", "INT", 
                      "sim/cockpit2/electrical/generator_on", "INT[8]", 
                      "sim/flightmodel/engine/ENGN_running", "INT[8]", 
					  "sim/cockpit2/radios/actuators/DME_slave_source", "INT",
					  "sim/cockpit2/radios/actuators/dme_power", "INT", new_data_xpl)
fsx_variable_subscribe("NAV DME:1", "nautical mile",
					   "NAV DMESPEED:1", "Knots",
                       "NAV DME:2", "nautical mile",
					   "NAV DMESPEED:2", "Knots",
                       "CIRCUIT AVIONICS ON", "Bool",
                       "ELECTRICAL MASTER BATTERY", "Bool", 
                       "GENERAL ENG MASTER ALTERNATOR:1", "Bool", 
                       "GENERAL ENG MASTER ALTERNATOR:2", "Bool", 
                       "RECIP ENG FUEL FLOW:1", "Pounds per hour", 
                       "RECIP ENG FUEL FLOW:2", "Pounds per hour", new_data_fsx)
                       
update_gui()                       