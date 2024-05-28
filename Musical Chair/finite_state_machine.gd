class_name FiniteStateMachine
extends Node

@export var state: State
@onready var business_goblin = $".."

func _ready():
	change_state(state)

func change_state(new_state: State):
	if state is State:
		state._exit_state()
	if business_goblin.chair_occupied:
		return
	if new_state is State:
		new_state._enter_state()
	state = new_state
