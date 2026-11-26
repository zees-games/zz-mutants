extends RefCounted

## Zombie Zone's spawn-provider contract (see the game's game/zz_packs.gd): the pack's monsters, class-free because a
## mounted pack's globals do not register. A row's `spawn.view` is the pack's own picture of it, a script under this
## directory that starts `extends "ZZ_VIEW_PARENT"`; the game seats it on its zombie view, and where the pack is
## absent on a client the monster is drawn as `spawn.body`, one of the game's own bodies.
## The game runs fine without this pack: nothing in it is named by the game.


## The Parasite Host: slow to start, brutal up close, and a heavy hitter with a long reach.
static func spawn_entries() -> Array[Dictionary]:
	return [{
		"category": "NPCs",
		"id": "parasite_host",
		"name": "Parasite Host",
		"icon": "",
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
