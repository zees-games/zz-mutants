extends "ZZ_VIEW_PARENT"

## The Parasite Host as drawn: "Scary Monster" by Bekalo Animations (CC BY 4.0), a Mixamo-rigged model whose one clip
## is a bind pose. Its idle, walk, run, attack, hit and death are posed here, by code, from a phase and the
## state, so there is no clip file to keep in step with the model. `ZZ_VIEW_PARENT` and `ZZ_PACK_DIR` are filled in
## by the game's ZzPackViews. Needs no game class: it draws on the zombie view's seams (build, present, flinch, die).

const MODEL := "ZZ_PACK_DIR/monsters/parasite_host.glb"
const HEIGHT := 2.25
const PREFIX := "mixamorig_"
const BONES: Array[String] = ["Hips", "Spine", "Spine1", "Spine2", "Neck", "Head", "LeftArm", "LeftForeArm", "RightArm",
	"RightForeArm", "LeftUpLeg", "LeftLeg", "RightUpLeg", "RightLeg", "JawDowm"]

var _idx: Dictionary = {}
var _rest: Dictionary = {}
var _phase := 0.0
var _swing := 0.0
var _dead_t := -1.0
var _hit_t := 0.0
var _lift := 0.0


func build(p_kind: StringName, p_variant: int) -> void:
	if _model != null:
		return

	kind = p_kind
	variant = p_variant
	body_id = &"parasite_host"
	_look = look_for(&"common", 0)
	var scene := _load_model()

	if scene == null:
		_model = _capsule()
		add_child(_model)
		return

	_model = scene.instantiate() as Node3D
	add_child(_model)
	_skeleton = _model.find_children("*", "Skeleton3D", true, false).front() as Skeleton3D
	_mesh = _model.find_children("*", "MeshInstance3D", true, false).front() as MeshInstance3D

	var ours := _model.find_children("*", "AnimationPlayer", true, false)
	for player: Node in ours:
		player.queue_free()

	for b in BONES:
		var i := _find(b)
		if i >= 0:
			_idx[b] = i
			_rest[b] = _skeleton.get_bone_rest(i)

	_fit()

	for m: Node in _model.find_children("*", "MeshInstance3D", true, false):
		(m as MeshInstance3D).visibility_range_end = lod.draw_until if lod != null else 120.0


## The model from the pack at runtime (a glb needs no import to load, so a mounted pack draws too).
func _load_model() -> PackedScene:
	var path := MODEL
	if ResourceLoader.exists(path):
		return load(path) as PackedScene

	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	if doc.append_from_file(path, state) != OK:
		return null

	var root := doc.generate_scene(state)
	if root == null:
		return null

	var packed := PackedScene.new()
	_own(root, root)
	var packed_ok := packed.pack(root) == OK
	root.free()
	return packed if packed_ok else null


func _own(node: Node, root: Node) -> void:
	for c in node.get_children():
		c.owner = root
		_own(c, root)


## The bone whose name starts `mixamorig_<name>_` (the glTF import numbers them).
func _find(part: String) -> int:
	var head := PREFIX + part + "_"
	for i in _skeleton.get_bone_count():
		if _skeleton.get_bone_name(i).begins_with(head):
			return i
	return -1


## Scales the model to [constant HEIGHT] and stands its feet on the origin; the source faces +Z, this family -Z.
func _fit() -> void:
	var box := _model.global_transform.affine_inverse() * _mesh.global_transform * _mesh.get_aabb()
	var rate := HEIGHT / maxf(box.size.y, 0.001)
	_model.basis = Basis(Vector3.UP, PI).scaled(Vector3.ONE * rate)
	_lift = -box.position.y * rate
	_model.position = Vector3(0.0, _lift, 0.0)


## A bone turned by [param euler] (model-space radians) off its rest pose.
func _turn(part: String, euler: Vector3) -> void:
	var i: int = _idx.get(part, -1)
	if i < 0:
		return

	var parent_g: Basis = _skeleton.get_bone_global_rest(_skeleton.get_bone_parent(i)).basis if _skeleton.get_bone_parent(i) >= 0 else Basis.IDENTITY
	var d := Basis.from_euler(euler)
	var local_delta := parent_g.inverse() * d * parent_g
	var rest: Transform3D = _rest[part]
	_skeleton.set_bone_pose_rotation(i, (local_delta * rest.basis).get_rotation_quaternion())


func present(delta: float, anim: int, _flags: int) -> void:
	if _model == null or _skeleton == null:
		return

	_frame += 1
	var at := global_position
	if _last_at != Vector3.INF and delta > 0.0:
		var moved := Vector2(at.x - _last_at.x, at.z - _last_at.z).length() / delta
		_speed = lerpf(_speed, moved, clampf(delta * 8.0, 0.0, 1.0))
	_last_at = at

	if anim == ZzZombieBody.Anim.DEAD and _dead_t < 0.0:
		die(&"limp", Vector3.ZERO, 0)

	_hit_t = maxf(_hit_t - delta, 0.0)

	if _dead_t >= 0.0:
		_dead_t += delta
		_ph_death(clampf(_dead_t / 1.2, 0.0, 1.0))
		return

	var moving := _speed > 0.25
	var running := _speed > 3.4
	_phase = fposmod(_phase + delta * (_speed * 1.1 if moving else 0.6), TAU)
	var attacking := anim == ZzZombieBody.Anim.ATTACK or anim == ZzZombieBody.Anim.STRIKE_DOWN

	if attacking:
		_swing = fposmod(_swing + delta / 0.9, 1.0)
	else:
		_swing = 0.0

	_ph_pose(moving, running, attacking)


## One frame of the living pose: arms hang forward as a corpse's do, the legs swing with the stride, the head lolls.
func _ph_pose(moving: bool, running: bool, attacking: bool) -> void:
	var s := sin(_phase)
	var amp := 0.9 if running else (0.55 if moving else 0.0)
	var lean := 0.35 if running else (0.18 if moving else 0.1)
	var reach := -1.1 - (0.4 if running else 0.0)
	var flinch := _hit_t / 0.45

	_turn("Hips", Vector3(0.0, 0.12 * s * amp, 0.0))
	_turn("Spine", Vector3(lean + 0.1 * flinch, -0.15 * s * amp, 0.0))
	_turn("Spine1", Vector3(lean * 0.5, 0.1 * s * amp, 0.0))
	_turn("Neck", Vector3(-lean * 0.4 + 0.12 * sin(_phase * 0.5), 0.0, 0.0))
	_turn("Head", Vector3(0.08 * sin(_phase * 0.5), 0.15 * s, 0.1 * flinch))

	# T-pose arms down to the sides (Z), then up in front (X).
	var raise := reach
	var arc := 0.0
	if attacking:
		arc = sin(_swing * PI)
		raise = reach - 0.9 * arc
	_turn("LeftArm", Vector3(raise + 0.3 * s * amp, 0.0, -1.35))
	_turn("RightArm", Vector3(raise - 0.3 * s * amp, 0.0, 1.35))
	_turn("LeftForeArm", Vector3(-0.5 - 0.5 * arc, 0.0, 0.0))
	_turn("RightForeArm", Vector3(-0.5 - 0.5 * arc, 0.0, 0.0))

	_turn("LeftUpLeg", Vector3(-0.8 * amp * s, 0.0, 0.0))
	_turn("RightUpLeg", Vector3(0.8 * amp * s, 0.0, 0.0))
	_turn("LeftLeg", Vector3(0.7 * amp * maxf(s, 0.0), 0.0, 0.0))
	_turn("RightLeg", Vector3(0.7 * amp * maxf(-s, 0.0), 0.0, 0.0))
	_turn("JawDowm", Vector3(0.5 * arc if attacking else 0.1, 0.0, 0.0))
	_model.position.y = _lift + (absf(s) * 0.04 * amp)


func _ph_death(t: float) -> void:
	_ph_pose(false, false, false)
	var fall := t * t
	_model.rotation.x = -PI * 0.5 * fall
	_model.position.y = _lift + 0.25 * fall


func flinch(_from_side: float = 1.0, _head := false) -> void:
	_hit_t = 0.45


func set_fade(_alpha: float) -> void:
	pass


func fade() -> float:
	return 1.0


func die(_reaction: StringName, _push: Vector3, _seed: int) -> void:
	if _dead_t < 0.0:
		_dead_t = 0.0


## It has no limbs to cut: a hit reads as a flinch and the body stays whole.
func sever_limb(_limb: StringName, _d: Dictionary, _impulse: Vector3) -> Vector3:
	return global_position + Vector3(0.0, 1.2, 0.0)


func stump_limb(_limb: StringName, _d: Dictionary) -> Vector3:
	return global_position + Vector3(0.0, 1.2, 0.0)


func restore_limbs() -> void:
	_dead_t = -1.0
	_model.rotation.x = 0.0
