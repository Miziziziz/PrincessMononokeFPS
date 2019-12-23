extends KinematicBody

var player = null
onready var anim = $"Scene Root/AnimationPlayer"

var speed = 5
var turn_speed = 100
var dead = false

var gibs = preload("res://Gibs.tscn")
var blood = preload("res://Blood.tscn")

func kill(explode_on_kill):
	dead = true
	$CollisionShape.disabled = true
	$Blood.emitting = true
	if explode_on_kill:
		var gibs_inst = gibs.instance()
		get_tree().get_root().add_child(gibs_inst)
		gibs_inst.global_transform.origin = global_transform.origin
		gibs_inst.rotation_degrees.y = rand_range(0.0, 360.0)
		$"Scene Root".hide()
	else:
		anim.play("die")
	
	

func _physics_process(delta):
	if player == null:
		return
	
	var dir = (player.global_transform.origin - global_transform.origin).normalized()
	var dis = player.global_transform.origin.distance_to(global_transform.origin)
	dir.y = 0.0
	
	var can_see_player = false
	var space_state = get_world().direct_space_state
	if player:
		var result = space_state.intersect_ray(global_transform.origin + Vector3.UP * 3.0, player.global_transform.origin, get_tree().get_nodes_in_group("boars"), 1)
		if !result:
			can_see_player = true
	
	if dis > 2.0 and can_see_player and !dead:
		move_and_collide(dir * speed * delta)
		aim_at(player.global_transform.origin, delta)
		if anim.current_animation != "run":
			anim.play("run")
	elif !dead and anim.current_animation != "walk":
		anim.play("idle")

func aim_at(target_pos, t_delta):
	var our_pos = global_transform.origin
	our_pos.y = 0
	target_pos.y = 0
	var to_target = target_pos - our_pos
	var goal_rot = rad2deg(atan2(to_target.x, to_target.z))
	# instantly face target
	if turn_speed < 0: 
		rotation_degrees.y = goal_rot
	# otherwise slowly rotate to target
	elif abs(angle_difference(goal_rot, rotation_degrees.y)) < turn_speed * t_delta:
		# prevent overshooting goal angle
		rotation_degrees.y = goal_rot
	else:
		#calc which direction to turn
		var right = global_transform.basis.x
		var turn_dir = 1
		if right.dot(to_target) < 0:
			turn_dir = -1
		rotation_degrees.y += turn_speed * turn_dir * t_delta

func angle_difference(from, to):
    return fposmod(to - from + 180,  180 * 2) - 180


