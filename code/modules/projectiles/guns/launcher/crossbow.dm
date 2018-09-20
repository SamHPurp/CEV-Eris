//AMMUNITION

/obj/item/weapon/arrow
	name = "bolt"
	desc = "It's got a tip for you - get the point?"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bolt"
	item_state = "bolt"
	throwforce = 8
	w_class = ITEM_SIZE_NORMAL
	sharp = 1
	edge = 0

/obj/item/weapon/arrow/proc/removed() //Helper for metal rods falling apart.
	return

/obj/item/weapon/spike
	name = "alloy spike"
	desc = "It's about a foot of weird silver metal with a wicked point."
	sharp = 1
	edge = 0
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	icon = 'icons/obj/weapons.dmi'
	icon_state = "metal-rod"
	item_state = "bolt"

/obj/item/weapon/arrow/quill
	name = "vox quill"
	desc = "A wickedly barbed quill from some bizarre animal."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "quill"
	item_state = "quill"
	throwforce = 5

/obj/item/weapon/arrow/rod
	name = "metal rod"
	desc = "Don't cry for me, Orithena."
	icon_state = "metal-rod"

/obj/item/weapon/arrow/rod/removed(mob/user)
	if(throwforce == 15) // The rod has been superheated - we don't want it to be useable when removed from the bow.
		user  << "[src] shatters into a scattering of overstressed metal shards as it leaves the crossbow."
		var/obj/item/weapon/material/shard/shrapnel/S = new()
		S.loc = get_turf(src)
		qdel(src)

/obj/item/weapon/gun/launcher/crossbow
	name = "powered crossbow"
	desc = "A 2557AD twist on an old classic. Pick up that can."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "crossbow"
	item_state = "crossbow-solid"
	fire_sound = 'sound/weapons/punchmiss.ogg' // TODO: Decent THWOK noise.
	fire_sound_text = "a solid thunk"
	fire_delay = 25
	slot_flags = SLOT_BACK

	var/obj/item/bolt
	var/tension = 0                         // Current draw on the bow.
	var/max_tension = 5                     // Highest possible tension.
	var/release_speed = 5                   // Speed per unit of tension.
	var/obj/item/weapon/cell/large/cell = null    // Used for firing superheated rods.
	var/current_user                        // Used to check if the crossbow has changed hands since being drawn.

/obj/item/weapon/gun/launcher/crossbow/update_release_force()
	release_force = tension*release_speed

/obj/item/weapon/gun/launcher/crossbow/consume_next_projectile(mob/user=null)
	if(tension <= 0)
		user << SPAN_WARNING("\The [src] is not drawn back!")
		return null
	return bolt

/obj/item/weapon/gun/launcher/crossbow/handle_post_fire(mob/user, atom/target)
	bolt = null
	tension = 0
	update_icon()
	..()

/obj/item/weapon/gun/launcher/crossbow/attack_self(mob/living/user as mob)
	if(tension)
		if(bolt)
			user.visible_message("[user] relaxes the tension on [src]'s string and removes [bolt].","You relax the tension on [src]'s string and remove [bolt].")
			bolt.loc = get_turf(src)
			var/obj/item/weapon/arrow/A = bolt
			bolt = null
			A.removed(user)
		else
			user.visible_message("[user] relaxes the tension on [src]'s string.","You relax the tension on [src]'s string.")
		tension = 0
		update_icon()
	else
		draw(user)

/obj/item/weapon/gun/launcher/crossbow/proc/draw(var/mob/user as mob)

	if(!bolt)
		user << "You don't have anything nocked to [src]."
		return

	if(user.restrained())
		return

	current_user = user
	user.visible_message("[user] begins to draw back the string of [src].",SPAN_NOTICE("You begin to draw back the string of [src]."))
	tension = 1

	while(bolt && tension && loc == current_user)
		if(!do_after(user, 25, src)) //crossbow strings don't just magically pull back on their own.
			user.visible_message("[usr] stops drawing and relaxes the string of [src].",SPAN_WARNING("You stop drawing back and relax the string of [src]."))
			tension = 0
			update_icon()
			return

		//double check that the user hasn't removed the bolt in the meantime
		if(!(bolt && tension && loc == current_user))
			return

		tension++
		update_icon()

		if(tension >= max_tension)
			tension = max_tension
			usr << "[src] clunks as you draw the string to its maximum tension!"
			return

		user.visible_message("[usr] draws back the string of [src]!",SPAN_NOTICE("You continue drawing back the string of [src]!"))

/obj/item/weapon/gun/launcher/crossbow/proc/increase_tension(var/mob/user as mob)

	if(!bolt || !tension || current_user != user) //Arrow has been fired, bow has been relaxed or user has changed.
		return


/obj/item/weapon/gun/launcher/crossbow/attackby(obj/item/I, mob/user)
	if(!bolt)
		if (istype(I,/obj/item/weapon/arrow))
			user.drop_from_inventory(I, src)
			bolt = I
			user.visible_message("[user] slides [bolt] into [src].","You slide [bolt] into [src].")
			update_icon()
			return
		else if(istype(I,/obj/item/stack/rods))
			var/obj/item/stack/rods/R = I
			if (R.use(1))
				bolt = new /obj/item/weapon/arrow/rod(src)
				bolt.fingerprintslast = src.fingerprintslast
				bolt.loc = src
				update_icon()
				user.visible_message("[user] jams [bolt] into [src].","You jam [bolt] into [src].")
				superheat_rod(user)
			return

	if(istype(I, /obj/item/weapon/cell/large))
		if(!cell)
			user.drop_from_inventory(cell, src)
			cell = I
			user << SPAN_NOTICE("You jam [cell] into [src] and wire it to the firing coil.")
			superheat_rod(user)
		else
			user << SPAN_NOTICE("[src] already has a cell installed.")

	else if(I.get_tool_type(usr, list(QUALITY_SCREW_DRIVING)))
		if(cell)
			var/obj/item/C = cell
			C.loc = get_turf(user)
			user << SPAN_NOTICE("You jimmy [cell] out of [src] with [I].")
			cell = null
		else
			user << SPAN_NOTICE("[src] doesn't have a cell installed.")

	else
		..()

/obj/item/weapon/gun/launcher/crossbow/proc/superheat_rod(var/mob/user)
	if(!user || !cell || !bolt) return
	if(cell.charge < 500) return
	if(bolt.throwforce >= 15) return
	if(!istype(bolt,/obj/item/weapon/arrow/rod)) return

	user << SPAN_NOTICE("[bolt] plinks and crackles as it begins to glow red-hot.")
	bolt.throwforce = 15
	bolt.icon_state = "metal-rod-superheated"
	cell.use(500)

/obj/item/weapon/gun/launcher/crossbow/update_icon()
	if(tension > 1)
		icon_state = "crossbow-drawn"
	else if(bolt)
		icon_state = "crossbow-nocked"
	else
		icon_state = "crossbow"


// Crossbow construction.
/obj/item/weapon/crossbowframe
	name = "crossbow frame"
	desc = "A half-finished crossbow."
	icon_state = "crossbowframe0"
	item_state = "crossbow-solid"

	var/buildstate = 0

/obj/item/weapon/crossbowframe/update_icon()
	icon_state = "crossbowframe[buildstate]"

/obj/item/weapon/crossbowframe/examine(mob/user)
	..(user)
	switch(buildstate)
		if(1) user << "It has a loose rod frame in place."
		if(2) user << "It has a steel backbone welded in place."
		if(3) user << "It has a steel backbone and a cell mount installed."
		if(4) user << "It has a steel backbone, plastic lath and a cell mount installed."
		if(5) user << "It has a steel cable loosely strung across the lath."

/obj/item/weapon/crossbowframe/attackby(obj/item/I, mob/user)


	var/list/usable_qualities = list()
	if(buildstate == 1)
		usable_qualities.Add(QUALITY_WELDING)
	if(buildstate == 3)
		usable_qualities.Add(QUALITY_SCREW_DRIVING)

	var/tool_type = I.get_tool_type(user, usable_qualities)
	switch(tool_type)

		if(QUALITY_WELDING)
			if(buildstate == 1)
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					user << SPAN_NOTICE("You weld the rods into place.")
					buildstate++
					update_icon()
					return
			return

		if(QUALITY_SCREW_DRIVING)
			if(buildstate == 3)
				if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					user << SPAN_NOTICE("You secure the crossbow's various parts.")
					new /obj/item/weapon/gun/launcher/crossbow(get_turf(src))
					qdel(src)
			return

		if(ABORT_CHECK)
			return

	if(istype(I,/obj/item/stack/rods))
		if(buildstate == 0)
			var/obj/item/stack/rods/R = I
			if(R.use(3))
				user << SPAN_NOTICE("You assemble a backbone of rods around the wooden stock.")
				buildstate++
				update_icon()
			else
				user << SPAN_NOTICE("You need at least three rods to complete this task.")
			return

	else if(istype(I,/obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = I
		if(buildstate == 2)
			if(C.use(5))
				user << SPAN_NOTICE("You wire a crude cell mount into the top of the crossbow.")
				buildstate++
				update_icon()
			else
				user << SPAN_NOTICE("You need at least five segments of cable coil to complete this task.")
			return
		else if(buildstate == 4)
			if(C.use(5))
				user << SPAN_NOTICE("You string a steel cable across the crossbow's lath.")
				buildstate++
				update_icon()
			else
				user << SPAN_NOTICE("You need at least five segments of cable coil to complete this task.")
			return

	else if(istype(I,/obj/item/stack/material) && I.get_material_name() == "plastic")
		if(buildstate == 3)
			var/obj/item/stack/material/P = I
			if(P.use(3))
				user << SPAN_NOTICE("You assemble and install a heavy plastic lath onto the crossbow.")
				buildstate++
				update_icon()
			else
				user << SPAN_NOTICE("You need at least three plastic sheets to complete this task.")
			return

	else
		..()
