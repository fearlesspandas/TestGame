extends Spatial


onready var camera_diff_ray = get_parent().find_node("CameraDiffRay")

func _physics_process(delta):
#	if camera_diff_ray.is_colliding():
#		self.global_transform.origin = camera_diff_ray.get_collision_point()
	pass
