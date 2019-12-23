extends Spatial

func load_enter(coll):
	if coll.name == "Player":
		$AnimationPlayer.play("entrance")