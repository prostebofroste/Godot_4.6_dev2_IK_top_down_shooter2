extends CharacterBody3D

var knockback_strength = 5.0 
var friction = 5.0 
var is_stunned = false

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

@export var status: Label3D 
@export var health_label: Label3D 
@export var hp: health_component

@export var movement_speed: float = 1.5
var target_node: Node3D

func _ready() -> void:
	hp.died.connect(_death)
	target_node = get_tree().get_first_node_in_group("Player")
	if not nav_agent.velocity_computed.is_connected(_on_navigation_agent_3d_velocity_computed):
		nav_agent.velocity_computed.connect(_on_navigation_agent_3d_velocity_computed)
	status.text = "idle"

func _physics_process(delta):
	health_label.text = "HP: " + str(hp.current_health)
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_stunned:
		var horizontal_velocity = Vector2(velocity.x, velocity.z)
		var new_horizontal = horizontal_velocity.move_toward(Vector2.ZERO, friction * delta)
		velocity.x = new_horizontal.x
		velocity.z = new_horizontal.y
		move_and_slide()
	else:
		navigation()

func apply_knockback(_from: Vector3):
	is_stunned = true
	var direction = _from.direction_to(global_position)
	direction.y = 0.0
	velocity = direction.normalized() * knockback_strength
	status.text = "stuned"
	
	await get_tree().create_timer(2.5).timeout
	
	status.text = "idle"
	is_stunned = false

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if is_stunned: return
	
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z
	move_and_slide()

func navigation():
	if not target_node: return

	nav_agent.target_position = target_node.global_position
	var look_target = target_node.global_position
	look_target.y = global_position.y # Ignoruj różnicę wysokości
	look_at(look_target)
	
	if nav_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	var new_velocity: Vector3 = (next_path_position - global_position).normalized() * movement_speed

	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		velocity.x = new_velocity.x
		velocity.z = new_velocity.z
		move_and_slide()
func _death():
	queue_free()
