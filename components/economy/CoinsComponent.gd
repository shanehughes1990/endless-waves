extends Node
class_name CoinsComponent

signal coins_changed(amount: int)

@export var starting_coins: int = 50
var current_coins: int

func _ready() -> void:
	current_coins = starting_coins
	coins_changed.emit(current_coins)

func add_coins(amount: int) -> void:
	current_coins += amount
	coins_changed.emit(current_coins)

func spend_coins(amount: int) -> bool:
	if current_coins >= amount:
		current_coins -= amount
		coins_changed.emit(current_coins)
		return true
	return false

func get_coins() -> int:
	return current_coins

func can_afford(amount: int) -> bool:
	return current_coins >= amount
