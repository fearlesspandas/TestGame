extends RayCast


onready var camerabody = get_parent().get_parent().find_node("CameraBody")
onready var camera_children = camerabody.get_children()
onready var cameraspace = get_parent().find_node("CameraSpace")
func _ready():
	self.add_exception(camerabody)
	for c in camera_children:
		self.add_exception(c)
func _physics_process(delta):
	self.cast_to = cameraspace.global_transform.origin
