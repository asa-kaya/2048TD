class_name Grid
extends Node2D

@export var cell_prefab: PackedScene
@export var object_pool: Array[Node2D]
@export var shift_duration: float = 1
#@onready var test := preload("res://battleships/common/cell_item/tiles/sea/sea_tile.tscn")

enum Direction { UP, LEFT, DOWN, RIGHT }

var grid: Array[Cell]
var cell_size: int
var grid_width: int
var grid_height: int
var reversed: bool

var active_tweens: Array[Tween]

signal all_tweens_finished

func setup(grid_layout: Array[int], size: int, width: int, is_player: bool, reverse: bool = false):
	self.grid_width = width
	self.grid_height = grid_layout.size() / width
	self.cell_size = size
	self.reversed = reverse

	# add a cell_prefab node for all 0 cells
	var grid_pixel_size = Vector2(size * width, size * grid_height)
	for i in range(grid_layout.size()):
		var c: Cell = cell_prefab.instantiate()
		grid.append(c)
		var cell_x: int = i % width
		var cell_y: int = int(i / width)

		c.position = Vector2(cell_x * size, cell_y * size) - (grid_pixel_size / 2) + Vector2(size/2, size/2)

		if reverse:
			c.position = c.position * Vector2(-1, 1)
		
		c.value = grid_layout[i]
		add_child(c)

		c.update_object(true)


func shift(direction: Direction) -> bool:
	print("shifting " + str(direction))

	var shift_dir := Vector2i.ZERO
	var scan_dir := Vector2i.ZERO
	var start_x := 0
	var start_y := 0
	var end_x := 0
	var end_y := 0

	if direction == Direction.UP:
		shift_dir = Vector2i.UP
		scan_dir = Vector2i(1, 1)
		end_x = grid_height
		end_y = grid_height
	elif direction == Direction.LEFT:
		shift_dir = Vector2i.LEFT
		scan_dir = Vector2i(1, 1)
		end_x = grid_height
		end_y = grid_height
	elif direction == Direction.DOWN:
		shift_dir = Vector2i.DOWN
		scan_dir = Vector2i(-1, -1)
		start_x = grid_height - 1
		start_y = grid_height - 1
		end_x =  - 1
		end_y =  - 1
	elif direction == Direction.RIGHT:
		shift_dir = Vector2i.RIGHT
		scan_dir = Vector2i(-1, -1)
		start_x = grid_height - 1
		start_y = grid_height - 1
		end_x =  - 1
		end_y =  - 1
	
	var has_shifted = false
	active_tweens = []
	for x in range(start_x, end_x, scan_dir.x):
		for y in range(start_y, end_y, scan_dir.y):
			if try_shift_cell_at(Vector2i(x, y), shift_dir):
				has_shifted = true
	
	if has_shifted:
		print("successfully shifted")
		grid.map(func(cell): cell.can_merge = true)
	
	await all_tweens_finished

	return has_shifted

func try_shift_cell_at(grid_position: Vector2i, direction: Vector2i) -> bool:
	var current_cell := get_cell(grid_position.x, grid_position.y)

	if current_cell.value == 0:
		return false

	var destination_cell := get_last_valid_cell_in_direction(grid_position, direction, current_cell.value, current_cell)
	if destination_cell and (current_cell != destination_cell) and (current_cell.value == destination_cell.value or destination_cell.value == 0):
		var cells_merged := destination_cell.value != 0
		if cells_merged:
			destination_cell.can_merge = false

		destination_cell.value += current_cell.value
		current_cell.value = 0

		# animate cell shifting
		var tween := get_tree().create_tween()
		var tween_duration := absf(current_cell.global_position.distance_to(destination_cell.global_position) / cell_size) * shift_duration
		tween.tween_property(current_cell.object, "global_position", destination_cell.global_position, tween_duration)
		tween.tween_callback(func():
			destination_cell.update_object(cells_merged)
			current_cell.update_object(true)
			active_tweens.pop_back()

			if active_tweens.size() <= 0:
				all_tweens_finished.emit()
		)
		active_tweens.push_back(tween)

		return true
	else:
		return false

func get_last_valid_cell_in_direction(grid_position: Vector2i, direction: Vector2i, value: int, cell: Cell) -> Cell:
	var next_position := Vector2i(grid_position.x + direction.x, grid_position.y + direction.y)
	var next_cell := get_cell(next_position.x, next_position.y, true)

	if (next_cell == null) or (not next_cell.can_merge) or (value != next_cell.value and next_cell.value != 0):
		return cell
	else:
		return get_last_valid_cell_in_direction(next_position, direction, value, next_cell)
	
func populate_random_empty_cell():
	var empty_cells: Array[Cell] = grid.filter(func(cell): return cell.value == 0)

	# TODO this should cause a game over
	if empty_cells.size() <= 0:
		return

	var randIdx := randi_range(0, empty_cells.size() - 1)

	empty_cells[randIdx].value = 2
	empty_cells[randIdx].update_object(true)

func get_cell(x: int, y: int, supress_out_of_range: bool = false) -> Cell:
	if not supress_out_of_range:
		assert(x >= 0 or x < grid_width, "x index out of range (x = %d)." % x)
		assert(y >= 0 or y < grid_height, "y index out of range (y = %d)." % y)
	elif (x < 0 or x > grid_width - 1) or (y < 0 or y > grid_height - 1):
		return null

	return grid[x + (grid_width * y)]

func get_neighbor_cell(current_cell: Cell, direction: Vector2) -> Cell:
	var cell_pos := grid.find(current_cell)
	if cell_pos == -1:
		return null
	
	if reversed:
		direction.x = -direction.x
	
	var neigh_index := cell_pos + (grid_width * direction.y) + direction.x
	var x_valid := (cell_pos % grid_width + direction.x) >= 0 and (cell_pos % grid_width + direction.x) < grid_width
	var y_valid := neigh_index >= 0 and neigh_index < grid.size()
	if x_valid and y_valid:
		return grid[cell_pos + (grid_width * direction.y) + direction.x]
	else:
		return null
