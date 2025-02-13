/datum/admin_secret_item/fun_secret/fix_all_lights
	name = "Fix Lights"

/datum/admin_secret_item/fun_secret/fix_all_lights/execute(mob/user)
	. = ..()
	if (!.)
		return
	var/choice = input("Fix Lights in:") as null | anything in list("Current Area", "Current Level", "Connected Levels", "All Lights")
	if (!choice)
		return
	switch (choice)
		if ("Current Area")
			var/area/usr_area = get_area(user)
			if (!usr_area)
				return to_chat(user, SPAN_DANGER("Invalid area!"))
			for (var/obj/machinery/light/light in usr_area)
				light.fix()
		if ("Current Level")
			var/user_z = get_z(user)
			if (!user_z)
				return to_chat(user, SPAN_DANGER("Invalid Z-Level!"))
			for (var/obj/machinery/light/light as anything in SSmachines.get_machinery_of_type(/obj/machinery/light))
				if (light.z == user_z)
					light.fix()
		if ("Connected Levels")
			var/list/user_levels = get_z(user)
			if (!user_levels)
				return to_chat(user, SPAN_DANGER("Invalid Z-Level!"))
			user_levels = GetConnectedZlevels(user_levels)
			for (var/obj/machinery/light/light as anything in SSmachines.get_machinery_of_type(/obj/machinery/light))
				if (light.z in user_levels)
					light.fix()
		if ("All Lights")
			for (var/obj/machinery/light/light as anything in SSmachines.get_machinery_of_type(/obj/machinery/light))
				light.fix()
