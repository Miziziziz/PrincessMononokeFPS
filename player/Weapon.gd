extends Spatial

onready var anim = $AnimationPlayer
onready var raycast = $RayCast

var moving = false
var not_moving = false

export var explode_on_kill = false
export var custom_call_attack = false

func shoot():
	anim.play("attack")
	if !custom_call_attack:
		attack()
	
func attack():
	if raycast.is_colliding() and raycast.get_collider().has_method("kill"):
		raycast.get_collider().kill(explode_on_kill)

func _process(delta):
	if moving and (!anim.is_playing() or anim.current_animation == "idle"):
		anim.play("walk", 0.2)
	elif not_moving and (!anim.is_playing() or anim.current_animation == "walk"):
		anim.play("idle", 0.2)
