extends Node

var player
var PlayerOriginalPos

func PlayerEnteredResetArea():
	player.position = PlayerOriginalPos
	
	
	
	
func SpawnVFX(vfxToSpawn : Resource, position : Vector2):
	var vfxInstance = vfxToSpawn.instantiate() 	
	vfxInstance.global_position = position
	get_tree().get_root().get_node("Root").add_child(vfxInstance)
	
	return vfxInstance
