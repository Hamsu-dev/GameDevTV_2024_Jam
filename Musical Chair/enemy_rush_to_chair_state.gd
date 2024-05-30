class_name EnemyRushToChairState
extends State

@export var actor: EnemyBase

var target_chair: Node2D = null
var animation_tree: AnimationTree
var playback: AnimationNodeStateMachinePlayback

func _ready():
	set_physics_process(false)

func _enter_state() -> void:
	if actor.chair_occupied:  # If the enemy already occupies a chair, do nothing
		return
	set_physics_process(true)
	# Find the nearest available chair
	target_chair = get_nearest_available_chair()
	# Initialize animation_tree and playback here
	animation_tree = actor.animation_tree
	if animation_tree:
		playback = animation_tree.get("parameters/playback")
		if playback:
			playback.travel("Walk")

func _exit_state() -> void:
	set_physics_process(false)

func _physics_process(delta) -> void:
	if target_chair:
		# Check if the target chair is still available
		if target_chair.occupied:
			target_chair = get_nearest_available_chair()
			if not target_chair:  # No available chairs
				return
				
		var direction = (target_chair.global_position - actor.global_position).normalized()
		actor.velocity = actor.velocity.move_toward(direction * actor.speed, actor.acceleration * delta)
		
		if direction != Vector2.ZERO:
			if animation_tree:
				animation_tree.set("parameters/Idle/blend_position", direction)
				animation_tree.set("parameters/Walk/blend_position", direction)
				if playback:
					playback.travel("Walk")
		else:
			if playback:
				playback.travel("Walk")
				
		actor.move_and_slide()
		
		# Check if the enemy has reached the chair
		if actor.global_position.distance_to(target_chair.global_position) < 10:
			# Get the ChairManager from the level node
			var chair_manager = get_tree().get_root().get_node("Game").current_level.get_node("ChairManager")
			chair_manager.on_chair_occupied(target_chair, actor, animation_tree)  # Notify manager about the occupied chair
			target_chair.occupied = true
			actor.chair_occupied = true
			actor.velocity = Vector2.ZERO
			print("Enemy occupied the chair!")
			set_physics_process(false)  # Stop processing physics for this state
			if playback:
				playback.travel("Idle")

func get_nearest_available_chair() -> Node2D:
	var chairs = get_tree().get_root().get_node("Game").current_level.get_node("Chairs").get_children()
	var nearest_chair: Node2D = null
	var min_distance = INF
	for chair in chairs:
		if not chair.occupied:
			var distance = actor.global_position.distance_to(chair.global_position)
			if distance < min_distance:
				min_distance = distance
				nearest_chair = chair
	return nearest_chair
