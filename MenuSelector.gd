extends Area2D

export var epsilon = 100
var mouse_pos = Vector3()
var within_epsilon = false
onready var menu_base = get_parent()
onready var original_pos = self.global_transform.origin
func _physics_process(delta):
	mouse_pos = get_local_mouse_position()
	within_epsilon = mouse_pos.length() > 0 and mouse_pos.length() < epsilon
	if within_epsilon:
		var base_origin = menu_base.global_transform.origin
		var self_origin = self.global_transform.origin
		var diff = self_origin - base_origin
		self.global_transform.origin -= diff
	else:
		self.global_transform.origin = original_pos
