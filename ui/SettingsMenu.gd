extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var camera_orbit = find_parent("CameraOrbit")
onready var escape_menu = find_parent("EscapeMenu")
onready var h_sense_label = find_node("h_sense_label")
onready var v_sense_label = find_node("v_sense_label")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_fullscreen_check_toggled(button_pressed):
	OS.set_window_fullscreen(button_pressed)


func _on_horizontal_camera_sens_value_changed(value):
	if camera_orbit != null:
		camera_orbit.lookSense_h = value
		h_sense_label.text = value
		


func _on_vertical_camera_sense_value_changed(value):
	if camera_orbit != null:
		camera_orbit.lookSense_v = value
		v_sense_label.text = value


func _on_back_button_pressed():
	escape_menu.show_all_assets()
	escape_menu.hide_asset("settings")
