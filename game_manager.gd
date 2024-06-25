extends Node2D

@export var cell_size: int
@export var cell_spacing: int
@export var grid_size: Vector2i

@onready var grid: Grid = $Grid
@onready var spawner: SpawnManager = $Spawner
#@onready var player := $Player
#@onready var run_manager := $RunManager

func _ready():
	var grid_layout: Array[int] = []
	grid_layout.resize(grid_size.x * grid_size.y)
	grid_layout.fill(0);

	grid.setup(grid_layout, cell_size, grid_size.x, true)

	grid.populate_random_empty_cell()
	grid.populate_random_empty_cell()
	
	spawner.start()
	#run_manager.init(player)

func _process(delta):
	spawner.process(delta)
	#run_manager.process(delta)

func _unhandled_input(event):
	var grid_has_shifted := false
	if Input.is_action_just_pressed("shift_up"):
		grid_has_shifted = await grid.shift(Grid.Direction.UP)
	elif Input.is_action_just_pressed("shift_left"):
		grid_has_shifted = await grid.shift(Grid.Direction.LEFT)
	elif Input.is_action_just_pressed("shift_down"):
		grid_has_shifted = await grid.shift(Grid.Direction.DOWN)
	elif Input.is_action_just_pressed("shift_right"):
		grid_has_shifted = await grid.shift(Grid.Direction.RIGHT)
	
	if grid_has_shifted:
		grid.populate_random_empty_cell()
