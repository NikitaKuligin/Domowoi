extends Control
# Ein Menü für zwei Fälle: Hauptmenü (in_game = false) und Pausenmenü im Spiel (in_game = true).

@export var in_game := false


func _ready() -> void:
	visible = not in_game
	$Center/VBox/Start.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if in_game and event.is_action_pressed("ui_cancel"): # ui_cancel = Esc
		visible = not visible
		get_tree().paused = visible
		if visible:
			$Center/VBox/Start.grab_focus()


func _on_start_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game.tscn") # aus der Pause = Neustart


func _on_exit_pressed() -> void:
	get_tree().quit()
