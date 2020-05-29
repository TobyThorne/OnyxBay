// Glass shards

/obj/item/weapon/material/shard
	name = "shard"
	icon = 'icons/obj/shards.dmi'
	desc = "Made of nothing. How does this even exist?" // set based on material, if this desc is visible it's a bug (shards default to being made of glass)
	icon_state = "large"
	randpixel = 8
	sharp = 1
	edge = 1
	w_class = ITEM_SIZE_SMALL
	mod_weight = 0.4
	mod_reach = 0.3
	mod_handy = 0.5
	force_const = 2.0
	thrown_force_const = 2.5
	force_divisor = 0.1 // 5 with hardness 50 (glass)
	thrown_force_divisor = 0.4 // 4 with weight 15 (glass)
	item_state = "shard-glass"
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	default_material = MATERIAL_GLASS
	unbreakable = 1 //It's already broken.
	drops_debris = 0

/obj/item/weapon/material/shard/set_material(new_material)
	..(new_material)
	if(!istype(material))
		return

	icon_state = "[material.shard_icon][pick("large", "medium", "small")]"
	update_icon()

	if(material.shard_type)
		SetName("[material.display_name] [material.shard_type]")
		desc = "A small piece of [material.display_name]. It looks sharp, you wouldn't want to step on it barefoot. Could probably be used as ... a throwing weapon?"
		switch(material.shard_type)
			if(SHARD_SPLINTER, SHARD_SHRAPNEL)
				gender = PLURAL
			else
				gender = NEUTER
	else
		qdel(src)

/obj/item/weapon/material/shard/update_icon()
	if(material)
		color = material.icon_colour
		// 1-(1-x)^2, so that glass shards with 0.3 opacity end up somewhat visible at 0.51 opacity
		alpha = 255 * (1 - (1 - material.opacity)*(1 - material.opacity))
	else
		color = "#ffffff"
		alpha = 255

/obj/item/weapon/material/shard/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(isWelder(W) && material.shard_can_repair)
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			material.place_sheet(loc)
			qdel(src)
			return
	return ..()

/obj/item/weapon/material/shard/Crossed(mob/M)
	if((locate(/obj/item/weapon/material/shard) in loc) != src)
		return

	if(isliving(M))
		var/mob/living/L = M

		if(L.buckled) //wheelchairs, office chairs, rollerbeds
			return

		playsound(src.loc, 'sound/effects/glass_step.ogg', 50, 1) // not sure how to handle metal shards with sounds
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.species.siemens_coefficient<0.5 || (H.species.species_flags & (SPECIES_FLAG_NO_EMBED|SPECIES_FLAG_NO_MINOR_CUT))) //Thick skin.
				return

			if( H.shoes || ( H.wear_suit && (H.wear_suit.body_parts_covered & FEET) ) )
				return

			to_chat(M, "<span class='danger'>You step on \the [src]!</span>")

			var/amount = 0
			for(var/obj/item/weapon/material/shard/S in loc)
				amount++

			var/list/check = list(BP_L_FOOT, BP_R_FOOT)
			while(check.len)
				var/picked = pick(check)
				var/obj/item/organ/external/affecting = H.get_organ(picked)
				if(affecting)
					if(BP_IS_ROBOTIC(affecting))
						return
					affecting.take_external_damage(min(5 * amount, 15), 0)
					H.updatehealth()
					if(affecting.can_feel_pain())
						H.Weaken(min(3 * amount, 9))
					return
				check -= picked
			return

// Preset types - left here for the code that uses them
/obj/item/weapon/material/shrapnel
	name = "shrapnel"
	default_material = MATERIAL_STEEL
	w_class = ITEM_SIZE_TINY	//it's real small

/obj/item/weapon/material/shard/shrapnel/New(loc)
	..(loc, MATERIAL_STEEL)
	name = "shrapnel"
	icon_state = "shrapnel[pick("large", "medium", "small")]"
	update_icon()

/obj/item/weapon/material/shard/phoron/New(loc)
	..(loc, MATERIAL_PHORON_GLASS)
