class_name Cell
extends Node2D

@onready var area: Area2D = $Area2D

var value: int = 0
var can_merge = true
var grid: Grid

var object: Node2D
var object_pool: Array[Node2D]

func _ready():
	grid = get_parent()
	object_pool = grid.object_pool
	
#func set_highlighted(is_highlighted: bool):
#	if tile:
#		tile.sprite.set_modulate(Color.DARK_CYAN if is_highlighted else Color.WHITE)

func get_neighbor(direction: Vector2) -> Cell:
	return grid.get_neighbor_cell(self, direction)

func update_object(do_popout_animation: bool):
	if object:
		object.queue_free()
		object = null
	
	if value == 0:
		return
	
	var idx := int(log(value) / log(2)) - 1
	
	object = object_pool[idx].duplicate()
	object.z_index = 2
	add_child(object)

	if do_popout_animation:
		var popout_tween := get_tree().create_tween()
		popout_tween.tween_property(object, "scale", scale * 1.2, 0.05)
		popout_tween.tween_property(object, "scale", scale, 0.05)