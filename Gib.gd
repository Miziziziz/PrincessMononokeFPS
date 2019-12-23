extends RigidBody

var min_init_speed = 8
var max_init_speed = 15

func _ready():
	apply_central_impulse(global_transform.basis.z * rand_range(min_init_speed, max_init_speed))
	
	$Guts1.hide()
	$Guts2.hide()
	if randi() % 2 == 0:
		$Guts1.show()
	else:
		$Guts2.show()

