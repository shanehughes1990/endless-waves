extends Monster
class_name MonsterDebug

func _ready() -> void:
	super._ready()
	print("MonsterDebug _ready() called")
	
	# Position randomly around the base
	var viewport_size = get_viewport().get_visible_rect().size
	var base_center = viewport_size / 2
	var distance = 200.0
	var angle = randf() * TAU
	
	global_position = base_center + Vector2(cos(angle), sin(angle)) * distance
	
	print("Monster-Debug spawned at: ", global_position)
	print("Viewport size: ", viewport_size)
	print("Base center: ", base_center)

func get_debug_info() -> Dictionary:
	var info = super.get_debug_info()
	info["type"] = "Monster-Debug"
	info["position"] = global_position
	return info
