extends SceneTree

## The spawn menu's icons: each monster whole in a three-quarter view, idle, drawn by Zombie Zone's own zombie view
## (so its look, hunch and clothes are what the game shows), on a transparent ground, fitted to its bounds, 128 px.
## Same seed, pose and camera every run; the game view's idle sway reads the wall clock, so pixels differ by about 1 % between runs.
## Run through tools/make_icons.sh, which points --path at a Zombie Zone checkout that mounts this pack.
##
##   godot --path <zombie-zone> --script <this file> -- --out=/abs/dir [--kinds=a,b] [--size=128]

const KINDS: PackedStringArray = ["leaper", "strangler", "bloater", "ram", "spitter", "rider", "brute", "sleeper",
	"screamer", "crawler", "riot", "mutant", "oil_monster", "parasite_host"]
const SHOT := 1024
const YAW := 150.0
const SETTLE := 20
const FIT := 1.6
const MARGIN := 0.06

var _out := ""
var _size := 128
var _kinds: PackedStringArray = KINDS
var _index := -1
var _frames := 0
var _view: Node3D
var _camera: Camera3D
var _root3d: Node3D


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
		elif arg.begins_with("--size="):
			_size = int(arg.trim_prefix("--size="))
		elif arg.begins_with("--kinds="):
			_kinds = arg.trim_prefix("--kinds=").split(",", false)

	if _out == "":
		push_error("render_icons: --out=<dir> is required")
		quit(2)
		return

	DirAccess.make_dir_recursive_absolute(_out)
	load("res://game/zz_packs.gd").scan()

	get_root().size = Vector2i(SHOT, SHOT)
	get_root().transparent_bg = true
	_root3d = Node3D.new()
	get_root().add_child(_root3d)

	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_CLEAR_COLOR
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.85, 0.85, 0.9)
	env.environment.ambient_light_energy = 0.6
	_root3d.add_child(env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35.0, 155.0, 0.0)
	sun.light_energy = 1.1
	_root3d.add_child(sun)

	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_root3d.add_child(_camera)
	_next()


func _next() -> void:
	_index += 1
	_frames = 0
	if _view != null:
		_view.queue_free()
		_view = null
	if _index >= _kinds.size():
		quit(0)
		return

	var world_view: Script = load("res://game/zz_world_view.gd")
	_view = world_view.view_for(StringName(_kinds[_index]))
	_root3d.add_child(_view)
	_view.rotation.y = deg_to_rad(YAW)
	_view.build(StringName(_kinds[_index]), 1)


func _process(_delta: float) -> bool:
	if _view == null:
		return false
	_frames += 1
	_view.present(1.0 / 30.0, load("res://npcs/zz_zombie_body.gd").Anim.IDLE, 0)

	if _frames == SETTLE:
		_fit()
	elif _frames == SETTLE + 3:
		var image := get_root().get_texture().get_image()
		image.convert(Image.FORMAT_RGBA8)
		image = _square(image)
		image.resize(_size, _size, Image.INTERPOLATE_LANCZOS)
		image.save_png(_out.path_join("%s.png" % _kinds[_index]))
		print("wrote %s.png" % _kinds[_index])
		_next()
	return false


## The picture cut to the drawn pixels and centred in a square with a margin: the camera only has to frame the figure
## loosely, so no model (the tall, the wide, the crouched) is clipped or lost in empty ground.
func _square(image: Image) -> Image:
	var used := image.get_used_rect()
	if used.size == Vector2i.ZERO:
		return image
	var side := int(ceilf(float(maxi(used.size.x, used.size.y)) * (1.0 + 2.0 * MARGIN)))
	var out := Image.create_empty(side, side, false, Image.FORMAT_RGBA8)
	out.blit_rect(image, used, Vector2i((side - used.size.x) / 2, (side - used.size.y) / 2))
	return out


## The camera looks slightly down at the centre of the figure's bounds; the frame is the larger of its extents.
func _fit() -> void:
	var box := AABB()
	var first := true
	var stack: Array[Node] = [_view]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		stack.append_array(node.get_children())
		var mesh := node as MeshInstance3D
		if mesh == null or not mesh.is_visible_in_tree() or mesh.mesh == null:
			continue
		var b := mesh.global_transform * mesh.get_aabb()
		box = b if first else box.merge(b)
		first = false

	var centre := box.get_center()
	var dir := Vector3(0.0, 0.25, 1.0).normalized()
	_camera.look_at_from_position(centre + dir * 20.0, centre)
	var span := maxf(box.size.y, maxf(box.size.x, box.size.z) * 0.95)
	_camera.size = maxf(span, 0.5) * FIT
