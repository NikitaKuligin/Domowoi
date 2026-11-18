extends Node3D
# Frosch hüpft am Flussufer zwischen den Wegpunkten hin und her.
# Kommt Domowoi nah heran, bleibt er stehen und schaut ihn an. Mit E beginnt ein Dialog:
# "Ja" = der Frosch verschwindet und an seiner Stelle liegt eine Krone, "Nein" = er hüpft weiter.

@export var waypoints: Array[Vector3] = [Vector3(-8.47, -0.017, 4.50), Vector3(-8.25, -0.011, 5.03), Vector3(-8.09, -0.010, 5.70), Vector3(-7.59, 0.001, 6.14), Vector3(-7.31, 0.001, 6.70), Vector3(-7.05, -0.002, 6.94)]
@export var speed := 0.3
@export var talk_radius := 0.6 # ab dieser Entfernung (Meter) bleibt der Frosch stehen
@export var turn_speed := 8.0

var target := 1 # Index des nächsten Wegpunkts
var step := 1 # +1 vorwärts, -1 zurück
var declined := false # nach "Nein" hüpft er weiter, bis der Spieler einmal weggegangen ist

const KRONE := preload("res://scenes/krone.tscn")

@onready var player: Node3D = get_node("../Player")
@onready var dialog: Control = get_node("../Dialog")
@onready var anim: AnimationPlayer = find_children("*", "AnimationPlayer", true, false)[0]


func _ready() -> void:
	position = waypoints[0]
	for a in ["run", "stand"]:
		anim.get_animation(a).loop_mode = Animation.LOOP_LINEAR


func _process(delta: float) -> void:
	if declined and not _player_in_radius():
		declined = false
	if _player_near():
		anim.play("stand")
		_face(player.global_position - global_position, delta)
		return
	anim.play("run") # "run" ist beim Frosch das Hüpfen
	var to_goal := waypoints[target] - position
	if to_goal.length() < 0.02:
		if target + step < 0 or target + step >= waypoints.size():
			step = -step # am Ende umkehren
		target += step
		return
	position = position.move_toward(waypoints[target], speed * delta)
	_face(to_goal, delta)


func _unhandled_input(event: InputEvent) -> void:
	if _player_near() and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E:
		dialog.open("Frosch", ["Ja", "Nein"], _on_answer, "Kannst du mir helfen?")
		get_viewport().set_input_as_handled()


func _on_answer(index: int) -> void:
	if index == 1:
		declined = true
		return
	var krone := KRONE.instantiate()
	krone.position = Vector3(position.x, Karte.surface(position), position.z)
	get_parent().add_child(krone)
	queue_free()


func _player_near() -> bool:
	return _player_in_radius() and not declined and player.form == "domowoi" and not player.dying


func _player_in_radius() -> bool:
	var to := player.global_position - global_position
	return Vector2(to.x, to.z).length() < talk_radius


func _face(dir: Vector3, delta: float) -> void:
	rotation.y = lerp_angle(rotation.y, atan2(dir.x, dir.z), turn_speed * delta)
