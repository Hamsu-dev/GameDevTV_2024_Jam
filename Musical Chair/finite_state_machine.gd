class_name FiniteStateMachine
extends Node

@export var state: State

func _ready():
	change_state(state)
	print(state)

func change_state(new_state: State):
	if state is State:
		state._exit_state()
	
	# Get the parent enemy instance
	var enemy = get_parent() as EnemyBase
	if enemy.chair_occupied:
		return  # Prevent any state change if the chair is occupied

	if new_state is State:
		new_state._enter_state()

	state = new_state
