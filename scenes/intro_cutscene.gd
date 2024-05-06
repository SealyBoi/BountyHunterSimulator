extends Node2D


func _ready():
	$AnimationPlayer.play("intro")
	$Player.play("idle")
	$Friend.play("idle")
	await get_tree().create_timer(2).timeout
	$BossRoar.play()
	$Friend.flip_h = true


func _on_boss_roar_finished():
	$AnimationPlayer.play("boss_charge")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "boss_charge":
		get_tree().change_scene_to_file("res://scenes/tests/test_area.tscn")
