# Game Data Configuration

This directory contains all game balance and configuration data.

## Data Files

- **units/** - Unit stats, abilities, and costs
- **buildings/** - Building stats, costs, requirements  
- **enemies/** - Enemy stats, behaviors, abilities
- **waves/** - Wave definitions and difficulty scaling
- **progression/** - Meta upgrades and achievements
- **economy/** - Resource costs and reward tables

## File Formats

### Godot Resources (.tres)
For type-safe, editor-friendly data:
```gdscript
# unit_stats.tres
[gd_resource type="Resource" format=3]

[ext_resource type="Script" path="res://scripts/resources/UnitStats.gd" id="1"]

[resource]
script = ExtResource("1")
health = 100.0
speed = 150.0
damage = 25.0
```

### JSON Files (.json)
For external balance tweaking:
```json
{
  "infantry": {
    "health": 100,
    "speed": 80,
    "damage": 15,
    "cost": 25
  },
  "archer": {
    "health": 75,
    "speed": 90,
    "damage": 20,
    "cost": 30
  }
}
```

## Loading Data

Use DataLoader autoload to access configuration:
```gdscript
# Access unit stats
var infantry_stats = DataLoader.get_unit_stats("infantry")
var health = infantry_stats.health
```

## Best Practices

- Use .tres for complex data with validation
- Use .json for simple key-value data
- Keep data files organized by category
- Test balance changes frequently
- Version control all data files
