extends Spatial

export var lookSens_h : float = 10
export var lookSense_v : float = 20
var minLookAngle : float = -90.0
var maxLookAngle : float = 90

export var mouseDelta : Vector2 = Vector2()
export var scrollDelta: float = 10
var mousepos : Vector2 = Vector2()
var ray_origin : Vector3 = Vector3()
var ray_target : Vector3 = Vector3()
var rot:     Vector3 = Vector3()
var detached : bool = false
var free_moving : bool = false
var force_attach: bool = false
var initangles_rightclick = Vector3()
onready var cameraspace : Spatial = get_child(0)
onready var camerabody = cameraspace.get_child(0)
onready var ray = get_node("CameraSpace/CameraBody/Camera/CursorRay")
onready var camera = get_node("CameraSpace/CameraBody/Camera")
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
		camerabody.move_and_slide(backdir,Vector3.UP)
	if event is InputEventMouseButton and event.is_action("scroll_in") and not free_moving:
		var backdir = (global_transform.origin - camera.global_transform.origin).normalized() * -scrollDelta
		camerabody.move_and_slide(backdir,Vector3.UP)

		
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
#	camera.rotation_degrees = self.rotation_degrees + initial_angles_diff
#	camera.global_transform.origin = self.global_transform.origin - initial_pos_diff
	camera.global_transform.basis = initbasis_refocus_camera
	camera.global_transform.origin = initpos_refocus_camera
	var self_rot = camera.rotation_degrees
	self.rotation_degrees = Vector3(0,0,0)
#	self.rotation_degrees.y = self_rot.y
	camera.look_at(self.global_transform.origin,Vector3.UP)
#	self.look_at(camera.global_transform.origin,Vector3.UP)
#	self.global_transform.basis.x *= -1
#	self.global_transform.basis.y *= -1
#	self.global_transform.basis.x *= -1
#	camera.global_transform.basis = initbasis_refocus_camera
#	camera.global_transform.origin = initpos_refocus_camera
	print("focusing")
	
	free_moving = false
	detached = false
func _physics_process(delta):
	var input = getInput()
	if input.length() > 0 and not force_attach:
		detached = true
		var dir =( (camera.global_transform.basis.z * input.z) + (camera.global_transform.basis.x * input.x) -Vector3(0,input.y,0) ) * delta * scrollDelta
		global_transform.origin -= dir
	if Input.is_action_just_pressed("right_click"):
		free_moving = not free_moving
		if free_moving:
			var camera_pos = camera.global_transform.origin
			var camera_basis = camera.global_transform.basis
			self.rotation_degrees = Vector3()
			camera.global_transform.origin = camera_pos
			camera.global_transform.basis = camera_basis
			initpos_refocus_camera = camera_pos
			initbasis_refocus_camera = camera_basis
		else:
			refocus_camera()
#		if not force_attach:
#			camera.rotation_degrees = initangles_rightclick
#			initangles_rightclick = Vector3()
	free_moving = free_moving or detached
	if Input.is_action_pressed("refocus_camera"):
		var camera_pos = camera.global_transform.origin
		var camera_basis = camera.global_transform.basis
		refocus_camera()
	elif free_moving:
#		camera.rotation_degrees.z = self.rotation_degrees.z
#		camera.rotation_degrees.x = self.rotation_degrees.x
		rot = Vector3(mouseDelta.y * lookSense_v,mouseDelta.x * lookSens_h/30,0)  * delta
		camera.rotation_degrees.x -= rot.x
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x,minLookAngle/2,maxLookAngle/2)
		camera.global_rotate(Vector3.UP,-rot.y)
		mouseDelta = Vector2()
	else:
		rot = Vector3(mouseDelta.y * lookSense_v,mouseDelta.x * lookSens_h,0)  * delta
		self.rotation_degrees.x += rot.x
		self.rotation_degrees.x = clamp(self.rotation_degrees.x,minLookAngle,maxLookAngle)
		self.rotation_degrees.y -= rot.y
		camera.look_at(self.global_transform.origin,Vector3.UP)
		mouseDelta = Vector2()
	
	
