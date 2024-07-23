extends Area2D

@onready var bullrt_sprite_2d = $Bullrt_Sprite2D

const SPEED = 800
var direction = 1
const DAMAGE = 35
 
func _physics_process(delta):
	if direction == -1:
		bullrt_sprite_2d.flip_h = true 
		
	position.x = position.x + SPEED * direction * delta	
	
	
	

func _on_body_entered(body):
	
	var vfxToSpawn = preload("res://game/Scene/vfX_bullet_hit.tscn")
	var vfxInstance = vfxToSpawn.instantiate() 	
	vfxInstance.global_position = global_position
	get_tree().get_root().get_node("Root").add_child(vfxInstance)
	
	if direction == -1:
		vfxInstance.scale.x = -1

	var enemy = body as EnemyController
	if enemy:
		enemy.ApplyDamage(DAMAGE)
	

	queue_free()
