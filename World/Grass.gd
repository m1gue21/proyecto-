extends Node2D


func create_grass_effect():
		###pasos para hacer un instance
		var GrassEffect = load ("res://Effects/GrassEffect.tscn")## se busca el objeto
		var grassEffect = GrassEffect.instance()## se llama el objeto
		var world = get_tree().current_scene #ahi le estamos dando acceso a nuestra lista de objetos
		world.add_child(grassEffect)## se esta llamando la variable que llama el objeto como hijo del nodo principal
		grassEffect.global_position = global_position## 2da globalposition es la de grass y la primera la del efecto
		


func _on_Hurtbox_area_entered(area):
	create_grass_effect()
	queue_free()
	
