extends AnimatedSprite2D

# Gun variables
@onready var bullet_scene = preload("res://player/bullets/bullet.tscn")
var can_fire = true
@export var fire_rate = 0.45
@export var damage = 1
@export var pass_through = 1
@export var barrels = 1
@onready var bullet_audio = $Bullet

func _ready():
	$FireRateTimer.wait_time = fire_rate

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(get_global_mouse_position())
	
	flip_player()
	_joystick_process(delta)
	fire_process(delta)

func flip_player():
	if get_global_mouse_position().x > 0:
		flip_v = false
		get_parent().get_node("AnimatedSprite2D").flip_h = true
	else:
		flip_v = true
		get_parent().get_node("AnimatedSprite2D").flip_h = false

func _joystick_process(delta):
	var joyInput = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if joyInput != Vector2.ZERO:
		if joyInput.x > 0:
			flip_v = false
			get_parent().get_node("AnimatedSprite2D").flip_h = true
		else:
			flip_v = true
			get_parent().get_node("AnimatedSprite2D").flip_h = false
		var mouseLoc = (get_viewport().get_visible_rect().size / 2) + (joyInput * 100)
		Input.warp_mouse(mouseLoc)
		rotation = joyInput.angle()

func fire_process(delta):
	if Input.is_action_pressed("fire") and can_fire:
		play("fire")
		bullet_audio.play()
		
		var bul_offset = -15 * (barrels - 1)
		for barrel in barrels:
			spawn_bullet(bul_offset)
			
			bul_offset += 30
		
		can_fire = false
		$FireRateTimer.start()
	elif Input.is_action_just_released("fire"):
		pass # can_fire = true

func spawn_bullet(offset):
	var bul = bullet_scene.instantiate()
	bul.position = $BulletSpawn.global_position
	bul.rotation = rotation + deg_to_rad(offset)
	bul.linear_velocity = (bul.position.direction_to($Target.global_position) * 1000).rotated(deg_to_rad(offset))
	bul.damage = damage
	bul.pass_through = pass_through
	get_tree().get_root().add_child(bul)

func _on_fire_rate_timer_timeout():
	can_fire = true

func update_firerate():
	$FireRateTimer.wait_time = fire_rate
