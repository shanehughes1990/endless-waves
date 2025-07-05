
extends Node

signal health_changed(current_health: int)
signal died()

@export var max_health: int = 100
var current_health: int


func _ready() -> void:
	current_health = max_health


func take_damage(damage_amount: int) -> void:
	current_health -= damage_amount
	if current_health < 0:
		current_health = 0
	
	health_changed.emit(current_health)
	
	if current_health == 0:
		died.emit()
