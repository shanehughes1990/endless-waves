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
	
	# Example: Add some test upgrades to see the system working
	await get_tree().create_timer(2.0).timeout  # Wait 2 seconds
	print_debug("Applying test upgrades...")
	WorldManager.add_session_upgrade("damage", 5)
	WorldManager.add_session_upgrade("health", 25)
	WorldManager.add_session_upgrade("fire_rate", 2)
