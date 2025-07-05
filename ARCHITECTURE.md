# Endless Waves - Architecture Flow

## System Overview

This document outlines the three-tier upgrade and progression system for Endless Waves.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        GAME MANAGER                            │
│                     (Persistent Layer)                         │
├─────────────────────────────────────────────────────────────────┤
│ • Permanent upgrades (bought in menus)                         │
│ • Save/load system                                             │
│ • Meta-progression between sessions                            │
│ • Player profile data                                          │
│                                                                │
│ Examples:                                                      │
│ - Base Damage +5 (permanent)                                  │
│ - Health Regen +2 (permanent)                                 │
│ - Unlock Tower Type: Archer                                   │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                       WORLD MANAGER                            │
│                    (Session/Wave Layer)                        │
├─────────────────────────────────────────────────────────────────┤
│ • Initialized with permanent upgrades from GameManager         │
│ • Temporary upgrades during current wave/run                   │
│ • Coins earned this session                                    │
│ • Current world state                                          │
│ • Single interface for components                              │
│                                                                │
│ Examples:                                                      │
│ - Base damage: 15 (10 base + 5 permanent)                     │
│ - Session damage boost: +3                                    │
│ - Final damage: 18                                            │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                        COMPONENTS                              │
│                     (Runtime Layer)                           │
├─────────────────────────────────────────────────────────────────┤
│ • Query ONLY WorldManager for all stats                       │
│ • Handle actual gameplay behavior                              │
│ • Calculate: base_stats + WorldManager.get_stat()             │
│                                                                │
│ Examples:                                                      │
│ - HealthComponent: 100 + WorldManager.get_health_bonus()      │
│ - AttackComponent: 10 + WorldManager.get_damage_bonus()       │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### Session Start

```
1. GameManager loads permanent upgrades from save file
2. GameManager calls WorldManager.initialize_session(permanent_stats)
3. WorldManager combines permanent + base stats internally
4. Components query WorldManager.get_damage(), WorldManager.get_health(), etc.
```

### During Gameplay

```
1. Player earns coins → WorldManager tracks session coins
2. Player buys session upgrades → WorldManager updates internal bonuses
3. Components call WorldManager.get_X() methods for current stats
4. Gameplay uses final calculated stats from WorldManager
```

### Session End

```
1. WorldManager passes earned coins/XP to GameManager
2. GameManager updates permanent progression
3. GameManager saves to persistent storage
4. WorldManager resets for next session
```

## Component Stat Calculation

### Example: AttackComponent

```gdscript
func calculate_damage() -> int:
    var base_damage = 10  # Component's base value
    var bonus = WorldManager.get_damage_bonus()  # Includes permanent + session
    return base_damage + bonus
```

### Example: HealthComponent

```gdscript
func calculate_max_health() -> int:
    var base_health = 100
    var bonus = WorldManager.get_health_bonus()  # Includes permanent + session
    return base_health + bonus
```

## Manager Responsibilities

### GameManager (Autoload)

- **Persistence**: Save/load player progress
- **Meta-progression**: Track permanent unlocks and upgrades
- **Menu Integration**: Provide data for upgrade shop UI
- **Session Initialization**: Pass permanent stats to WorldManager

**Key Methods:**

```gdscript
func get_permanent_stats() -> Dictionary  # Returns all permanent upgrades
func unlock_tower_type(tower_type: String) -> void
func save_progress() -> void
func load_progress() -> void
func initialize_world_session() -> void  # Calls WorldManager.initialize_session()
```

### WorldManager (Autoload)

- **Session State**: Track current wave/run progress
- **Stat Aggregation**: Combine permanent + session + base stats
- **Resource Management**: Coins, temporary bonuses
- **Component Interface**: Single source of truth for all components

**Key Methods:**

```gdscript
func initialize_session(permanent_stats: Dictionary) -> void
func get_damage_bonus() -> int  # Returns total damage bonus
func get_health_bonus() -> int  # Returns total health bonus
func add_session_upgrade(type: String, amount: int) -> void
func end_session() -> Dictionary  # Returns earned rewards
```

### Components (Scene-based)

- **Stat Calculation**: Query WorldManager for all bonuses
- **Behavior Implementation**: Handle actual game mechanics
- **Update Handling**: Recalculate when WorldManager signals changes

**Key Methods:**

```gdscript
func recalculate_stats() -> void
func get_effective_damage() -> int  # base + WorldManager.get_damage_bonus()
func get_effective_health() -> int  # base + WorldManager.get_health_bonus()
```

## Tower System Integration

### Different Tower Types
Each tower type has different base stats but shares the upgrade system:

```gdscript
# Base (Player's main base)
base_damage = 10
base_health = 100
base_fire_rate = 1.0

# Archer Tower (Fast, low damage)
base_damage = 5
base_health = 50
base_fire_rate = 2.0

# Cannon Tower (Slow, high damage)
base_damage = 25
base_health = 75
base_fire_rate = 0.5
```

All towers benefit from the same upgrade system but scale differently.

## Questions to Resolve

1. **Upgrade Categories**: Should upgrades be global (affect all towers) or specific (affect tower types differently)?

2. **Session Transfer**: What data should transfer from WorldManager to GameManager at session end?
   - Coins earned?
   - XP/progress points?
   - Achievements unlocked?

3. **Component Updates**: How should components know when to recalculate stats?
   - Signal-based when upgrades change?
   - Poll every frame?
   - Manual refresh calls?

4. **Save Timing**: When should GameManager save?
   - Only at session end?
   - Periodically during gameplay?
   - Immediately when permanent upgrades are purchased?

5. **Session Persistence**: Should session progress persist if the game crashes or is closed mid-wave?

## Implementation Priority

1. **Phase 1**: Extend WorldManager with session upgrade tracking and permanent stat initialization
2. **Phase 2**: Create GameManager for persistent upgrades and session initialization
3. **Phase 3**: Update components to query only WorldManager
4. **Phase 4**: Implement save/load system in GameManager
5. **Phase 5**: Add multiple tower types using the unified system
