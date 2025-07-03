extends Node
class_name MovementComponent

signal movement_speed_changed(new_speed: float)

@export var movement_speed: float = 100.0

func _ready() -> void:
	movement_speed_changed.emit(movement_speed)

func set_movement_speed(new_speed: float) -> void:
	movement_speed = new_speed
	movement_speed_changed.emit(movement_speed)

func get_movement_speed() -> float:
	return movement_speed
