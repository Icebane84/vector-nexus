extends SpringArm3D
class_name PlayerCamera
@export var sensitivity: float = 0.15
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_excluded_object(owner.get_rid())
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		rotation.x = clamp(rotation.x - deg_to_rad(event.relative.y * sensitivity), deg_to_rad(-60), deg_to_rad(30))

func trigger_fov_kick(amount: float = 5.0, duration: float = 0.1) -> void:

	var camera = get_node("Camera3D") as Camera3D

	var base_fov = camera.fov

	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

	

	tween.tween_property(camera, "fov", base_fov + amount, duration)

	tween.tween_property(camera, "fov", base_fov, duration * 2.0)
