extends Node3D
# Kolobok: Kommt der Spieler nah heran, dreht er sich zu ihm und ruft ihn mit einer Sprechblase.
# Mit E startet der Dialog. Wählt man "Ich fresse dich jetzt!", verschwindet Kolobok.

@export var speaker := "Kolobok"
@export var answers: Array[String] = ["XXXXXX", "YYYYYY", "Ich fresse dich jetzt!"]
@export var eat_answer := 2 # bei dieser Antwort wird Kolobok gefressen und verschwindet
@export var talk_radius := 0.6 # ab dieser Entfernung (Meter) erscheint die Sprechblase
@export var turn_speed := 5.0

@onready var player: Node3D = get_node("../Player")
@onready var dialog: Control = get_node("../Dialog")
@onready var bubble: Node3D = $Bubble
@onready var bubble_label: Label3D = $Bubble/Label


func _process(delta: float) -> void:
	var to := player.global_position - global_position
	bubble.visible = Vector2(to.x, to.z).length() < talk_radius and not player.dying
	if bubble.visible:
		bubble_label.text = "He, Domowoi!" if player.form == "domowoi" else "He, Frosch!"
		rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), turn_speed * delta) # zum Spieler drehen


func _unhandled_input(event: InputEvent) -> void:
	if bubble.visible and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E:
		dialog.open(speaker, answers, _on_answer)
		get_viewport().set_input_as_handled()


func _on_answer(index: int) -> void:
	if index == eat_answer:
		queue_free()
