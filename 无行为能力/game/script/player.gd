extends CharacterBody2D
class_name PlayerController

const SPEED = 300
const JUMP_VELOCITY = -1000
const GRAVITY = 2000
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var shooting_point = $shooting_Point
 
var AirbornLastFrame = false

var isShooting = false
const SHOOT_DURATION = 0.8



enum PlayerState {Normal,Hurt,Dead}

var currentState : PlayerState = PlayerState.Normal:
	set(new_value):
		currentState = new_value
		match currentState:
			PlayerState.Hurt:
				if is_on_floor():
					animated_sprite_2d.play("hit_satnd")
				else: 
					animated_sprite_2d.play("hit_jump")
			PlayerState.Dead:	
				animated_sprite_2d.play("die")
				set_collision_layer_value(2,false)


var currentHealth
const MAX_HEALTH = 200
					

func _ready(): 
	currentHealth = MAX_HEALTH
	GameManager.player = self 
	GameManager.PlayerOriginalPos = position

func _process(_delta):
	UpdateAnimation()
	
func _physics_process(delta):
	if is_on_floor() == false:
		velocity.y += GRAVITY * delta
		AirbornLastFrame = true
	elif  AirbornLastFrame:
		PlaylandVFX()
		AirbornLastFrame = false	
	
	if currentState == PlayerState.Hurt or currentState == PlayerState.Dead:
		velocity.x = 0
		move_and_slide()
		return
	
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY
		PlayerJumpUpVFX()
				
	var direction = Input.get_axis("left","right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x=0 
	
	if Input.is_action_just_pressed("shoot"):
		TryToShoot()
	
		
	if Input.is_action_just_pressed("down") && is_on_floor():
		position.y += 10
			
	move_and_slide()
	
	
	
	
func UpdateAnimation():
	
	
	if currentState == PlayerState.Dead:
		return
	elif currentState == PlayerState.Hurt:
		if animated_sprite_2d.is_playing():
			return
		else:
			currentState == PlayerState.Normal	
		
			
	
	
	
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x < 0
		if velocity.x < 0:
			shooting_point.position.x = -49
		else:
			shooting_point.position.x = 49 	
			
			
	if is_on_floor():	
		if abs(velocity.x)	>= 0.1:
			
			var playingAnimationFrame = animated_sprite_2d.frame
			var playingAnimationName = animated_sprite_2d.animation
			
			if isShooting:
				animated_sprite_2d.play("Shoot_run")
				
				if playingAnimationName == "run":
					animated_sprite_2d.frame = playingAnimationFrame
				
			else:	
				animated_sprite_2d.play("run")
			
			
		else:
			if isShooting:
				animated_sprite_2d.play("shoot_stand")
			else:	
				animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d	.play("jump")
		 
		if isShooting:
			animated_sprite_2d.play("Shoot_jump")	
			
			
func PlayerJumpUpVFX():
	var vfxToSpawn = preload("res://game/Scene/vfX_jump_up.tscn")
	var vfxInstance = vfxToSpawn.instantiate() 	
	vfxInstance.global_position = global_position
	get_tree().get_root().get_node("Root").add_child(vfxInstance)
	
func PlaylandVFX():
	var vfxToSpanwn = preload("res://game/Scene/vfX_land.tscn")	
	GameManager.SpawnVFX(vfxToSpanwn,global_position)
	
func Shoot():
	var bulleTospawn = preload("res://game/Scene/bullet.tscn")	
	var bulletInstance = GameManager.SpawnVFX(bulleTospawn,shooting_point.global_position)
	 
	if animated_sprite_2d.flip_h:
		bulletInstance.direction = -1
	else:
		bulletInstance.direction = 1	
		
		
		
		
		
func TryToShoot():
	if isShooting:
		return
		
	isShooting = true
	Shoot()		
	await get_tree().create_timer(SHOOT_DURATION).timeout
	isShooting = false
		
	
	 
	
func ApplyDamage (damage:int):
	if currentState	 == PlayerState.Hurt || currentState == PlayerState.Dead:
		return
		
	currentHealth -= damage
	currentState = PlayerState.Hurt	
	
	if currentHealth <=0:
		currentHealth = 0
		currentState = PlayerState.Dead
		
	
