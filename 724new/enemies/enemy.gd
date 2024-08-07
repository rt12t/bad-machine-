class_name Enemy
extends CharacterBody2D

enum Direction{
	LEFT = -1,
	RIGHT = 1,
}

@export var direction := Direction.LEFT:
	set(v):
		direction = v
		if not is_node_ready():
			await ready
		graphics.scale.x = -direction
@export var max_speed: float = 800
@export var accleration: float = 800

var defualt_gravity := ProjectSettings.get("physics/2d/default_gravity") as float		

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine
@onready var graphics: Node2D = $Graphics


func move(speed: float, delta:float)-> void:
	velocity.x = move_toward(velocity.x, speed * direction, accleration * delta)
	velocity.y += defualt_gravity * delta
	
	move_and_slide()
