extends RigidBody2D

@onready var player = get_tree().get_root().get_node("TestArea/Player")
@export var speed = 10

func _physics_process(delta):
	var dist: int = position.distance_to(player.global_position)
	if dist <= 500:
		var dir = position.direction_to(player.global_position) * (speed - roundi(dist / 50))
		var collision = move_and_collide(dir)
		if collision and collision.get_collider().name == "Player":
			# Play money making animation and sound
			# Return to menu/go to next level
			get_tree().call_deferred("return_to_menu")

func return_to_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
