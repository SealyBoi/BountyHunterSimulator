extends RigidBody2D

@export var damage = 1

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		body.hit(damage)
		queue_free()
	elif not body.is_in_group("xp"):
		#queue_free()
		pass
