extends RefCounted

## The zombie kit the thirteen kinds draw with (see ZzZombieViewBase.register_kit): their six bodies and atlases, the
## clips two of them borrow, and every look. A look names a body, a height, the bones it reshapes and its colours.

const BODY_DIR := "zombies"


static func kit(dir: String) -> Dictionary:
	var bodies := {}
	var atlases := {}
	var normals := {}
	var atlas_of := {}
	var wears := {}

	for id: StringName in [&"brute", &"bloater", &"strangler", &"spitter", &"sleeper", &"screamer"]:
		bodies[id] = dir.path_join("%s/zombie_%s.glb" % [BODY_DIR, id])
		atlases[id] = dir.path_join("%s/%s_albedo.png" % [BODY_DIR, id])
		normals[id] = dir.path_join("%s/%s_normal.png" % [BODY_DIR, id])
		atlas_of[id] = id
		wears[id] = {}

	return {
		"bodies": bodies, "atlases": atlases, "normals": normals, "atlas_of": atlas_of, "wears": wears,
		"clips_from": {&"spitter": &"basic", &"sleeper": &"basic"},
		"looks": LOOKS,
	}


## Per kind: the body, how tall (m), how wide against that, its colours, which bones are reshaped
## (bone -> scale), how hunched, its clips where they differ, and what it wears.
const LOOKS := {
	&"leaper": {"body": &"sam", "height": 1.7, "girth": 0.9, "skin": "9ea39a", "top": "262d3d", "bottom": "202226", "hat": "1d2230",
		"bones": {"UpperArm.L*": 1.12, "UpperArm.R*": 1.12, "Head": 0.95}, "hunch": 0.35,
		"clips": {"walk": &"crawl", "idle": &"crawl", "run_arms": &"crawl", "run": &"crawl"}, "wear": [], "blood": 0.6},
	&"strangler": {"body": &"strangler", "height": 2.05, "girth": 0.78,
		"bones": {"Neck": Vector3(0.9, 2.2, 0.9), "Head": 0.85, "Tongue1*": Vector3(1.5, 2.6, 1.5)}, "hunch": 0.3, "shamble": {"stoop": 0.3, "head": 0.45, "arms": -0.2, "swing": 0.5, "drag": 0.25, "sway": 0.18}, "wear": [], "blood": 2.0, "dirt": 0.0},
	&"bloater": {"body": &"bloater", "height": 1.85, "girth": 1.4,
		"bones": {"Abdomen": Vector3(1.45, 1.0, 1.45), "Torso": Vector3(1.25, 1.0, 1.3), "Head": 0.9}, "hunch": 0.0, "shamble": {"stoop": 0.1, "swing": 0.45, "drag": 0.5, "trail": 0.2, "sway": 0.25, "hip": 0.25, "cadence": 0.8}, "wear": [], "blood": 2.0, "dirt": 0.0},
	&"ram": {"body": &"arm", "height": 2.05, "girth": 1.1, "skin": "6e6152", "bottom": "2e3440",
		"bones": {}, "hunch": 0.2, "shamble": {"stoop": 0.4, "head": -0.1, "arms": -0.35, "swing": 0.65, "drag": 0.5, "sway": 0.2, "hip": 0.2}, "wear": [], "mark": "3a2a24", "vein": "1c1814", "blood": 0.64,
		"clips": {"attack_idle": &"attack", "crawl": &"walk"}},
	&"spitter": {"body": &"spitter", "height": 1.95, "girth": 0.8,
		"bones": {"Neck": Vector3(0.9, 2.4, 0.9), "Head": 0.9}, "hunch": 0.15, "shamble": {"stoop": 0.3, "head": 0.55, "hang": -0.9, "swing": 0.5, "drag": 0.2}, "wear": [], "blood": 2.0, "dirt": 0.0, "glow": "4f8a12"},
	&"rider": {"body": &"basic", "height": 1.2, "girth": 1.0, "skin": "8a7a66", "bottom": "4a3a2a", "belt": "2a221a",
		"bones": {"UpperArm.L*": 1.35, "UpperArm.R*": 1.35, "Head": 1.15, "UpperLeg.L*": 0.8, "UpperLeg.R*": 0.8}, "hunch": 0.55, "wear": [], "blood": 0.64,
		"clips": {"run": &"run_arms", "walk": &"run_arms"}},
	&"brute": {"body": &"brute", "height": 2.95, "girth": 1.55,
		"bones": {"UpperArm.L*": 1.4, "UpperArm.R*": 1.4, "Shoulder.L": 1.3, "Shoulder.R": 1.3, "Head": 0.6, "Torso": Vector3(1.2, 1.0, 1.15)}, "hunch": 0.35, "shamble": {"stoop": 0.35, "head": 0.1, "arms": -0.5, "hang": -0.9, "swing": 0.6, "drag": 0.6, "trail": 0.1, "sway": 0.22, "hip": 0.2, "cadence": 0.8, "lurch": 0.0},
		"wear": [], "blood": 2.0, "dirt": 0.0},
	&"sleeper": {"body": &"sleeper", "height": 1.65, "girth": 0.85,
		"bones": {"Index1.L*": Vector3(0.8, 1.9, 0.8), "Index1.R*": Vector3(0.8, 1.9, 0.8), "Middle1.L*": Vector3(0.8, 1.9, 0.8), "Middle1.R*": Vector3(0.8, 1.9, 0.8), "Pinky1.L*": Vector3(0.8, 1.9, 0.8), "Pinky1.R*": Vector3(0.8, 1.9, 0.8)},
		"hunch": 0.0, "shamble": {"stoop": 0.12, "head": 0.1, "arms": -0.5, "hang": -0.8, "swing": 0.8, "drag": 0.8, "trail": 0.0, "sway": 0.05, "hip": 0.04, "cadence": 0.7, "lurch": 0.0}, "wear": [&"red_eyes"], "blood": 2.0, "dirt": 0.0},
	&"screamer": {"body": &"screamer", "height": 2.0, "girth": 0.72,
		"bones": {"Abdomen": Vector3(0.62, 1.15, 0.62), "Torso": Vector3(0.68, 1.1, 0.7), "Neck": Vector3(0.8, 1.6, 0.8), "BottomMouth": 1.4}, "hunch": 0.2, "shamble": {"stoop": 0.1, "head": -0.1, "arms": -0.5, "hang": -0.7, "swing": 0.7, "drag": 0.7, "trail": 0.0, "sway": 0.08, "hip": 0.06, "cadence": 1.1, "lurch": 0.0},
		"wear": [], "blood": 2.0, "dirt": 0.0},
	&"crawler": {"body": &"basic", "height": 1.75, "girth": 1.0, "skin": "6f7a55", "bottom": "3a3a30", "belt": "4a2020",
		"bones": {"UpperLeg.L*": 0.04, "UpperLeg.R*": 0.04}, "hunch": 0.0,
		"clips": {"idle": &"crawl", "walk": &"crawl", "run": &"crawl", "run_arms": &"crawl", "attack": &"crawl", "attack_idle": &"crawl", "attack_run": &"crawl", "hit": &"crawl", "jump_idle": &"crawl"}, "wear": [&"gore"], "blood": 0.55},
	&"riot": {"body": &"sam", "height": 1.85, "girth": 1.1, "skin": "7f8b6e", "top": "1e2430", "bottom": "1b1f28", "hat": "1c2230",
		"bones": {}, "hunch": 0.05, "shamble": {"stoop": 0.05, "head": 0.05, "arms": -0.5, "hang": -0.8, "swing": 0.55, "drag": 0.4, "trail": 0.25, "sway": 0.1}, "wear": [&"helmet", &"shield"], "blood": 0.6},
}
