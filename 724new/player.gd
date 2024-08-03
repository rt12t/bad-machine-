extends CharacterBody2D

enum State {
	IDLE,
	RUNNING,
	JUMP,
	FALL,
	LANDING,
	WALL_SLIDING,
	
}

const GROUN_STATES := [State.IDLE,State.RUNNING,State.LANDING]
const  RUN_SPEED := 400
const  FLLOR_ACCELERATION := RUN_SPEED / 0.8
const  AIR_ACCELERATION := RUN_SPEED /0.1
const JUMP_VELOCITY := -1150
const default_gravity = 2000


#var gravity := ProjectSettings.get("physics/2d/default_gravity") as float
var is_first_tick := false

@onready var graphics: Node2D = $Graphics
@onready var animation_player = $AnimationPlayer
@onready var jump_request_timer = $JumpRequestTimer
@onready var coyote_timer: Timer = $"Coyote Timer"
@onready var hand_cheker: RayCast2D = $Graphics/HandCheker
@onready var foot_cheker: RayCast2D = $Graphics/FootCheker

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start()
	if event.is_action_released("jump"):
		jump_request_timer.stop()
		if velocity.y < JUMP_VELOCITY / 2:
			velocity.y = JUMP_VELOCITY / 2

func tick_physics(state: State, delta: float) -> void:
	
	match state:
		State.IDLE:
			move(default_gravity,delta)
		
		State.RUNNING:
			move(default_gravity,delta)
		
		State.JUMP:
			move(default_gravity,delta)
			
		State.LANDING:
			move(default_gravity,delta)
		
		State.FALL:
			move(default_gravity,delta)	
			
		State.WALL_SLIDING:
			move(default_gravity / 30 ,delta)
			#graphics.scale.x = get_wall_normal().x
	is_first_tick = false				
		
	
	
	
	
func move(gravity: float, delta: float)	-> void:
	var direction := Input.get_axis("move_left","move_right")
	var acceleration := FLLOR_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.x = move_toward(velocity.x, direction * RUN_SPEED, acceleration * delta)
	velocity.y += gravity * delta
	
	
	
		
	if not is_zero_approx(direction):	
		graphics.scale.x = -1 if direction < 0 else 1
		
	move_and_slide()
	
			
func get_next_state(state:State) ->	 State:
	var can_jump := is_on_floor() or coyote_timer.time_left > 0
	var should_jump = can_jump and jump_request_timer.time_left > 0
	if should_jump:
		return State.JUMP
		
	var direction := Input.get_axis("move_left","move_right")
	var is_still := is_zero_approx(direction) and is_zero_approx(velocity.x)
	
	match state:
		State.IDLE:
			if not is_on_floor():
				return State.FALL
			if not is_still:
				return State.RUNNING
			
		State.RUNNING:
			if is_still:
				return State.IDLE
			
		State.JUMP:
			if velocity.y >= 0:
				return State.FALL
			
		State.FALL:
			if is_on_floor():
				return State.LANDING
			if is_on_wall() and hand_cheker.is_colliding() and foot_cheker.is_colliding():
				return State.WALL_SLIDING
					
				
		State.LANDING:
			if not animation_player.is_playing():
				return State.IDLE
		
		State.WALL_SLIDING:
			if is_on_floor():
				return State.IDLE
			if not is_on_wall():
				return State.FALL
							


	return state			
	
func transition_state(from: State, to: State) -> void:
	if from not in GROUN_STATES and to in GROUN_STATES:
		coyote_timer.stop()
	
	match to:
		State.IDLE:
			animation_player.play("idle")
		
		State.RUNNING:
			animation_player.play("running")	
		
		State.JUMP:
			animation_player.play("jump")
			velocity.y = JUMP_VELOCITY
			coyote_timer.stop()
			jump_request_timer.stop()
		
		State.FALL:
			animation_player.play("full")	
			if from in GROUN_STATES:
				coyote_timer.start()
		
		State.LANDING:
			animation_player.play("landing")
					
		State.WALL_SLIDING:
			animation_player.play("wall_sliding")		
				
	is_first_tick = true