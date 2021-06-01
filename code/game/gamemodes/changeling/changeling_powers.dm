
/datum/changeling //stores changeling powers, changeling recharge thingie, changeling absorbed DNA and changeling ID (for changeling hivemind)
	var/list/datum/absorbed_dna/absorbed_dna = list()
	var/list/absorbed_languages = list()
	var/absorbedcount = 0
	var/chem_charges = 20
	var/chem_recharge_rate = 0.5
	var/chem_storage = 50
	var/sting_range = 1
	var/changelingID = "Changeling"
	var/geneticdamage = 0
	var/isabsorbing = 0
	var/geneticpoints = 10
	var/purchasedpowers = list()
	var/mimicing = ""
	var/lingabsorbedcount = 1
	var/cloaked = 0
	var/armor_deployed = 0 //This is only used for changeling_generic_equip_all_slots() at the moment.
	var/recursive_enhancement = 0 //Used to power up other abilities from the ling power with the same name.
	var/list/purchased_powers_history = list() //Used for round-end report, includes respec uses too.
	var/last_shriek = null // world.time when the ling last used a shriek.
	var/next_escape = 0	// world.time when the ling can next use Escape Restraints
	var/readapts = 1
	var/max_readapts = 2
	var/true_dead = FALSE
	var/damaged = FALSE
	var/heal = 0
	var/isdetachingnow = FALSE
	var/FLP_last_time_used = 0
	var/rapidregen_active = FALSE
	var/is_revive_ready = FALSE


/datum/changeling/New()
	..()
	if(possible_changeling_IDs.len)
		changelingID = pick(possible_changeling_IDs)
		possible_changeling_IDs -= changelingID
		changelingID = "[changelingID]"
	else
		changelingID = "[rand(1,999)]"


/datum/changeling/Destroy()
	purchasedpowers = null
	absorbed_languages.Cut()
	absorbed_dna.Cut()
	. = ..()


/datum/changeling/proc/regenerate()
	chem_charges = min(max(0, chem_charges+chem_recharge_rate), chem_storage)
	geneticdamage = max(0, geneticdamage-1)


/datum/changeling/proc/GetDNA(dna_owner)
	for(var/datum/absorbed_dna/DNA in absorbed_dna)
		if(dna_owner == DNA.name)
			return DNA


/mob/proc/is_regenerating()
	if(status_flags & FAKEDEATH)
		return TRUE
	else
		return FALSE


/mob/proc/absorbDNA(datum/absorbed_dna/newDNA)
	var/datum/changeling/changeling = null
	if(src.mind && src.mind.changeling)
		changeling = src.mind.changeling
	if(!changeling)
		return

	for(var/language in newDNA.languages)
		changeling.absorbed_languages |= language

	changeling_update_languages(changeling.absorbed_languages)

	if(!changeling.GetDNA(newDNA.name)) // Don't duplicate - I wonder if it's possible for it to still be a different DNA? DNA code could use a rewrite
		changeling.absorbed_dna += newDNA


//Restores our verbs. It will only restore verbs allowed during lesser (monkey) form if we are not human
/mob/proc/make_changeling()
	if(!mind)
		return FALSE
	if(!mind.changeling)
		mind.changeling = new /datum/changeling(gender)

	verbs += /datum/changeling/proc/EvolutionMenu
	add_language("Changeling")

	var/lesser_form = !ishuman(src)

	var/mob/living/carbon/Z = src
	var/obj/item/organ/internal/biostructure/BIO = locate() in Z.contents
	if(istype(Z))
		if(!BIO && !istype(Z, /mob/living/carbon/brain))
			Z.insert_biostructure()
		else
			var/obj/item/organ/internal/brain/brain = Z.internal_organs_by_name[BP_BRAIN]
			if(brain)
				brain.vital = 0 // make our brain not vital ~~Fucking useful comment

	if(!powerinstances.len)
		for(var/P in powers)
			powerinstances += new P()

	// Code to auto-purchase free powers.
	for(var/datum/power/changeling/P in powerinstances)
		if(!P.genomecost) // Is it free?
			if(!(P in mind.changeling.purchasedpowers)) // Do we not have it already?
				mind.changeling.purchasePower(mind, P.name, 0)// Purchase it. Don't remake our verbs, we're doing it after this.

	for(var/datum/power/changeling/P in mind.changeling.purchasedpowers)
		if(P.isVerb)
			if(lesser_form && !P.allowduringlesserform)
				continue
			if(!(P in src.verbs))
				verbs += P.verbpath

	for(var/language in languages)
		mind.changeling.absorbed_languages |= language

	var/mob/living/carbon/human/H = src
	if(istype(H))
		var/datum/absorbed_dna/newDNA = new(H.real_name, H.dna, H.species.name, H.languages, H.modifiers, H.flavor_texts)
		absorbDNA(newDNA)

	return TRUE


//removes our changeling verbs
/mob/proc/remove_changeling_powers()
	if(!mind?.changeling)
		return
	for(var/datum/power/changeling/P in mind.changeling.purchasedpowers)
		if(P.isVerb)
			verbs -= P.verbpath


//Helper proc. Does all the checks and stuff for us to avoid copypasta
/mob/proc/changeling_power(required_chems = 0, required_dna = 0, max_genetic_damage = 100, max_stat = CONSCIOUS)
	if(!mind)
		return
	if(!iscarbon(src))
		return

	var/datum/changeling/changeling = mind.changeling
	if(!changeling)
		to_world_log("[src] has the changeling verb but is not a changeling.")
		return

	if(stat > max_stat)
		to_chat(src, "<span class='warning'>We are incapacitated.</span>")
		return

	if(changeling.absorbed_dna.len < required_dna)
		to_chat(src, "<span class='warning'>We require at least [required_dna] samples of compatible DNA.</span>")
		return

	if(changeling.chem_charges < required_chems)
		to_chat(src, "<span class='warning'>We require at least [required_chems] units of chemicals to do that!</span>")
		return

	if(changeling.geneticdamage > max_genetic_damage)
		to_chat(src, "<span class='warning'>Our genomes are still reassembling. We need time to recover first.</span>")
		return

	return changeling


//Used to dump the languages from the changeling datum into the actual mob.
/mob/proc/changeling_update_languages(updated_languages)
	languages = list()
	for(var/language in updated_languages)
		languages += language

	//This isn't strictly necessary but just to be safe...
	add_language("Changeling")
	return


//Speeds up chemical regeneration
/mob/proc/changeling_fastchemical()
	mind.changeling.chem_recharge_rate *= 2
	return TRUE


//Increases macimum chemical storage
/mob/proc/changeling_engorgedglands()
	mind.changeling.chem_storage += 25
	return TRUE


// HIVE MIND UPLOAD/DOWNLOAD DNA
var/list/datum/absorbed_dna/hivemind_bank = list()


//////////
//STINGS//
//////////
/mob/proc/sting_can_reach(mob/M, sting_range = 1)
	if(M.loc == src.loc)
		return TRUE //target and source are in the same thing
	if(!isturf(loc) || !isturf(M.loc))
		to_chat(src, "<span class='warning'>We cannot reach \the [M] with a sting!</span>")
		return FALSE //One is inside, the other is outside something.
	// Maximum queued turfs set to 25; I don't *think* anything raises sting_range above 2, but if it does the 25 may need raising
	if(!AStar(src.loc, M.loc, /turf/proc/AdjacentTurfs, /turf/proc/Distance, max_nodes=25, max_node_depth=sting_range)) //If we can't find a path, fail
		to_chat(src, "<span class='warning'>We cannot find a path to sting \the [M] by!</span>")
		return FALSE
	return TRUE


//Handles the general sting code to reduce on copypasta (seeming as somebody decided to make SO MANY dumb abilities)
/mob/proc/changeling_sting(verb_path, mob/living/carbon/human/T, required_chems = 0, loud = FALSE)
	if(!T)
		return
	if(!ishuman(T) || (T == src))
		T.Click()
		return

	var/datum/changeling/changeling = changeling_power(required_chems)
	if(!changeling)
		return

	if(!sting_can_reach(T, changeling.sting_range))
		return

	var/obj/item/organ/external/target_limb = T.get_organ(src.zone_sel.selecting)
	if (!target_limb)
		to_chat(src, "<span class='warning'>[T] is missing the limb we are targeting.</span>")
		return

	changeling.chem_charges -= required_chems
	changeling.sting_range = 1

	verbs -= verb_path
	spawn(1 SECOND)
		verbs += verb_path

	if(loud)
		visible_message("<span class='danger'>[src] fires an organic shard into [T]!</span>")
	else
		to_chat(src, "<span class='notice'>We stealthily sting [T].</span>")

	for(var/obj/item/clothing/clothes in list(T.head, T.wear_mask, T.wear_suit, T.w_uniform, T.gloves, T.shoes))
		if(istype(clothes) && (clothes.body_parts_covered & target_limb.body_part) && (clothes.item_flags & ITEM_FLAG_THICKMATERIAL))
			to_chat(src, "<span class='warning'>[T]'s armor has protected them.</span>")
			return //thick clothes will protect from the sting

	if(T.isSynthetic() || BP_IS_ROBOTIC(target_limb))
		return
	if(!T.mind || !T.mind.changeling)	//T will be affected by the sting
		if(target_limb.can_feel_pain())
			T.flash_pain(75)
			to_chat(T, "<span class='danger'>Your [target_limb.name] hurts.</span>")
		return T
	return


/mob/proc/changeling_generic_weapon(weapon_type, loud = TRUE, required_chems = 20)
	var/datum/changeling/changeling = changeling_power(required_chems, 1)
	if(!changeling)
		return

	if(!ishuman(src))
		return FALSE

	var/mob/living/M = src

	if(M.l_hand && M.r_hand)
		to_chat(M, "<span class='danger'>Your hands are full.</span>")
		return

	var/obj/item/weapon/W = new weapon_type(src)
	put_in_hands(W)

	changeling.chem_charges -= required_chems
	if(loud)
		playsound(src, 'sound/effects/blob/blobattack.ogg', 30, 1)
	return TRUE


/mob/proc/change_ctate(path)
	var/datum/click_handler/handler = src.GetClickHandler()
	if(!ispath(path))
		to_chat(src, "<span class='warning'>This is awkward. 1-800-CALL-CODERS to fix this.</span>")
		return
	if(handler.type == path)
		to_chat(src, "<span class='notice'>You unprepare [handler.handler_name].</span>")
		usr.PopClickHandler()
	else
		to_chat(src, "<span class='warning'>You prepare your ability.</span>")
		PushClickHandler(path)
