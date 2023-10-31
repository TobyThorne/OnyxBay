
/datum/organ_condition/internal/dead
	name = "Dead"
	desc = "The organ is dead."
	id = ORCON_I_DEAD

	organ_efficiency = 0.0 // Can't work at all
	organ_pain_mult = 0.3 // Doesn't hurt as much since most nerve endings are dead, but still hurts

	var/death_time = 0

/datum/organ_condition/internal/dead/activate(obj/item/organ/O)
	O.damage = O.max_damage
	O.set_next_think(0)
	O.death_time = world.time
	if(O.owner && O.vital)
		O.owner.death()
	return
