extends Area2D
@onready var collision_shape_2d = $CollisionShape2D


const DAMAGE = 30



func _on_body_entered(body):
	var player = body as PlayerController
	if player:
		player.ApplyDamage(DAMAGE)
