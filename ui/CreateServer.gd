extends Control

onready var ip_label = find_node("IpAddressLabel")


func _on_CreateServerButton_pressed():
	NetworkManager.create_server()
	ip_label.text = "new server created at:" + ServerManager.ip_address
