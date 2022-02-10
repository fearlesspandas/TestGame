extends Spatial

export(Resource) var entity
onready var player = get_node("P1")
func _ready():
	entity.instance()
	for i in 10:
		var instance = entity.instance()
		instance.global_transform.origin = player.global_transform.origin + Vector3(0,10,0)
		get_tree().get_root().get_child(0).add_child(instance)
