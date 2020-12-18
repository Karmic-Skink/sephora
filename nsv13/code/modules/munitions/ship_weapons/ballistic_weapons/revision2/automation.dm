//Allows you to fully automate missile construction

/obj/machinery/missile_builder
	name = "Seegson model 'Ford' robotic autowrench"
	desc = "An advanced robotic arm that can be arrayed with other such devices to form an assembly line for guided munition production. Click it with a multitool to change its construction step."
	icon = 'nsv13/icons/obj/munitions/assembly.dmi'
	icon_state = "assemblybase"
	circuit = /obj/item/circuitboard/missile_builder
	anchored = TRUE
	density = TRUE
	idle_power_usage = ACTIVE_POWER_USE
	var/arm_icon_state = "welder2"
	var/tier = 1
	var/list/held_components = list() //All the missile construction components that they've put into the arm.
	var/obj/item/arm = null
	var/obj/item/ship_weapon/ammunition/missile/missile_casing/target
	var/munition_type = /obj/item/ship_weapon/ammunition/missile/missile_casing
	var/list/target_states = list(1, 7, 9) //The target construction state of the missile

/obj/item/circuitboard/missile_builder
	name = "Seegson model 'Ford' robotic autowrench (board)"
	build_path = /obj/machinery/missile_builder

/obj/item/circuitboard/missile_builder/wirer
	name = "Seegson model 'Ford' robotic autowirer (board)"
	build_path = /obj/machinery/missile_builder/wirer

/obj/machinery/missile_builder/wirer
	name = "Seegson model 'Ford' robotic autowirer"
	target_states = list(8)
	circuit = /obj/item/circuitboard/missile_builder/wirer

/obj/item/circuitboard/missile_builder/welder
	name = "Seegson model 'Ford' robotic autowelder (board)"
	build_path = /obj/machinery/missile_builder/welder

/obj/machinery/missile_builder/welder
	name = "Seegson model 'Ford' robotic autowelder"
	target_states = list(10)
	circuit = /obj/item/circuitboard/missile_builder/welder

/obj/item/circuitboard/missile_builder/screwdriver
	name = "Seegson model 'Ford' robotic bolt driver (board)"
	build_path = /obj/machinery/missile_builder/screwdriver

/obj/machinery/missile_builder/screwdriver
	name = "Seegson model 'Ford' robotic bolt driver"
	target_states = list(3,5)
	circuit = /obj/item/circuitboard/missile_builder/screwdriver

/obj/machinery/missile_builder/AltClick(mob/user)
	. = ..()
	setDir(turn(src.dir, -90))

/obj/machinery/missile_builder/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	arm = new /obj/item(src)
	arm.icon = icon
	arm.icon_state = arm_icon_state
	vis_contents += arm
	arm.mouse_opacity = FALSE

/obj/machinery/missile_builder/Destroy()
	STOP_PROCESSING(SSobj, src)
	qdel(arm)
	. = ..()

/obj/machinery/missile_builder/process()
	var/turf/input_turf = get_turf(get_step(src, src.dir))
	if(target && get_dist(target, src) > 1)
		target = null
		visible_message("[name] shakes its arm melancholically.")
		arm.shake_animation()
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
	if(target)
		arm.icon_state = arm_icon_state
		target.state++ //Next step!
		target.check_completion()
		do_sparks(10, TRUE, target)
		playsound(src, 'sound/items/welder.ogg', 100, 1)
		playsound(src, 'sound/machines/ping.ogg', 50, 0)
		target = null
		return
	target = locate(munition_type) in input_turf
	if(!target || !istype(target, munition_type))
		target = null
		return
	var/found = FALSE
	for(var/target_state in target_states)
		if(target.state == target_state)
			found = TRUE
			break

	if(!found)
		visible_message("<span class='notice'>[src] sighs.</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
		target = null
		return FALSE
	src.visible_message("<span class='notice'>[src] whirrs into life!</span>")
	arm.icon_state = "[arm_icon_state]_anim"
	playsound(src, 'sound/items/drill_use.ogg', 100, 1)

/obj/item/circuitboard/missile_builder/assembler
	name = "Seegson model 'Ford' robotic missile assembly arm (board)"
	build_path = /obj/machinery/missile_builder/assembler

/obj/machinery/missile_builder/assembler
	arm_icon_state = "assembler2"
	desc = "An assembly arm which can slot a multitude of missile components into casings for you! Swipe it with an ID to release its stored components."
	req_one_access = list(ACCESS_MUNITIONS)
	circuit = /obj/item/circuitboard/missile_builder/assembler

/obj/machinery/missile_builder/assembler/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/ship_weapon/parts/missile))
		if(!do_after(user, 0.5 SECONDS, target=src))
			return FALSE
		to_chat(user, "<span class='notice'>You slot [I] into [src], ready for construction.</span>")
		I.forceMove(src)
		held_components += I
	if(istype(I, /obj/item/card/id) && allowed(user))
		to_chat(user, "<span class='warning'>You dump [src]'s contents out.</span>")
		for(var/obj/item/X in held_components)
			X.forceMove(get_turf(src))
			held_components -= X

/obj/machinery/missile_builder/assembler/process()
	var/turf/input_turf = get_turf(get_step(src, src.dir))
	if(target && get_dist(target, src) > 1)
		target = null
		visible_message("[name] shakes its arm melancholically.")
		arm.shake_animation()
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
	if(target)
		var/found = FALSE
		for(var/obj/item/ship_weapon/parts/missile/M in held_components)
			if(target.state == M.target_state)
				M.forceMove(target)
				held_components -= M
				target.state ++
				found = TRUE
				break
		if(found)
			target.check_completion()
			playsound(src, 'sound/items/welder.ogg', 100, 1)
			playsound(src, 'sound/machines/ping.ogg', 50, 0)
			do_sparks(10, TRUE, target)
			target = null
		arm.icon_state = arm_icon_state
		return
	target = locate(munition_type) in input_turf
	if(!target || !istype(target, munition_type))
		target = null
		return
	src.visible_message("<span class='notice'>[src] whirrs into life!</span>")
	arm.icon_state = "[arm_icon_state]_anim"
	playsound(src, 'sound/items/drill_use.ogg', 100, 1)
