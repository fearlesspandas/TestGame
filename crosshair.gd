extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var menuEnabled = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _physics_process(delta):
	if Input.is_action_just_released("middle_click"):
		menuEnabled = not menuEnabled
	if menuEnabled:
		var menu = self.get_child(self.get_child_count()-1)
		if self.get_child_count() == 1:
			menu = load("res://RingMenu.tscn").instance()
			self.add_child(menu)
	else:
		if self.get_child_count() > 1:
			var menu = self.get_child(self.get_child_count() - 1)
			self.remove_child(menu)
			if menu != null:
				menu.call_deferred("free")
			
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
