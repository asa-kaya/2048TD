class_name SpawnManager
extends Node2D

@export var spawn_distance: int
@export var enemy_prefab: PackedScene

var spawn_interval = 1
var spawn_time_elapsed = 0
var running = false


func start():
	running = true

func stop():
	running = false

func process(delta):
	if not running:
		return

	spawn_time_elapsed += delta

	if spawn_time_elapsed >= spawn_interval:
		spawn_enemy()
		spawn_time_elapsed = 0

var counter = 0
func spawn_enemy():
	var e : Node2D = enemy_prefab.instantiate()
	var rand_angle := randf_range(0, 2*PI)
	e.global_position = (get_viewport_rect().size / 2) + Vector2(0, spawn_distance).rotated(rand_angle)
	add_child(e)