///////Munitions Related Misc Machinery Goes Here//////

///////TELECOMMS//////

/obj/machinery/telecomms/server/presets/munitions
	id = "Munitions Server"
	freq_listening = list(FREQ_MUNITIONS)
	autolinkers = list("munitions")

/obj/machinery/telecomms/server/presets/atc
	id = "Air Traffic Control Server"
	freq_listening = list(FREQ_ATC)
	autolinkers = list("atc")

/obj/machinery/telecomms/relay/preset/overmap
	id = "Overmap Relay"
	autolinkers = list("relay")
	use_power = NO_POWER_USE

//////SUIT STORAGE//////

/obj/machinery/suit_storage_unit/pilot
	suit_type = /obj/item/clothing/suit/space/hardsuit/pilot
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double
