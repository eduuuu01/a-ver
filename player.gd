extends CharacterBody2D

@export var SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -900.0
@export var MAX_CHARGE_TIME: float = 5.0
@export var MAX_BOOST_SPEED: float = 5000.0

var charge_time: float = 0.0
var is_charging: bool = false
var last_direction: int = 1

func _ready() -> void:
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Salto (desactivado mientras se carga)
	if not is_charging and Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Cargar con la tecla C
	if Input.is_action_pressed("c_charge"):
		is_charging = true
		charge_time = min(charge_time + delta, MAX_CHARGE_TIME)
		velocity.x = 0.0
	else:
		if is_charging and Input.is_action_just_released("c_charge"):
			# Al soltar: aplicar boost proporcional
			var boost_ratio: float = charge_time / MAX_CHARGE_TIME
			var boosted_speed: float = lerp(SPEED, MAX_BOOST_SPEED, boost_ratio)
			var input_dir: float = Input.get_axis("izquierda", "derecha")
			if input_dir != 0.0:
				last_direction = int(sign(input_dir))
			velocity.x = last_direction * boosted_speed
			charge_time = 0.0
			is_charging = false
		else:
			# Movimiento normal
			var direction: float = Input.get_axis("izquierda", "derecha")
			if direction != 0.0:
				last_direction = int(sign(direction))
				velocity.x = direction * SPEED
			else:
				# Frenado suave (usar función global move_toward)
				velocity.x = move_toward(velocity.x, 0.0, SPEED * delta)

	move_and_slide()
