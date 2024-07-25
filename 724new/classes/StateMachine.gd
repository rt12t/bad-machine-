#class_name StateMachine
extends Node

#var current_state: int = -1:
	#set(v):
		#owner.transition_state(current_state,v)
		#current_state = v
		
		
		
#func _ready() -> void:
	#await owner.ready
	#current_state = 0	 	
	
