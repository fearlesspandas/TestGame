extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var menuEnabled = false
var autopilotEnabled = true
var escape_menu_enuabled = false
var menu_instance = null
var autopilot_label_instance = null
var escape_menu_instance = null
# Called when the node enters the scene tree for the first time.
func _ready():
#	OS.set_window_fullscreen(!OS.window_fullscreen)
	pass
func _process(delta):
	if Input.is_action_just_pressed("toggle_autopilot"):
		autopilotEnabled = not autopilotEnabled
	if Input.is_action_just_released("middle_click"):
		menuEnabled = not menuEnabled
	if Input.is_action_just_pressed("escape"):
		escape_menu_enuabled = not escape_menu_enuabled
	if escape_menu_enuabled or menuEnabled:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if menuEnabled:
		if menu_instance == null:
			menu_instance = load("res://RingMenu.tscn").instance()
		self.add_child(menu_instance)
	else:
		self.remove_child(menu_instance)
		if menu_instance != null:
			menu_instance.call_deferred("free")
			menu_instance = null
	if autopilotEnabled:
		if autopilot_label_instance == null:
			autopilot_label_instance = load("res://autopilot_label.tscn").instance()
		self.add_child(autopilot_label_instance)
	else:
		self.remove_child(autopilot_label_instance)
		if autopilot_label_instance != null:
			autopilot_label_instance.call_deferred("free")
			autopilot_label_instance = null
	

