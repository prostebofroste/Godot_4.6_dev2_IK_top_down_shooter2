extends CharacterBody3D

@onready var aim_marker: Marker3D = $AimMarker
@onready var leg_marker: Marker3D = $LegMarker
@onready var animation_player: AnimationPlayer = $"Crouched Walking/AnimationPlayer"

const SPEED = 5.0
const CHARGE_WALK_SPEED = 3.0 # Nowa stała: prędkość chodzenia podczas ładowania
const LEG_SMOOTH_SPEED = 10.0

# --- Ustawienia ładowania ataku ---
const MAX_CHARGE_TIME = 0.2   
const MIN_KICK_VEL = 0.0      
const MAX_KICK_VEL = 15.0     

var charge_timer: float = 0.0 
var is_attacking := false

func _physics_process(delta: float) -> void:
	# 1. Grawitacja
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Obsługa ładowania ataku (Input)
	if not is_attacking:
		# Ładowanie (trzymanie spacji)
		if Input.is_action_pressed("spacebar"):
			charge_timer += delta
			charge_timer = min(charge_timer, MAX_CHARGE_TIME)
		
		# Atak (puszczenie spacji)
		if Input.is_action_just_released("spacebar"):
			start_kick()
			charge_timer = 0.0 # Reset licznika PO ataku

	# 3. Logika stanu
	if is_attacking:
		process_kick_state(delta)
	else:
		process_move_state(delta)

	move_and_slide()

# --- STAN RUCHU ---
func process_move_state(delta: float):
	# 1. Wybierz prędkość: Zwykła czy "ciężka" (podczas ładowania)
	var current_speed = SPEED
	if charge_timer > 0:
		current_speed = CHARGE_WALK_SPEED # Używamy wolniejszej prędkości (lub daj tu SPEED, jeśli ma biegać szybko)

	# 2. Standardowe poruszanie
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		# Opcjonalnie: inna animacja podczas ładowania?
		if charge_timer > 0:
			animation_player.play("idle") # Lub np. "walk_ready"
		else:
			animation_player.play("run")
		
		# Noga goni kierunek ruchu
		var target_position = direction * 1.0 
		leg_marker.position = leg_marker.position.lerp(target_position, delta * LEG_SMOOTH_SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		animation_player.play("idle")
		leg_marker.position = leg_marker.position.lerp(Vector3.ZERO, delta * LEG_SMOOTH_SPEED)

# --- STAN ATAKU ---
func start_kick():
	# Oblicz siłę
	var charge_factor = charge_timer / MAX_CHARGE_TIME
	charge_factor = clamp(charge_factor, 0.0, 1.0)
	
	var current_kick_force = lerp(MIN_KICK_VEL, MAX_KICK_VEL, charge_factor)
	
	# Kierunek skoku (w stronę celownika)
	var direction = global_position.direction_to(aim_marker.global_position)
	direction.y = 0 
	direction = direction.normalized()
	
	velocity = direction * current_kick_force
	
	# Tween (hamowanie po skoku)
	var t = create_tween()
	t.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var dash_duration = lerp(0.3, 0.8, charge_factor) 
	t.tween_property(self, "velocity", Vector3.ZERO, dash_duration)
	
	is_attacking = true
	animation_player.play("kick")

func process_kick_state(delta: float):
	var target_local = to_local(aim_marker.global_position)
	target_local = target_local.limit_length(1.5)
	leg_marker.position = leg_marker.position.lerp(target_local, delta * LEG_SMOOTH_SPEED * 2)

# --- SYGNAŁY ---
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "kick":
		is_attacking = false

func _on_kick_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Kickable"):
		if body.has_method("apply_knockback"):
			# Możesz teraz uzależnić siłę odrzutu obiektu od naładowania!
			# Np. body.apply_knockback(global_position, charge_timer)
			body.apply_knockback(global_position)
