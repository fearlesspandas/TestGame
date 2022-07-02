extends Node
export var accell : float = 2.5
var decell : float = accell
export var jumpForce :float = 15
export var jumpMax: float = jumpForce
export var gravity : float = 40
export var MAX_MOVE_SPEED = 10
export var path_finding_epsiolon : float = 5
var accelerating:bool = false
var allowed_to_move:bool = true
var dest : Array = []
var next_dest :Vector3 = Vector3()
#var path : Vector3 = Vector3()
var moveSpeed_x : float = 0
var moveSpeed_z : float = 0
var autopilot_on: bool = true
var next_selection = null
onready var rigid = get_node("RigidBody")
onready var main_map = find_parent("Main")

func update_fields(fields):
	#update destinations
	var newdests = fields["dest"]
	if newdests != null:
		add_new_dests(newdests)
	var returnFields = {"dest":self.dest}
	if fields["autopilot_on"] != null:
		autopilot_on = fields["autopilot_on"]
	if fields["path"] != null:
		handle_dir(fields["path"])
		
func add_new_dests(newdests):
	for d in newdests:
		var type = d["type"]
		var loc = d["location"]	
		self.dest.append({"type":type,"location":loc})
	var returnFields = {"dest":self.dest}
	NetworkManager.server_set_client_fields(self.name,returnFields)
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

func toggle_autopilot():
	autopilot_on = not autopilot_on
	
func handle_movement_speeds(within_epsilon:bool,input:Vector3,delta):
	if within_epsilon:
		moveSpeed_z = decelerate(moveSpeed_z)
		moveSpeed_x = decelerate(moveSpeed_x)
	else:
		moveSpeed_z += accell * input.z * delta
		moveSpeed_x += accell * input.x * delta
		moveSpeed_x = capspeed(moveSpeed_x)
		moveSpeed_z = capspeed(moveSpeed_z)
		
func update_next_selection():
	if next_selection != null:
		next_selection.call_deferred("free")
	next_selection = SelectorModelClient.get_resource_by_type(dest[0].type).instance()
	
func handle_next_dest(delta):
		var next_dest = dest[0]
		var next = next_dest.location
		var diff_vec = next - rigid.global_transform.origin
		var within_epsilon = diff_vec.length() < path_finding_epsiolon
		handle_movement_speeds(within_epsilon,Vector3(1,1,1),delta)
		if within_epsilon and dest.size() > 1:
			if next_selection == null:
				update_next_selection()
			dest.pop_front()	
			next_selection.in_transit(self)
			var returnDest = {"dest":self.dest}
			NetworkManager.server_set_client_fields(self.name,returnDest)
			update_next_selection()
		else:
			handle_dir(diff_vec,true)
			
func handle_autopilot(delta):
	#pop dest on arrival
	if dest.size() > 0:
		handle_next_dest(delta)
		
func handle_jump_force(shouldjump):
	if shouldjump:
		jumpForce-=jumpMax/3
	else:
		jumpForce += jumpMax/500
	jumpForce = clamp(jumpForce,0,jumpMax)
	
func handle_dir(path:Vector3,skip_mvmt_calc:bool = false):
#	print("server handledir")
	if not skip_mvmt_calc:
		handle_movement_speeds(false,Vector3(1,1,1),1)
	var normal = path.normalized()
	var should_jump = normal.y > 0.1 #and jumpForce > jumpMax/3
	var scalar = 1
	if not skip_mvmt_calc:
		scalar = 2
	var vec = Vector3(normal.x * moveSpeed_x* scalar,normal.y * jumpForce, normal.z * moveSpeed_z * scalar )
	handle_jump_force(should_jump)
	rigid.set_axis_velocity(vec)
	
func handle_sync(delta):
	var fields = {"location":rigid.global_transform.origin,"rot":rigid.global_transform.rotation_degrees,"jumpForce":jumpForce}
	NetworkManager.server_set_client_fields_unreliable(self.name,fields)
	
func _process(delta):
	handle_sync(delta)
	if autopilot_on:
		handle_autopilot(delta)
	else:
		handle_movement_speeds(true,Vector3(1,1,1),1)
