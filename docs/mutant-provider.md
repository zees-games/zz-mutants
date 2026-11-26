# Mutant provider interface

A mutant pack ships `addons/<id>/spawn_provider.gd`, scanned by Zombie Zone's `ZzPacks`, the same file every ZZ monster pack uses. Each row is
`{category, id, name, icon, kind: "npc", spawn: {npc?, health?, speed?, damage?, reach?, body?, brain?, view?, boss?, meta?}, cfg_hint}`.

Rules:
- `icon` is a png path in the pack, `icons/<id>.png`: 128 px RGBA, the model whole in a three-quarter view. Every kind and the Parasite Host has one, drawn by the game's own zombie view with `tools/make_icons.sh` (then `tools/contact_sheet.sh` to look at them all). `""` means the game's default picture.
- `body` names a game body (`common`, `leaper`, `brute`, ...) the game always has; the game works with no mutant pack, using commons only.
- `view` is a script path relative to the pack. It must `extends "ZZ_VIEW_PARENT"`; the game replaces that token with the game's zombie view and `ZZ_PACK_DIR` with the pack directory, writes the result under `user://zz_pack_views/` and loads it. A view that fails to load is dropped and the game uses `body`.
- A pack replacing this one supplies its own `brain` (path, via the pack mount); no `class_name`, no `uid://`.
- Tuning lives in cfg/addon/zombie_zone/packs.yml `monsters:`.

Not done yet: the 13 built-in specials are still in the game; the director `SPECIALS` pool, the hard preloads (zz_client_state.gd, zz_world_view_base.gd) and brute/sleeper handling are not yet optional.
