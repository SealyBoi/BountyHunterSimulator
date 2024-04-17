extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var player = get_parent().get_node("Player")
@onready var nav = $NavigationAgent2D
@onready var xp_blip = preload("res://objects/xp_blip.tscn")
@export var SPEED = 250
@export var health = 2
@export var damage = 1
var spawning = true
var is_hitting = false
var can_hit = true
var bug: String

func _ready():
	anim.play("spawn")
	$CollisionShape2D.disabled = true
	$SpawnTimer.start()

func _physics_process(delta):
	if spawning:
		return
	
	if not nav.is_navigation_finished() and bug == "bug01":
		move()
	elif position.distance_to(player.global_position) >= 500 and bug == "bug02":
		move()

func move():
	var next_pos = nav.get_next_path_position()
	var curr_pos = global_position
	velocity = (next_pos - curr_pos).normalized() * SPEED
	move_and_slide()

func _on_nav_timer_timeout():
	nav.set_target_position(player.global_position)

func _on_spawn_timer_timeout():
	assign_bug()
	$CollisionShape2D.disabled = false
	spawning = false

func assign_bug():
	if randi() % 2 == 0:
		anim.play("bug01")
		SPEED += 50
		bug = "bug01"
	else:
		anim.play("bug02")
		health += 2
		bug = "bug02"

func hit(damage):
	health -= damage
	if health <= 0:
		var rand = randi_range(1, 3)
		for i in rand:
			call_deferred("spawn_xp_blip")
		queue_free()

func spawn_xp_blip():
	var blip = xp_blip.instantiate()
	blip.position = position
	get_parent().add_child(blip)

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
