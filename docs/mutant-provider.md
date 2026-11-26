# Mutant provider interface

A mutant pack ships `addons/<id>/spawn_provider.gd`, scanned by Zombie Zone's `ZzPackList`, the same file every ZZ monster pack uses. Each row is
`{category, id, name, icon, kind: "npc", spawn: {npc?, health?, speed?, damage?, reach?, body?, brain?, boss?, meta?}, cfg_hint}`.

Rules:
- `body` names a game body (`common`, `leaper`, `brute`, ...) the game always has; the game works with no mutant pack, using commons only.
- A pack replacing this one supplies its own `brain` (path, via the pack mount) and view; no `class_name`, no `uid://`.
- Tuning lives in cfg/addon/zombie_zone/packs.yml `monsters:`.

Game side still to do: make the director `SPECIALS` pool, the hard preloads (zz_client_state.gd, zz_world_view_base.gd) and brute/sleeper handling optional when no pack provides them.
