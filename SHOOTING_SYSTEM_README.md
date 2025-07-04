# Base Auto-Firing System for Idle Game

## Overview
The base has a comprehensive auto-firing shooting system that automatically defends against enemies. This is designed for an **idle game** where players watch the action and focus on upgrades and progression.

## Key Features

### ✅ Fully Automated Defense
- **Auto-Targeting**: Automatically detects and targets enemies within range
- **Auto-Firing**: Shoots at enemies without any player input
- **Smart Priority**: Multiple targeting modes (Nearest, Furthest, Lowest Health, etc.)
- **Multi-Target Support**: Can engage multiple enemies simultaneously
- **Idle-Friendly**: Runs continuously without player interaction

### ✅ Upgradeable Weapon Stats (All Exportable)
- **Attack Damage**: Damage dealt per projectile (default: 25.0)
- **Attack Speed**: Attacks per second (default: 2.0)
- **Attack Range**: Maximum targeting distance (default: 300.0)
- **Projectile Speed**: Speed of fired projectiles (default: 600.0)
- **Projectile Pierce**: Number of enemies projectile can pass through (default: 0)
- **Projectile Range**: Maximum travel distance for projectiles (default: 800.0)

### ✅ Visual Feedback
- **Debug Range Drawing**: Red circle showing attack range
- **Target Lines**: Yellow lines showing current targets
- **Projectile Colors**: Customizable projectile appearance
- **Combat Feedback**: Console logs for debugging

### ✅ Progression System Ready
Public methods for upgrade integration:
- `upgrade_damage(amount: float)`
- `upgrade_attack_speed(amount: float)`
- `upgrade_range(amount: float)`
- `upgrade_projectile_speed(amount: float)`
- `upgrade_pierce(amount: int)`

## Idle Game Design

### Core Loop
1. **Watch**: Base automatically defends against enemy waves
2. **Earn**: Gain coins from defeating enemies
3. **Upgrade**: Spend coins to improve base capabilities
4. **Progress**: Face stronger enemies and unlock new features

### No Manual Input Required
- Base fires automatically when enemies are in range
- Targeting is handled by AI priority system
- Players focus on strategic upgrade decisions
- Perfect for background/idle gameplay

## How the Auto-System Works

### 1. Enemy Detection
```gdscript
# Area2D automatically detects enemies entering/exiting range
targeting_area.body_entered.connect(_on_enemy_entered_range)
targeting_area.body_exited.connect(_on_enemy_exited_range)
```

### 2. Target Selection AI
```gdscript
enum TargetPriority {
    NEAREST,           # Focus closest threats
    FURTHEST,          # Strategic long-range
    LOWEST_HEALTH,     # Finish off weak enemies
    HIGHEST_HEALTH,    # Focus on strong enemies
    FIRST_IN_RANGE     # Simple first-come basis
}
```

### 3. Automatic Firing
```gdscript
# Timer-based system ensures consistent firing rate
attack_timer.wait_time = 1.0 / attack_speed
# Fires when enemies are available and timer expires
```

### 4. Projectile Management
- Automatically spawns and manages projectiles
- Handles collision detection and damage
- Self-destructs when out of range or after pierce limit

## Debug Controls (Development Only)

For testing during development:

- **F1**: Spawn enemy manually (testing)
- **F2**: Toggle base debug drawing (visualization)
- **F3**: Upgrade base damage (+10)
- **F4**: Upgrade base attack speed (+0.5/s)
- **F5**: Upgrade base range (+50)
- **SPACE**: Start wave system
- **NUMPAD_ENTER**: Spawn enemy near base (immediate testing)

## Configuration

### Inspector Settings (Exported Variables)

**Weapon Stats:**
- Attack Damage: Base damage per shot
- Attack Speed: Automatic firing rate
- Attack Range: Detection and engagement range
- Projectile Speed: Projectile travel speed
- Projectile Pierce: Multi-enemy penetration
- Projectile Range: Maximum projectile distance

**Targeting AI:**
- Auto Target: Enable/disable the auto-firing system
- Target Priority: AI decision making for target selection
- Multi Target: Engage multiple enemies simultaneously
- Max Targets: Limit concurrent targets for balance

**Visual Effects:**
- Muzzle Flash: Firing visual effects
- Projectile Color: Customize projectile appearance
- Fire Sound: Audio feedback system

## Integration for Idle Game

### Economy System
```gdscript
# Example upgrade purchasing system
func purchase_damage_upgrade(cost: int) -> bool:
    if player_coins >= cost:
        player_coins -= cost
        base.upgrade_damage(upgrade_amount)
        return true
    return false
```

### Progressive Difficulty
- Enemies get stronger over time
- Base upgrades keep pace with difficulty
- Creates satisfying progression curve
- Encourages continued engagement

### Performance Optimized
- Efficient enemy detection using Area2D signals
- Smart target cleanup removes dead enemies
- Projectiles self-manage lifecycle
- Frame-rate independent timing

## Future Idle Game Features

Possible expansions:
- Multiple weapon types (lasers, missiles, etc.)
- Passive income generation
- Prestige/rebirth mechanics
- Automated enemy wave progression
- Offline progress calculation
- Achievement system
- Special abilities and power-ups

## Testing the System

1. Run the World-Debug scene
2. Observe automatic base behavior
3. Press NUMPAD_ENTER to add test enemies
4. Watch base automatically engage targets
5. Use F3-F5 to test upgrade effects
6. Use F2 to visualize range and targeting

The system is designed to be satisfying to watch while requiring minimal player input - perfect for an idle/incremental game experience!
