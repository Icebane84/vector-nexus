# [GVRN] [UAM-V15]
# Artifact ID: UI.Kernel.HUD
# Description: The primary Head-Up Display controller.
#              Orchestrates health bars, lock-on indicators, and status icons.
# Version:       2.0 [SOVEREIGN]
# Relationships: GOVERNED_BY(Director), CONSUMES(GameEvents)
# Status:        [CANONIZED]

extends CanvasLayer

var _locked_target: Node3D = null
var _active_combatants: Dictionary = {}

func _ready() -> void:
	# Sovereign Decoupling: Listen to Global Synapse for stat updates
	GameEvents.instance.player_health_changed.connect(_on_health_changed)
	GameEvents.instance.player_stamina_changed.connect(_on_stamina_changed)
	GameEvents.instance.player_sanity_changed.connect(_on_sanity_changed)

	GameEvents.instance.lock_on_target_changed.connect(_on_lock_on_target_changed)
	GameEvents.instance.combat_state_changed.connect(_on_combat_state_changed)
	GameEvents.instance.player_active_item_changed.connect(_on_active_item_changed)
	GameEvents.instance.interaction_hint_shown.connect(_on_interaction_hint_shown)
	GameEvents.instance.interaction_hint_hidden.connect(_on_interaction_hint_hidden)

func _process(_delta: float) -> void:
	if not _locked_target or not is_instance_valid(_locked_target):
		if %LockOnReticle.visible:
			%LockOnReticle.hide()
		return

	var cam: Camera3D = get_viewport().get_camera_3d()
	if not cam: return

	# SKILL-006: Surface-Aware (Targeting the specific marker)
	var marker: Node3D = _locked_target.get_node_or_null("LockOnMarker") as Node3D
	var target_pos: Vector3 = marker.global_position if marker else _locked_target.global_position

	if cam.is_position_behind(target_pos):
		%LockOnReticle.hide()
	else:
		%LockOnReticle.show()
		%LockOnReticle.position = cam.unproject_position(target_pos)

func _on_lock_on_target_changed(target: Node3D) -> void:
	_locked_target = target
	%LockOnReticle.visible = (target != null)

func _on_health_changed(curr: float, max_v: float) -> void:
	%HealthBar.max_value = max_v
	%HealthBar.value = curr

func _on_stamina_changed(curr: float, max_v: float) -> void:
	%StaminaBar.max_value = max_v
	%StaminaBar.value = curr

	# PHOENIX-PREF: Hidden when full
	%StaminaBar.visible = curr < max_v

func _on_sanity_changed(curr: float, max_v: float) -> void:
	if has_node("%SanityBar"):
		%SanityBar.max_value = max_v
		%SanityBar.value = curr

		# PHOENIX-PREF: Visual indicator of "Shadow Energy"
		# We might want to change the bar color or add a glow based on curr/max

func _on_combat_state_changed(actor: Node3D, new_state: T.CombatState) -> void:
	if new_state in [T.CombatState.CHASE, T.CombatState.ATTACK]:
		_active_combatants[actor] = true
	else:
		_active_combatants.erase(actor)

	# Cleanup invalid/freed actors (SKILL-002 Memory Safety)
	for key: Variant in _active_combatants.keys():
		if not is_instance_valid(key):
			_active_combatants.erase(key)

	var indicator: Control = get_node_or_null("%CombatIndicator") as Control
	if indicator:
		indicator.visible = not _active_combatants.is_empty()

func _on_active_item_changed(item: ItemData) -> void:
	var tex_rect = %ItemTexture as TextureRect
	var count_label = %ItemCount as Label
	if not tex_rect or not count_label: return

	if item and item.count > 0:
		tex_rect.texture = item.icon
		count_label.text = str(item.count)
		%ActiveItemSlot.show()
	else:
		tex_rect.texture = null
		count_label.text = "0"
		%ActiveItemSlot.hide()

func _on_interaction_hint_shown(text: String) -> void:
	if has_node("%InteractionPrompt") and has_node("%PromptLabel"):
		%PromptLabel.text = text
		%InteractionPrompt.show()

func _on_interaction_hint_hidden() -> void:
	if has_node("%InteractionPrompt"):
		%InteractionPrompt.hide()
