extends Spatial

onready var map = get_tree().get_root().get_child(0)
export(Resource) var Ramp
var ramp_instances:Array = []
var radius = 10

func _ready():
	for i in 10:
		var self_origin = self.global_transform.origin
		var instance = Ramp.instance()
		var rad = 2*PI/10
		var x = self_origin.x + sin(i) * radius
		var y = 3
		var z = self_origin.z + cos(i) * radius
		var pos = Vector3(x,y,z)
		self.look_at(pos,Vector3.UP)
		instance.global_transform.origin =  pos
		instance.rotation_degrees = -self.rotation_degrees
		instance.rotation_degrees.x -= 30
		map.add_child(instance)
