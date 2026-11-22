extends Control
# Dialogfenster mit Antwortmöglichkeiten. Während es offen ist, steht das Spiel still.
# W/S wählt eine Antwort, E bestätigt (die Maus nicht), Esc schließt das Fenster.

var selected := 0
var on_answer: Callable # bekommt den Index der gewählten Antwort

@onready var name_label: Label = $Panel/VBox/Name
@onready var text_label: Label = $Panel/VBox/Text
@onready var options: Array[Node] = [$Panel/VBox/Option1, $Panel/VBox/Option2, $Panel/VBox/Option3]


# line = was die Figur sagt (darf leer sein), texts = Antworten des Spielers.
func open(speaker: String, texts: Array, callback: Callable, line := "") -> void:
	name_label.text = speaker
	text_label.text = line
	text_label.visible = line != ""
	for i in options.size():
		options[i].visible = i < texts.size() # überzählige Felder ausblenden
		if i < texts.size():
			options[i].get_node("Label").text = texts[i]
	on_answer = callback
	selected = 0
	_highlight()
	visible = true
	get_tree().paused = true


func close() -> void:
	visible = false
	get_tree().paused = false


func _input(event: InputEvent) -> void:
	if not visible or not event is InputEventKey or not event.pressed or event.echo:
		return
	var count := options.filter(func(o): return o.visible).size()
	match event.physical_keycode:
		KEY_W:
			selected = (selected - 1 + count) % count
			_highlight()
		KEY_S:
			selected = (selected + 1) % count
			_highlight()
		KEY_E:
			_choose()
		KEY_ESCAPE:
			close()
		_:
			return
	get_viewport().set_input_as_handled() # damit Esc nicht zusätzlich das Pausenmenü öffnet


# Fenster schließen, dann die Antwort melden (die Figur darf daraufhin gleich ein neues Fenster öffnen).
func _choose() -> void:
	close()
	on_answer.call(selected)


func _highlight() -> void:
	for i in options.size():
		options[i].modulate = Color.WHITE if i == selected else Color(1, 1, 1, 0.4)
