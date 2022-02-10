extends MeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var orbit = get_parent()
onready var y_value  = self.global_transform.origin.y
func _physics_process(delta):
	self.rotation_degrees.x = -orbit.rotation_degrees.x
	self.global_transform.origin.y = y_value

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
