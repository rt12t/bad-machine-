extends CharacterBody2D

enum State {
	IDLE,
	RUNNING,
	JUMP,
	FALL,
	LANDING,
	WALL_SLIDING,
	WALL_JUMP,
	ATTACK_1,
	ATTACK_2,
	ATTACK_3,
}

const GROUN_STATES := [
	State.IDLE,State.RUNNING,State.LANDING,
	State.ATTACK_1, State.ATTACK_2, State.ATTACK_3
]
const  RUN_SPEED := 400
const  FLLOR_ACCELERATION := RUN_SPEED / 0.8
const  AIR_ACCELERATION := RUN_SPEED /0.1
const JUMP_VELOCITY := -1150
const default_gravity = 2000
const WALL_JUMP_VELOCITY := Vector2(1000,-800)

@export var can_combo := false  

#var gravity := ProjectSettings.get("physics/2d/default_gravity") as float
var is_first_tick := false
var is_combo_requested := false

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
			
	if event.is_action_pressed("attack") and can_combo:
		is_combo_requested = true		
			

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
		
		State.WALL_JUMP:
			move(default_gravity,delta)	
			
		State.ATTACK_1,State.ATTACK_2,State.ATTACK_3:
			move(default_gravity,delta)
				
			
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
		
	if state in GROUN_STATES and not is_on_floor():
		return State.FALL	
		
		
	var direction := Input.get_axis("move_left","move_right")
	var is_still := is_zero_approx(direction) and is_zero_approx(velocity.x)
	
	match state:
		State.IDLE:
			if Input.is_action_just_pressed("attack"):
				return State.ATTACK_1	
			if not is_still:
				return State.RUNNING
			
		State.RUNNING:
			if Input.is_action_just_pressed("attack"):
				return State.ATTACK_1		
			if is_still:
				return State.IDLE
			
		State.JUMP:
			if velocity.y >= 0:
				return State.FALL
			
		State.FALL:
			if is_on_floor():
				return State.LANDING
			if  is_on_wall() and hand_cheker.is_colliding() and foot_cheker.is_colliding():
				return State.WALL_SLIDING
					
				
		State.LANDING:
			if not animation_player.is_playing():
				return State.IDLE
			if Input.is_action_just_pressed("attack"):
				return State.ATTACK_1	
		
		State.WALL_SLIDING:
			if jump_request_timer.time_left > 0:
				return State.WALL_JUMP
			if is_on_floor():
				return State.IDLE
			if not is_on_wall() and hand_cheker.is_colliding() and foot_cheker.is_colliding():
				return State.FALL
		
		State.WALL_JUMP:
			if velocity.y >= 0:
				return State.FALL
				
		State.ATTACK_1:
			if not animation_player.is_playing():
				return State.ATTACK_2 if is_combo_requested else State.IDLE	
		
		State.ATTACK_2:
			if not animation_player.is_playing():
				return State.ATTACK_3 if is_combo_requested else State.IDLE		
				
		State.ATTACK_3:
			if not animation_player.is_playing():
				return State.IDLE								


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
			
		
		State.WALL_JUMP:
			animation_player.play("jump")
			velocity = WALL_JUMP_VELOCITY
			velocity.x = get_floor_normal().x
			jump_request_timer.stop()	
			
		State.ATTACK_1:
			animation_player.play("attack_2")
			is_combo_requested = false
			
		State.ATTACK_2:
			animation_player.play("attack")
			is_combo_requested = false
			
		State.ATTACK_3:
			animation_player.play("attack3")	
			is_combo_requested = false			
				
	is_first_tick = true
