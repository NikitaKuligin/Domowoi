extends Node3D
# Kikimora wartet unsichtbar unter Wasser. Nimmt der Spieler die Wunderblume (wake), taucht sie langsam auf
# und geht auf ihn zu. Erreicht sie ihn, ist das Spiel vorbei.
# Steht ein abgesetzter Kolobok im Sumpf, geht sie zuerst zu ihm; er rennt dann weg und sie kommt wieder zum Spieler.
# Sie läuft nur im Sumpfgebiet (Karte.in_swamp) und bleibt sonst am Rand stehen.

@export var speed := 0.35
@export var catch_radius := 0.25
@export var rise_time := 3.0 # Sekunden zum Auftauchen
@export var rise_depth := 0.45 # so tief steckt sie vorher im Wasser
@export var turn_speed := 5.0

var state := "sleeping" # "sleeping", "rising", "hunting"

@onready var model: Node3D = $Model
@onready var player: Node3D = get_node("../Player")
@onready var kolobok: Node3D = get_node("../Kolobok")


func _ready() -> void:
	global_position.y = Karte.surface(global_position)
	hide()


func wake() -> void:
	if state != "sleeping":
		return
	state = "rising"
	show()
	var top := model.position.y
	model.position.y = top - rise_depth
	var tween := create_tween()
	tween.tween_property(model, "position:y", top, rise_time)
	tween.tween_callback(func(): state = "hunting")


func _process(delta: float) -> void:
	if state != "hunting" or player.dying:
		return
	# Steht Kolobok außerhalb des Sumpfs, kommt sie nicht an ihn heran und geht gleich zum Spieler.
	var chasing_kolobok: bool = kolobok.state == "placed" and Karte.in_swamp(kolobok.global_position)
	var target: Vector3 = kolobok.global_position if chasing_kolobok else player.global_position
	var to := target - global_position
	to.y = 0
	if to.length() < catch_radius:
		if chasing_kolobok:
			kolobok.scare()
		else:
			player.caught()
		return
	rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), turn_speed * delta)
	var next := global_position + to.normalized() * speed * delta
	if Karte.in_swamp(next): # außerhalb des Sumpfs bleibt sie am Rand stehen
		global_position = Vector3(next.x, Karte.surface(next), next.z)
