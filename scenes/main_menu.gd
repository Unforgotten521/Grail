extends Control


func _ready() -> void:
    $MenuContainer/NewGameButton.pressed.connect(_on_new_game_pressed)
    $MenuContainer/ExitButton.pressed.connect(_on_exit_pressed)


func _on_new_game_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/map.tscn")


func _on_exit_pressed() -> void:
    get_tree().quit()
