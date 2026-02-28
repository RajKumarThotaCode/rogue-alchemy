extends CharacterBody2D

signal alchemy_toggled(is_on: bool)
signal slots_changed

@export var speed: float = 180.0
@export var jump_velocity: float = -320.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var alchemy_enabled: bool = false

var slots: Array[Dictionary] = []
var inventory: Array[String] = []

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	_initialize_slots()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var direction: float = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

	if direction != 0.0:
		sprite_2d.flip_h = direction < 0.0

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("alchemy_toggle"):
		set_alchemy_enabled(not alchemy_enabled)
	elif event.is_action_pressed("cast"):
		cast_spell()


func set_alchemy_enabled(is_on: bool) -> void:
	if alchemy_enabled == is_on:
		return

	alchemy_enabled = is_on
	emit_signal("alchemy_toggled", alchemy_enabled)


func add_material(material_id: String) -> void:
	for i in slots.size():
		if slots[i]["material_id"] == "":
			slots[i]["material_id"] = material_id
			slots[i]["enabled"] = false
			emit_signal("slots_changed")
			return

	inventory.append(material_id)


func toggle_slot_enabled(index: int) -> void:
	if index < 0 or index >= slots.size():
		return

	if slots[index]["material_id"] == "":
		return

	slots[index]["enabled"] = not slots[index]["enabled"]
	emit_signal("slots_changed")


func get_enabled_materials() -> Array[String]:
	var enabled_materials: Array[String] = []

	for slot in slots:
		if slot["enabled"] and slot["material_id"] != "":
			enabled_materials.append(slot["material_id"])
			if enabled_materials.size() == 3:
				break

	return enabled_materials


func resolve_spell(material_ids: Array[String]) -> String:
	if material_ids.is_empty():
		return "none"

	var sorted_ids := material_ids.duplicate()
	sorted_ids.sort()
	var key := "+".join(sorted_ids)

	var spell_map := {
		"iron": "sword_slash",
		"fire": "fire_burst",
		"frost": "ice_stab",
		"air": "gust",
		"fire+iron": "flame_blade",
		"iron+shadow": "shadow_slash",
		"air+fire": "fire_wave",
		"air+fire+iron": "blazing_whirl",
		"air+frost+iron": "ice_lance"
	}

	return spell_map.get(key, "none")


func cast_spell() -> void:
	var spell_id := resolve_spell(get_enabled_materials())
	print(spell_id)


func _initialize_slots() -> void:
	slots.clear()
	for _i in 9:
		slots.append({
			"material_id": "",
			"enabled": false
		})
