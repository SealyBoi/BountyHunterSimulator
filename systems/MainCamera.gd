extends Camera2D

@onready var player = get_parent().get_node("Player")
var speed = 10

func _physics_process(delta):
	position = lerp(position, player.position, speed * delta)
