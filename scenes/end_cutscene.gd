extends Node2D


func _ready():
	$AnimationPlayer.play("outro")
	$Player.play("idle")
	$Friend.play("panic")
	$Bug.play("fly")
	await get_tree().create_timer(1).timeout
	$AnimationPlayer.play("kill_bug")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "kill_bug":
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
