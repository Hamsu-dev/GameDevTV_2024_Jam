extends Area2D

const debuff_area = preload("res://slow_debuff.tscn")

@export var speed = 100.0
@export var slow_factor = 0.25
@export var arc_height = 50.0

@onready var sprite = $Sprite2D

var target_position = Vector2.ZERO
var rotation_speed = 0.0

func _ready():
	rotation_speed = randf_range(-1.0, 1.0) * 2 * PI
	animate_to_target()

func _physics_process(delta):
	rotation += rotation_speed * delta

func instantiate_debuff_area():
	var debuff = Utils.instantiate_scene_on_world(debuff_area, global_position)
	var game = get_tree().get_root().get_node("Game")
	game.add_debuff(debuff)  # Add debuff to the active list

func animate_to_target():
	var tween = get_tree().create_tween()
	var distance = global_position.distance_to(target_position)
	var duration = distance / speed
	var mid_position = (global_position + target_position) / 2
	mid_position.y -= arc_height  # Create an arc by adjusting the y-position

	tween.tween_property(self, "global_position", mid_position, duration)
	tween.tween_property(self, "global_position", target_position, duration)
	
	
	tween.finished.connect(_on_tween_finished)

func _on_tween_finished():
	create_debuff_area()
	queue_free()

func create_debuff_area():
	var debuff_instance = Utils.instantiate_scene_on_world(debuff_area, global_position)
	var game = get_tree().get_root().get_node("Game")
	game.add_debuff(debuff_instance)
