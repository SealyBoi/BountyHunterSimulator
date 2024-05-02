extends Node2D

@onready var tilemap: TileMap = $TileMap
@onready var enemy_scene = preload("res://enemies/basic_bug.tscn")
@onready var boss_scene = preload("res://enemies/boss_bug.tscn")
@onready var survival_timer_label = $UI/HUD/SurvivalTimer
@export var spawn_time = .75
var tilemap_x = 0
var tilemap_y = 0
var tile_size = 64
var total_survival_time = 0
var total_enemies = 0
@export var MAX_ENEMIES = 25
var boss_is_dead = false
var health_mod = 0

func _ready():
	tilemap_x = (tilemap.get_used_rect().size.x - 8) / 2
	tilemap_y = (tilemap.get_used_rect().size.y - 8) / 2
	$SpawnUtilities/SpawnTimer.wait_time = spawn_time

func _process(delta):
	total_survival_time += delta
	survival_timer_label.text = str(round(total_survival_time))

func _on_spawn_timer_timeout():
	if total_enemies >= MAX_ENEMIES or boss_is_dead:
		return
	
	var enemy = enemy_scene.instantiate()
	enemy.position = assign_random_pos()
	enemy.assign_dead(decrement_total_enemies)
	get_node("EnemyPool").add_child(enemy)
	enemy.health += health_mod
	total_enemies += 1

func _on_boss_timer_timeout():
	var boss = boss_scene.instantiate()
	boss.position = assign_random_pos()
	boss.assign_dead(boss_died)
	add_child(boss)

func assign_random_pos():
	var neg_x_mod = -1 if randi_range(0,2) == 0 else 1
	var neg_y_mod = -1 if randi_range(0,2) == 0 else 1
	return Vector2(randi_range(0, tilemap_x) * neg_x_mod * tile_size, randi_range(0, tilemap_y) * neg_y_mod * tile_size)

func decrement_total_enemies():
	total_enemies -= 1

func boss_died():
	for enemy in $EnemyPool.get_children():
		enemy.queue_free()
	boss_is_dead = true

func _on_difficulty_timer_timeout():
	MAX_ENEMIES += 5
	spawn_time -= .5
	$SpawnUtilities/SpawnTimer.wait_time = .5 if spawn_time <= .5 else spawn_time
	health_mod += 1
