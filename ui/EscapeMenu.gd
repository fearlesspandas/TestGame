extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


onready var settings_menu = find_node("SettingsMenu")
onready var logout_button = find_node("LogoutButton")
onready var settings_button = find_node("SettingsButton")
onready var camera_orbit = find_parent("CameraOrbit")
onready var all_assets = {"settings":settings_menu,"settings_button":settings_button,"logout_button":logout_button}
func _ready():
	pass
func show_asset(id):
	all_assets[id].visible = true
func hide_asset(id):
	all_assets[id].visible = false
func show_all_assets():
	for k in all_assets.keys():
		all_assets[k].visible = true
func hide_all_assets():		
	for k in all_assets.keys():
		all_assets[k].visible = false

func _process(delta):
	if Input.is_action_just_pressed("escape"):
		self.visible = not self.visible
#		camera_orbit.stop_movement = self.visible #handles making cursor visible as well
		
func _on_SettingsButton_pressed():
	hide_all_assets()
	show_asset("settings")


func _on_LogoutButton_pressed():
	NetworkManager.kicked()
