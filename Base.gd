extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_input_event(camera, event, position, normal, shape_idx):
	print("clicked")


func _on_Area_body_entered(body):
	print("entered")


func _on_Area_mouse_entered():
	print("house entered") # Replace with function body.
