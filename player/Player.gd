extends CharacterBody2D

# Player anim
@onready var anim = $AnimatedSprite2D
var being_hit = false

# Player gun
@onready var gun = $Gun

# Base player variables
@export var SPEED = 500.0
@export var DASH_SPEED = 1000.0
@export var health = 15
var MAX_HEALTH = 15
var invulnerable = false
var damage_reduction = 0

# Dash variables
var can_dash = true
var dashing = false
var last_dir = Vector2(1,0)
var last_anim = "idle"
var dash_acc = 0
@export var DASH_TIME = 0.25
@export var DASH_COOLDOWN = 2

# Player Level variables
var level = 0
var xp_threshold = 100 # Amount of xp required to level up
var xp = 0

# Player HUD variables
@onready var HUD = get_parent().get_node("UI/HUD")
@onready var health_bar = HUD.get_node("HealthBar")
@onready var dash_bar = HUD.get_node("DashBar")
@onready var xp_bar = HUD.get_node("XpBar")
@onready var level_up = HUD.get_node("LevelUpScreen")

func _ready():
	health = MAX_HEALTH
	health_bar.max_value = MAX_HEALTH
	health_bar.value = health
	health_bar.step = 0.1
	
	dash_bar.max_value = DASH_COOLDOWN
	dash_bar.value = DASH_COOLDOWN
	dash_bar.step = DASH_COOLDOWN / 20
	$DashCooldown.wait_time = DASH_COOLDOWN
	
	xp_bar.max_value = xp_threshold
	xp_bar.value = xp
	
	anim.play("idle")
	anim.flip_h = true

func _input(event):
	if event.is_action_pressed("pause"):
		get_parent().get_node("UI/HUD/PauseScreen").visible = true
		get_parent().get_node("UI/HUD/PauseScreen/Options/Resume").grab_focus()
		get_tree().paused = true

func _physics_process(delta):
	# Easiest solution for now to fix the hurt anim is to just cancel all other actions for .1 seconds
	if being_hit:
		return
	
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
			anim.play(last_anim)
	elif not can_dash:
		dash_acc += delta
		dash_bar.value = dash_acc
		gun.visible = true
	
	if Input.is_action_just_pressed("dash") and can_dash:
		can_dash = false
		dashing = true
		invulnerable = true
		dash_acc = 0
		last_anim = anim.animation
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
		health -= damage * (1 - damage_reduction)
		health_bar.value = health
		being_hit = true
		anim.play("hurt")
		if health <= 0:
			call_deferred("reload_scene")
		await get_tree().create_timer(0.1, false).timeout
		being_hit = false

func reload_scene():
	get_tree().reload_current_scene()

func gain_xp(gained_xp):
	# Max level
	if level >= 18:
		return
	
	xp += gained_xp
	if xp >= xp_threshold:
		xp = 0
		xp_threshold += 75
		level += 1
		xp_bar.max_value = xp_threshold
		level_up.visible = true
		level_up.get_node("ItemOptions/Item2/ItemButton").grab_focus()
		get_tree().paused = true
	xp_bar.value = xp

func modify_stat(stat: String, value: float):
	match stat:
		"health":
			MAX_HEALTH += value
			health += MAX_HEALTH
			health_bar.value = health
			health_bar.max_value = MAX_HEALTH
		"fire_rate":
			gun.fire_rate = gun.fire_rate - value
			gun.update_firerate()
		"speed":
			SPEED +=  value
		"dash_cooldown":
			DASH_COOLDOWN = DASH_COOLDOWN - value
			$DashCooldown.wait_time = DASH_COOLDOWN
			dash_bar.max_value = DASH_COOLDOWN
		"pierce":
			gun.pass_through += value
		"damage":
			gun.damage += value
		"armor":
			damage_reduction += value
		"barrel":
			gun.barrels += 1
