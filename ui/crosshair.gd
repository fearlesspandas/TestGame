extends Control

export(Resource) var ring_menu
export(Resource) var autopilot_label
export(Resource) var FPS_label
export(Resource) var JumpRemaining_label
onready var player = find_parent("P1").find_node("Player")
onready var camera = find_parent("P1").find_node("PlayerCam")
var menuEnabled = false
var autopilotEnabled = true
var escape_menu_enuabled = false
var menu_instance = null
var autopilot_label_instance = null
var escape_menu_instance = null
var fps_label_instance = null
var jump_label_instance = null
# Called when the node enters the scene tree for the first time.
func _ready():
	jump_label_instance = JumpRemaining_label.instance()
	self.add_child(jump_label_instance)
	pass
func handle_fps():
	if fps_label_instance != null:
		fps_label_instance.text = str(Engine.get_frames_per_second())
func handle_jump_force():
	if jump_label_instance != null:
		jump_label_instance.text = str(player.jump_force)
func _process(delta):
	handle_fps()
	handle_jump_force()
	if Input.is_action_just_pressed("middle_click"):
		menuEnabled = not menuEnabled
	if Input.is_action_just_pressed("escape"):
		escape_menu_enuabled = not escape_menu_enuabled
		player.stop_selection
	if escape_menu_enuabled or menuEnabled:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if menuEnabled:
		if menu_instance == null:
			menu_instance = ring_menu.instance()
		self.add_child(menu_instance)
	else:
		if menu_instance != null:
			var children = menu_instance.get_children()
			for c in children:
				if c.has_method("on_destroy"):
					c.on_destroy()
#			menu_instance.on_destroy()
		self.remove_child(menu_instance)
		if menu_instance != null:
			menu_instance.call_deferred("free")
			menu_instance = null
	if player.autopilot_on:
		if autopilot_label_instance == null:
			autopilot_label_instance = autopilot_label.instance()
		self.add_child(autopilot_label_instance)
		if fps_label_instance == null:
			fps_label_instance = FPS_label.instance()
		self.add_child(fps_label_instance)
	else:
		self.remove_child(autopilot_label_instance)
		if autopilot_label_instance != null:
			autopilot_label_instance.call_deferred("free")
			autopilot_label_instance = null
		self.remove_child(fps_label_instance)
		if fps_label_instance != null:
			fps_label_instance.call_deferred("free")
			fps_label_instance = null	
	

