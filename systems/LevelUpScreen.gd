extends Control

func unpause():
	visible = false
	get_tree().paused = false


func _on_item1_button_pressed():
	unpause()


func _on_item2_button_pressed():
	unpause()


func _on_item3_button_pressed():
	unpause()
