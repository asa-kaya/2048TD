extends Node2D

@export var cell_size: int
@export var cell_spacing: int
@export var grid_size: Vector2i

@onready var grid: Grid = $Grid
#@onready var player := $Player
#@onready var run_manager := $RunManager

func _ready():
	var grid_layout: Array[int] = []
	grid_layout.resize(grid_size.x * grid_size.y)
	grid_layout.fill(0);
	
	var rand1 := randi_range(0, grid_layout.size() - 1)
	var rand2 := randi_range(0, grid_layout.size() - 2)

	grid_layout[rand1] = 2
	grid_layout[rand2 if (rand2 < rand1) else (rand2 + 1)] = 2
	# add holes to field when total size of items is less than 25% of the field size
	#var threshold := int(grid_layout.size() * 0.25)

	grid.setup(grid_layout, cell_size, grid_size.x, true)

	#run_manager.init(player)

#func _process(delta):
	#run_manager.process(delta)

func _unhandled_input(event):
	if Input.is_action_just_pressed("shift_up"):
		grid.shift(Grid.Direction.UP)
	elif Input.is_action_just_pressed("shift_left"):
		grid.shift(Grid.Direction.LEFT)
	elif Input.is_action_just_pressed("shift_down"):
		grid.shift(Grid.Direction.DOWN)
	elif Input.is_action_just_pressed("shift_right"):
		grid.shift(Grid.Direction.RIGHT)
