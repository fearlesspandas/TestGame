extends RayCast

var camerasnap: float = 10

func _ready():
	set_debug_shape_custom_color(Color.darkmagenta)
	self.collide_with_areas = true
onready var camera:Camera = get_parent()
onready var camerabody = camera.get_parent()
onready var cameraspace = camerabody.get_parent()
onready var cameraorbit:Spatial = cameraspace.get_parent()


var ray_origin : Vector3 = Vector3()
var ray_target : Vector3 = Vector3()
var mouse_position:Vector2 = Vector2()
var intersect_pos : Vector3 = Vector3()
var intersection_object : Object = null
func _physics_process(delta):
	mouse_position = get_viewport().get_mouse_position()
	ray_origin = camera.project_ray_origin(mouse_position)
	ray_target = ray_origin + camera.project_ray_normal(mouse_position) * 1000
	var space_state = get_world().direct_space_state
	var intersection = space_state.intersect_ray(ray_origin,ray_target)
	if not intersection.empty():
		intersect_pos = intersection.position
		intersection_object = intersection.collider

