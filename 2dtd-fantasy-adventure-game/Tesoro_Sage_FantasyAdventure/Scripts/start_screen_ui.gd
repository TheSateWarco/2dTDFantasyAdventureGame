extends Control


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Tesoro_Sage_FantasyAdventure/Scenes/Levels/MainGameLvl.tscn")


func _on_quit_button_pressed() -> void:
	$QuitConfirmDialog.popup_centered()


func _on_quit_config_dialog_confirmed() -> void:
	get_tree().quit()
