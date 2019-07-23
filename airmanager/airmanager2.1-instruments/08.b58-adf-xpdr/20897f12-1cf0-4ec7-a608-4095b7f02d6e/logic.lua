img_add_fullscreen("adf_xpn_radio.png")

adf1txt = txt_add("---", "-fx-font-family:\"Digital-7 Mono\"; -fx-font-size:48px; -fx-fill: firebrick; -fx-font-weight:bold; -fx-text-alignment: CENTER;", 45, 28, 200, 60)
--adf2txt = txt_add("---", "-fx-font-family:\"Digital-7 Mono\"; -fx-font-size:48px; -fx-fill: firebrick; -fx-font-weight:bold; -fx-text-alignment: CENTER;", 45, 90, 200, 60)
xpntxt = txt_add("----", "-fx-font-family:\"Digital-7 Mono\"; -fx-font-size:48px; -fx-fill: firebrick; -fx-font-weight:bold; -fx-text-alignment: CENTER;", 268, 28, 200, 60)

--function PT_radio(adf1,adf2,transponder)
	
function PT_radio(adf1,transponder)

	if adf1 == 0 then
	txt_set(adf1txt, "---")
	else
	txt_set(adf1txt, string.format("%.1f", adf1))
	end
	
	--ihs: elimino el adf2
	
	--if adf2 == 0 then
	--txt_set(adf2txt, "---")
	--else
	--txt_set(adf2txt, string.format("%.1f", adf2))
	--end

	txt_set(xpntxt, transponder)
	    
end

function PT_radio_FSX(adf1,adf2,transponder)
	
	adf1 = adf1/1000
	adf2 = adf2/1000
	
	PT_radio(adf1, adf2, transponder)

end

xpl_dataref_subscribe("sim/cockpit2/radios/actuators/adf1_frequency_hz", "INT",
					 -- "sim/cockpit2/radios/actuators/adf2_frequency_hz", "INT",
					  "sim/cockpit/radios/transponder_code", "INT", PT_radio)
fsx_variable_subscribe("ADF ACTIVE FREQUENCY:1", "Hz",
					   "ADF ACTIVE FREQUENCY:2", "Hz",
					   "TRANSPONDER CODE:1", "number", PT_radio_FSX)