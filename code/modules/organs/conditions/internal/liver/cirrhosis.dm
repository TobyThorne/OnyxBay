
/datum/organ_condition/internal/cirrhosis
	name = "Cirrhosis"
	desc = "A condition in which your liver is scarred and permanently damaged. Scar tissue replaces healthy liver tissue, preventing your liver from working normally and making it easily damageable."
	id = ORCON_I_CIRRHOSIS

	organ_efficiency = 0.9
	organ_damage_mult = 1.25

	stage = 1
	max_stage = 4

/datum/organ_condition/internal/cirrhosis/update_stage()
	switch(stage)
		if(1)
			name = "[initial(name)] (Initial)"
			organ_efficiency = 0.9
			organ_damage_mult = 1.25
		if(2)
			name = "[initial(name)] (Moderate)"
			organ_efficiency = 0.6
			organ_damage_mult = 1.75
		if(3)
			name = "[initial(name)] (Severe)"
			organ_efficiency = 0.3
			organ_damage_mult = 2.5
		if(4)
			name = "[initial(name)] (Terminal)"
			organ_efficiency = 0.0
			organ_damage_mult = 3.0
	return
