function new_mode(position, direction)
    
	desired_mode = position + direction
	
	if desired_mode == 0 then
		xpl_command("sim/transponder/transponder_off")
	elseif desired_mode == 1 then
		xpl_command("sim/transponder/transponder_standby")
	elseif desired_mode == 2 then
		xpl_command("sim/transponder/transponder_on")
	elseif desired_mode == 3 then
		xpl_command("sim/transponder/transponder_alt")
	elseif desired_mode == 4 then
		xpl_command("sim/transponder/transponder_test")
	end

end

function new_sqwk1000(sqwk1000)

	if sqwk1000 == 1 then
		xpl_command("sim/transponder/transponder_thousands_up")
		fsx_event("XPNDR_1000_INC")
	elseif sqwk1000 == -1 then
		xpl_command("sim/transponder/transponder_thousands_down")
		fsx_event("XPNDR_1000_DEC")
	end

end

function new_sqwk100(sqwk100)

	if sqwk100 == 1 then
		xpl_command("sim/transponder/transponder_hundreds_up")
		fsx_event("XPNDR_100_INC")
	elseif sqwk100 == -1 then
		xpl_command("sim/transponder/transponder_hundreds_down")
		fsx_event("XPNDR_100_DEC")
	end

end

function new_sqwk10(sqwk10)

	if sqwk10 == 1 then
		xpl_command("sim/transponder/transponder_tens_up")
		fsx_event("XPNDR_10_INC")
	elseif sqwk10 == -1 then
		xpl_command("sim/transponder/transponder_tens_down")
		fsx_event("XPNDR_10_DEC")
	end

end

function new_sqwk1(sqwk1)

	if sqwk1 == 1 then
		xpl_command("sim/transponder/transponder_ones_up")
		fsx_event("XPNDR_1_INC")
	elseif sqwk1 == -1 then
		xpl_command("sim/transponder/transponder_ones_down")
		fsx_event("XPNDR_1_DEC")
	end

end

function new_ident()

	xpl_command("sim/transponder/transponder_ident")

end

-- Add images in Z-order --
img_add_fullscreen("BKKT76A.png")
img_ident = img_add("light.png", 160, 54, 46, 22)

-- Set default visibility --
img_visible(img_ident, false)

-- Add text in Z-order --
txt_code_1000 = txt_add("7", " -fx-font-family: Arial; -fx-font-size:30px; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment: CENTER;", 188, 32, 200, 200)
txt_code_100 = txt_add("0", " -fx-font-family: Arial; -fx-font-size:30px; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment: CENTER;", 298, 32, 200, 200)
txt_code_10 = txt_add("0", " -fx-font-family: Arial; -fx-font-size:30px; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment: CENTER;", 411, 32, 200, 200)
txt_code_1 = txt_add("0", " -fx-font-family: Arial; -fx-font-size:30px; -fx-fill: white; -fx-font-weight:bold; -fx-text-alignment: CENTER;", 523, 32, 200, 200)

function new_transponder(id, code, mode)
	
	-- Transponder code
	txt_set(txt_code_1, code % 10)
	txt_set(txt_code_10, math.floor(code / 10 % 10) )
	txt_set(txt_code_100, math.floor(code / 100 % 10) )
	txt_set(txt_code_1000, math.floor(code / 1000 % 10) )

	-- Are we squawking ident?
	if id == 0 or mode <= 1 then
		img_visible(img_ident, false)
	elseif id == 1 and mode >= 2 then
		img_visible(img_ident, true)
	end
	
	-- Set switch state
	switch_set_state(switch_mode, mode)

end

function new_transponder_FSX(code)

	new_transponder(0, code, 3)

end

-- Switches, buttons and dials --
switch_mode = switch_add("BKKT76Amode1.png","BKKT76Amode2.png","BKKT76Amode3.png","BKKT76Amode4.png","BKKT76Amode5.png",56,62,50,50, new_mode)

dial_sqwk1000 = dial_add("BKKT76Asetbutsmall.png", 262, 65, 50, 50, new_sqwk1000)
dial_sqwk100 = dial_add("BKKT76Asetbutsmall.png", 374, 65, 50, 50, new_sqwk100)
dial_sqwk10 = dial_add("BKKT76Asetbutsmall.png", 486, 65, 50, 50, new_sqwk10)
dial_sqwk1 = dial_add("BKKT76Asetbutsmall.png", 598, 65, 50, 50, new_sqwk1)

ident = button_add("identbutton.png", "identbutton.png", 160, 54, 46, 22, new_ident)

-- Bus subscribe --
xpl_dataref_subscribe("sim/cockpit/radios/transponder_light", "INT",
					  "sim/cockpit/radios/transponder_code", "INT",
					  "sim/cockpit/radios/transponder_mode", "INT", new_transponder)
fsx_variable_subscribe("TRANSPONDER CODE:1", "Hz",
					   "TRANSPONDER AVAILABLE", "BOOL", new_transponder_FSX)