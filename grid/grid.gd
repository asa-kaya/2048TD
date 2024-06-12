class_name Grid
extends Node2D

@export var cell: PackedScene
@export var object_pool: Array[Node2D]
#@onready var test := preload("res://battleships/common/cell_item/tiles/sea/sea_tile.tscn")

enum Direction { TOPLEFT, TOP, TOPRIGHT, LEFT, RIGHT, BOTTOMLEFT, BOTTOM, BOTTOMRIGHT }

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

	# add a cell node for all 0 cells
	var grid_pixel_size = Vector2(size * width, size * grid_height)
	for i in range(grid_layout.size()):
		var c: Cell = cell.instantiate()
		grid.append(c)
		var cell_x: int = i % width
		var cell_y: int = int(i / width)

		c.position = Vector2(cell_x * size, cell_y * size) - (grid_pixel_size / 2) + Vector2(size/2, size/2)

		if reverse:
			c.position = c.position * Vector2(-1, 1)
		
		c.value = grid_layout[i]
		add_child(c)

		c.update_object()
		#c.area.collision_layer = 2 if is_player else 4
		#c.area.collision_mask = 2 if is_player else 4


func get_neighbor_cell(current_cell: Cell, direction: Vector2) -> Cell:
	var cell_pos := grid.find(current_cell)
	if cell_pos == -1:
		return null
	
	if reversed:
		direction.x = -direction.x
	
	var neigh_index := cell_pos + (grid_width * direction.y) + direction.x
	var x_valid := (cell_pos % grid_width + direction.x) >= 0 and (cell_pos % grid_width + direction.x) < grid_width
	#print(str(cell_pos % grid_width + direction.x) + " < " + str(grid_width))
	var y_valid := neigh_index >= 0 and neigh_index < grid.size()
	if x_valid and y_valid:
		return grid[cell_pos + (grid_width * direction.y) + direction.x]
	else:
		return null