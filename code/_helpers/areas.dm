//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all turfs in areas of that type in the world.
/proc/get_area_turfs(var/areatype, var/list/predicates)
	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/turfs = new/list()
	for(var/areapath in typesof(areatype))
		var/area/A = locate(areapath)
		for(var/turf/T in A.contents)
			if(!predicates || all_predicates_true(list(T), predicates))
				turfs += T
	return turfs

/proc/pick_area_turf(var/areatype, var/list/predicates)
	var/list/turfs = get_area_turfs(areatype, predicates)
	if(turfs && turfs.len)
		return pick(turfs)

/proc/is_matching_vessel(var/atom/A, var/atom/B)
	var/area/area1 = get_area(A)
	var/area/area2 = get_area(B)
	if (!area1 || !area2)
		return FALSE

	if (area1.vessel == area2.vessel)
		return TRUE
	return FALSE

/atom/proc/get_vessel()
	var/area/A = get_area(src)
	return A.vessel