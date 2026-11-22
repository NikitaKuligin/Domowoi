extends Node3D
# Domowoi läuft mit WASD über die Karte, die Maus dreht die Kamera um ihn herum (Third-Person).
# W läuft in Blickrichtung der Kamera, das Modell dreht sich weich in Laufrichtung.
# Betritt Domowoi das Sumpfwasser, sinkt er langsam ein und das Spiel beginnt im Hauptmenü neu.
# Mit der Krone (Taste 1) wird der Spieler zum Frosch: er hüpft (Animation) und kann auch übers Wasser. Ohne Kollision.
# In jeder anderen Gestalt macht E ihn wieder zu Domowoi (nur die Taste, nicht die Maus).
# Taste 3 setzt Kolobok aus dem Inventar an der aktuellen Stelle ab.
# Die Höhe kommt aus der Höhenkarte (Karte.surface): Boden, Steg oder Wasseroberfläche.

@export var speed := 1.0
@export var turn_speed := 10.0 # wie schnell sich das Modell in Laufrichtung dreht
@export var mouse_sensitivity := 0.003 # Drehung pro Pixel Mausbewegung (Radiant)
@export var pitch_min := -1.2 # Kamera höchstens so steil von oben (Radiant)
@export var pitch_max := -0.05 # und höchstens so flach, sonst rutscht die Kamera unter den Boden
@export var map_half_size := 11.6 # Karte ist ca. 24x24, weiter geht es nicht
@export var sink_time := 3.0 # Sekunden bis Domowoi ganz im Sumpf verschwunden ist
@export var sink_depth := 0.35 # so tief sinkt das Modell ein

# Aktuelle Gestalt des Spielers: "domowoi" oder "frosch". Nur Domowoi ertrinkt im Sumpf.
var form := "domowoi"
var dying := false
var anim: AnimationPlayer # nur beim Frosch, Domowoi hat keine Animationen

const DOMOWOI_SCENE := preload("res://models/characters/Domowoi/Domowoi.glb")
const DOMOWOI_SCALE := 0.128
const DOMOWOI_LIFT := 0.18 # Ursprung des Modells liegt in der Körpermitte, so stehen die Füße auf dem Boden
const FROG_SCENE := preload("res://models/characters/Frog Pet/Frog Pet.glb")
const FROG_SCALE := 0.15

@onready var model: Node3D = $Model
@onready var pivot: Node3D = $CameraPivot
@onready var bubble: Node3D = $Bubble
@onready var inventar: Control = get_node("../Inventar")
@onready var kolobok: Node3D = get_node("../Kolobok")


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Maus verstecken und festhalten
	position.y = Karte.surface(position)
	await get_tree().create_timer(3.0).timeout # Sprechblase "Ich bin so hungrig!" nach 3 Sekunden ausblenden
	bubble.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		pivot.rotation.y -= event.relative.x * mouse_sensitivity
		pivot.rotation.x = clampf(pivot.rotation.x - event.relative.y * mouse_sensitivity, pitch_min, pitch_max)
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # nach Fensterwechsel per Klick wieder einfangen
	elif event is InputEventKey and event.pressed and not event.echo and not dying:
		match event.physical_keycode:
			KEY_1: # Krone: in den Frosch verwandeln
				if form == "domowoi" and inventar.has(0):
					become_frog()
			KEY_2: # Erdbeere essen
				inventar.take(1)
			KEY_3: # Kolobok hier absetzen
				if inventar.take(2):
					kolobok.place(global_position)
			KEY_E: # zurück zu Domowoi (in Domowoi-Gestalt ist E zum Reden/Aufheben da)
				if form != "domowoi":
					become_domowoi()


func _process(delta: float) -> void:
	if dying:
		return
	var dir := Vector3.ZERO
	if Input.is_physical_key_pressed(KEY_W): dir.z -= 1
	if Input.is_physical_key_pressed(KEY_S): dir.z += 1
	if Input.is_physical_key_pressed(KEY_A): dir.x -= 1
	if Input.is_physical_key_pressed(KEY_D): dir.x += 1
	if anim:
		anim.play("stand" if dir == Vector3.ZERO else "run") # "run" ist beim Frosch das Hüpfen
	if dir == Vector3.ZERO:
		return
	dir = dir.normalized().rotated(Vector3.UP, pivot.rotation.y) # relativ zur Kamera
	position += dir * speed * delta
	position.x = clampf(position.x, -map_half_size, map_half_size)
	position.z = clampf(position.z, -map_half_size, map_half_size)
	position.y = Karte.surface(position) # dem Gelände folgen
	model.rotation.y = lerp_angle(model.rotation.y, atan2(dir.x, dir.z), turn_speed * delta) # weich drehen
	if form == "domowoi" and Karte.is_water(position):
		sink()


# Für Figuren und Gegenstände: Will der Spieler gerade mit etwas in der Nähe interagieren?
# Linke Maustaste geht immer, E nur als Domowoi (sonst verwandelt E zurück).
func wants_interact(event: InputEvent) -> bool:
	if dying:
		return false
	if event is InputEventMouseButton:
		return event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	return form == "domowoi" and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E


func sink() -> void:
	dying = true
	# Nur das Modell sinkt, die Kamera bleibt oben und schaut zu.
	var tween := create_tween()
	tween.tween_property(model, "position:y", model.position.y - sink_depth, sink_time)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))


# Kikimora hat den Spieler erwischt: Spiel vorbei, zurück ins Hauptmenü.
func caught() -> void:
	dying = true
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


# Der Spieler wird an Ort und Stelle zum Frosch.
func become_frog() -> void:
	form = "frosch"
	_swap_model(FROG_SCENE, FROG_SCALE)
	anim = model.find_children("*", "AnimationPlayer", true, false)[0]
	for a in ["run", "stand"]:
		anim.get_animation(a).loop_mode = Animation.LOOP_LINEAR


# Zurück zu Domowoi. Steht er dabei im Sumpfwasser, versinkt er.
func become_domowoi() -> void:
	form = "domowoi"
	anim = null
	_swap_model(DOMOWOI_SCENE, DOMOWOI_SCALE, DOMOWOI_LIFT)
	if Karte.is_water(position):
		sink()


# Neues Modell an Stelle des alten, Blickrichtung bleibt.
func _swap_model(scene: PackedScene, model_scale: float, lift := 0.0) -> void:
	var facing := model.rotation.y
	model.queue_free()
	model = scene.instantiate()
	model.scale = Vector3.ONE * model_scale
	model.position.y = lift
	model.rotation.y = facing
	add_child(model)
