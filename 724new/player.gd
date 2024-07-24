extends CharacterBody2D

const  RUN_SPEED := 300
const  ACCELERATION := RUN_SPEED / 0.7
const JUMP_VELOCITY := -800

var gravity := ProjectSettings.get("physics/2d/default_gravity") as float
@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var jump_request_timer = $JumpRequestTimer

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start()
	if event.is_action_released("jump")	and velocity.y < JUMP_VELOCITY / 2:
		velocity.y = JUMP_VELOCITY / 2

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left","move_right")
	velocity.x = move_toward(velocity.x, direction * RUN_SPEED, ACCELERATION * delta)
	velocity.y += gravity * delta
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		
	if is_on_floor():	
		if is_zero_approx(direction) and is_zero_approx(velocity.x):
			animation_player.play("idle")
		else:
			animation_player.play("running")
	else:
		animation_player.play("jump")
		
	if not is_zero_approx(direction):	
		sprite_2d.flip_h = direction < 0
	var was_on_floor := is_on_floor()	
	move_and_slide()
