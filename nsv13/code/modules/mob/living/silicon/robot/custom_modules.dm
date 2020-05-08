/obj/item/robot_module/munitions
	name = "Munitions"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/charger,
		/obj/item/flashlight/atc_wavy_sticks/cyborg,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/munitions_magnetic_clamp/cyborg,
		/obj/item/munitions_magnetic_clamp/cyborg,
		/obj/item/jetfuel_nozzle/cyborg,
		/obj/item/gun/ballistic/automatic/toy/cyborg)
	emag_modules = list()
	ratvar_modules = list()
	moduleselect_icon = "standard" //need new icon set
	hat_offset = -3 //??? icon dependant

/obj/item/robot_module/munitions/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	..()
	var/obj/item/gun/ballistic/automatic/toy/cyborg/DS = locate(/obj/item/gun/ballistic/automatic/toy/cyborg) in basic_modules
	if(DS)
		if(DS.magazine.stored_ammo.len < DS.magazine.max_ammo)
			DS.magazine.stored_ammo += new /obj/item/ammo_casing/caseless/foam_dart(src)