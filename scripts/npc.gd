extends Node3D
# Kolobok steht da und summt (Sprechblase mit Noten). Kommt der Spieler nah heran, dreht er sich zu ihm
# und ruft ihn. Mit E oder Mausklick beginnt der Dialog:
#   "Hallo! Wie geht's?" -> "Ich komme später wieder." = Kolobok ist danach verschwunden
#                        -> "Mir geht's gut. Und dir?" = er hat Angst und will mit
#   "Nimm mich mit!"     -> "Komm mit!" = Kolobok kommt ins Inventarfeld 3
#                        -> "Ich komme später wieder." = Kolobok ist danach verschwunden
# Mit Taste 3 setzt der Spieler ihn irgendwo ab (place). Erreicht ihn dort Kikimora (scare),
# rennt er zurück an seinen Anfangsplatz.

@export var talk_radius := 0.6 # ab dieser Entfernung (Meter) ruft er den Spieler
@export var turn_speed := 5.0
@export var run_speed := 1.5 # so schnell rennt er vor Kikimora weg
@export var icon: Texture2D = preload("res://textures/ui/Icon_Kolobok.png")

# "home" = am Anfangsplatz, "leaving" = verschwindet, sobald der Spieler weg ist, "carried" = im Inventar,
# "placed" = vom Spieler abgesetzt, "fleeing" = rennt nach Hause
var state := "home"
var home: Vector3
var notes: Sprite3D

@onready var player: Node3D = get_node("../Player")
@onready var dialog: Control = get_node("../Dialog")
@onready var inventar: Control = get_node("../Inventar")
@onready var bubble: Node3D = $Bubble
@onready var bubble_label: Label3D = $Bubble/Label


func _ready() -> void:
	home = global_position
	notes = Sprite3D.new() # Sprechblase mit Noten, an derselben Stelle wie die Ruf-Blase
	notes.texture = preload("res://textures/ui/Sprechblase_Noten.png")
	notes.pixel_size = 0.0012
	notes.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	notes.position = bubble.position
	add_child(notes)


func _process(delta: float) -> void:
	var to := player.global_position - global_position
	var near: bool = Vector2(to.x, to.z).length() < talk_radius and not player.dying
	if state == "leaving" and not near:
		state = "gone"
		hide()
	if state == "fleeing":
		_run_home(delta)
	bubble.visible = state == "home" and near
	notes.visible = state in ["home", "placed"] and not bubble.visible
	notes.position.y = bubble.position.y + sin(Time.get_ticks_msec() * 0.004) * 0.015 # leicht wippen
	if bubble.visible:
		bubble_label.text = "He, Domowoi!" if player.form == "domowoi" else "He, Frosch!"
		rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), turn_speed * delta) # zum Spieler drehen


func _unhandled_input(event: InputEvent) -> void:
	if bubble.visible and player.wants_interact(event):
		dialog.open("Kolobok", ["Ich komme später wieder.", "Mir geht's gut. Und dir?"], _on_greeting, "Hallo! Wie geht's?")
		get_viewport().set_input_as_handled()


func _on_greeting(index: int) -> void:
	if index == 0:
		state = "leaving"
	else:
		dialog.open("Kolobok", ["Komm mit!", "Ich komme später wieder."], _on_offer,
			"Ich habe Angst, hier allein zu bleiben. Nimm mich mit, vielleicht kann ich dir helfen!")


func _on_offer(index: int) -> void:
	if index == 0:
		state = "carried"
		hide()
		inventar.add(2, icon)
	else:
		state = "leaving"


# Vom Spieler an Stelle p abgesetzt.
func place(p: Vector3) -> void:
	global_position = Vector3(p.x, Karte.surface(p), p.z)
	state = "placed"
	show()


# Kikimora ist da: weglaufen.
func scare() -> void:
	state = "fleeing"


func _run_home(delta: float) -> void:
	var to := home - global_position
	to.y = 0
	if to.length() < 0.05:
		global_position = home
		state = "home"
		return
	global_position += to.normalized() * minf(run_speed * delta, to.length())
	global_position.y = Karte.surface(global_position)
	rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), turn_speed * 2 * delta)
