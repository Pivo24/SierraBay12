/obj/item/organ/external/head/insectoid/nabber
	name = "head"
	vital = 0
	action_button_name = "Switch Stance" // Basically just a wrapper for switch stance verb, since GAS use it more than normals.
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_GENDERED_ICON | ORGAN_FLAG_CAN_BREAK

/obj/item/organ/external/head/insectoid/nabber/get_eye_overlay()
	var/obj/item/organ/internal/eyes/eyes = owner.internal_organs_by_name[owner.species.vision_organ ? owner.species.vision_organ : BP_EYES]
	if (!eyes)
		return

	for (var/obj/item/equipped as anything in owner.get_equipped_items())
		if (HAS_FLAGS(equipped.body_parts_covered, EYES))
			return

	return eyes.get_special_overlay()

/obj/item/organ/external/head/insectoid/nabber/refresh_action_button()
	. = ..()
	if(.)
		action.button_icon_state = "nabber-stance-[owner && owner.pulling_punches ? 1 : 0]"
		if(action.button) action.button.UpdateIcon()

/obj/item/organ/external/head/insectoid/nabber/attack_self(mob/user)
	. = ..()
	if(.)
		owner.pull_punches()
		refresh_action_button()
