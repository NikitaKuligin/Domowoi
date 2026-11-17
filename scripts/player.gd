extends Node3D
# Domowoi läuft mit WASD über die Karte. Ohne Kollision und ohne Animation.
# Die Höhe bleibt konstant (die Karte ist fast flach); für Hügel braucht man eine Kollision der Karte + RayCast3D nach unten.

@export var speed := 1.0
@export var map_half_size := 11.6 # Karte ist ca. 24x24, weiter geht es nicht

@onready var model: Node3D = $Model


func _process(delta: float) -> void:
	var dir := Vector3.ZERO
	if Input.is_physical_key_pressed(KEY_W): dir.z -= 1
	if Input.is_physical_key_pressed(KEY_S): dir.z += 1
	if Input.is_physical_key_pressed(KEY_A): dir.x -= 1
	if Input.is_physical_key_pressed(KEY_D): dir.x += 1
	if dir == Vector3.ZERO:
		return
	dir = dir.normalized()
	position += dir * speed * delta
	position.x = clampf(position.x, -map_half_size, map_half_size)
	position.z = clampf(position.z, -map_half_size, map_half_size)
	model.rotation.y = atan2(dir.x, dir.z) # Modell in Laufrichtung drehen
