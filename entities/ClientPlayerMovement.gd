extends Node

export var path_finding_epsilon = 5
export(float) var accell = 1.5
export(float) var decell = 2 * accell
export(float) var MAX_MOVE_SPEED = 5
var autopilot_on : bool = true
var stop_selection: bool = false
var selection_type : Resource
var dest = []
var selections = []
var moveSpeed_z = 0
var moveSpeed_x = 0
var last_path = Vector3()
var last_received_position = null
var prior_pos = Vector3()
var last_dir = Vector3()
onready var kinematic = find_node("KinematicBody")
onready var camerawrapper = get_parent().find_node("PlayerCam")
onready var camera = camerawrapper.find_node("CameraOrbit")
onready var camerautil:Camera = camerawrapper.find_node("Camera")
onready var cursor_ray = camerawrapper.find_node("CursorRay")
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
func move_towards_loc(loc:Vector3,rot):
	var diff = (loc) - kinematic.global_transform.origin
	last_received_position = loc
	kinematic.rotation_degrees = rot
func set_rotation_degrees(rot,dist):
	if dist > 100:
		kinematic.rotation_degrees = rot

func handle_left_click():
	if Input.is_action_just_pressed("toggle_autopilot"):
		toggle_autopilot()
	if Input.is_action_just_pressed("clear_waypoints"):
		Server.client_clear_waypoints()
	if Input.is_action_just_pressed("click") and not stop_selection and not selection_type == null:
#		print("selecting",cursor_ray.intersect_pos)
		var instance = selection_type.instance()
		instance.global_transform.origin = cursor_ray.intersect_pos
		Server.client_add_dest(Server.player_id,cursor_ray.intersect_pos,instance.type)
		
func decelerate(value:float) -> float:
	if value > 0:
		value -= min(decell,value) 
	if value < 0:
		value += min(decell,-value)
	return value
	
func capspeed(value:float) -> float:
	if value > MAX_MOVE_SPEED:
		return MAX_MOVE_SPEED
	elif value < -MAX_MOVE_SPEED:
		return -MAX_MOVE_SPEED
	else:
		return value
		
func draw_dest():
	for s in selections:
		Server.map.remove_child(s)
		if s != null:
			s.call_deferred("free")
			s = null
	selections = []
	for d in dest:
		var instance = SelectorModelClient.get_resource_by_type(d.type).instance()
		instance.global_transform.origin = d.location
		Server.map.add_child(instance)
		selections.append(instance)

func handle_manual(delta):
	var input = getInput()
	var pointer = camera.pointer
	var dir = pointer.global_transform.basis.z * input.z + pointer.global_transform.basis.x * input.x + Vector3(0,input.y,0)
	Server.client_move_entity(dir,Server.player_id)
	
func handle_semi_pilot(delta):
	if last_received_position != null:
		kinematic.global_transform.origin = last_received_position
		last_dir = last_received_position - prior_pos
		prior_pos = last_received_position
		last_received_position = null
#	else:
#		kinematic.global_transform.origin +=  (last_dir)
	if not autopilot_on:
		handle_manual(delta)
		
func toggle_autopilot():
	Server.client_toggle_autopilot()
	autopilot_on = not autopilot_on
	camera.force_attach = not autopilot_on

func _physics_process(delta):
	handle_left_click()
	handle_semi_pilot(delta)
#	handle_autopilot(delta)
