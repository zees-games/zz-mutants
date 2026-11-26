extends RefCounted

## Zombie Zone's spawn-provider contract (see the game's game/zz_packs.gd): the pack's monsters, class-free because a
## mounted pack's globals do not register. A row's `spawn.view` is the pack's own picture of it, a script under this
## directory that starts `extends "ZZ_VIEW_PARENT"`; the game seats it on its zombie view, and where the pack is
## absent on a client the monster is drawn as `spawn.body`, one of the game's own bodies.
## The game runs fine without this pack: nothing in it is named by the game.


## The game's special infected, as `core` rows: the kinds the game's director, boxes and brains name by id, defined here as data
## (kinds.gd) with their brains (brains/) and bodies (kit.gd, zombies/). Without this pack the game has none of them and runs on commons.
static func spawn_entries() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var kinds: Array = load(_dir() + "/kinds.gd").KINDS

	for k: Dictionary in kinds:
		out.append({"category": "NPCs", "id": k["id"], "name": k["name"], "icon": _dir() + "/icons/%s.png" % k["id"], "kind": "npc", "core": true, "role": k["role"], "spawn": k})

	out.append_array(_extra())
	return out


## The body tables the game's zombie view lays over its own (see ZzZombieViewBase.register_kit); [param dir] is this directory.
static func zombie_kit(dir: String) -> Dictionary:
	return load(_dir() + "/kit.gd").kit(dir)


## The line the game's credits screen shows for this pack (see ZzPacks.credit_lines).
static func credits_line() -> String:
	return "Mutants pack: Buff Mutant 2.0 by Zeldrix (CC-BY 4.0), modified; Scary, Lovcraftian, Toothy, Oil-monster by lealeelu (CC-BY 4.0), modified, teeth: Tooth and spike collection by mStuff (CC0); Scary Monster by Bekalo Animations (CC-BY 4.0)"


static func _dir() -> String:
	return (new().get_script() as Script).resource_path.get_base_dir()


## The Parasite Host: slow to start, brutal up close, and a heavy hitter with a long reach.
static func _extra() -> Array[Dictionary]:
	return [{
		"category": "NPCs",
		"id": "parasite_host",
		"name": "Parasite Host",
		"icon": _dir() + "/icons/parasite_host.png",
		"kind": "npc",
		"spawn": {
			"npc": "parasite_host",
			"health": 420.0,
			"speed": 3.1,
			"damage": 28.0,
			"reach": 2.0,
			"body": "brute",
			"view": "views/parasite_host_view.gd",
		},
		"cfg_hint": {"count": 1, "health": 420.0, "special": "a long reach and a heavy swing; walks, then runs when hurt"},
	}]
