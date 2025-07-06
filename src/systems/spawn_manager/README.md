# SpawnManager System

The SpawnManager is an advanced wave-based enemy spawning system that provides visual editing tools, configurable wave progression, and real-time enemy tracking for the Endless Waves game.

## 🎯 Features

### Visual Spawn System

- **Red Circle Visualization**: Visible in both Godot editor and runtime
- **Resizable Spawn Radius**: Adjust in editor with real-time preview
- **Circumference Spawning**: Enemies spawn ON the circle line, not inside
- **@tool Integration**: Live preview in editor while designing levels

### Wave Management

- **Milestone System**: Regular waves (1-9, 11-19) vs Boss waves (10, 20, 30)
- **Auto/Manual Triggers**: Toggle between automatic progression and manual control
- **Configurable Difficulty**: Scalable enemy counts and wave duration
- **Real-time Statistics**: Live tracking of spawned, alive, and killed enemies

### Enemy Integration

- **Base Enemy Support**: Works with the Enemy class hierarchy (Rank/Type/Special/Boss)
- **Spawn Tracking**: Automatic lifecycle management for spawned enemies
- **Coin Rewards**: Integrated with WorldManager for automatic coin awarding

## 📝 Setup Instructions

### 1. Adding SpawnManager to a Scene

```gdscript
# In your world scene (e.g., world_1.tscn):
# 1. Instance the SpawnManager scene: res://src/systems/spawn_manager/spawn_manager.tscn
# 2. Position it where you want enemies to spawn around
# 3. Adjust the spawn_radius in the inspector
```

### 2. WorldManager Integration

The SpawnManager is automatically managed by WorldManager:

```gdscript
# WorldManager creates and positions SpawnManager automatically
# Access via WorldManager.spawn_manager
```

### 3. Configuration in Godot Editor

Select the SpawnManager node and configure these properties in the Inspector:

#### Visual Configuration

- **Spawn Radius**: Size of the red circle (50.0 default)
- **Circle Color**: Color of the spawn visualization (Red default)
- **Circle Thickness**: Line thickness of the circle (3.0 default)

#### Wave System

- **Auto Start Waves**: Enable automatic wave progression (false default)
- **Wave Delay**: Time between waves in auto mode (5.0 seconds)
- **Milestone Interval**: Boss wave frequency (10 = every 10th wave)

#### Regular Waves

- **Base Enemy Count**: Starting number of enemies per wave (5 default)
- **Enemy Count Increase**: Additional enemies per milestone tier (2 default)
- **Base Wave Duration**: How long regular waves last (30.0 seconds)
- **Spawn Interval**: Time between individual enemy spawns (1.0 second)

#### Boss Waves

- **Boss Enemy Count**: Number of boss enemies (1 default)
- **Boss Minion Count**: Supporting enemies in boss waves (3 default)
- **Boss Wave Duration**: How long boss waves last (60.0 seconds)

#### Cluster Spawning

- **Enable Clusters**: Turn cluster spawning on/off (true default)
- **Cluster Size**: Enemies per cluster (3 default)
- **Cluster Radius**: Size of cluster spawn area (20.0 default)
- **Clusters Per Wave**: Number of clusters per wave (2 default)

#### Enemy Types

- **Debug Enemy Scene**: Scene to spawn for testing (DebugEnemy default)

## 🎮 Usage Guide

### Manual Wave Control

```gdscript
# Start a wave manually
spawn_manager.start_wave()

# Get current wave statistics
var stats = spawn_manager.get_wave_stats()
print("Current wave: ", stats.current_wave)
print("Enemies alive: ", stats.enemies_alive)

# Reset the entire spawn system
spawn_manager.reset_spawn_system()

# Toggle auto-start mode
spawn_manager.toggle_auto_start()
```

### Debug Controls (ImGui Interface)

When running the game, open the WorldManager debug interface to access:

#### Wave Statistics

- Current Wave Number
- Wave Active Status
- Is Spawning Status
- Enemies Alive Count
- Enemies Spawned This Wave
- Enemies Killed This Wave
- Total Enemies Spawned
- Total Enemies Killed
- Boss Wave Indicator
- Auto Start Status

#### Control Buttons

- **Start Wave**: Manually trigger the next wave
- **Reset System**: Clear all enemies and reset to wave 0
- **Toggle Auto**: Enable/disable automatic wave progression

### Wave Progression Logic

#### Regular Waves (1-9, 11-19, 21-29, etc.)

- Enemy count scales with milestone tiers
- Tier 0 (waves 1-9): 5 enemies
- Tier 1 (waves 11-19): 7 enemies  
- Tier 2 (waves 21-29): 9 enemies
- Formula: `base_enemy_count + (tier * enemy_count_increase)`

#### Boss Waves (10, 20, 30, etc.)

- Special milestone waves with unique configuration
- 1 boss enemy + 3 minion enemies (configurable)
- Longer duration (60 seconds vs 30 seconds)
- Detected automatically using `wave_num % milestone_interval == 0`

## 🔧 Advanced Configuration

### Custom Enemy Types

To add new enemy types to the spawn system:

1. Create your enemy scene extending the Enemy base class
2. Add it to the SpawnManager's enemy type configuration
3. Implement spawn logic in `_spawn_enemy()` method

```gdscript
# Example: Adding multiple enemy types
@export var goblin_scene: PackedScene
@export var orc_scene: PackedScene
@export var dragon_scene: PackedScene
```

### Cluster Spawning Implementation

Cluster spawning allows multiple enemies to spawn near the same point:

```gdscript
# Get cluster positions around a main spawn point
var main_pos = _get_random_spawn_position()
var cluster_positions = _get_cluster_spawn_positions(main_pos, cluster_size)

# Spawn enemies at each cluster position
for pos in cluster_positions:
    _spawn_enemy_at_position(pos)
```

### Wave Completion Conditions

Waves can end in two ways:

1. **Time Expires**: Wave timer reaches duration limit
2. **All Enemies Defeated**: All spawned enemies are killed and spawning is complete

## 🐛 Troubleshooting

### Common Issues

#### Enemies Not Spawning

- Check that `debug_enemy_scene` is assigned in the inspector
- Verify that the Enemy scene extends the Enemy base class
- Ensure spawn_radius is greater than 0

#### Waves Not Auto-Starting

- Enable `auto_start_waves` in the inspector or via debug controls
- Check that `wave_delay` is set to a reasonable value (> 0)
- Verify previous wave has ended properly

#### Visual Circle Not Showing in Editor

- Ensure the SpawnManager script has the `@tool` directive
- Check that `spawn_radius` is greater than 0
- Try adjusting `circle_color` and `circle_thickness`

#### Debug Interface Not Showing Stats

- Confirm SpawnManager is properly initialized by WorldManager
- Check that WorldManager's `spawn_manager` reference is not null
- Verify ImGui is enabled in the project

### Debug Commands

```gdscript
# Print current spawn statistics
print(spawn_manager.get_wave_stats())

# Force end current wave
spawn_manager._end_wave()

# Manually spawn a single enemy
spawn_manager._spawn_enemy()

# Clear all enemies without resetting wave counter
for enemy in spawn_manager.spawned_enemies:
    enemy.queue_free()
spawn_manager.spawned_enemies.clear()
```

## 📋 Integration Checklist

When integrating SpawnManager into a new world:

- [ ] Add SpawnManager scene to world
- [ ] Position SpawnManager at desired spawn center
- [ ] Configure spawn radius for the level size
- [ ] Set appropriate enemy counts for difficulty
- [ ] Test manual wave triggering
- [ ] Verify enemy spawning on circumference
- [ ] Check coin rewards are working
- [ ] Test auto-progression if desired
- [ ] Confirm boss waves work at milestone intervals
- [ ] Validate debug interface shows correct stats

## 🔮 Future Enhancements

The SpawnManager is designed to be extensible. Planned features include:

- **Multiple Spawn Points**: Support for multiple spawn circles per world
- **Spawn Patterns**: Directional spawning, formation spawning
- **Enemy Pools**: Different enemy types per rank/tier
- **Dynamic Difficulty**: Adaptive enemy scaling based on player performance
- **Visual Effects**: Spawn animations and particle effects
- **Audio Integration**: Spawn sounds and wave start/end audio cues

---

**Note**: This SpawnManager is part of the Endless Waves component-based architecture and integrates seamlessly with the WorldManager, Enemy system, and upgrade mechanics.
