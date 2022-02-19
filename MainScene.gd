extends Spatial

var device_ip_address
var create_server = false
var ip_in = "192.168.1.168"
onready var ip_label = find_node("IpLabel")
onready var pc_label = find_node("PClabel")
onready var control = find_node("Control")
onready var main = find_node("Main")
onready var music = find_node("MainMusic")
