
/datum/organ_condition/rejection
	name = "Rejection"
	desc = "The organ is getting rejected by the body."
	id = ORCON_REJECTION

	organ_efficiency = 1.0

	active = TRUE

	stage = 0
	max_stage = INFINITY

	var/previous_stage = 0
	var/rejecting = 0

/datum/organ_condition/rejection/update(obj/item/organ/O)
	if(!O.owner)
		return
	if(O.owner.virus_immunity() < 10) // for now just having shit immunity will suppress it
		rejecting = max(0, rejecting - 1)
		update_stage()
		if(stage == 0)
			return
	if(O.dna)
		if(!stage)
			if(O.owner.blood_incompatible(O.dna.b_type, O.species))
				rejecting = 1
		else
			rejecting++ // Rejection severity increases over time.
			update_stage()
			if(rejecting % 10 == 0) //Only fire every ten rejection ticks.
				switch(stage)
					if(1)
						O.germ_level++
					if(2)
						O.germ_level += rand(1, 2)
					if(3)
						O.germ_level += rand(2, 3)
					if(4)
						O.germ_level += rand(3, 5)
						O.owner.reagents.add_reagent(/datum/reagent/toxin, rand(1, 2))

/datum/organ_condition/rejection/update_stage()
	previous_stage = stage
	switch(rejecting)
		if(0)
			stage = 0
			if(stage != previous_stage)
				name = "[initial(name)] (Supressed)"
				organ_efficiency = 1.0
		if(1 to 50)
			stage = 1
			if(stage != previous_stage)
				name = "[initial(name)] (Initial)"
				organ_efficiency = 0.95
		if(51 to 200)
			stage = 2
			if(stage != previous_stage)
				name = "[initial(name)] (Moderate)"
				organ_efficiency = 0.75
		if(201 to 500)
			stage = 3
			if(stage != previous_stage)
				name = "[initial(name)] (Severe)"
				organ_efficiency = 0.35
		if(501 to INFINITY)
			stage = 4
			if(stage != previous_stage)
				name = "[initial(name)] (Terminal)"
				organ_efficiency = 0.1
	return
