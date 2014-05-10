/**
* Cables 2.0.
*
*   Cables now spawn machinery objects on the turf that
* actually manage connections.  The structures are consumed
* and turn into overlays.
*
* By N3X15 for /vg/station.
*/

/**
*  Cables are basically just overlays that yell at
* the real cable linkage object (/obj/machinery/networked/power/cable)
* and tell it which directions are added/removed.
*/
/obj/structure/cable
	level = 1
	anchored =1
	name = "power cable"
	desc = "A flexible superconducting cable for heavy-duty power transfer"
	//icon = 'icons/obj/power_cond_red.dmi'
	icon_state = "0-1"

	var/d1 = 0
	var/d2 = 1
	var/coil_type = /obj/item/weapon/cable_coil
	var/obj/machinery/networked/power/cable/cable
	var/_color = "red"

	level = 1
	anchored = 1
	layer = 2.44 //Just below unary stuff, which is at 2.45 and above pipes, which are at 2.4
	icon = 'icons/obj/power_cond_white.dmi' // 500+ color :V
	color = "#FF0000"

/obj/structure/cable/yellow
	_color = "yellow"
	color = "#FFFF00"
	coil_type = /obj/item/weapon/cable_coil/yellow

/obj/structure/cable/green
	_color = "green"
	color = "#00FF00"
	coil_type = /obj/item/weapon/cable_coil/green

/obj/structure/cable/blue
	_color = "blue"
	color = "#0000FF"
	coil_type = /obj/item/weapon/cable_coil/blue

/obj/structure/cable/pink
	_color = "pink"
	color = "#FFC0CB"
	coil_type = /obj/item/weapon/cable_coil/pink

/obj/structure/cable/orange
	_color = "orange"
	color = "#FFA500"
	coil_type = /obj/item/weapon/cable_coil/orange

/obj/structure/cable/cyan
	_color = "cyan"
	color = "#00FFFF"
	coil_type = /obj/item/weapon/cable_coil/cyan

/obj/structure/cable/white
	_color = "white"
	color = "#FFFFFF"
	coil_type = /obj/item/weapon/cable_coil/white

// the power cable object
/obj/structure/cable/New()
	..()

	// ensure d1 & d2 reflect the icon_state for entering and exiting cable
	var/dash = findtext(icon_state, "-")
	d1 = text2num( copytext( icon_state, 1, dash ) )
	d2 = text2num( copytext( icon_state, dash+1 ) )

	// hide if turf is not intact
	var/turf/T = get_turf(src)
	if(level==1) hide(T.intact)

	// Connect.
	if(!T.cable)
		T.cable = new(T)
	cable = T.cable
	cable.addLink(src)

/obj/structure/cable/Destroy()
	if(cable)
		cable.rmLink(src)
	..()

/obj/structure/cable/update_icon()
	icon_state="[d1]-[d2]"

/obj/structure/cable/attack_tk(var/mob/user)
	return

/obj/structure/cable/attackby(var/obj/item/W, var/mob/user)
	var/turf/T = src.loc
	if(T.intact)
		return
	if(istype(W, /obj/item/weapon/wirecutters))
		if (cable.shock(user, 50))
			return

		new coil_type(T, d1 ? 2 : 1)

		for(var/mob/O in viewers(src, null))
			O.show_message("\red [user] cuts the [src].", 1)

		var/message = "\A [src] has been cut "
		var/atom/A = user
		if(A)
			var/turf/Z = get_turf(A)
			var/area/my_area = get_area(Z)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\power\cable.dm:104: message += " in [my_area.name]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</A>)"
			message += {"in [my_area.name]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</A>) (<A HREF='?_src_=vars;Vars=\ref[A]'>VV</A>)"}
			// END AUTOFIX
			var/mob/M = get(A, /mob)
			if(M)
				message += " - Cut By: [M.real_name] ([M.key]) (<A HREF='?_src_=holder;adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>)"
				log_game("[M.real_name] ([M.key]) cut a wire in [my_area.name] ([T.x],[T.y],[T.z])")
		message_admins(message, 0, 1)
		del(src)
		return	// not needed, but for clarity
	else if(istype(W, /obj/item/weapon/cable_coil))
		var/obj/item/weapon/cable_coil/coil = W
		coil.cable_join(src, user)

	else if(istype(W, /obj/item/device/multitool))
		if(cable.powernet && (cable.powernet.avail > 0))		// is it powered?
			user << "\red [cable.powernet.avail]W in power network."
		else
			user << "\red The [src] is not powered."

		cable.shock(user, 5, 0.2)
	else
		if (W.flags & CONDUCT)
			cable.shock(user, 50, 0.7)

	src.add_fingerprint(user)

/obj/structure/cable/hide(var/i)
	if(level == 1 && istype(loc, /turf))
		invisibility = i ? 101 : 0
	update_icon()

/obj/structure/cable/ex_act(severity)
	var/lengths = d1 ? 2 : 1
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(50))
				new coil_type(src.loc, lengths)
				qdel(src)

		if(3.0)
			if (prob(25))
				new coil_type(src.loc, lengths)
				qdel(src)