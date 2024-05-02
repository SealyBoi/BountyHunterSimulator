extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var player = get_tree().get_root().get_node("TestArea/Player")
@onready var nav = $NavigationAgent2D
@onready var xp_blip = preload("res://objects/xp_blip.tscn")
@export var SPEED = 250
@export var health = 2
@export var damage = 1
var spawning = true
var is_hitting = false
var being_hit = false
var can_hit = true
var bug: String

signal dead

func assign_dead(function):
	dead.connect(function)

# Bug02 projectile
@onready var stinger_scene = preload("res://player/bullets/stinger.tscn")
var can_fire = true

func _ready():
	anim.play("spawn")
	$CollisionShape2D.disabled = true
	$Area2D.monitoring = false
	$SpawnTimer.start()

func _physics_process(delta):
	if spawning:
		return
	
	if not nav.is_navigation_finished() and bug == "bug01":
		move()
	elif bug == "bug02":
		if position.distance_to(player.global_position) >= 500:
			move()
		else:
			shoot_at_player()

func move():
	if is_hitting or being_hit:
		return
	
	anim.play(bug)
	var next_pos = nav.get_next_path_position()
	var curr_pos = global_position
	velocity = (next_pos - curr_pos).normalized() * SPEED
	move_and_slide()

func shoot_at_player():
	if not can_fire:
		return
	
	anim.play("bug02_attack")
	is_hitting = true
	var stinger = stinger_scene.instantiate()
	stinger.position = position
	stinger.look_at(player.global_position)
	stinger.linear_velocity = stinger.position.direction_to(player.global_position) * 500
	get_tree().get_root().add_child(stinger)
	can_fire = false
	await get_tree().create_timer(1).timeout
	can_fire = true
	is_hitting = false

func _on_nav_timer_timeout():
	nav.set_target_position(player.global_position)

func _on_spawn_timer_timeout():
	assign_bug()
	$CollisionShape2D.disabled = false
	$Area2D.monitoring = true
	spawning = false

func assign_bug():
	if randi() % 4 == 0:
		anim.play("bug02")
		health += 2
		bug = "bug02"
	else:
		anim.play("bug01")
		SPEED += 50
		bug = "bug01"

func hit(damage):
	health -= damage
	being_hit = true
	if bug == "bug01":
		anim.play("bug01_hurt")
	else:
		anim.play("bug02_hurt")
	if health <= 0:
		die()
	else:
		await get_tree().create_timer(.1, false).timeout
		being_hit = false

func spawn_xp_blip():
	var blip = xp_blip.instantiate()
	blip.position = position
	get_parent().add_child(blip)

func _on_area_2d_body_entered(body):
	if body.name == "Player" and bug == "bug01":
		player.hit(damage)
		is_hitting = true
		anim.play("bug01_attack")
		$HitTimer.start()

func _on_area_2d_body_exited(body):
	if bug == "bug01":
		is_hitting = false
		$HitTimer.stop()

func _on_hit_timer_timeout():
	if is_hitting:
		player.hit(damage)
		$HitTimer.start()

func die():
	anim.play(bug + "_die")
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D.set_deferred("monitoring", false)
	spawning = true
	await get_tree().create_timer(1).timeout
	var rand = randi_range(1, 3)
	for i in rand:
		call_deferred("spawn_xp_blip")
	dead.emit()
	queue_free()
