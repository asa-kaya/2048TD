class_name ObjectivePoint
extends Node2D

@export var max_hp: int

@onready var area: Area2D = $Area2D
@onready var hp_label: RichTextLabel = $HPLabel

var current_hp: int = 1 : set = _set_current_hp

signal hp_depleted

func _ready():
	#TODO probably move this to GameManager later
	global_position = get_viewport_rect().size / 2 #center objective point

	current_hp = max_hp
	area.area_entered.connect(_on_area_entered)
	hp_depleted.connect(func(): print("player died"))

func take_damage(value: int):
	current_hp -= value

func _set_current_hp(value: int):
	current_hp = value
	hp_label.text = "[center]%d/%d[/center]" % [current_hp, max_hp]

	if current_hp <= 0:
		hp_depleted.emit()

func _on_area_entered(collider: Area2D):
	if collider.get_parent() is Enemy:
		take_damage(1)
		collider.get_parent().queue_free()
