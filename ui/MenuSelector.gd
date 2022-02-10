extends Area2D

export var epsilon = 5
export var mouse_delta = 5
export var selection_type:Resource
var shifted : bool = false
var mouse_pos = Vector3()
var within_epsilon = false
var stop_cam : bool = false
onready var menu_base = get_parent()
onready var original_pos = self.global_transform.origin
onready var player = find_parent("P1").get_node("Player")
onready var control = find_parent("CrosshairControl")
onready var camera = find_parent("PlayerCam")
func _ready():
	player.stop_selection = true
	camera.stop_movement = true
func on_destroy():
	player.stop_selection = false
	camera.stop_movement = false
	control.menuEnabled = false
func _physics_process(delta):
	mouse_pos = get_global_mouse_position()#get_local_mouse_position()
	within_epsilon = (mouse_pos - original_pos).length() < epsilon
	var base_origin = menu_base.global_transform.origin
	var self_origin = self.global_transform.origin
	var diff = original_pos - base_origin
#	if Input.is_action_just_pressed("middle_click"):
	player.stop_selection = control.menuEnabled
	camera.stop_movement = control.menuEnabled
		#control closes this itsel fon middle click
		
#	print(player)
	if within_epsilon:
		self.global_transform.origin = original_pos + diff.normalized() * mouse_delta
		if Input.is_action_just_released("click"):
			player.selection_type = selection_type
			on_destroy()
	else:
#		if player!= null:
#			player.stop_selection = false
#			camera.stop_movement = false
		self.global_transform.origin = original_pos
