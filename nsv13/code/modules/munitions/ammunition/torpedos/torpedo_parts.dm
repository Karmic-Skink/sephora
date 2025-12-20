/obj/item/ship_weapon/parts/missile/warhead/torpedo
	name = "\improper NTP-2 standard torpedo payload"
	icon_state = "warhead"
	desc = "An extremely heavy warhead designed to be fitted to a torpedo. This one contains a standard explosive charge."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo

/obj/item/ship_weapon/parts/missile/warhead/decoy
	name = "\improper NTP-0x 'DCY' electronic countermeasure torpedo payload"
	icon_state = "warhead_decoy"
	desc = "A simple electronic countermeasure wrapped in a metal casing. While these form inert torpedoes, they can be used to distract enemy defenses to divert their flak away from other targets."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/decoy

/obj/item/ship_weapon/parts/missile/warhead/bunker_buster
	name = "\improper NTP-4 'BNKR' torpedo payload"
	icon_state = "warhead_shredder"
	desc = "An extremely heavy warhead designed to be fitted to a torpedo. This one has an inbuilt plasma charge to amplify its damage."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/hull_shredder

/obj/item/ship_weapon/parts/missile/warhead/probe
	name = "\improper NTX 'Voyager' astrological probe payload"
	desc = "An advanced sensor suite specially kitted to collect information about astrological phenomena."
	icon_state = "warhead_probe"
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/probe

/obj/item/ship_weapon/parts/missile/warhead/freight
	name = "\improper NTP-F 530mm freight torpedo payload"
	//icon_state = "warhead_freight"
	desc = "A hollowed out nosecone that allows torpedoes to carry freight instead of an actual payload."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/freight

/obj/item/ship_weapon/parts/missile/warhead/hellfire
	name = "hellfire torpedo warhead"
	icon_state = "warhead_nuclear"
	desc = "An advanced warhead which carries a plasma enriched incendiary device. Torpedoes equipped with these can quickly annihilate targets with extreme prejudice, however they are extremely costly to produce."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/hellfire

/obj/item/ship_weapon/parts/missile/warhead/plushtide
	name = "emotional support torpedo warhead"
	icon_state = "warhead_decoy"
	desc = "A warhead with several plushies somehow crammed into it. For when what your enemy needs really is just a hug."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/plushtide

/obj/item/ship_weapon/parts/missile/warhead/proto_disruption
	name = "prototype disruption torpedo warhead"
	icon_state = "warhead_disruption"
	desc = "A prototype warhead which carries an uranium-iron core EMP payload based on recovered syndicate duds. Causes a significant electromagnetic pulse upon detonation capable of causing havoc in ship systems."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/proto_disruption

//Modular Parts
/obj/item/ship_weapon/parts/missile/warhead/modular
	name = "modular torpedo payload"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "warhead_highvelocity"
	desc = "A heavy warhead designed to be fitted to a missile. It's currently inert."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing //Used for warheads, missiles are different from torp.
	modular_part = TRUE

/obj/item/ship_weapon/parts/missile/guidance_system/modular
	name = "modular torpedo guidance system"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "guidance"
	desc = "A guidance module for soon-to-be guided munitions, allowing them to lock onto a target inside their operational range. The microcomputer inside it is capable of performing thousands of calculations a second."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	modular_part = TRUE

/obj/item/ship_weapon/parts/missile/propulsion_system/modular
	name = "modular torpedo propulsion system"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "propulsion"
	desc = "A gimballed thruster with an attachment nozzle, designed to be mounted in guided munitions."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	modular_part = TRUE

/obj/item/ship_weapon/parts/missile/iff_card/modular
	name = "modular torpedo IFF card"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "iff"
	desc = "An IFF chip which allows a guided munition to distinguish friend from foe. The electronics contained herein are relatively simple, but nonetheless crucial."
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	modular_part = TRUE
