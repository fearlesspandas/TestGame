extends RayCast

var camerasnap: float = 10

onready var base = get_parent().get_parent().get_parent()
onready var camera:Camera = find_parent("Camera")
onready var cameraspace = base.find_node("CameraSpace")
onready var cameraorbit:Spatial = base.find_node("CameraOrbit")
onready var player = find_parent("P1").find_node("Player")


func _ready():
	set_debug_shape_custom_color(Color.darkmagenta)
	self.collide_with_areas = true
	self.add_exception(player)
	for c in player.get_children():
		self.add_exception(c)
	
var ray_origin : Vector3 = Vector3()
var ray_target : Vector3 = Vector3()
var mouse_position:Vector2 = Vector2()
var intersect_pos : Vector3 = Vector3()
var intersection_object : Object = null



func pos_isPlayer() -> bool:
	var playerpos = player.kinematic.global_transform.origin
#	print("checking pos",intersect_pos,playerpos)
	var diff = (intersect_pos - playerpos).length()
	print("diff",(intersect_pos - playerpos).length())
	return diff < 2
func _physics_process(delta):
	mouse_position = get_viewport().get_mouse_position()
	ray_origin = camera.project_ray_origin(mouse_position)
	ray_target = ray_origin + camera.project_ray_normal(mouse_position) * 1000
	var space_state = get_world().direct_space_state
	var intersection = space_state.intersect_ray(ray_origin,ray_target)
	
	if not intersection.empty():
		intersect_pos = intersection.position
		intersection_object = intersection.collider
	else:
		intersection_object= null

