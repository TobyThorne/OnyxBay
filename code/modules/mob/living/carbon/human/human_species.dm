/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH
	virtual_mob = null

/mob/living/carbon/human/dummy/mannequin/Initialize()
	. = ..()
	STOP_PROCESSING(SSmobs, src)
	GLOB.human_mob_list -= src
	delete_inventory()

/mob/living/carbon/human/dummy/mannequin/add_to_living_mob_list()
	return FALSE

/mob/living/carbon/human/dummy/mannequin/add_to_dead_mob_list()
	return FALSE

/mob/living/carbon/human/dummy/mannequin/update_deformities()
	return // There's simply no need in extra processing

/mob/living/carbon/human/dummy/mannequin/fully_replace_character_name(new_name)
	..("[new_name] (mannequin)", FALSE)

/mob/living/carbon/human/dummy/mannequin/InitializeHud()
	return	// Mannequins don't get HUDs

/mob/living/carbon/human/skrell/Initialize(mapload, new_loc)
	h_style = "Skrell Male Tentacles"
	. = ..(mapload, new_loc, SPECIES_SKRELL)

/mob/living/carbon/human/tajaran/Initialize(mapload, new_loc)
	h_style = "Tajaran Ears"
	. = ..(mapload, new_loc, SPECIES_TAJARA)

/mob/living/carbon/human/unathi/Initialize(mapload, new_loc)
	h_style = "Unathi Horns"
	. = ..(mapload, new_loc, SPECIES_UNATHI)

/mob/living/carbon/human/vox/Initialize(mapload, new_loc)
	h_style = "Long Vox Quills"
	. = ..(mapload, new_loc, SPECIES_VOX)

/mob/living/carbon/human/diona/Initialize(mapload, new_loc)
	. = ..(mapload, new_loc, SPECIES_DIONA)

/mob/living/carbon/human/machine/Initialize(mapload, new_loc)
	. = ..(mapload, new_loc, SPECIES_IPC)

/mob/living/carbon/human/nabber/Initialize(mapload, new_loc)
	pulling_punches = 1
	. = ..(mapload, new_loc, SPECIES_NABBER)

/mob/living/carbon/human/monkey/Initialize(mapload, new_loc)
	. = ..(mapload, new_loc, "Monkey")

/mob/living/carbon/human/farwa/Initialize(mapload, new_loc)
	. = ..(mapload, new_loc, "Farwa")

/mob/living/carbon/human/neaera/Initialize(mapload, new_loc)
	. = ..(mapload, new_loc, "Neaera")

/mob/living/carbon/human/stok/Initialize(mapload, new_loc)
	. = ..(mapload, new_loc, "Stok")


/mob/living/carbon/human/vrhuman/Initialize(mapload, new_loc)
	. = ..(mapload, new_loc, "VR human")

/mob/living/carbon/human/gravworlder/Initialize(mapload, new_loc)
	. = ..(mapload, new_loc, "Grav-Adapted Human")

/mob/living/carbon/human/spacer/Initialize(mapload, new_loc)
	. = ..(mapload, new_loc, "Space-Adapted Human")

/mob/living/carbon/human/vatgrown/Initialize(mapload, new_loc)
	. = ..(mapload, new_loc, "Vat-Grown Human")

/mob/living/carbon/human/vatgrown/female/Initialize(mapload, new_loc)
	. = ..(mapload, new_loc, "Vat-Grown Human")
	gender = "female"
	regenerate_icons()

/mob/living/carbon/human/abductor/Initialize(mapload, new_loc)
	. = ..(mapload, new_loc, SPECIES_ABDUCTOR)
