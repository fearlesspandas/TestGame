extends RigidBody


onready var outer:MeshInstance = find_node("outerring")
onready var middle:MeshInstance = find_node("disc")
onready var body:MeshInstance = find_node("body")

var color_palette = []
var properties = {}

func _ready():
	color_palette.append(make_color_type("1c1b20","e2e134","4a4b56"))
	color_palette.append(make_color_type("0d2043","d9e7ff","2265d3"))
	color_palette.append(make_color_type("162c17","ddedde","37833c"))
	color_palette.append(make_color_type("463206","fee5b2","b98318"))
	color_palette.append(make_color_type("441510","fddcd9","c8382d"))
	
	var rand_pal = color_palette[int(rand_range(0,color_palette.size()))]
	
func make_color_type(outer,middle,inner) -> Dictionary:
	return {"outer":outer,"middle":middle,"inner":inner}
