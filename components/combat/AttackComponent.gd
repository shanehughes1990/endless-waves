extends Node
class_name AttackComponent

signal attack_performed(target: Node, damage: float)

enum AttackType {
	MELEE,
	RANGED,
	EXPLOSIVE
}

enum ElementalType {
	NONE
}

@export var attack_speed: float = 1.0  # attacks per second
@export var attack_damage: float = 10.0
@export var attack_type: AttackType = AttackType.MELEE
@export var elemental_type: ElementalType = ElementalType.NONE

var attack_timer: float = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if attack_timer > 0:
		attack_timer -= delta

func can_attack() -> bool:
	return attack_timer <= 0.0

func perform_attack(target: Node) -> void:
	if can_attack():
		attack_performed.emit(target, attack_damage)
		attack_timer = 1.0 / attack_speed

func get_attack_info() -> Dictionary:
	return {
		"speed": attack_speed,
		"damage": attack_damage,
		"type": AttackType.keys()[attack_type],
		"elemental": ElementalType.keys()[elemental_type],
		"can_attack": can_attack()
	}
