extends Node3D
# Krone: dreht sich langsam. Steht der Spieler davor und drückt E (oder klickt), kommt sie ins Inventarfeld 1.

@export var pickup_radius := 0.5
@export var icon: Texture2D = preload("res://textures/ui/Icon_Krone.png")

@onready var player: Node3D = get_tree().current_scene.get_node("Player")
@onready var inventar: Control = get_tree().current_scene.get_node("Inventar")


func _process(delta: float) -> void:
	rotation.y += delta # langsam drehen, damit man sie bemerkt


func _unhandled_input(event: InputEvent) -> void:
	if player.wants_interact(event) and _player_near():
		inventar.add(0, icon)
		get_viewport().set_input_as_handled()
		queue_free()


func _player_near() -> bool:
	var to := player.global_position - global_position
	return Vector2(to.x, to.z).length() < pickup_radius and not player.dying
