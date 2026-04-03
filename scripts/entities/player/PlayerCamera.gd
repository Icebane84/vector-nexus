extends SpringArm3D
class_name PlayerCamera

@export var sensitivity: float = 0.15

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Ignores the player's collision shape to prevent camera snapping
	add_excluded_object(owner.get_rid())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# FIX: Modify Euler angles directly to prevent the camera from tilting sideways (Z-Roll)
		rotation.y -= deg_to_rad(event.relative.x * sensitivity)
		rotation.x -= deg_to_rad(event.relative.y * sensitivity)
		
		# Clamps the up/down look angle
		rotation.x = clamp(rotation.x, deg_to_rad(-60), deg_to_rad(30))

func trigger_fov_kick(amount: float = 5.0, duration: float = 0.1) -> void:
	# Grab the child camera lens
	var camera := get_node_or_null("Camera3D") as Camera3D
	if not camera: 
		return # Safety check just in case the node gets renamed
	
	var base_fov := camera.fov
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	# The Juice: Push in, then snap back
	tween.tween_property(camera, "fov", base_fov + amount, duration)
	tween.tween_property(camera, "fov", base_fov, duration * 2.0)
