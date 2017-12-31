-- Global variables
headingbug = 0

-- DIAL FUNCTIONS --
--function new_obs(obsset)
--
	--if obsset == -1 then
		--xpl_command("sim/radios/obs1_down")
		--fsx_event("VOR2_OBI_DEC")
	--elseif obsset == 1 then
		--xpl_command("sim/radios/obs1_up")
		--fsx_event("VOR2_OBI_INC")
	--end
	
--end

--function new_heading(headingset)

--headset = headingset

	--return headset
	
	
--end



img_add_fullscreen("hsi_outer_frame.png")

img_rose = img_add_fullscreen("hsi_rose.png")
img_bug = img_add_fullscreen("bughsi.png")
--img_center = img_add_fullscreen("HSI_centre.png")
img_neddle = img_add_fullscreen("hsi_neddle.png")
img_center_neddle = img_add("hsi_center_neddle.png",0,0,600,600)



--img_glideslope_active = img_add("glideslope_active.png",0,0,512,512)
--img_glideslope_flags = img_add("glideslope_flags.png",0,0,512,120)

img_TO_flag = img_add_fullscreen("TO_flag.png")
img_FROM_flag = img_add_fullscreen("from_flag.png")
img_NAV_flag = img_add_fullscreen("NAV_flag.png")

img_add_fullscreen("hsi_inner_frame.png")
img_add_fullscreen("HSI_plane.png")
img_glideslope_markers = img_add_fullscreen("glideslope_markers.png")
img_adf_needle = img_add_fullscreen("adf_needle.png")

txt_dme = txt_add(" ", "-fx-font-family: arial; -fx-font-size:22px; -fx-fill: cyan; -fx-font-weight:normal; -fx-text-alignment: RIGHT;", 300, 120, 200, 200)

txt_dme1Annun = txt_add("DME-NAV1", "-fx-font-family: arial; -fx-font-size:25px; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment: RIGHT;", 335, 90, 200, 200)
txt_dme2Annun = txt_add("DME-NAV2", "-fx-font-family: arial; -fx-font-size:25px; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment: RIGHT;", 335, 90, 200, 200)

txt_dmeNm = txt_add("NM", "-fx-font-family: arial; -fx-font-size:22px; -fx-fill: white; -fx-font-weight:normal; -fx-text-alignment: RIGHT;", 335, 120, 200, 200)

txt_crsAnnun = txt_add("CRS", "-fx-font-family: arial; -fx-font-size:25px; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment: LEFT;", 65, 90, 200, 200)
txt_crs = txt_add(" ", "-fx-font-family: arial; -fx-font-size:25px; -fx-fill: green; -fx-font-weight:bold; -fx-text-alignment: RIGHT;", -80, 120, 200, 200)

txt_hdgAnnun = txt_add("HDG", "-fx-font-family: arial; -fx-font-size:25px; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment: LEFT;", 65, 450, 200, 200)
txt_hdg = txt_add(" ", "-fx-font-family: arial; -fx-font-size:25px; -fx-fill: cyan; -fx-font-weight:bold; -fx-text-alignment: RIGHT;", -80, 480, 200, 200)

txt_dmeGS = txt_add(" ", "-fx-font-family: arial; -fx-font-size:22px; -fx-fill: cyan; -fx-font-weight:normal; -fx-text-alignment: RIGHT;", 300, 480, 200, 200)
txt_GSPD = txt_add("GSPD", "-fx-font-family: arial; -fx-font-size:25px; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment: RIGHT;", 335, 450, 200, 200)
txt_KT = txt_add("KT", "-fx-font-family: arial; -fx-font-size:22px; -fx-fill: white; -fx-font-weight:normal; -fx-text-alignment: RIGHT;", 335, 480, 200, 200)





function PT_hsi(nav1_nav_id,
				heading,
				hsiSourceSelectPilot,
				crs,
				hsihdef,
                hsivdef,
				glideslopeflag,
				hBug,
				toFromFlag,
				dmeNav2Dist,
				dmeNav1Dist,
				adf,
				dmeGS)
    
    img_rotate(img_rose, -heading)
    
    
	hsihdef = var_cap(hsihdef, -2.5, 2.5)
	hsivdef = var_cap(hsivdef, -2.5, 2.5)
	
        dh = hsihdef*37 * math.cos((-heading+crs)*math.pi/180)
        dv = hsihdef*37 * math.sin((-heading+crs)*math.pi/180)
		dm = hsivdef*32
    
    img_rotate(img_center, -heading+crs)
    img_rotate(img_neddle, -heading+crs)
    img_rotate(img_center_neddle, -heading+crs)
    img_move(img_center_neddle, dh, dv, nil, nil)
	
	eHbug = hBug
	
	if headset == 1 then
		xpl_dataref_write("sim/cockpit2/autopilot/heading_dial_deg_mag_pilot", "FLOAT", (eHbug +1))
		headset = 0
	end
	
	if headset == -1 then
		xpl_dataref_write("sim/cockpit2/autopilot/heading_dial_deg_mag_pilot", "FLOAT", (eHbug -1))
		headset = 0
	end
	
	if eHbug >= 361 then
		xpl_dataref_write("sim/cockpit2/autopilot/heading_dial_deg_mag_pilot", "FLOAT", 1)
	end
	
	if eHbug < 0 then
		xpl_dataref_write("sim/cockpit2/autopilot/heading_dial_deg_mag_pilot", "FLOAT", 359)
	end
	
	
	
	img_rotate(img_bug, -heading+hBug)
	img_rotate(img_FROM_flag, -heading+crs)
	img_rotate(img_TO_flag, -heading+crs)
	
	if toFromFlag == 0 then
		img_visible(img_NAV_flag, true)
		img_visible(img_TO_flag, false)
		img_visible(img_FROM_flag, false)
	end
	
	if toFromFlag == 1 then
		img_visible(img_TO_flag, true)
		img_visible(img_FROM_flag, false)
		img_visible(img_NAV_flag, false)
	end
	
	if toFromFlag == 2 then
		img_visible(img_FROM_flag, true)
		img_visible(img_TO_flag, false)
		img_visible(img_NAV_flag, false)
	end
    
    -- if nav1display > 0 or nav2display > 0 or hsiSourceSelectPilot == 2 then
        -- img_visible(img_center_neddle, true)
    -- else
        -- img_visible(img_center_neddle, false)
    -- end
    
    img_move(img_glideslope_markers, nil, dm*9/10 , nil, nil)
    if glideslopeflag == 0 then 
        --img_visible(img_glideslope_flags, true)
        img_visible(img_glideslope_markers, false)
    end
    if glideslopeflag == 1 then
        --img_visible(img_glideslope_flags, false)
        img_visible(img_glideslope_markers, true) 
    end

	-- sanchezih: cambia label dme1/dme2 y distancia (nm)
	if hsiSourceSelectPilot == 0 then

		visible(txt_dme1Annun, true)
		visible(txt_dme2Annun, false)
		dmeNav1Dist = var_round(dmeNav1Dist,1)
		txt_set(txt_dme, dmeNav1Dist)
	elseif hsiSourceSelectPilot == 1 then
		visible(txt_dme1Annun, false)
		visible(txt_dme2Annun, true)
		dmeNav2Dist = var_round(dmeNav2Dist,1)
		txt_set(txt_dme, dmeNav2Dist)
	else
		visible(txt_dme1Annun, false)
		visible(txt_dme2Annun, false)
	end

	
	
	crs1 = var_round(crs, 0)
	txt_set(txt_crs, crs1)
	visible(txt_crs, true)
	
	hdg = var_round(hBug, 0)
	txt_set(txt_hdg, hdg)
	visible(txt_hdg, true)
	
	dmeGS = var_round(dmeGS,0)

	txt_set(txt_dmeGS, dmeGS)
	visible(txt_dmeGS, true)
	
	-- RMI
	
	if adf > 89.5 and adf < 90.5 then
		img_rotate(img_adf_needle, 90)
	else
		img_rotate(img_adf_needle, adf)
	end
	
	
	
end

function PT_hsi_FSX(obs, tofrom, heading, glide, vertical, horizontal)

	if glide == false then
		glideslope = 0
	elseif glide == true then
		glideslope = 1
	end
	
	vertical = 4 / 119 * vertical
	horizontal = 4 / 127 * horizontal
	
	PT_hsi(heading, 1, obs, 0, horizontal, 0, 0, vertical, 0, 0, 1, glideslope)

end



	
	
-- DIAL ADD --
--dial_OBS = dial_add("dialhsi.png", 10, 400, 104, 104, new_obs)
--dial_BUG = dial_add("headingbug.png", 398, 400, 104, 104, new_heading)

--dial_click_rotate(dial_OBS, 5)
--dial_click_rotate(dial_BUG, 5)

fsx_variable_subscribe("NAV OBS:2", "Degrees",
					   "NAV GS FLAG:2", "Bool",
					   "PLANE HEADING DEGREES GYRO", "Degrees",
					   "NAV HAS GLIDE SLOPE:2", "Bool", 
					   "NAV GSI:1", "Number",
					   "NAV CDI:1", "Number", PT_hsi_FSX)
xpl_dataref_subscribe(
						"sim/cockpit2/radios/indicators/nav2_nav_id", 					"DATA",
						"sim/cockpit2/gauges/indicators/heading_electric_deg_mag_pilot","FLOAT",
						"sim/cockpit2/radios/actuators/HSI_source_select_pilot", 		"INT",
						"sim/cockpit2/radios/actuators/hsi_obs_deg_mag_pilot", 			"FLOAT",
						"sim/cockpit2/radios/indicators/hsi_hdef_dots_pilot", 			"FLOAT",
						"sim/cockpit2/radios/indicators/hsi_vdef_dots_pilot", 			"FLOAT", 
						"sim/cockpit2/radios/indicators/hsi_display_vertical_pilot", 	"INT",
						"sim/cockpit2/autopilot/heading_dial_deg_mag_pilot", 			"FLOAT",
						"sim/cockpit2/radios/indicators/hsi_flag_from_to_pilot", 		"INT",
						"sim/cockpit/radios/nav2_dme_dist_m", 							"FLOAT",
						"sim/cockpit/radios/nav1_dme_dist_m", 							"FLOAT",
						"sim/cockpit2/radios/indicators/adf1_relative_bearing_deg", 	"FLOAT",
						"sim/cockpit/radios/nav2_dme_speed_kts", "FLOAT", PT_hsi)
			  
--xpl_dataref_subscribe("sim/cockpit/autopilot/heading_mag", "FLOAT", PT_headingBug)