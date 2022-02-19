extends Spatial

export var lookSens_h : float = 10
export var lookSense_v : float = 20
export var minLookAngle : float = -90.0
export var maxLookAngle : float = 90
export var moveDelta : float = 20
export var mouseDelta : Vector2 = Vector2()
export var scrollDelta: float = 5
var mousepos : Vector2 = Vector2()
var ray_origin : Vector3 = Vector3()
var ray_target : Vector3 = Vector3()
var rot:     Vector3 = Vector3()
var detached : bool = false
var free_moving : bool = false
var force_attach: bool = false
var stop_movement:bool = false
var initangles_rightclick = Vector3()
onready var cameraspace : Spatial = find_node("CameraSpace")
onready var arm = find_node("SpringArm")
onready var camerabody = find_node("CameraBody")
onready var ray = find_node("CursorRay")
onready var camera = find_node("Camera")
onready var pointer = get_node("Pointer")
onready var initbasis_refocus_camera = camera.global_transform.basis
onready var initpos_refocus_camera = camera.global_transform.origin
onready var initangles_refocus_orbit = self.rotation_degrees
onready var initial_pos_diff = self.global_transform.origin - camera.global_transform.origin
onready var initial_angles_diff = self.rotation_degrees - camera.rotation_degrees
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
		mousepos = event.position
	if event is InputEventMouseButton and event.is_action("scroll_out") and not free_moving:
		var backdir = (global_transform.origin - camera.global_transform.origin).normalized() * scrollDelta
#		camerabody.move_and_slide(backdir,Vector3.UP)
		cameraspace.global_transform.origin += backdir
	if event is InputEventMouseButton and event.is_action("scroll_in") and not free_moving:
		var backdir = (global_transform.origin - camera.global_transform.origin).normalized() * -scrollDelta
#		camerabody.move_and_slide(backdir,Vector3.UP)
		cameraspace.global_transform.origin += backdir

		
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
	if Input.is_action_pressed("jump") and detached:
		input.y += 1
	if Input.is_action_pressed("shift") and detached:
		input.y -= 1	
	input = input.normalized()
	return input
func refocus_camera():
	camera.global_transform.basis = initbasis_refocus_camera
	camera.global_transform.origin = initpos_refocus_camera
	var self_rot = camera.rotation_degrees
	self.rotation_degrees = Vector3(0,0,0)
	camera.look_at(self.global_transform.origin,Vector3.UP)
	var campos = camera.global_transform.origin
	var cambasis = camera.global_transform.basis
	self.look_at(camera.global_transform.origin,Vector3.UP)
	self.global_transform.basis.x *= -1
	self.global_transform.basis.x *= -1
	camera.global_transform.origin = campos
	camera.global_transform.basis = cambasis
	free_moving = false
	detached = false
func prep_free_moving():
	var camera_pos = camera.global_transform.origin
	var camera_basis = camera.global_transform.basis
	self.rotation_degrees = Vector3(0,self.rotation_degrees.y,0)
	camera.global_transform.origin = camera_pos
	camera.global_transform.basis = camera_basis
	initpos_refocus_camera = camera_pos
	initbasis_refocus_camera = camera_basis
	
func _physics_process(delta):
	var input = getInput()
	if input.length() > 0 and not force_attach:
		if not detached:
			prep_free_moving()
		detached = true
		var dir =( (camera.global_transform.basis.z * input.z) + (camera.global_transform.basis.x * input.x) -Vector3(0,input.y,0) ) * delta * moveDelta
		global_transform.origin -= dir
	if Input.is_action_just_pressed("escape"):
		stop_movement = not stop_movement
		
	if stop_movement:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_pressed("right_click") and not stop_movement:
		free_moving = not free_moving
		if free_moving:
			prep_free_moving()
		else:
			refocus_camera()
	free_moving = free_moving or detached
	pointer.visible = not detached
	if Input.is_action_pressed("refocus_camera"):
		refocus_camera()
	elif free_moving and not stop_movement:
		rot = Vector3(mouseDelta.y * lookSense_v,mouseDelta.x * lookSens_h/30,0)  * delta
		camera.rotation_degrees.x -= rot.x
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x,minLookAngle,maxLookAngle)
		camera.global_rotate(Vector3.UP,-rot.y)
		mouseDelta = Vector2()
	elif not stop_movement:
		rot = Vector3(mouseDelta.y * lookSense_v,mouseDelta.x * lookSens_h,0)  * delta
		self.rotation_degrees.x += rot.x
		self.rotation_degrees.x = clamp(self.rotation_degrees.x,minLookAngle,maxLookAngle)
		self.rotation_degrees.y -= rot.y
		camera.look_at(self.global_transform.origin,Vector3.UP)
		mouseDelta = Vector2()
	
	
