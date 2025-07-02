# AutoLoad Scripts

This directory contains singleton scripts that are automatically loaded when the game starts.

## Key AutoLoads

- **GameManager.gd** - Global game state and coordination
- **EventBus.gd** - Global signal communication hub  
- **AudioManager.gd** - Music and sound effect management
- **SaveManager.gd** - Save/load game data
- **DataLoader.gd** - Load configuration from data files

## Usage

AutoLoad scripts should:
- Extend Node (not scene-specific nodes)
- Use typed GDScript for performance
- Expose clean public APIs
- Communicate via signals when possible
- Handle initialization in _ready()

## Example Structure

```gdscript
extends Node

# Signals for other systems to connect
signal game_state_changed(new_state: GameState)

# Typed properties
var current_state: GameState = GameState.MENU

enum GameState {
    MENU,
    PLAYING, 
    PAUSED,
    GAME_OVER
}

func _ready() -> void:
    _initialize()

func _initialize() -> void:
    # Setup code here
    pass
```
