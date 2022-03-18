extends RayCast


#onready var camerabody = get_parent().get_parent().find_node("CameraBody")
#onready var camera_children = camerabody.get_children()
onready var cameraspace = get_parent().find_node("CameraSpace")
onready var camera_orbit = get_parent()
#func _ready():
#	self.add_exception(camerabody)
#	for c in camera_children:
#		self.add_exception(c)
#func _physics_process(delta):
##	if camera_orbit.detached:
##		self.global_transform.origin = camerabody.global_transform.origin
##		self.cast_to = cameraspace.global_transform.origin
##	else:
##		self.global_transform.origin = camera_orbit.global_transform.origin
#	if not camera_orbit.detached:
#		self.cast_to = cameraspace.global_transform.origin
