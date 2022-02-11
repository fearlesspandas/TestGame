extends Spatial
export var accell : float = 2.5
var decell : float = accell
export var jumpForce :float = 15
export var gravity : float = 40
export var MAX_MOVE_SPEED = 10
export var path_finding_epsiolon : float = 1
var accelerating:bool = false
var allowed_to_move:bool = true
var dest : Array = []
var next_dest :Vector3 = Vector3()
var path : Vector3 = Vector3()
var moveSpeed_x : float = 0
var moveSpeed_z : float = 0
var selection:Array = []
var next_sel: Node = null
var selections_for_removal: Array = []
var within_epsilon : bool = false
var active_dest : bool = false
var autopilot_on : bool = true
var stop_selection: bool = false
var selection_type : Resource
onready var rigid = get_node("RigidBody")
onready var camera = get_parent().get_node("PlayerCam")
onready var camerautil:Camera = camera.get_node("Camera")
onready var cursor_ray = camera.find_node("CursorRay")
onready var main_map = find_parent("Main")
func decelerate(value:float) -> float:
	if value > 0:
		value -= min(decell,value) 
	if value < 0:
		value += min(decell,-value)
	return value
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
func capspeed(value:float) -> float:
	if value > MAX_MOVE_SPEED:
		return MAX_MOVE_SPEED
	elif value < -MAX_MOVE_SPEED:
		return -MAX_MOVE_SPEED
	else:
		return value
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
		dest = []
		selections_for_removal.append_array(selection)
		selection = []
		destroy_selections()
	if Input.is_action_just_released("click") and not stop_selection and selection_type != null:
		var dist_map = []		
		for i in selection.size():
			var s = selection[i]
			var dist = min(
				(s.global_transform.origin - cursor_ray.intersect_pos).length(),
				(s.global_transform.origin + Vector3(0,5,0) - cursor_ray.intersect_pos).length()
			)
			if dist < path_finding_epsiolon:
				dist_map.append([dist,i])
		if dist_map.size() > 0:
			for a in dist_map:
				var ind = a[1]
				var s = selection[ind]
				selection.remove(ind)
				dest.remove(ind)
				selections_for_removal.push_back(s)
				destroy_selections()
		else:
			dest.push_back(cursor_ray.intersect_pos) # get intersection object, check if in selection
			create_selection(selection_type)
func handle_autopilot(input:Vector3,delta):
	camera.force_attach = false
	var diff = Vector3()
	
	active_dest = dest.size() > 0 and selection.size() > 0
	if active_dest:
		next_dest = dest[0]
		next_sel = selection[0]
		diff = (next_dest - rigid.global_transform.origin)
		within_epsilon = diff.length() < path_finding_epsiolon
	accelerating =  (active_dest and not within_epsilon)
	if accelerating:
		moveSpeed_z += delta*accell
	else:
		moveSpeed_x = decelerate(moveSpeed_x)
		moveSpeed_z = decelerate(moveSpeed_z)
	moveSpeed_x = capspeed(moveSpeed_x)
	moveSpeed_z = capspeed(moveSpeed_z)
	var checkforzero = moveSpeed_z
	if checkforzero == 0:
		checkforzero = 1
	path = (diff.normalized() * checkforzero) + Vector3(0,input.y* jumpForce,0)
	if (accelerating) or input.y > 0:
		rigid.set_axis_velocity(path)
	if within_epsilon and selection.size() > 1 and dest.size() > 1:
		if next_sel != null and weakref(next_sel).get_ref() and  next_sel.has_method("in_transit"):
			dest.pop_front()
			selections_for_removal.push_back(next_sel)
			selection.pop_front()
			next_sel.in_transit(self)
			destroy_selections()
	if within_epsilon and selection.size () == 1 and dest.size() == 1:
		if next_sel != null and weakref(next_sel).get_ref() and next_sel.has_method("at_dest"):
			next_sel.at_dest(self)
func handle_manual(input:Vector3,delta):
#	autopilot_label.visible = false
	camera.force_attach = true
	accelerating =  (input.length() > 0)
	if accelerating:
		moveSpeed_z += delta*accell * input.z
		moveSpeed_x += delta*accell * input.x
	else:
		moveSpeed_x = decelerate(moveSpeed_x)
		moveSpeed_z = decelerate(moveSpeed_z)
	moveSpeed_x = capspeed(moveSpeed_x)
	moveSpeed_z = capspeed(moveSpeed_z)
	var vec = (camera.global_transform.basis)
	var dir =( (vec.z * moveSpeed_z) + (vec.x * moveSpeed_x) + Vector3(0,input.y * jumpForce,0) )
	rigid.set_axis_velocity(dir)
func toggle_autopilot():
	autopilot_on = not autopilot_on
	if not autopilot_on:
		within_epsilon = false
	
func _physics_process(delta):
	if Input.is_action_just_pressed("toggle_autopilot"):
		toggle_autopilot()
	if Input.is_action_just_pressed("toggle_movement"):
		allowed_to_move = not allowed_to_move
	var input = getInput()
	if autopilot_on:
		handle_left_click()
		if allowed_to_move:
			handle_autopilot(input,delta)
	else:
		handle_manual(input,delta)
#	print(autopilot_on,input,moveSpeed_x,moveSpeed_z)
