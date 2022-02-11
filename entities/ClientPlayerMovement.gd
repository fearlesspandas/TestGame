extends Node


var selection:Array = []
var next_sel: Node = null
var selections_for_removal: Array = []
var autopilot_on : bool = true
var stop_selection: bool = false
var selection_type : Resource
onready var rigid = get_node("RigidBody")
onready var camera = get_parent().get_node("PlayerCam")
onready var camerautil:Camera = camera.get_node("Camera")
onready var cursor_ray = camera.find_node("CursorRay")
onready var main_map = find_parent("Main")

func getInput() -> Vector3:
	var input:Vector3 = Vector3()
	if Input.is_action_pressed("move_forward"):
		input.z += 1
	if Input.is_action_pressed("move_backward"):
		input.z -= 1
	if Input.is_action_pressed("move_left"):
		input.x += 1
	if Input.is_action_pressed("move_right"):
		input.x -= 1
	if Input.is_action_just_pressed("jump") and (not camera.detached):
		input.y += 1
	input = input.normalized()
	return input
func move_towards_loc(loc:Vector3):
	var diff = loc - rigid.global_transform.origin
	rigid.global_transform.origin = loc
func set_rotation_degrees(rot):
	rigid.rotation_degrees = rot
func create_selection(location:Resource):
	var instance = location.instance()
	if main_map != null:
		main_map.add_child(instance)
		selection.push_back(instance)
		instance.global_transform.origin = cursor_ray.intersect_pos
func destroy_selections():
	for s in selections_for_removal:
		get_tree().get_root().get_child(0).remove_child(s)
		if s != null:
			s.call_deferred("free")
	selections_for_removal = []
func handle_left_click():
	if Input.is_action_just_pressed("clear_waypoints"):
		pass #send waypoint request
	if Input.is_action_just_pressed("click") and not stop_selection:
		Server.client_add_dest(Server.player_id,cursor_ray.intersect_pos,"Waypoint")
func toggle_autopilot():
	pass #send autopilot request

func _physics_process(delta):
	handle_left_click()
