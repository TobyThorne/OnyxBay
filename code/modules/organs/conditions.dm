
/datum/organ_condition
	var/name = "Unknown Condition"
	var/desc = "It affects an organ. Somehow."
	var/id = "condition"
	var/list/capacities = list(
		ORGAN_CAPACITY_EFFECT_OFFSET = list(),
		ORGAN_CAPACITY_EFFECT_MULT = list(),
		ORGAN_CAPACITY_EFFECT_LIMIT = list(),
		ORGAN_CAPACITY_EFFECT_KEEP = list()
		// ORGAN_CAPACITY_EFFECT = list(CAPACITY_NAME = value, CAPACITY_NAME2 = value2)
	)

	var/organ_efficiency = 1.0 // Multiplies parent organ's efficiency by this
	var/organ_damage_mult = 1.0 // Multiplies parent organ's incoming damage multiplier by this
	var/organ_pain_mult = 1.0 // Multiplies parent organ's pain multiplier by this
	var/organ_germ_mult  1.0 // Multiplies parent organ's germ multiplier by this

	var/organ_pain = 0 // How much pain it inflicts

	var/hidden = ORCON_VIS_NORMAL // How difficult it is to identify this condition
	var/permanent = FALSE // Can this condition ever be lost?

	var/stage = 0
	var/max_stage = 0

	var/active = FALSE

/datum/organ_condition/proc/update(obj/item/organ/O)
	return

/datum/organ_condition/proc/update_stage(obj/item/organ/O)
	return

/datum/organ_condition/proc/activate(obj/item/organ/O)
	return

/datum/organ_condition/proc/deactivate(obj/item/organ/O)
	return
