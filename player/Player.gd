extends KinematicBody

export var move_accel = 4
export var drag = 0.16
export var jump_force = 20
export var gravity = 60
export var mouse_sens = 0.5

var velocity = Vector3()
var snap_vec = Vector3()

onready var camera = $Camera

signal shoot
signal moving
signal still

onready var weapon1 = $Camera/Rifle
onready var weapon2 = $Camera/Sword
var cur_weapon_is_1 = true
var cur_weapon = null

var max_lean = 1.5
var cur_lean = 0.0
var lean_rate_out = 55.0
var lean_rate_in = 15.0

func _ready():
	for boar in get_tree().get_nodes_in_group("boars"):
		boar.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cur_weapon_is_1 = false
	switch_weapons()

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= mouse_sens * event.relative.x
		camera.rotation_degrees.x -= mouse_sens * event.relative.y
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)

func _process(delta):
	if Input.is_action_pressed("exit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("shoot"):
		cur_weapon.shoot()
	
	if Input.is_action_just_pressed("switch_weapons"):
		switch_weapons()

func switch_weapons():
	cur_weapon_is_1 = !cur_weapon_is_1
	if cur_weapon_is_1:
		cur_weapon = weapon1
		weapon1.show()
		weapon2.hide()
	else:
		cur_weapon = weapon2
		weapon2.show()
		weapon1.hide()

func _physics_process(delta):
	var move_vec = Vector3()
	if Input.is_action_pressed("move_forwards"):
		move_vec += Vector3.FORWARD
	if Input.is_action_pressed("move_backwards"):
		move_vec += Vector3.BACK
	if Input.is_action_pressed("move_left"):
		move_vec += Vector3.LEFT
	if Input.is_action_pressed("move_right"):
		move_vec += Vector3.RIGHT
	
	if move_vec == Vector3():
		cur_weapon.moving = false
		cur_weapon.not_moving = true
	else:
		cur_weapon.moving = true
		cur_weapon.not_moving = false
	
	if move_vec.x != 0:
		cur_lean += lean_rate_out * delta * -sign(move_vec.x)
		cur_lean = clamp(cur_lean, -max_lean, max_lean)
	elif cur_lean != 0:
		var lean_amnt = delta * lean_rate_in
		if abs(cur_lean) < lean_amnt:
			cur_lean = 0.0
		else:
			cur_lean += -sign(cur_lean) * lean_amnt
	$Camera.rotation_degrees.z = cur_lean
		
	
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3.UP, rotation.y)	
	
	velocity += move_accel * move_vec - velocity * Vector3(drag,0,drag) + gravity * Vector3.DOWN * delta
	velocity = move_and_slide_with_snap(velocity + get_floor_velocity() , snap_vec, Vector3.UP, false, 4, PI, false)
	var grounded = is_on_floor()
	if grounded:
		velocity.y = -0.01
	if grounded and Input.is_action_just_pressed("jump"):
		velocity.y = jump_force
		snap_vec = Vector3.ZERO
	else:
		snap_vec = Vector3.DOWN