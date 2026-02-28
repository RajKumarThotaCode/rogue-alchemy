extends CharacterBody2D

const SPEED := 220.0
const JUMP_VELOCITY := -420.0
const GRAVITY := 980.0

@onready var model: Polygon2D = $Model

func _ready() -> void:
	# A simple rectangle body to keep the scene fully self-contained.
	model.polygon = PackedVector2Array([
		Vector2(-14, -24),
		Vector2(14, -24),
		Vector2(14, 24),
		Vector2(-14, 24)
	])
	model.color = Color(0.85, 0.35, 0.9)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	move_and_slide()
