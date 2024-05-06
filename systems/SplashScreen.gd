extends Control



func _ready():
	$AudioStreamPlayer2D.play()
	$AnimationPlayer.play("splash")


func _on_animation_player_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
