class_name Grid
extends Node2D

@export var cell_prefab: PackedScene
@export var object_pool: Array[Node2D]
#@onready var test := preload("res://battleships/common/cell_item/tiles/sea/sea_tile.tscn")

enum Direction { UP, LEFT, DOWN, RIGHT }

var grid: Array[Cell]
var cell_size: int
var grid_width: int
var grid_height: int
var reversed: bool


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

		c.update_object()


func shift(direction: Direction):
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
	
	for x in range(start_x, end_x, scan_dir.x):
		for y in range(start_y, end_y, scan_dir.y):
			try_shift_cell_at(Vector2i(x, y), shift_dir)

func try_shift_cell_at(grid_position: Vector2i, direction: Vector2i) -> bool:
	var current_cell := get_cell(grid_position.x, grid_position.y)

	if current_cell.value == 0:
		return false

	var next_cell := get_cell(grid_position.x + direction.x, grid_position.y + direction.y, true)

	print("%d, %d" % [grid_position.x + direction.x, grid_position.y + direction.y])
	if next_cell and (current_cell.value == next_cell.value or next_cell.value == 0):
		next_cell.value += current_cell.value
		current_cell.value = 0
		next_cell.update_object()
		current_cell.update_object()
		return true
	else:
		return false

func get_last_valid_cell_in_direction(grid_position: Vector2i, direction: Vector2i, value: int, cell: Cell) -> Cell:
	var next_position := Vector2i(grid_position.x + direction.x, grid_position.y + direction.y)
	var next_cell := get_cell(next_position.x, next_position.y, true)

	if next_cell == null or value != next_cell.value or next_cell.value != 0:
		return cell
	else:
		return get_last_valid_cell_in_direction(next_position, direction, value, next_cell)
	

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