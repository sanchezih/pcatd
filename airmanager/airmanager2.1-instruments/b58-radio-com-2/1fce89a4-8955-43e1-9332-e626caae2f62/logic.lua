img_add_fullscreen("com_nav_radio.png")

com2_act_txt 	= txt_add("---.--", "-fx-font-family:\"Digital-7 Mono\"; -fx-font-size:48px; -fx-fill: firebrick; -fx-font-weight:bold; -fx-text-alignment: CENTER;", 45, 28, 200, 60)
com2_stby_txt	= txt_add("---.--", "-fx-font-family:\"Digital-7 Mono\"; -fx-font-size:48px; -fx-fill: firebrick; -fx-font-weight:bold; -fx-text-alignment: CENTER;", 45, 90, 200, 60)
nav2_act_txt	= txt_add("---.--", "-fx-font-family:\"Digital-7 Mono\"; -fx-font-size:48px; -fx-fill: firebrick; -fx-font-weight:bold; -fx-text-alignment: CENTER;", 268, 28, 200, 60)
nav2_stby_txt	= txt_add("---.--", "-fx-font-family:\"Digital-7 Mono\"; -fx-font-size:48px; -fx-fill: firebrick; -fx-font-weight:bold; -fx-text-alignment: CENTER;", 268, 90, 200, 60)

function PT_radio(com2_act,com2_stby,nav2_act,nav2_stby)	
  txt_set(com2_act_txt,		string.format("%d.%.02d",com2_act/100,	com2_act%100) )  
  txt_set(com2_stby_txt,	string.format("%d.%.02d",com2_stby/100, com2_stby%100) )
  txt_set(nav2_act_txt, 	string.format("%d.%.02d",nav2_act/100, 	nav2_act%100) )
  txt_set(nav2_stby_txt,	string.format("%d.%.02d",nav2_stby/100, nav2_stby%100) )
end

function PT_radio_FSX(com1,com2,nav1,nav2)
    PT_radio(com1*100+0.01,com2*100+0.01,nav1*100+0.01,nav2*100+0.01)
end

xpl_dataref_subscribe("sim/cockpit2/radios/actuators/com2_frequency_hz", "INT",
					  "sim/cockpit2/radios/actuators/com2_standby_frequency_hz", "INT",
					  "sim/cockpit2/radios/actuators/nav2_frequency_hz", "INT",
					  "sim/cockpit2/radios/actuators/nav2_standby_frequency_hz", "INT", PT_radio)
fsx_variable_subscribe("COM ACTIVE FREQUENCY:1", "Mhz",
					   "COM ACTIVE FREQUENCY:2", "Mhz",
					   "NAV ACTIVE FREQUENCY:1", "Mhz",
					   "NAV ACTIVE FREQUENCY:2", "Mhz", PT_radio_FSX)