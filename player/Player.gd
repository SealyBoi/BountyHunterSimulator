extends CharacterBody2D

# Player anim
@onready var anim = $AnimatedSprite2D

# Player gun
@onready var gun = $Gun

# Base player variables
@export var SPEED = 500.0
@export var DASH_SPEED = 1000.0
@export var health = 15
const MAX_HEALTH = 15
var invulnerable = false

# Dash variables
var can_dash = true
var dashing = false
var last_dir = Vector2(1,0)
var dash_acc = 0
@export var DASH_TIME = 0.25
@export var DASH_COOLDOWN = 2

# Player HUD variables
@onready var HUD = get_parent().get_node("UI/HUD")
@onready var health_bar = HUD.get_node("HealthBar")
@onready var dash_bar = HUD.get_node("DashBar")

func _ready():
	health = MAX_HEALTH
	health_bar.max_value = MAX_HEALTH
	health_bar.value = health
	
	dash_bar.max_value = DASH_COOLDOWN
	dash_bar.value = DASH_COOLDOWN
	dash_bar.step = DASH_COOLDOWN / 20
	$DashCooldown.wait_time = DASH_COOLDOWN
	
	anim.play("idle")
	anim.flip_h = true

func _physics_process(delta):
	dash_process(delta)
	move_process(delta)

	move_and_slide()

func dash_process(delta):
	if dashing:
		velocity = last_dir * DASH_SPEED
		dash_acc += delta
		dash_bar.value = dash_acc
		if dash_acc > DASH_TIME:
			dashing = false
			invulnerable = false
	elif not can_dash:
		dash_acc += delta
		dash_bar.value = dash_acc
		anim.play("idle")
		gun.visible = true
	
	if Input.is_action_just_pressed("dash") and can_dash:
		can_dash = false
		dashing = true
		invulnerable = true
		dash_acc = 0
		if last_dir.x > 0:
			anim.play("dash_left")
		else:
			anim.play("dash_right")
		gun.visible = false
		$DashCooldown.start()

func move_process(delta):
	if dashing:
		return
	
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	if direction:
		anim.play("walk")
		last_dir = direction
	else:
		anim.play("idle")
	velocity = direction * SPEED

func _on_dash_cooldown_timeout():
	can_dash = true

func hit(damage):
	if not invulnerable:
		health -= damage
		health_bar.value = health
		if health <= 0:
			call_deferred("reload")

func reload():
	get_tree().reload_current_scene()
