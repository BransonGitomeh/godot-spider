extends KinematicBody

# uses code from Jayanam
# https://www.youtube.com/watch?v=kc-zJnRvPUY

export var movedir = Vector3(0, 0, 0)
var velocity = Vector3()
export var gravity = -35
var camera
var character

export var size_scale = 1

export var SPEED =2
export var ACCELERATION = 1
export var DECELERATION = 4
export var JUMP_HEIGHT = 10

var is_moving = true

var can_jump = false

var right = false
var left = false
var up = false
var down = false


func _ready():
	# $direction.text = "waiting for you to touch a side"
	character = get_node(".")


func _physics_process(delta):
	camera = get_node("target/Camera").get_global_transform()
	get_node("target/Camera").player = self

	loop_controls()

	movedir.y = 0
	movedir = movedir.normalized()

	velocity.y += delta * gravity

	# horizontal velocity
	var hv = velocity
	hv.y = 0

	var new_pos = movedir * SPEED
	var accel = DECELERATION

	if movedir.dot(hv) > 0:
		accel = ACCELERATION

	hv = hv.linear_interpolate(new_pos, accel * delta)

	velocity.x = hv.x
	velocity.z = hv.z

	velocity = move_and_slide(velocity, Vector3(0, 1, 0))

	if is_moving && ! Input.is_key_pressed(KEY_SHIFT):
		var angle = atan2(hv.x, hv.z)
		var char_rot = get_rotation()
		char_rot.y = angle
		set_rotation(char_rot)

	if Input.is_action_pressed('ui_accept'):
		print("jump")
		velocity.y = JUMP_HEIGHT


	# jump
	if is_on_floor():
		can_jump = true
	else:
		if can_jump && ! $Ground.is_colliding() && is_moving:
			velocity.y = JUMP_HEIGHT
			can_jump = false

	if Input.is_action_pressed("ui_up"):
		up = true
	if Input.is_action_just_released("ui_up"):
		up = false

	if Input.is_action_pressed("ui_down"):
		down = true
	if Input.is_action_just_released("ui_down"):
		down = false


	if Input.is_action_pressed("ui_right"):
		right = true
	if Input.is_action_just_released("ui_right"):
		right = false


	if Input.is_action_pressed("ui_left"):
		left = true
	if Input.is_action_just_released("ui_left"):
		left = false


func loop_controls():
	movedir = Vector3(0, 0, 0)

	is_moving = false

	if is_on_wall():
		return

	if up:
		movedir += -camera.basis[2]
		is_moving = true
	if down:
		movedir += camera.basis[2]
		is_moving = true
	if left:
		movedir += -camera.basis[0]
		is_moving = true
	if right:
		movedir += camera.basis[0]
		is_moving = true


func _on_right_pressed():
	right = true
	$direction.text = "right touched"

func _on_right_released():
	right = false
	$direction.text = "right released"

func _on_left_pressed():
	left = true
	$direction.text = "left touched"

func _on_left_released():
	left = false
	$direction.text = "left released"

func _on_top_pressed():
	up = true
	$direction.text = "top touched"

func _on_top_released():
	up = false
	$direction.text = "top released"

func _on_bottom_pressed():
	down = true
	$direction.text = "bottom touched"

func _on_bottom_released():
	down = false
	$direction.text = "bottom released"
