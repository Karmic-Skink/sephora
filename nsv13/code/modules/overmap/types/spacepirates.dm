
//Space Pirate ships go here

//AI versions

/obj/structure/overmap/spacepirate/ai
	name = "Space Pirate"
	desc = "A Space Pirate Vessel"
	icon = ''
	icon_state = ""
	faction = "pirate"
	mass = MASS_SMALL
	armor = list("overmap_light" = 30, "overmap_heavy" = 10)
	ai_trait = AI_TRAIT_DESTROYER //might need a custom trait here
	var/morale = TRUE

/obj/structure/overmap/spacepirate/ai/Initialize()
	. = ..()
	name = "[name] ([rand(0,999)])" //pirate names go here
	max_integrity = rand(350, 650)
	integrity_failure = max_integrity
	obj_integrity = max_integrity
	var/random_appearance = pick(1,2,3,4,5)
	switch(random_appearance)
		if(1)
			icon_state = ""
			collision_positions = ""
		if(2)
			icon_state = ""
			collision_positions = ""
		if(3)
			icon_state = ""
			collision_positions = ""
		if(4)
			icon_state = ""
			collision_positions = ""
		if(5)
			icon_state = ""
			collision_positions = ""

/obj/structure/overmap/spacepirate/ai/apply_weapons()
	var/random_weapons = pick(1, 2, 3, 4, 5)
	switch(random_weapons)
		if(1)
			weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount(src)
			weapon_types[FIRE_MODE_TORPEDO] = new/datum/ship_weapon/torpedo_launcher(src)
			torpedos = 10
		if(2)
			weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount(src)
			weapon_types[FIRE_MODE_RAILGUN] = new/datum/ship_weapon/railgun(src)
			shots_left = 10
		if(3)
			weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount(src)
			weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src)
		if(4)
			weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount(src)
			weapon_types[FIRE_MODE_MISSILE] = new/datum/ship_weapon/missile_launcher(src)
			missiles = 10
		if(5)
			weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount(src)
			weapon_types[FIRE_MODE_FLAK] = new/datum/ship_weapon/flak(src)

/obj/structure/overmap/spacepirate/ai/boarding //our boarding capable variant (we want to control how many of these there are)
	ai_trait = AI_TRAIT_BOARDER
