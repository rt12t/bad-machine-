extends CharacterBody2D

const SPEED = 200
var direction = -1
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var ray_cast_2d_forward = $CollisionShape2D/RayCast2D


func _process(_delta):
	UpdateAnimation() 

func _physics_process(_delta):
	if is_on_floor() == false:
		velocity.y = 800
		
	if ray_cast_2d_forward.is_colliding():
		direction = -direction
		ray_cast_2d_forward.target_position.x = -ray_cast_2d_forward.target_position.x
		
		
	velocity.x = direction * SPEED	
	
	move_and_slide()
	
func UpdateAnimation():
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x > 0
		
	animated_sprite_2d.play("walk")	
		
		
	
	
	
