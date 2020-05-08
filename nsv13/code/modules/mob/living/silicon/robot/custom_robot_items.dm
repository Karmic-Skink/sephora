/obj/item/flashlight/atc_wavy_sticks/cyborg

/obj/item/munitions_magnetic_clamp/cyborg
	name = "Magnetic Clamp"
	desc = "Mag clamp for hauling munitions"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "disintegrate"
	var/obj/item/load = null

/obj/item/munitions_magnetic_clamp/cyborg/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(isopenturf(target))
		deploy_load(user, target)

/obj/item/munitions_magnetic_clamp/cyborg/proc/deploy_load(mob/user, atom/location)
	if(load)
		load.forceMove(location)
		user.visible_message("[user] deploys [load].", "<span class='notice'>You deploy [load].</span>")
		load = null
	else
		to_chat(user, "<span class='warning'>The clamp is empty!</span>")

/*
	if(istype(I, /obj/item/munitions_magnetic_clamp/cyborg))
		var/obj/item/munitions_magnetic_clamp/cyborg/C = I
		if(C.load)
			to_chat(user, "<span class='warning'>[C] already has [C.load] loaded!</span>")
			return
		user.visible_message("<span class='notice'>[user] loads [src].</span>", "<span class='notice'>You load [src] into [C].</span>")
		C.load = new/obj/item/(C)
		qdel(src) //"Load"
		return
	else
		return ..()
*/

/obj/item/jetfuel_nozzle/cyborg

/obj/item/gun/ballistic/automatic/toy/cyborg
	name = "Nosemounted Donksoft Cannon"
	desc = "Donksoft Air Superiority"
	burst_size = 5 //mow them all down!
	fire_delay = 1
	mag_type = /obj/item/ammo_box/magazine/toy/cyborg
	actions_types = null

obj/item/gun/ballistic/automatic/toy/cyborg/eject_magazine() //Keep that magazine in there
	return

/obj/item/ammo_box/magazine/toy/cyborg
	name = "foam force cyborg magazine"
	icon_state = "smg9mm-42"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	max_ammo = 50

//obj/item/vox_box/cyborg