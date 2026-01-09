extends Camera3D

@export var marker_3d: Marker3D 
@export var target_character: CharacterBody3D # Pamiętaj, aby przypisać gracza w Inspektorze!
@export var smooth_speed: float = 5.0
@export var look_ahead_factor: float = 0.3 # Jak bardzo kamera wychyla się do myszki

@export var gun_pivot: Node3D 

# Zmienna na offset, ale nie musisz jej wpisywać ręcznie, obliczymy ją w _ready
@export var camera_offset: Vector3 

func _ready():
	# Jeśli przypisałeś gracza, obliczamy początkową odległość kamery od niego
	# Dzięki temu kamera zachowa pozycję ustawioną w edytorze
	if target_character:
		camera_offset = global_position - target_character.global_position
	else:
		# Fallback jeśli zapomnisz przypisać gracza lub wolisz sztywne wartości
		if camera_offset == Vector3.ZERO:
			camera_offset = Vector3(0, 10, 10)

func _process(delta: float) -> void:
	shoot_ray()
	follow_target(delta) # <--- TO BYŁO BRAKUJĄCE OGNIWO
func shoot_ray():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	
	var ray_query = PhysicsRayQueryParameters3D.create(from, to)
	
	# Ważne: Wykluczamy gracza, żeby kamera nie celowała w jego głowę, gdy najedziesz na nią myszką
	if target_character:
		ray_query.exclude = [target_character.get_rid()]
	
	var raycast_result = space.intersect_ray(ray_query)
	
	if not raycast_result.is_empty():
			if gun_pivot:
				gun_pivot.look_at(raycast_result.position, Vector3.UP)
				gun_pivot.rotation.z = 0 
				gun_pivot.rotation.x = 0

			if marker_3d:
				marker_3d.global_position = raycast_result.position

func follow_target(delta):
	if not target_character or not marker_3d:
		return

	# Oblicz wektor przesunięcia w stronę celownika
	# marker_3d.global_position to punkt, w który patrzysz
	var mouse_offset = (marker_3d.global_position - target_character.global_position) * look_ahead_factor
	
	# Ograniczamy ten offset, żeby kamera nie uciekła za daleko (max 5 jednostek)
	mouse_offset = mouse_offset.limit_length(5.0) 
	
	# Docelowa pozycja:
	# 1. Pozycja gracza
	# 2. Plus stały dystans kamery (wysokość i oddalenie)
	# 3. Plus lekkie przesunięcie w stronę myszki (tylko w poziomie X i Z)
	var desired_position = target_character.global_position + camera_offset + Vector3(mouse_offset.x, 0, mouse_offset.z)
	
	# Płynne przesuwanie kamery (Lerp)
	global_position = global_position.lerp(desired_position, delta * smooth_speed)
