extends KinematicBody

var player = null
onready var anim = $"Scene Root/AnimationPlayer"

func _ready():
	pass # Replace with function body.


func kill(explode_on_kill):
	print('dead and would explode: ', explode_on_kill)

#func _process(delta):
#	pass
