extends MeshInstance3D
class_name AttackGlintComponent
func trigger_glint():
	show(); var tw = create_tween()
	tw.tween_property(self, "scale", Vector3(1.5, 1.5, 1.5), 0.1)
	tw.tween_property(self, "scale", Vector3.ZERO, 0.1).set_delay(0.1)
