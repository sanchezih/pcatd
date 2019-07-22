-- Global variables --
-- Initialize the needles at 90 degrees
local gbl_cur_s1_heading    = 90
local gbl_target_s1_heading = 0
local gbl_cur_s2_heading    = 90
local gbl_target_s2_heading = 0
local gbl_factor            = 0.26

img_add_fullscreen("adf_backdrop.png")
rose = img_add_fullscreen("adf_rose.png")
img_s2_needle = img_add_fullscreen("adf_green_neddle.png")
img_s1_needle = img_add_fullscreen("adf_blue_neddle.png")

function PT_adf(heading, adf1, vor2)

	img_rotate(rose, heading * -1)
	gbl_target_s1_heading = adf1
	gbl_target_s2_heading = vor2
	
end

-- Slowly move needle to current heading --
function timer_callback()	

    -- Rotate needle images
	img_rotate(img_s1_needle, gbl_cur_s1_heading)
    img_rotate(img_s2_needle, gbl_cur_s2_heading)

    -- Source 1 needle
    raw_diff = (360 + gbl_target_s1_heading - gbl_cur_s1_heading) %360
    diff = fif(raw_diff < 180, raw_diff, (360 - raw_diff) * -1)
    gbl_cur_s1_heading = fif(math.abs(diff) < 0.001, gbl_target_s1_heading, gbl_cur_s1_heading + (diff * gbl_factor) )

    -- Source 2 needle
    raw_diff = (360 + gbl_target_s2_heading - gbl_cur_s2_heading) %360
    diff = fif(raw_diff < 180, raw_diff, (360 - raw_diff) * -1)
    gbl_cur_s2_heading = fif(math.abs(diff) < 0.001, gbl_target_s2_heading, gbl_cur_s2_heading + (diff * gbl_factor) )

end

xpl_dataref_subscribe("sim/cockpit/gyros/psi_ele_ind_degm", "FLOAT",
					  "sim/cockpit2/radios/indicators/nav1_relative_bearing_deg", "FLOAT",
					  "sim/cockpit2/radios/indicators/nav2_relative_bearing_deg", "FLOAT", PT_adf)
fsx_variable_subscribe("PLANE HEADING DEGREES GYRO", "DEGREES",
					   "ADF RADIAL:1", "Degrees",
					   "NAV RELATIVE BEARING TO STATION:2", "DEGREES", PT_adf)
					   
-- Timers --
tmr_update = timer_start(0, 50, timer_callback)					   