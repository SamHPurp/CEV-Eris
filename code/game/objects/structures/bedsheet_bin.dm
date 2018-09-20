/*
CONTAINS:
BEDSHEETS
LINEN BINS
*/

/obj/item/weapon/bedsheet
	name = "bedsheet"
	desc = "A surprisingly soft linen bedsheet."
	icon = 'icons/obj/items.dmi'
	icon_state = "sheet"
	item_state = "bedsheet"
	layer = 4.0
	throwforce = WEAPON_FORCE_HARMLESS
	throw_speed = 1
	throw_range = 2
	w_class = ITEM_SIZE_SMALL

/obj/item/weapon/bedsheet/attack_self(mob/user as mob)
	user.drop_from_inventory(src)
	if(layer == initial(layer))
		layer = ABOVE_MOB_LAYER
	else
		layer = initial(layer)
	add_fingerprint(user)

/obj/item/weapon/bedsheet/attackby(obj/item/I, mob/user)
	if(is_sharp(I))
		user.visible_message(
			SPAN_NOTICE("\The [user] begins cutting up \the [src] with \a [I]."),
			SPAN_NOTICE("You begin cutting up \the [src] with \the [I].")
		)
		if(do_after(user, 50, src))
			user << SPAN_NOTICE("You cut \the [src] into pieces!")
			for(var/i in 1 to rand(2,5))
				new /obj/item/weapon/reagent_containers/glass/rag(get_turf(src))
			qdel(src)
		return
	..()

/obj/item/weapon/bedsheet/blue
	icon_state = "sheetblue"

/obj/item/weapon/bedsheet/green
	icon_state = "sheetgreen"

/obj/item/weapon/bedsheet/orange
	icon_state = "sheetorange"

/obj/item/weapon/bedsheet/purple
	icon_state = "sheetpurple"

/obj/item/weapon/bedsheet/rainbow
	icon_state = "sheetrainbow"

/obj/item/weapon/bedsheet/red
	icon_state = "sheetred"

/obj/item/weapon/bedsheet/yellow
	icon_state = "sheetyellow"

/obj/item/weapon/bedsheet/mime
	icon_state = "sheetmime"

/obj/item/weapon/bedsheet/clown
	icon_state = "sheetclown"

/obj/item/weapon/bedsheet/captain
	icon_state = "sheetcaptain"

/obj/item/weapon/bedsheet/rd
	icon_state = "sheetrd"

/obj/item/weapon/bedsheet/medical
	icon_state = "sheetmedical"

/obj/item/weapon/bedsheet/hos
	icon_state = "sheethos"

/obj/item/weapon/bedsheet/hop
	icon_state = "sheethop"

/obj/item/weapon/bedsheet/ce
	icon_state = "sheetce"

/obj/item/weapon/bedsheet/brown
	icon_state = "sheetbrown"


/obj/structure/bedsheetbin
	name = "linen bin"
	desc = "A linen bin. It looks rather cosy."
	icon = 'icons/obj/structures.dmi'
	icon_state = "linenbin-full"
	anchored = 1
	var/amount = 20
	var/list/sheets = list()
	var/obj/item/hidden = null


/obj/structure/bedsheetbin/examine(mob/user)
	..(user)

	if(amount < 1)
		user << "There are no bed sheets in the bin."
		return
	if(amount == 1)
		user << "There is one bed sheet in the bin."
		return
	user << "There are [amount] bed sheets in the bin."


/obj/structure/bedsheetbin/update_icon()
	switch(amount)
		if(0)				icon_state = "linenbin-empty"
		if(1 to amount / 2)	icon_state = "linenbin-half"
		else				icon_state = "linenbin-full"


/obj/structure/bedsheetbin/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/bedsheet))
		user.drop_from_inventory(I, src)
		sheets.Add(I)
		amount++
		user << SPAN_NOTICE("You put [I] in [src].")
	//make sure there's sheets to hide it among, make sure nothing else is hidden in there.
	else if(amount && !hidden && I.w_class < ITEM_SIZE_LARGE)
		user.drop_from_inventory(I, src)
		hidden = I
		user << SPAN_NOTICE("You hide [I] among the sheets.")

/obj/structure/bedsheetbin/attack_hand(mob/user as mob)
	if(amount >= 1)
		amount--

		var/obj/item/weapon/bedsheet/B
		if(sheets.len > 0)
			B = sheets[sheets.len]
			sheets.Remove(B)

		else
			B = new /obj/item/weapon/bedsheet(loc)

		B.loc = user.loc
		user.put_in_hands(B)
		user << SPAN_NOTICE("You take [B] out of [src].")

		if(hidden)
			hidden.loc = user.loc
			user << SPAN_NOTICE("[hidden] falls out of [B]!")
			hidden = null


	add_fingerprint(user)

/obj/structure/bedsheetbin/attack_tk(mob/user as mob)
	if(amount >= 1)
		amount--

		var/obj/item/weapon/bedsheet/B
		if(sheets.len > 0)
			B = sheets[sheets.len]
			sheets.Remove(B)

		else
			B = new /obj/item/weapon/bedsheet(loc)

		B.loc = loc
		user << SPAN_NOTICE("You telekinetically remove [B] from [src].")
		update_icon()

		if(hidden)
			hidden.loc = loc
			hidden = null


	add_fingerprint(user)
