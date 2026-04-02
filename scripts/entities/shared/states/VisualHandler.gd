func play_hit_flash(visual_node: Node3D) -> void:

	var tween = create_tween()

	# Phoenix VII.2: Modulate raw RGB values above 1.0 for HDR Bloom

	tween.tween_property(visual_node, "visual_instance_shader_parameter/flash_weight", 1.0, 0.05)

	tween.tween_property(visual_node, "visual_instance_shader_parameter/flash_weight", 0.0, 0.1)
