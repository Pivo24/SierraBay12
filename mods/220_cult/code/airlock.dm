/obj/machinery/door/airlock/use_tool(obj/item/C, mob/living/user, list/click_params)
	// Brace is considered installed on the airlock, so interacting with it is protected from electrification.
	if(brace && C && (istype(C.GetIdCard(), /obj/item/card/id) || istype(C, /obj/item/material/twohanded/jack)))
		return brace.use_tool(C, user)

	if(!brace && istype(C, /obj/item/airlock_brace))
		var/obj/item/airlock_brace/A = C
		if(!density)
			to_chat(user, SPAN_WARNING("You must close \the [src] before installing \the [A]!"))
			return TRUE

		if(!length(A.req_access) && (alert("\the [A]'s 'Access Not Set' light is flashing. Install it anyway?", "Access not set", "Yes", "No") == "No"))
			return TRUE

		playsound(user, 'sound/machines/lockreset.ogg', 50, 1)
		if(do_after(user, 6 SECONDS, src, DO_REPAIR_CONSTRUCT) && density && A && user.unEquip(A, src))
			to_chat(user, SPAN_NOTICE("You successfully install \the [A]."))
			brace = A
			brace.airlock = src
			update_icon()
		return TRUE

	if(!istype(user, /mob/living/silicon))
		if(isElectrified())
			if(shock(user, 75))
				return TRUE

	if (!repairing && MACHINE_IS_BROKEN(src) && locked) //bolted and broken
		if (cut_bolts(C,user))
			return TRUE

	if (!repairing && isWelder(C) && operating != DOOR_OPERATING_YES && density)
		var/obj/item/weldingtool/W = C
		if(!W.can_use(1, user))
			return TRUE
		playsound(src, 'sound/items/Welder.ogg', 50, 1)
		user.visible_message(SPAN_WARNING("\The [user] begins welding \the [src] [welded ? "open" : "closed"]!"),
							SPAN_NOTICE("You begin welding \the [src] [welded ? "open" : "closed"]."))
		if(do_after(user, (rand(3,5)) SECONDS, src, DO_REPAIR_CONSTRUCT))
			if (density && operating != DOOR_OPERATING_YES && !repairing && W.remove_fuel(1, user))
				playsound(src, 'sound/items/Welder2.ogg', 50, 1)
				welded = !welded
				update_icon()
				return TRUE
		else
			to_chat(user, SPAN_NOTICE("You must remain still to complete this task."))
			return TRUE

	if (isScrewdriver(C))
		if (p_open)
			if (MACHINE_IS_BROKEN(src))
				to_chat(user, SPAN_WARNING("The panel is broken, and cannot be closed."))
				return TRUE
			else
				p_open = FALSE
				user.visible_message(SPAN_NOTICE("[user.name] closes the maintenance panel on \the [src]."), SPAN_NOTICE("You close the maintenance panel on \the [src]."))
				playsound(src.loc, "sound/items/Screwdriver.ogg", 20)
				update_icon()
				return TRUE
		else
			p_open = TRUE
			user.visible_message(SPAN_NOTICE("[user.name] opens the maintenance panel on \the [src]."), SPAN_NOTICE("You open the maintenance panel on \the [src]."))
			playsound(src.loc, "sound/items/Screwdriver.ogg", 20)
			update_icon()
			return TRUE

	if (isWirecutter(C) || isMultitool(C) || istype(C, /obj/item/device/assembly/signaler))
		return attack_hand(user)

	if (istype(C, /obj/item/pai_cable))
		var/obj/item/pai_cable/cable = C
		cable.resolve_attackby(src, user)

	if (!repairing && isCrowbar(C))
		if (p_open && (operating == DOOR_OPERATING_BROKEN || (!operating && welded && !arePowerSystemsOn() && density && !locked)) && !brace)
			playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
			user.visible_message("\The [user] starts removing the electronics from the airlock assembly.", "You start to remove electronics from the airlock assembly.")
			if(do_after(user, 4 SECONDS, src, DO_REPAIR_CONSTRUCT))
				to_chat(user, SPAN_NOTICE("You've removed the airlock electronics!"))
				deconstruct(user)
				return TRUE
		else if(arePowerSystemsOn())
			to_chat(user, SPAN_NOTICE("The airlock's motors resist your efforts to force it."))
			return TRUE
		else if(locked)
			to_chat(user, SPAN_NOTICE("The airlock's bolts prevent it from being forced."))
			return TRUE
		else if(brace)
			to_chat(user, SPAN_NOTICE("The airlock's brace holds it firmly in place."))
			return TRUE
		else
			if(density)
				spawn(0)	open(1)
				return TRUE
			else
				spawn(0)	close(1)
				return TRUE

			//if door is unbroken, hit with fire axe using harm intent
	if (istype(C, /obj/item/material/twohanded/fireaxe) && !MACHINE_IS_BROKEN(src) && user.a_intent == I_HURT)
		var/obj/item/material/twohanded/fireaxe/F = C
		if (F.wielded)
			playsound(src, 'sound/weapons/smash.ogg', 100, 1)
			if (damage_health(F.force_wielded * 2, F.damtype))
				user.visible_message(SPAN_DANGER("[user] smashes \the [C] into the airlock's control panel! It explodes in a shower of sparks!"), SPAN_DANGER("You smash \the [C] into the airlock's control panel! It explodes in a shower of sparks!"))
			else
				user.visible_message(SPAN_DANGER("[user] smashes \the [C] into the airlock's control panel!"))
			return TRUE

	if (istype(C, /obj/item/material/twohanded/fireaxe) && !arePowerSystemsOn())
		if(locked)
			to_chat(user, SPAN_NOTICE("The airlock's bolts prevent it from being forced."))
			return TRUE
		else if(!welded && !operating )
			if(density)
				var/obj/item/material/twohanded/fireaxe/F = C
				if(F.wielded)
					spawn(0)	open(1)
				else
					to_chat(user, SPAN_WARNING("You need to be wielding \the [C] to do that."))
				return TRUE
			else
				var/obj/item/material/twohanded/fireaxe/F = C
				if(F.wielded)
					spawn(0)	close(1)
				else
					to_chat(user, SPAN_WARNING("You need to be wielding \the [C] to do that."))
				return TRUE

	if (istype(C, /obj/item/paper/talisman/emp)) //220_cult - обязательная строчка для взаимодействия талисмана со шлюзом
		return

	return ..()
