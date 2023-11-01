var/list/organ_cache = list()

/obj/item/organ
	name = "organ"
	icon = 'icons/mob/human_races/organs/human.dmi'
	w_class = ITEM_SIZE_TINY
	dir = SOUTH

	// Strings.
	var/organ_tag = "organ"           // Unique identifier.
	var/parent_organ = BP_CHEST       // Organ holding this object.

	// Status tracking.
	var/status = 0                    // Various status flags (such as robotic)
	var/vital = FALSE                 // Lose a vital limb, die immediately.
	var/list/capacities = list(
		// CAPACITY_NAME = importance
	)
	var/list/default_conditions = list() // Contains OROCON IDs
	var/list/conditions = list()
	var/list/active_conditions = list() // Thinking conditions

	var/efficiency = 1.0

	// Reference data.
	var/mob/living/carbon/human/owner // Current mob owning the organ.
	var/datum/dna/dna                 // Original DNA.
	var/datum/species/species         // Original species.

	// Damage vars.
	var/health = 0                    // Current damage to the organ
	var/broken_health = 0             // Damage before becoming broken
	var/max_health = 100              // Damage cap
	var/damage_mult = 1.0             // Incoming damage multiplier
	var/pain = 0                      // How much pain we hold
	var/pain_mult = 1.0               // Pain multiplier
	var/conditional_pain = 0          // Constant pain from conditions
	var/germ_mult = 1.0               // How prone to infections it is
	var/rejecting = FALSE             // Is this organ already being rejected?

	var/death_time = 0

	var/food_organ_type                              // path of food made from organ, ex.
	var/obj/item/reagent_containers/food/food_organ
	var/is_edible = FALSE                            // used to override food_organ's creation and using

/obj/item/organ/New(mob/living/carbon/holder)
	..(holder)

	if(food_organ_type && is_edible)
		food_organ = new food_organ_type(src)

	if(max_health && !broken_health)
		broken_health = Floor(max_health * 0.5)

	if(istype(holder))
		owner = holder
		w_class = max(w_class + mob_size_difference(holder.mob_size, MOB_MEDIUM), 1) //smaller mobs have smaller organs.

		if(holder.dna)
			dna = holder.dna.Clone()
			species = all_species[dna.species]
		else
			species = all_species[SPECIES_HUMAN]
			log_debug("[src] spawned in [holder] without a proper DNA.")

	if(dna)
		if(!blood_DNA)
			blood_DNA = list()
		blood_DNA[dna.unique_enzymes] = dna.b_type

	create_reagents(5 * (w_class-1)**2)
	reagents.add_reagent(/datum/reagent/nutriment/protein, reagents.maximum_volume)

	for(var/id in default_conditions)
		add_condition(id, FALSE)
	update_conditions()

	update_icon()

/obj/item/organ/Destroy()
	owner = null
	dna = null
	QDEL_NULL(food_organ)
	QDEL_NULL_LIST(conditions)
	active_conditions.Cut()
	capacities.Cut()
	return ..()

/obj/item/organ/proc/add_condition(var/condition_id, update_conditions = TRUE)
	if(!condition_id || !(condition_id in GLOB.organ_conditions))
		return FALSE
	conditions[condition_id] = new GLOB.organ_conditions[condition_id]()
	active_conditions.Add(conditions[condition_id])
	if(update_conditions)
		update_conditions()
	return TRUE

/obj/item/organ/proc/remove_condition(var/condition_id, update_conditions = TRUE)
	if(!condition_id || !(condition_id in GLOB.organ_conditions) || !conditions[condition_id])
		return FALSE
	active_conditions.Remove(conditions[conditions_id])
	qdel(conditions[conditions_id])
	conditions.Remove(conditions_id)
	if(update_conditions)
		update_conditions()
	return TRUE

/obj/item/organ/proc/get_condition(var/condition_id)
	if(!condition_id || !(condition_id in GLOB.organ_conditions) || !conditions[condition_id])
		return null
	return conditions[conditions_id]

/obj/item/organ/proc/update_conditions()
	efficiency = initial(efficiency)
	max_health = initial(max_health)
	damage_mult = initial(damage_mult)
	pain_mult = initial(pain_mult)
	conditional_pain = initial(conditional_pain)
	for(var/datum/organ_condition/OC in conditions)
		OC.update()
		efficiency *= OC.organ_efficiency
		damage_mult *= OC.organ_damage_mult
		pain_mult *= OC.organ_pain_mult
		conditional_pain += OC.organ_pain

/obj/item/organ/proc/update_pain()
	pain = 0
	pain += conditional_pain
	pain += (max_health - health)
	pain *= pain_mult
	return pain

/obj/item/organ/proc/update_health()
	return

/obj/item/organ/proc/set_dna(datum/dna/new_dna)
	if(new_dna)
		dna = new_dna.Clone()
		if(!blood_DNA)
			blood_DNA = list()
		blood_DNA.Cut()
		blood_DNA[dna.unique_enzymes] = dna.b_type
		species = all_species[new_dna.species]

/obj/item/organ/think()
	if(loc != owner)
		owner = null

	//Process infections
	if(BP_IS_ROBOTIC(src) || (owner?.species?.species_flags & SPECIES_FLAG_IS_PLANT))
		germ_level = 0
		// If `think()` is called not by the owner in `handle_organs()` but on his own.
		if(NEXT_THINK)
			set_next_think(world.time + 1 SECOND)
		return

	if(owner)
		if(isundead(owner))
			germ_level = 0
			if(NEXT_THINK)
				set_next_think(world.time + 1 SECOND)
			return
	else
		if(reagents && !is_preserved())
			var/datum/reagent/blood/B = locate(/datum/reagent/blood) in reagents.reagent_list
			if(B && prob(40))
				reagents.remove_reagent(/datum/reagent/blood, 0.1)
				blood_splatter(src, B, 1)
			if(config.health.organs_can_decay)
				take_general_damage(rand(1, 3))
			germ_level += rand(2, 6)
			if(germ_level >= INFECTION_LEVEL_TWO)
				germ_level += rand(2, 6)
			if(germ_level >= INFECTION_LEVEL_THREE)
				die()

	else if(owner.bodytemperature >= 170) // Cryo stops germs from moving and doing their bad stuffs
		// Handle antibiotics and curing infections
		handle_antibiotics()
		handle_rejection()
		handle_germ_effects()

	//check if we've hit max_damage
	if(damage >= max_damage)
		die()

	if(food_organ)
		update_food_from_organ()

	// If `think()` is called not by the owner in `handle_organs()` but on his own.
	if(NEXT_THINK)
		set_next_think(world.time + 1 SECOND)

/obj/item/organ/proc/cook_organ()
	die()

/obj/item/organ/proc/is_preserved()
	if(istype(loc,/obj/item/organ))
		var/obj/item/organ/O = loc
		return O.is_preserved()
	else
		return (istype(loc,/obj/item/organ/internal/cerebrum/mmi) || istype(loc,/obj/structure/closet/body_bag/cryobag) || istype(loc,/obj/structure/closet/crate/freezer) || istype(loc,/obj/item/storage/box/freezer) || istype(loc,/mob/living/simple_animal/hostile/little_changeling))

/obj/item/organ/_examine_text(mob/user)
	. = ..()
	. += "\n[show_decay_status(user)]"
	if(get_dist(src, user) > 1)
		return
	. += food_organ.get_bitecount()

/obj/item/organ/proc/show_decay_status(mob/user)
	if(status & ORGAN_DEAD)
		return SPAN_NOTICE("\The [src] looks severely damaged.")

/obj/item/organ/proc/handle_germ_effects()
	//** Handle the effects of infections

	var/virus_immunity = owner.virus_immunity()

	var/antibiotics = owner.chem_effects[CE_ANTIBIOTIC]

	if (germ_level > 0 && germ_level < INFECTION_LEVEL_ONE/2 && prob(virus_immunity*0.3))
		germ_level--

	if (germ_level >= INFECTION_LEVEL_ONE/2)
		//aiming for germ level to go from ambient to INFECTION_LEVEL_TWO in an average of 15 minutes
		if(antibiotics < 5 && prob(round(germ_level/6 * owner.immunity_weakness() * 0.01)))
			if(virus_immunity > 0)
				germ_level += round(1/virus_immunity, 1) // Immunity starts at 100. This doubles infection rate at 50% immunity. Rounded to nearest whole.
			else // Will only trigger if immunity has hit zero. Once it does, 10x infection rate.
				germ_level += 10

	if(germ_level >= INFECTION_LEVEL_ONE)
		var/fever_temperature = (owner.species.heat_level_1 - owner.species.body_temperature - 5)* min(germ_level/INFECTION_LEVEL_TWO, 1) + owner.species.body_temperature
		owner.bodytemperature += between(0, (fever_temperature - (20 CELSIUS))/BODYTEMP_COLD_DIVISOR + 1, fever_temperature - owner.bodytemperature)

	if (germ_level >= INFECTION_LEVEL_TWO)
		var/obj/item/organ/external/parent = owner.get_organ(parent_organ)
		//spread germs
		if (antibiotics < 5 && parent.germ_level < germ_level && ( parent.germ_level < INFECTION_LEVEL_ONE*2 || prob(owner.immunity_weakness() * 0.3) ))
			parent.germ_level++

		if (prob(3))	//about once every 30 seconds
			take_general_damage(1,silent=prob(30))

/obj/item/organ/proc/remove_rejuv()
	qdel(src)

/obj/item/organ/proc/rejuvenate(ignore_prosthetic_prefs = FALSE)
	damage = 0
	status = 0
	if(!ignore_prosthetic_prefs && owner && owner.client && owner.client.prefs && owner.client.prefs.real_name == owner.real_name)
		var/status = owner.client.prefs.organ_data[organ_tag]
		if(status == "assisted")
			mechassist()
		else if(status == "mechanical")
			robotize()

//Germs
/obj/item/organ/proc/handle_antibiotics()
	if(!owner || !germ_level)
		return
	var/antibiotics = owner.chem_effects[CE_ANTIBIOTIC]
	if(!antibiotics)
		return

	if (germ_level < INFECTION_LEVEL_ONE)
		germ_level = 0	//cure instantly
	else if (germ_level < INFECTION_LEVEL_TWO)
		germ_level -= 5	//at germ_level == 500, this should cure the infection in 5 minutes
	else
		germ_level -= 3 //at germ_level == 1000, this will cure the infection in 10 minutes

/obj/item/organ/proc/take_general_damage(amount, silent = FALSE)
	CRASH("Not Implemented")

/obj/item/organ/proc/heal_damage(amount)
	damage = between(0, damage - round(amount, 0.1), max_damage)

/**
 *  Remove an organ
 *
 *  drop_organ - if true, organ will be dropped at the loc of its former owner
 */
/obj/item/organ/proc/removed(mob/living/user, drop_organ = TRUE)
	if(!istype(owner))
		return

	if(drop_organ)
		dropInto(owner.loc)

	playsound(src, SFX_FIGHTING_CRUNCH, rand(65, 80), FALSE)

	// Start processing the organ on his own
	set_next_think(world.time)
	rejecting = null
	if(!BP_IS_ROBOTIC(src))
		var/datum/reagent/blood/organ_blood = locate(/datum/reagent/blood) in reagents.reagent_list //TODO fix this and all other occurences of locate(/datum/reagent/blood) horror
		if(!organ_blood || !organ_blood.data["blood_DNA"])
			owner.vessel.trans_to(src, 5, 1, 1)

	if(owner && vital)
		if(user)
			admin_attack_log(user, owner, "Removed a vital organ ([src]).", "Had a vital organ ([src]) removed.", "removed a vital organ ([src]) from")
		owner.death()

	owner = null

/obj/item/organ/proc/replaced(mob/living/carbon/human/target, obj/item/organ/external/affected)
	owner = target
	forceMove(owner)
	if(BP_IS_ROBOTIC(src))
		set_dna(owner.dna)
	update_conditions()
	return 1

/obj/item/organ/attack(mob/target, mob/user)
	if(status & ORGAN_ROBOTIC || !istype(target) || !istype(user) || (user != target && user.a_intent == I_HELP))
		return ..()

	if(food_organ.bitecount == 0)
		if(alert("Do you really want to use this organ as food? It will be useless for anything else afterwards.",,"Ew, no.","Bon appetit!") == "Ew, no.")
			to_chat(user, SPAN_NOTICE("You successfully repress your cannibalistic tendencies."))
			return
		update_food_from_organ()
		cook_organ()

	if(QDELETED(src))
		return

	target.attackby(return_item(), user)

/obj/item/organ/proc/can_recover()
	return (!(status & ORGAN_DEAD) || death_time >= world.time - ORGAN_RECOVERY_THRESHOLD)

/obj/item/organ/proc/get_scan_results()
	. = list()
	if(BP_IS_ASSISTED(src))
		. += "Assisted"
	else if(BP_IS_ROBOTIC(src))
		. += "Mechanical"

	if(status & ORGAN_CUT_AWAY)
		. += "Severed"
	if(status & ORGAN_MUTATED)
		. += "Genetic Deformation"
	if(status & ORGAN_DEAD)
		if(can_recover())
			. += "Critical"
		else
			. += "Destroyed"
	switch (germ_level)
		if (INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE + 200)
			. +=  "Mild Infection"
		if (INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
			. +=  "Mild Infection+"
		if (INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
			. +=  "Mild Infection++"
		if (INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
			. +=  "Acute Infection"
		if (INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
			. +=  "Acute Infection+"
		if (INFECTION_LEVEL_TWO + 300 to INFECTION_LEVEL_TWO + 400)
			. +=  "Acute Infection++"
		if (INFECTION_LEVEL_THREE to INFINITY)
			. +=  "Septic"
	if(rejecting)
		. += "Genetic Rejection"


//used by stethoscope
/obj/item/organ/proc/stethoscope_results()
	return


// Edible organs yay
/obj/item/organ/return_item()
	return food_organ

/obj/item/organ/proc/organ_eaten(mob/user)
	qdel(src)

/obj/item/organ/proc/update_food_from_organ()
	food_organ.SetName(name)
	food_organ.appearance = src
	reagents.trans_to(food_organ, reagents.total_volume)
