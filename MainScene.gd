extends Spatial

export(Resource) var entity
onready var player = get_node("P1")
func _ready():
	entity.instance()
	for i in 1:
		var instance = entity.instance()
		instance.global_transform.origin = player.global_transform.origin
		get_tree().get_root().add_child(instance)
