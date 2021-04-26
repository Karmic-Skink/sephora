//FOR NT EYES ONLY
//Mk1 Prototype Defence Screen Reactor

#define REACTOR_STATE_IDLE 1
#define REACTOR_STATE_INITIALIZING 2
#define REACTOR_STATE_RUNNING 3
#define REACTOR_STATE_SHUTTING_DOWN 4
#define REACTOR_STATE_EMISSION 5

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor
	name = "mk I Prototype Defence Screen Reactor"
	desc = "A highly experimental, unstable and highly illegal nucleium driven reactor for the generation of defensive screens."
	icon = 'nsv13/icons/obj/machinery/pdsr.dmi'
	icon_state = "idle"
	pixel_x = -32
	pixel_y = -32
	density = FALSE //You can walk over it, expect death
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | FREEZE_PROOF
	light_color = LIGHT_COLOR_BLOOD_MAGIC //Dark Red
	dir = 8 //gotta pick a direction
	var/state = REACTOR_STATE_IDLE
	var/current_uptime = 0 //How long the PDSR has been running
	var/next_slowprocess = 0 //We don't need to fire more than once a second

	//Reactor Vars
	var/id = null
	var/reaction_temperature = 0 //Temperature of the reaction
	var/reaction_containment = 0 //Stability of the overall reaction
	var/reaction_polarity = 0 //Polarity of the reaction
	var/reaction_polarity_trend = 0 //Trend in the shift of polarity
	var/reaction_polarity_timer = 0 //Timer for tracking trends
	var/reaction_polarity_injection = 1 //How we are polarising our nucleium - Starts positive
	var/reaction_rate = 0 //Rate at which the reaction is occuring
	var/reaction_min_coolant_moles = 20 //Required number of coolant moles
	var/reaction_min_coolant_pressure = 100 //Required minimum pressure of coolant
	var/reaction_min_ambient_pressure = 101.25 //Checking to see that we haven't just vented the chamber
	var/reaction_injection_rate = 0 //Rate at which we are injecting nucleium in moles
	var/reaction_min_rate = 0 //Minimum rate at which nucleium can be injected in moles
	var/reaction_energy_output = 0 //How much energy we are producing for the !shields

	//!Shield Vars
	var/list/shield = list("integrity" = 0, "max_integrity" = 0, "stability" = 0)
	var/power_input = 0 //How much power is currently allocated
	var/screen_regen = 50 //Allocation to regenerate the !shields
	var/screen_hardening = 50 //Allocation to strengthen the !shields
	var/min_power_input = 0 //Minimum power required to sustain !shield integrity
	var/max_power_input = 0 //Maximum power able to be supplied to the !shields
	var/last_hit = 0 //Last time our !shield was hit
	var/active = FALSE //If projecting !shields or not
	var/connected_relays = 0 //Number of relays we have connected

	//TGUI Vars
	var/list/records = list()
	var/records_length = 120
	var/records_interval = 10
	var/records_next_interval = 0

//////General Procs///////

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/Initialize()
	.=..()
	var/obj/structure/overmap/ours = get_overmap()
	ours?.shields = src
	if(!ours)
		addtimer(CALLBACK(src, .proc/try_find_overmap), 20 SECONDS)

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/try_find_overmap()
	var/obj/structure/overmap/ours = get_overmap()
	ours?.shields = src
	if(!ours)
		message_admins("WARNING: PDSR in [get_area(src)] does not have a linked overmap!")
		log_game("WARNING: PDSR in [get_area(src)] does not have a linked overmap!")

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/try_use_power(amount)
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(!C.powernet)
			return FALSE
		var/power_in_net = C.powernet.avail-C.powernet.load

		if(power_in_net && power_in_net > amount)
			C.powernet.load += amount
			return TRUE
		return FALSE
	return FALSE

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/process()
	update_parents()
	if(next_slowprocess < world.time)
		slowprocess()
		next_slowprocess = world.time + 1 SECONDS

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/slowprocess()
	var/datum/gas_mixture/nucleium_input = airs[2]
	var/datum/gas_mixture/coolant_input = airs[1]
	var/datum/gas_mixture/coolant_output = airs[3]
	var/nuc_in = nucleium_input.get_moles(/datum/gas/nucleium)

	handle_power_reqs()

	if(state <= REACTOR_STATE_EMISSION)
		handle_relays()

	if(state == REACTOR_STATE_INITIALIZING || state == REACTOR_STATE_RUNNING)
		current_uptime ++ //Keep a log of how long we've been running
		handle_containment()

	if(state == REACTOR_STATE_INITIALIZING)
		if(reaction_containment >= 100)
			state = REACTOR_STATE_RUNNING

	if(state == REACTOR_STATE_RUNNING)
		if(nuc_in >= reaction_min_rate) //If we are running in nominal conditions...
			nucleium_input.adjust_moles(/datum/gas/nucleium, -reaction_injection_rate)
			//Handle reaction rate adjustments here
			var/target_reaction_rate = (0.5 + (1e-03 * (reaction_injection_rate ** 2))) + (current_uptime / 1000)
			var/delta_reaction_rate = target_reaction_rate - reaction_rate
			reaction_rate += delta_reaction_rate / 2 //Function goes here
			reaction_temperature += reaction_rate //Function goes
			handle_polarity(TRUE)

		else if(nuc_in < reaction_min_rate) //If we are running without sufficient nucleium...
			if(nuc_in <= 1 && reaction_rate > 5) //...and have an active mix but no nucleium

				var/target_reaction_rate = 0
				var/delta_reaction_rate = target_reaction_rate - reaction_rate
				reaction_rate += delta_reaction_rate / 2 //Function goes here
				reaction_temperature += reaction_rate * 1.5
				handle_polarity()

			else if(nuc_in <1 && reaction_rate <5) //...and is safe to shutdown
				if(reaction_rate <= 1 && min_power_input == 0)
					state = REACTOR_STATE_SHUTTING_DOWN

				else
					var/target_reaction_rate = 0
					var/delta_reaction_rate = target_reaction_rate - reaction_rate
					reaction_rate += delta_reaction_rate / 2 //Function goes here
					reaction_temperature += reaction_rate * 0.8 //Lower the heat gain

				handle_polarity() //??

			else //...and has some nucleium but not sufficient nucleium for a stable reaction
				var/bingo = nuc_in
				nucleium_input.adjust_moles(/datum/gas/nucleium, -reaction_injection_rate) //Use whatever is in there
				//Handle reaction rate adjustments here WITH PENALTIES
				var/target_reaction_rate = (0.5 + (1e-03 * (reaction_injection_rate ** 2))) + (current_uptime / 500)
				var/delta_reaction_rate = target_reaction_rate - reaction_rate
				reaction_rate += delta_reaction_rate / 2 //Function goes here
				reaction_temperature += reaction_rate * 1.33 //Heat Penalty
				//Handle polarity here
				handle_polarity(TRUE)

		if(reaction_rate > 5) //TEMP USE FUNCTIONS
			reaction_energy_output = reaction_rate //FUNCTIONS

		if(coolant_input.total_moles() >= reaction_min_coolant_moles) //Check for there being some amount of coolant
			//process some amount of heat transfer here
			var/input_coolant_energy = coolant_input.return_temperature() * coolant_input.heat_capacity()
			var/output_coolant_temp = input_coolant_energy + (reaction_temperature / 10) / coolant_input.heat_capacity() //A function of reaction temperature required
			var/delta_coolant = output_coolant_temp - coolant_input.return_temperature()
			reaction_temperature -= delta_coolant
			coolant_output.merge(coolant_input) //Pass coolant from input to output
			coolant_output.set_temperature(output_coolant_temp)
			coolant_input.clear() //Clean garbage

		handle_screens()
		handle_emission()
		handle_temperature()

	if(state == REACTOR_STATE_SHUTTING_DOWN)
		reaction_rate = 0
		reaction_temperature -= reaction_temperature / 4
		handle_temperature()
		handle_emission()
		if(reaction_temperature <= 10)
			state = REACTOR_STATE_IDLE
			current_uptime = 0
			depower_shield()

	handle_alarm()
	handle_records()
	update_icon()

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/attackby(obj/item/I, mob/living)
	if(I.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, I))
			return
		var/obj/item/multitool/M = I
		M.buffer = src
		playsound(src, 'sound/items/flashlight_on.ogg', 100, TRUE)
		to_chat(user, "<span class='notice'>Buffer loaded</span>")

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_records()
	if(world.time >= records_next_interval)
		records_next_interval = world.time + records_interval

		var/list/r_power_input = records["r_power_input"]
		r_power_input += power_input
		if(r_power_input.len > records_length)
			r_power_input.Cut(1, 2)
		var/list/r_min_power_input = records["r_min_power_input"]
		r_min_power_input += min_power_input
		if(r_min_power_input.len > records_length)
			r_min_power_input.Cut(1, 2)
		var/list/r_max_power_input = records["r_max_power_input"]
		r_max_power_input += max_power_input
		if(r_max_power_input.len > records_length)
			r_max_power_input.Cut(1, 2)
		var/list/r_reaction_polarity = records["r_reaction_polarity"]
		r_reaction_polarity += reaction_polarity
		if(r_reaction_polarity.len > records_length)
			r_reaction_polarity.Cut(1,2)
		var/list/r_reaction_containment = records["r_reaction_containment"]
		r_reaction_containment += reaction_containment
		if(r_reaction_containment.len > records_interval)
			r_reaction_containment.Cut(1,2)

//////Reactor Procs//////

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_containment() //We manage poweruse and containment here
	if(try_use_power(power_input))
		if(power_input > max_power_input && power_input <= 1.25 * max_power_input) //Overloading Containment - Rapid Rise
			var/overloading_containment = reaction_containment
			if(overloading_containment < 25)
				overloading_containment = 25
			var/overloading_function = ((8 * NUM_E **(-8 * overloading_containment)) / ((1 + NUM_E ** (-8 * overloading_containment)) ** 2)) * 2
			reaction_containment += overloading_function * (power_input / max_power_input)
			current_uptime ++ //Overloading has a cost

		else if(power_input >= min_power_input && power_input <= max_power_input) //Nominal Containment - Maintain Containment
			var/containment_function = (8 * NUM_E **(-8 * reaction_containment)) / ((1 + NUM_E ** (-8 * reaction_containment)) ** 2)
			reaction_containment += containment_function * (power_input / max_power_input)

		else if(power_input < min_power_input && power_input >= 0.75 * min_power_input) //Insufficient Power for Containment - Slow Loss
			var/loss_function = ((8 * NUM_E **(-8 * reaction_containment)) / ((1 + NUM_E ** (-8 * reaction_containment)) ** 2)) / 2
			reaction_containment += loss_function * (power_input / max_power_input)

	else //Insufficient Power for Containment - Rapid Contaiment Failure
		reaction_containment -= 3 //Check this

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_power_reqs() //How much power is required
	min_power_input = max(0, (-1e+6 + (reaction_temperature * connected_relays))) //RESOLVE THIS LATER
	max_power_input = 10e+6 + (2e+6 * connected_relays)

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_alarm()
	if(reaction_containment < 33 && state == REACTOR_STATE_RUNNING)
		to_chat("DANGER: Reaction Containment Critical. Emission Imminent.")
		playsound(src, 'nsv13/sound/effects/ship/pdsr_warning.ogg', 100, 1) //Do this properly

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_polarity(var/injecting = FALSE)
	if(reaction_polarity_timer < world.time) //Handle the trend
		reaction_polarity_timer = world.time + rand(5 SECONDS, 20 SECONDS)
		reaction_polarity_trend = (rand(-10, 10)) / 100 //To give us a range

	var/delta_polarity = reaction_polarity_trend - reaction_polarity
	if(injecting)
		reaction_polarity += (delta_polarity / 2) + (0.02 * reaction_polarity_injection)

	else
		reaction_polarity += delta_polarity / 2

	if(reaction_polarity > 1)
		reaction_polarity = 1

	else if(reaction_polarity < -1)
		reaction_polarity = -1

	var/polarity_function = reaction_polarity * (0.5 * reaction_polarity)
	reaction_containment -= polarity_function
	reaction_temperature += polarity_function * max(1, (current_uptime / 1000))

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_emission()
	if(reaction_containment <= 0)
		reaction_containment = 0

	//more goes here


/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_temperature()
	var/turf/open/L = get_turf(src)
	if(!istype(L) || !(L.air))
		return
	var/datum/gas_mixture/env = L.return_air()
	var/heat_kelvin = reaction_temperature + 273.15
	if(env.return_temperature() <= heat_kelvin)
		var/delta_env = heat_kelvin - env.return_temperature()
		var/temperature = env.return_temperature()
		env.set_temperature(temperature += delta_env / 2)
		air_update_turf()

	reaction_containment -= (reaction_temperature / 50) + (current_uptime / 1000)


/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/update_icon()
	switch(state)
		if(REACTOR_STATE_EMISSION)
			icon_state = "emission"
			return
		if(REACTOR_STATE_SHUTTING_DOWN)
			icon_state = "shutdown"
			return
		if(REACTOR_STATE_RUNNING)
			icon_state = "running"
			return
		if(REACTOR_STATE_INITIALIZING)
			icon_state = "initializing"
			return
		if(REACTOR_STATE_IDLE)
			icon_state = "idle"
			return

//////Shield Procs//////

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/absorb_hit(damage)
	if(!active)
		return FALSE //!shields not raised

	if(shield["integrity"] >= damage)
		shield["integrity"] -= damage //Deduct from !shield
		var/current_hit = world.time
		if(current_hit <= last_hit + 10) //1 Second
			shield["stability"] -= rand((damage / 20), (damage / 10)) //Rapid hits will reduce stability greatly

		else
			shield["stability"] -= rand((damage / 100), (damage / 50)) //Reduce !shield stability

		last_hit = current_hit //Set our last hit
		if(shield["stability"] <= 0)
			shield["stability"] = 0
			active = FALSE //Collapse !shield
			var/sound = 'nsv13/sound/effects/ship/ship_hit_shields_down.ogg'
			var/obj/structure/overmap/OM = get_overmap()
			OM?.relay(sound, null, loop=FALSE, channel = CHANNEL_SHIP_FX)
			current_uptime += 5

		return TRUE

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_screens()
	if(!active)
		shield["stability"] ++ //Realign the screen manifold
		if(shield["stability"] >= 100)
			shield["stability"] = 100
			active = TRUE //Renable !shields

	else if(active)
		var/screen_energy = reaction_energy_output
		shield["stability"] += power_input / ((max_power_input * 1.5) - max(min_power_input, 0))
		if(shield["stability"] > 100)
			shield["stability"] = 100
		var/hardening_allocation = max(((screen_hardening / 100) * screen_energy), 0)
		screen_energy -= hardening_allocation
		shield["max_integrity"] = hardening_allocation * (connected_relays * 100) //Each relay is worth 100 shield points
		var/regen_allocation = max(((screen_regen / 100) * screen_energy), 0)
		screen_energy -= regen_allocation
		shield["integrity"] += regen_allocation
		if(shield["integrity"] > shield["max_integrity"])
			shield["integrity"] = shield["max_integrity"]

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/handle_relays() //Checking to see how many relays we have
	connected_relays = 0
	for(var/obj/machinery/defense_screen_relay/DSR in GLOB.machines)
		if(powered())
			connected_relays ++

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/proc/depower_shield()
	shield["integrity"] = 0
	shield["max_integrity"] = 0
	shield["stability"] = 0
	active = FALSE

//////MAINFRAME CONSOLE//////

/obj/machinery/computer/ship/defence_screen_mainframe_reactor //For controlling the reactor
	name = "mk I Prototype Defence Screen Mainframe"
	desc = "The mainframe controller for the PDSR"
	icon_screen = "idhos" //temp
	req_access = list(ACCESS_ENGINE)
	circuit = /obj/item/circuitboard/computer/defence_screen_mainframe_reactor
	var/id = null
	var/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/reactor //Connected reactor

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, I))
			return
		var/obj/item/multitool/M = I
		reactor = M.buffer
		M.buffer = null
		playsound(src, 'sound/items/flashlight_on.ogg', 100, TRUE)
		to_chat(user, "<span class='notice'>Buffer transfered</span>")

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/attack_hand(mob/user)
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	if(!reactor)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return

	ui_interact(user)

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/attack_ai(mob/user)
	. = ..()
	if(!reactor)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return
	ui_interact(user)

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/attack_robot(mob/user)
	. = ..()
	if(!reactor)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return
	ui_interact(user)

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/attack_ghost(mob/user)
	if(!reactor)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return
	. = ..() //parent should call ui_interact

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/LateInitialize()
	if(id) //If mappers set an ID)
		for(var/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/dsr in GLOB.machines)
			if(dsr.id == id)
				reactor = dsr

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PDSRMainframe")
		ui.open()

/obj/machinery/computer/ship/defence_screen_mainframe_reactor/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(!reactor)
		return
	var/adjust = text2num(params["adjust"])
	if(action == "injection_allocation")
		if(adjust && isnum(adjust))
			reactor.reaction_injection_rate = adjust
			if(reactor.reaction_injection_rate > 25)
				reactor.reaction_injection_rate = 25
			if(reactor.reaction_injection_rate < 0)
				reactor.reaction_injection_rate = 0

	switch(action)
		if("polarity")
			reactor.reaction_polarity_injection = !reactor.reaction_polarity_injection



/obj/machinery/computer/ship/defence_screen_mainframe_reactor/ui_data(mob/user)
	var/list/data = list()
	data["r_temp"] = reactor.reaction_temperature
	data["r_containment"] = reactor.reaction_containment
	data["r_polarity"] = reactor.reaction_polarity
	data["r_reaction_rate"] = reactor.reaction_rate
	data["r_injection_rate"] = reactor.reaction_injection_rate
	data["r_polarity_injection"] = reactor.reaction_polarity_injection
	data["r_energy_output"] = reactor.reaction_energy_output
	data["r_power_input"] = reactor.power_input
	data["records"] = reactor.records
	return data

/obj/item/circuitboard/computer/defence_screen_mainframe_reactor
	name = "mk I Prototype Defence Screen Mainframe (Computer Board)"
	build_path = /obj/machinery/computer/ship/reactor_control_computer

//////SCREEN MANIPULATOR//////

/obj/machinery/computer/ship/defense_screen_mainframe_shield //For controlling the !shield
	name = "mk I Prototype Defence Screen Manipulator"
	desc = "The screen manipulator for the PDSR"
	icon_screen = "security" //temp
	req_access = list(ACCESS_ENGINE)
	var/id = null
	var/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/reactor //Connected reactor

/obj/machinery/computer/ship/defense_screen_mainframe_shield/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, I))
			return
		var/obj/item/multitool/M = I
		reactor = M.buffer
		M.buffer = null
		playsound(src, 'sound/items/flashlight_on.ogg', 100, TRUE)
		to_chat(user, "<span class='notice'>Buffer transfered</span>")

/obj/machinery/computer/ship/defense_screen_mainframe_shield/attack_hand(mob/user)
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	if(!reactor)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return

	ui_interact(user)

/obj/machinery/computer/ship/defense_screen_mainframe_shield/attack_ai(mob/user)
	. = ..()
	if(!reactor)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return
	ui_interact(user)

/obj/machinery/computer/ship/defense_screen_mainframe_shield/attack_robot(mob/user)
	. = ..()
	if(!reactor)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return
	ui_interact(user)

/obj/machinery/computer/ship/defense_screen_mainframe_shield/attack_ghost(mob/user)
	if(!reactor)
		to_chat(user, "<span class='warning'>Unable to detect linked reactor</span>")
		return
	. = ..()

/obj/machinery/computer/ship/defense_screen_mainframe_shield/LateInitialize()
	if(id) //If mappers set an ID)
		for(var/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/dsr in GLOB.machines)
			if(dsr.id == id)
				reactor = dsr

/obj/machinery/computer/ship/defense_screen_mainframe_shield/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PDSRManipulator")
		ui.open()

/obj/machinery/computer/ship/defense_screen_mainframe_shield/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(!reactor)
		return
	var/adjust = text2num(params["adjust"])
	if(action == "regen")
		if(adjust && isnum(adjust))
			reactor.screen_regen = adjust
			reactor.screen_hardening = 100 - reactor.screen_regen

	if(action == "hardening")
		if(adjust && isnum(adjust))
			reactor.screen_hardening = adjust
			reactor.screen_regen = 100 - reactor.screen_hardening

	if(action == "power_allocation")
		if(adjust && isnum(adjust))
			reactor.power_input = adjust
			if(reactor.power_input > (reactor.max_power_input * 1.25))
				reactor.power_input = reactor.max_power_input * 1.25

			if(reactor.power_input < 0)
				reactor.power_input = 0



/obj/machinery/computer/ship/defense_screen_mainframe_shield/ui_data(mob/user)
	var/list/data = list()
	data["r_power_input"] = reactor.power_input
	data["r_min_power_input"] = reactor.min_power_input
	data["r_max_power_input"] = reactor.max_power_input
	data["s_active"] = reactor.active
	data["s_regen"] = reactor.screen_regen
	data["s_hardening"] = reactor.screen_hardening
	data["s_integrity"] = reactor.shield["integrity"]
	data["s_max_integrity"] = reactor.shield["max_integrity"]
	data["s_stability"] = reactor.shield["stability"]
	data["records"] = reactor.records
	data["available_power"] = 0
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(C.powernet)
			data["available_power"] = C.powernet.avail-C.powernet.load

	return data

/obj/item/circuitboard/computer/defense_screen_mainframe_shield
	name = "mk I Prototype Defence Screen Manipulator (Computer Board)"
	build_path = /obj/machinery/computer/ship/defense_screen_mainframe_shield






/obj/machinery/defense_screen_relay
	name = "mk I Prototype Defence Screen Relay"
	desc = "A relay for distributing"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	anchored = TRUE
	density = TRUE


#undef REACTOR_STATE_IDLE
#undef REACTOR_STATE_INITIALIZING
#undef REACTOR_STATE_RUNNING
#undef REACTOR_STATE_SHUTTING_DOWN
#undef REACTOR_STATE_EMISSION
