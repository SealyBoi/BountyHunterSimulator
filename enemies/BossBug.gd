extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var player = get_parent().get_node("Player")
@onready var nav = $NavigationAgent2D
@export var SPEED = 250
@export var DASH_SPEED = 800
@export var health = 60
@export var damage = 3
var spawning = true
var is_hitting = false
var can_hit = true

var last_anim = "bossbug"

# Boss attack cycle
var is_charging = false
var is_dashing = false
var is_resting = false
var target_pos: Vector2
var invincible = false

func _ready():
	anim.play("spawn")
	$CollisionShape2D.disabled = true
	$Area2D.monitoring = false
	$SpawnTimer.start()

func _physics_process(delta):
	if spawning or is_charging or is_resting:
		return
	
	if is_dashing:
		dash()
		return
	
	if position.distance_to(player.global_position) >= 800:
		move()
	else:
		if randi_range(0,100) % 5 == 0:
			charge()
		else:
			move()

func move():
	if not nav.is_navigation_finished():
		var next_pos = nav.get_next_path_position()
		var curr_pos = global_position
		if curr_pos.direction_to(player.global_position).x >= 0:
			anim.flip_h = true
		else:
			anim.flip_h = false
		velocity = (next_pos - curr_pos).normalized() * SPEED
		move_and_slide()

func charge():
	var charge_timer = 3
	var dash_timer = 1.5
	var rest_timer = 3
	# Let boss charge up a dash
	anim.play("charge")
	is_charging = true
	# After 'x' seconds of charging, dash
	await get_tree().create_timer(charge_timer).timeout
	target_pos = player.global_position
	anim.play("dash")
	is_dashing = true
	is_charging = false
	invincible = true
	# After 'x' seconds of dashing, rest
	await get_tree().create_timer(dash_timer).timeout
	anim.play("rest")
	is_resting = true
	is_dashing = false
	invincible = false
	# After 'x' seconds of resting, back to cycle
	await get_tree().create_timer(rest_timer).timeout
	anim.play("bossbug")
	is_resting = false

func dash():
	if not nav.is_navigation_finished():
		var next_pos = target_pos
		var curr_pos = global_position
		if curr_pos.direction_to(target_pos).x >= 0:
			anim.flip_h = true
		else:
			anim.flip_h = false
		velocity = (next_pos - curr_pos).normalized() * DASH_SPEED
		move_and_slide()

func _on_nav_timer_timeout():
	nav.set_target_position(player.global_position)

func _on_spawn_timer_timeout():
	anim.play("bossbug")
	$CollisionShape2D.disabled = false
	$Area2D.monitoring = true
	spawning = false

func hit(damage):
	if invincible:
		return
	
	health -= damage
	last_anim = last_anim if anim.animation == "hurt" else anim.animation
	anim.play("hurt")
	if health <= 0:
		queue_free()
	else:
		await get_tree().create_timer(.1).timeout
		anim.play(last_anim)

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
