extends KinematicBody

onready var base = get_parent()
onready var cameraorbit = base.find_node("CameraOrbit")
onready var cameraspace = cameraorbit.find_node("CameraSpace")
onready var camera_diff_ray = cameraorbit.find_node("CameraDiffRay")
func _physics_process(delta):
	var diff =  Vector3()
	self.look_at(cameraorbit.global_transform.origin,Vector3.UP)
	if not camera_diff_ray.is_colliding() or cameraorbit.detached:
#		print("Not colliding")
		diff = cameraspace.global_transform.origin - self.global_transform.origin
		self.global_transform.origin = cameraspace.global_transform.origin
	else:
#		print("iscolliding")
		self.global_transform.origin = camera_diff_ray.get_collision_point()
#

