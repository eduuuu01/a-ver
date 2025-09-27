extends CharacterBody2D

@export var SPEED: float = 900.0
@export var JUMP_VELOCITY: float = -900.0
@export var MAX_CHARGE_TIME: float = 5.0
@export var MAX_BOOST_SPEED: float = 1800.0

@export var MAX_HEALTH: float = 100.0
@export var HEALTH_LOSS_RATE: float = 8.0

var charge_time: float = 0.0
var is_charging: bool = false
var last_direction: int = 1
var health: float = MAX_HEALTH

func _ready() -> void:
	velocity = Vector2.ZERO
	if $HealthBar:
		$HealthBar.max_value = MAX_HEALTH
		$HealthBar.value = health
		_update_health_color()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if not is_charging and Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("c_charge"):
		is_charging = true
		charge_time = min(charge_time + delta, MAX_CHARGE_TIME)
		health = max(health - HEALTH_LOSS_RATE * delta, 0.0)
		velocity.x = 0.0
	else:
		if is_charging and Input.is_action_just_released("c_charge"):
			var boost_ratio: float = charge_time / MAX_CHARGE_TIME
			var boosted_speed: float = lerp(SPEED, MAX_BOOST_SPEED, boost_ratio)
			var input_dir: float = Input.get_axis("izquierda", "derecha")
			if input_dir != 0.0:
				last_direction = int(sign(input_dir))
			velocity.x = last_direction * boosted_speed
			charge_time = 0.0
			is_charging = false
		else:
			var direction: float = Input.get_axis("izquierda", "derecha")
			if direction != 0.0:
				last_direction = int(sign(direction))
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0.0, SPEED * delta)

	move_and_slide()

	if $HealthBar:
		$HealthBar.value = health
		_update_health_color()

	if health <= 0.0:
		print("¡Game Over!")

# --- Función para cambiar el color según la vida ---
func _update_health_color() -> void:
	if not $HealthBar:
		return
	var ratio: float = health / MAX_HEALTH
	if ratio > 0.5:
		$HealthBar.tint_progress = Color(0,1,0)       # Verde
	elif ratio > 0.2:
		$HealthBar.tint_progress = Color(1,1,0)       # Amarillo
	else:
		$HealthBar.tint_progress = Color(1,0,0)       # Rojodasdadas
		
