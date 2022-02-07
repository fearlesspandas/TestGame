extends Spatial

export var lookSens_h : float = 20
export var lookSense_v : float = 20
var minLookAngle : float = -90.0
var maxLookAngle : float = 90

export var mouseDelta : Vector2 = Vector2()
export var scrollDelta: float = 20
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
onready var initangles_refocus = camera.rotation_degrees
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
		mousepos = event.position
	if event is InputEventMouseButton and event.is_action("scroll_out"):
		var backdir = global_transform.basis.z * scrollDelta
		camerabody.move_and_slide(backdir,Vector3.UP)
	if event is InputEventMouseButton and event.is_action("scroll_in"):
		var backdir = global_transform.basis.z * -scrollDelta
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
func _physics_process(delta):
	var input = getInput()
	if input.length() > 0 and not force_attach:
		detached = true
		var dir =( (camera.global_transform.basis.z * input.z) + (camera.global_transform.basis.x * input.x) -Vector3(0,input.y,0) ) * delta * scrollDelta
		global_transform.origin -= dir
	if Input.is_action_just_pressed("right_click"):
		free_moving = not free_moving
#		if not force_attach:
#			camera.rotation_degrees = initangles_rightclick
#			initangles_rightclick = Vector3()
	free_moving = free_moving or detached
	if Input.is_action_pressed("refocus_camera"):
		camera.rotation_degrees = initangles_refocus
		detached = false
	elif free_moving:
#		cameraspace.rotation_degrees.x = 0
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
		mouseDelta = Vector2()
	
	
