extends StaticBody2D
class_name Base

@onready var health_component: HealthComponent = $HealthComponent
@onready var upgrades_component: UpgradesComponent = $UpgradesComponent
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# Center the base on screen
	var viewport_size = get_viewport().get_visible_rect().size
	global_position = viewport_size / 2
	
	# Load the Godot icon
	sprite.texture = load("res://icon.svg")

func get_debug_info() -> Dictionary:
	return {
		"health": {
			"current": health_component.current_health,
			"max": health_component.max_health,
			"percentage": health_component.get_health_percentage()
		},
		"upgrades": upgrades_component.get_all_upgrades()
	}
