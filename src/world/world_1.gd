extends Node2D

## World 1 - The first level/world in the game.
##
## Registers itself with WorldManager and handles basic world setup.

func _ready() -> void:
	# Register this world with the WorldManager
	WorldManager.register_world(self)
	
	# Basic world setup
	print_debug("World 1 loaded and registered")
	
	# Example: Give player some starting coins for this world
	WorldManager.add_coins(50)
