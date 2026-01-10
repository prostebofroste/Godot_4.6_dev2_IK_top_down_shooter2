extends CharacterBody3D

# --- KOMPONENTY ---
@onready var aim_marker: Marker3D = $AimMarker
@onready var leg_marker: Marker3D = $LegMarker
@onready var animation_player: AnimationPlayer = $"Crouched Walking/AnimationPlayer"

# --- ZMIENNE EKSPORTOWANE ---
@export var hp: Node # Zakładam, że to Twój health_component
@export var attack_power := 10.0
@export var dash_power := 100.0
@export var max_stamina: float = 100.0

# --- STAŁE RUCHU ---
const SPEED = 5.0
const CHARGE_WALK_SPEED = 3.0
const LEG_SMOOTH_SPEED = 10.0
const FRICTION = 5.0

# --- USTAWIENIA ATAKU ---
const MAX_CHARGE_TIME = 0.2
const MIN_KICK_VEL = 0.0
const MAX_KICK_VEL = 15.0

# --- SYSTEM STAMINY I COOLDOWN ---
const STAMINA_REGEN_INTERVAL = 0.5 # Co ile sekund regenerować
const STAMINA_REGEN_AMOUNT = 5   # Ile punktów przywracać
const DASH_COST = 20.0
const ATTACK_COST = 5.0
const DASH_COOLDOWN = 0.5
const ATTACK_COOLDOWN = 1.0

# --- MASZYNA STANÓW (State Machine) ---
enum State { MOVE, ATTACK, DASH, STUNNED }
var current_state: State = State.MOVE

# --- ZMIENNE POMOCNICZE ---
var stamina: float
var charge_timer: float = 0.0
var current_kick_force: float = 0.0

# Timery logiczne
var stamina_timer: float = 0.0
var can_dash: bool = true
var can_attack: bool = true

func _ready() -> void:
	stamina = max_stamina
	if hp and hp.has_signal("died"):
		hp.died.connect(death)

func _physics_process(delta: float) -> void:
	# 1. Grawitacja (działa zawsze)
	if not is_on_floor():
		velocity += get_gravity() * delta # Pamiętaj o * delta przy grawitacji wbudowanej w 4.0, jeśli używasz standardowego ProjectSettings

	# 2. Regeneracja Staminy
	process_stamina(delta)

	# 3. Maszyna Stanów
	match current_state:
		State.MOVE:
			process_move_state(delta)
		State.ATTACK:
			process_kick_state(delta)
		State.DASH:
			process_dash_state(delta)
		State.STUNNED:
			process_stunned_state(delta)
	
	move_and_slide()

# --- LOGIKA STANÓW ---

func process_move_state(delta: float):
	# Obsługa Inputów tylko w stanie ruchu
	
	# -> Dash
	if Input.is_action_just_pressed("dash") and can_dash:
		if stamina >= DASH_COST:
			start_dash()
			return # Przerywamy klatkę, zmieniamy stan

	# -> Ładowanie Ataku
	if Input.is_action_pressed("spacebar") and can_attack:
		charge_timer += delta
		charge_timer = min(charge_timer, MAX_CHARGE_TIME)
	
	# -> Wykonanie Ataku (po puszczeniu)
	if Input.is_action_just_released("spacebar") and can_attack:
		if stamina >= ATTACK_COST:
			start_kick()
			charge_timer = 0.0
			return # Przerywamy klatkę, zmieniamy stan
		else:
			charge_timer = 0.0 # Reset, brak staminy

	# Ruch właściwy
	var current_speed = SPEED
	if charge_timer > 0:
		current_speed = CHARGE_WALK_SPEED # Wolniej przy ładowaniu

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		if charge_timer > 0:
			animation_player.play("idle") # Ewentualnie inna animacja ładowania
		else:
			animation_player.play("run")
		
		# Noga goni cel
		var target_position = direction * 1.0
		leg_marker.position = leg_marker.position.lerp(target_position, delta * LEG_SMOOTH_SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		animation_player.play("idle")
		leg_marker.position = leg_marker.position.lerp(Vector3.ZERO, delta * LEG_SMOOTH_SPEED)

func process_kick_state(delta: float):
	# W stanie ataku porusza się siłą rozpędu z start_kick, tutaj tylko wizualia nogi
	var target_local = to_local(aim_marker.global_position)
	target_local = target_local.limit_length(1.5)
	leg_marker.position = leg_marker.position.lerp(target_local, delta * LEG_SMOOTH_SPEED * 2)

func process_dash_state(delta: float):
	# Podobnie jak atak, dash jest sterowany przez Tween lub velocity ustawione na starcie
	var target_local = to_local(leg_marker.global_position)
	target_local = target_local.limit_length(1.5)
	leg_marker.position = leg_marker.position.lerp(target_local, delta * LEG_SMOOTH_SPEED * 2)

func process_stunned_state(delta: float):
	# Hamowanie friction (dla knockbacku)
	var horizontal_velocity = Vector2(velocity.x, velocity.z)
	var new_horizontal = horizontal_velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	velocity.x = new_horizontal.x
	velocity.z = new_horizontal.y
	
	# Wyjście ze stuna gdy prędkość spadnie (opcjonalne, zależnie od gameplayu)
	if horizontal_velocity.length() < 1.0:
		current_state = State.MOVE

# --- AKCJE ---

func start_kick():
	current_state = State.ATTACK
	stamina -= ATTACK_COST
	start_cooldown("attack", ATTACK_COOLDOWN)

	# Oblicz siłę
	var charge_factor = charge_timer / MAX_CHARGE_TIME
	charge_factor = clamp(charge_factor, 0.0, 1.0)
	current_kick_force = lerp(MIN_KICK_VEL, MAX_KICK_VEL, charge_factor)
	
	var direction = global_position.direction_to(aim_marker.global_position)
	direction.y = 0
	direction = direction.normalized()
	
	velocity = direction * current_kick_force
	
	# Tween (hamowanie)
	var t = create_tween()
	t.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var dash_duration = lerp(0.3, 0.8, charge_factor)
	t.tween_property(self, "velocity", Vector3.ZERO, dash_duration)
	
	# print(clamp((attack_power * current_kick_force/10),7,15))
	animation_player.play("kick")

func start_dash():
	current_state = State.DASH
	stamina -= DASH_COST
	start_cooldown("dash", DASH_COOLDOWN)
	
	print("dash start")
	var direction = global_position.direction_to(leg_marker.global_position)
	direction.y = 0
	direction = direction.normalized()
	
	# Jeśli nie celujemy, dash do przodu
	if direction == Vector3.ZERO:
		direction = transform.basis.z 

	velocity = direction * dash_power
	
	# Tween do wyhamowania dasha (żeby nie lecieć w nieskończoność)
	var t = create_tween()
	t.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "velocity", Vector3.ZERO, 0.3)
	t.tween_callback(func(): 
		if current_state == State.DASH: 
			current_state = State.MOVE
	)

# --- SYSTEM POMOCNICZY ---

func process_stamina(delta: float):
	if stamina < max_stamina:
		stamina_timer += delta
		if stamina_timer >= STAMINA_REGEN_INTERVAL:
			stamina += STAMINA_REGEN_AMOUNT
			stamina = min(stamina, max_stamina)
			stamina_timer = 0.0
			print("Stamina: ", stamina)

func start_cooldown(type: String, time: float):
	if type == "dash":
		can_dash = false
		await get_tree().create_timer(time).timeout
		can_dash = true
		print("Dash gotowy")
	elif type == "attack":
		can_attack = false
		await get_tree().create_timer(time).timeout
		can_attack = true
		# print("Atak gotowy")

# --- SYGNAŁY I LOGIKA ORYGINALNA (Zachowane) ---

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "kick":
		# Wracamy do ruchu po zakończeniu animacji ataku
		if current_state == State.ATTACK:
			current_state = State.MOVE

func _on_kick_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Kickable"):
		if body.has_method("apply_knockback"):
			# Możesz teraz uzależnić siłę odrzutu obiektu od naładowania!
			# Np. body.apply_knockback(global_position, charge_timer)
			body.apply_knockback(global_position,(attack_power * (current_kick_force/10)))

# To funkcja, którą ta postać wykonuje gdy KTOŚ INNY ją uderzy
func apply_knockback(_from: Vector3, amount):
	var direction = _from.direction_to(global_position)
	direction.y = 0
	
	# Ważne: Przełączamy stan na STUNNED, żeby Move State nie nadpisał velocity zerem w następnej klatce
	current_state = State.STUNNED
	velocity = direction.normalized() * (amount/2)

func death():
	get_tree().quit()
