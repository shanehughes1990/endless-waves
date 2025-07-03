extends Node2D

@onready var world_manager: WorldSceneManager = $WorldSceneManager

func _ready() -> void:
	print("World-Debug: Scene loaded, WorldSceneManager will handle initialization...")
