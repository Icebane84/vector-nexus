extends Label3D
class_name FloatingDamageText

var _active: bool = false
var _lifetime: float = 0.0
const MAX_LIFETIME: float = 1.0
const FLOAT_SPEED: float = 1.5

func _physics_process(delta: float) -> void:
	if not _active:
		return
		
	_lifetime += delta
	global_position.y += FLOAT_SPEED * delta
	
	# Fade out calculation
	var alpha := 1.0 - (_lifetime / MAX_LIFETIME)
	modulate.a = clampf(alpha, 0.0, 1.0)
	
	if _lifetime >= MAX_LIFETIME:
		_deactivate()

func activate(amount: float, start_pos: Vector3) -> void:
	text = str(snappedf(amount, 0.1))
	global_position = start_pos
	modulate.a = 1.0
	_lifetime = 0.0
	_active = true
	show()

func _deactivate() -> void:
	_active = false
	hide()
