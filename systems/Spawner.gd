extends Node2D

@onready var tilemap: TileMap = $TileMap
@onready var enemy_scene = preload("res://enemies/basic_bug.tscn")
@onready var boss_scene = preload("res://enemies/boss_bug.tscn")
@export var spawn_time = 0.5
var tilemap_x = 0
var tilemap_y = 0
var tile_size = 64

func _ready():
	tilemap_x = (tilemap.get_used_rect().size.x - 8) / 2
	tilemap_y = (tilemap.get_used_rect().size.y - 8) / 2
	$SpawnUtilities/SpawnTimer.wait_time = spawn_time

func _on_spawn_timer_timeout():
	var enemy = enemy_scene.instantiate()
	enemy.position = assign_random_pos()
	add_child(enemy)

func _on_boss_timer_timeout():
	var boss = boss_scene.instantiate()
	boss.position = assign_random_pos()
	add_child(boss)

func assign_random_pos():
	var neg_x_mod = -1 if randi_range(0,2) == 0 else 1
	var neg_y_mod = -1 if randi_range(0,2) == 0 else 1
	return Vector2(randi_range(0, tilemap_x) * neg_x_mod * tile_size, randi_range(0, tilemap_y) * neg_y_mod * tile_size)
