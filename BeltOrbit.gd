extends Spatial


onready var belt = get_node("QuantumBelt")

var rot_y = 10
var rot_x = 0
var rot_z = -20
func _physics_process(delta):
	rotation_degrees.y += rot_y
	rotation_degrees.x += rot_x
	rotation_degrees.z += rot_z
