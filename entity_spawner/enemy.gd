class_name Enemy
extends Node2D

@export var speed: float

func _ready():
	# temporarily despawn after a while
	get_tree().create_timer(15).timeout.connect(queue_free)

func _process(delta):
	# move towards center
	global_position = global_position.move_toward(get_viewport_rect().size / 2, speed * delta)