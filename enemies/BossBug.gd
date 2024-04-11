extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var player = get_parent().get_node("Player")
@onready var nav = $NavigationAgent2D
@export var SPEED = 250
@export var health = 60
@export var damage = 3
var spawning = true
var is_hitting = false
var can_hit = true

func _ready():
	anim.play("spawn")
	$CollisionShape2D.disabled = true
	$SpawnTimer.start()

func _physics_process(delta):
	if spawning:
		return
	
	if not nav.is_navigation_finished():
		var next_pos = nav.get_next_path_position()
		var curr_pos = global_position
		velocity = (next_pos - curr_pos).normalized() * SPEED
		move_and_slide()

func _on_nav_timer_timeout():
	nav.set_target_position(player.global_position)

func _on_spawn_timer_timeout():
	anim.play("bug02")
	$CollisionShape2D.disabled = false
	spawning = false

func hit(damage):
	health -= damage
	if health <= 0:
		queue_free()

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player.hit(damage)
		is_hitting = true
		$HitTimer.start()

func _on_area_2d_body_exited(body):
	is_hitting = false
	$HitTimer.stop()

func _on_hit_timer_timeout():
	if is_hitting:
		player.hit(damage)
		$HitTimer.start()
