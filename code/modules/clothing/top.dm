
///////////////////////////////////////////////////////////////////////
// Topwear

/obj/item/clothing/top
	icon = 'icons/obj/clothing/uniforms.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/inv_slots/uniforms/hand_l_default.dmi',
		slot_r_hand_str = 'icons/inv_slots/uniforms/hand_r_default.dmi',
		)
	name = "top"
	body_parts_covered = UPPER_TORSO|ARMS
	permeability_coefficient = 0.90
	slot_flags = SLOT_TOP
	armor = list(melee = 5, bullet = 5, laser = 5,energy = 0, bomb = 0, bio = 0)
	w_class = ITEM_SIZE_NORMAL
	force = 0
	species_restricted = list("exclude", SPECIES_MONKEY)
	var/has_sensor = SUIT_HAS_SENSORS //For the crew computer 2 = unable to change mode
	var/sensor_mode = 0
		/*
		1 = Report living/dead
		2 = Report detailed damages
		3 = Report location
		*/
	var/displays_id = 1
	var/rolled_down = -1 //0 = unrolled, 1 = rolled, -1 = cannot be toggled
	var/rolled_sleeves = -1 //0 = unrolled, 1 = rolled, -1 = cannot be toggled

	//convenience var for defining the icon state for the overlay used when the clothing is worn.
	//Also used by rolling/unrolling.
	var/worn_state = null
	valid_accessory_slots = list(ACCESSORY_SLOT_UTILITY,ACCESSORY_SLOT_HOLSTER,ACCESSORY_SLOT_ARMBAND,ACCESSORY_SLOT_RANK,ACCESSORY_SLOT_DEPT,ACCESSORY_SLOT_DECOR,ACCESSORY_SLOT_MEDAL,ACCESSORY_SLOT_INSIGNIA)
	restricted_accessory_slots = list(ACCESSORY_SLOT_UTILITY,ACCESSORY_SLOT_HOLSTER,ACCESSORY_SLOT_ARMBAND,ACCESSORY_SLOT_RANK,ACCESSORY_SLOT_DEPT)

	drop_sound = SFX_DROP_CLOTH
	pickup_sound = SFX_PICKUP_CLOTH
