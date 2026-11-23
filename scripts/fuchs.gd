extends Node3D
# Fuchs versteckt sich hinter den Büschen bei Kolobok. Lässt der Spieler Kolobok allein (hunt),
# läuft der Fuchs zu ihm und frisst ihn: Kolobok verschwindet, an seiner Stelle liegen Krümel.
# Danach ist der Fuchs doppelt so groß und geht zurück hinter die Büsche, jetzt ragt er über sie hinaus.
# Dort dreht er sich wieder so wie am Anfang (Blick zu Koloboks Platz).

@export var speed := 0.5
@export var turn_speed := 6.0
@export var grow_time := 1.0 # Sekunden zum Wachsen
@export var crumb_count := 5
@export var crumb_radius := 0.08 # so weit liegen die Krümel verstreut
@export var crumb_scale := 2.0 # Größe der Krümel gegenüber dem Modell

const KRUEMEL := preload("res://models/environment/Kruemel/Kruemel.glb")

var state := "hiding" # "hiding", "running", "eating", "returning", "done"
var target: Node3D
var hide_spot: Vector3
var hide_rot: float # Blickrichtung am Versteck


func _ready() -> void:
	hide_spot = global_position
	hide_rot = rotation.y


func hunt(kolobok: Node3D) -> void:
	if state != "hiding":
		return
	target = kolobok
	state = "running"


func _process(delta: float) -> void:
	match state:
		"running":
			if _walk_to(target.global_position, 0.12, delta):
				_eat()
		"returning":
			if _walk_to(hide_spot, 0.02, delta):
				state = "done"
		"done":
			rotation.y = lerp_angle(rotation.y, hide_rot, turn_speed * 0.5 * delta) # langsam umdrehen


# Läuft auf p zu, true wenn angekommen.
func _walk_to(p: Vector3, reach: float, delta: float) -> bool:
	var to := p - global_position
	to.y = 0
	if to.length() < reach:
		return true
	rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), turn_speed * delta)
	var next := global_position + to.normalized() * minf(speed * delta, to.length())
	global_position = Vector3(next.x, Karte.surface(next), next.z)
	return false


func _eat() -> void:
	state = "eating"
	var spot := target.global_position
	target.eaten()
	for i in crumb_count:
		var k: Node3D = KRUEMEL.instantiate()
		get_parent().add_child(k)
		var p := spot + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * crumb_radius
		k.global_position = Vector3(p.x, Karte.surface(p), p.z)
		k.rotation.y = randf() * TAU
		k.scale = Vector3.ONE * crumb_scale
	var tween := create_tween()
	tween.tween_property(self, "scale", scale * 2.0, grow_time)
	tween.tween_callback(func(): state = "returning")
