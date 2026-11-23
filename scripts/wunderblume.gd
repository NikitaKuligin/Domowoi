extends Node3D
# Wunderblume auf der Insel im Sumpf. Nur Domowoi kann sie pflücken (mit E):
# sie kommt ins Inventarfeld 4 und Kikimora wacht auf.

@export var pickup_radius := 0.5
@export var icon: Texture2D = preload("res://textures/ui/Icon_Wunderblume.png")

@onready var player: Node3D = get_node("../Player")
@onready var inventar: Control = get_node("../Inventar")
@onready var kikimora: Node3D = get_node("../Kikimora")


func _unhandled_input(event: InputEvent) -> void:
	if player.form == "domowoi" and player.wants_interact(event) and _player_near():
		inventar.add(3, icon)
		kikimora.wake()
		get_viewport().set_input_as_handled()
		queue_free()


func _player_near() -> bool:
	var to := player.global_position - global_position
	return Vector2(to.x, to.z).length() < pickup_radius
