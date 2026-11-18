extends Node3D
# Erdbeerbusch: Beim Spielstart wird er auf die Bodenhöhe gesetzt.
# Im Editor muss man ihn also nur waagerecht (x/z) verschieben.
# Steht der Spieler davor und drückt E, verschwindet der Busch und eine Erdbeere kommt ins Inventarfeld 2.

@export var pickup_radius := 0.5
@export var icon: Texture2D = preload("res://textures/ui/Icon_Erdbeere.png")

@onready var player: Node3D = get_tree().current_scene.get_node("Player")
@onready var inventar: Control = get_tree().current_scene.get_node("Inventar")


func _ready() -> void:
	global_position.y = Karte.height(global_position)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E and _player_near():
		inventar.add(1, icon)
		get_viewport().set_input_as_handled()
		queue_free()


func _player_near() -> bool:
	var to := player.global_position - global_position
	return Vector2(to.x, to.z).length() < pickup_radius and not player.dying
