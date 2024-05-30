extends Control


func _on_button_pressed():
	get_tree().call_deferred("reload_current_scene")
