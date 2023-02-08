extends KinematicBody

export var gravity = -27
var DIRECTION = Vector3()
var velocity = Vector3()

var jump_num = 0
export var extra_jump = 1
export var jump_height = 20

export var CAMERA_PATH : NodePath
var CAMERA : Camera

var Walking = false
var CURRENT_SPEED
var SPEED_CHANGE = {
	"REGULAR_SPEED" : 10,
	"WALK_SPEED" : 3
	}

var AIM = false
export var ANGULAR_ACCELERATION = 10
onready var BODY = get_node("Body")

func _input(event):
	if event.is_action_pressed("aim"):
		AIM = !AIM
	if Input.is_action_pressed("walk"):
		Walking = !Walking

func _ready():
	CAMERA = get_node(CAMERA_PATH)

func _process(delta):
	Walk()
	Walk_Logic(delta)
	Jump()
	Aim_Logic(delta)
	pass

func Walk():
	if Walking == false:
		CURRENT_SPEED = SPEED_CHANGE.REGULAR_SPEED
	else:
		CURRENT_SPEED = SPEED_CHANGE.WALK_SPEED

func Walk_Logic(delta):
	CURRENT_SPEED = SPEED_CHANGE.REGULAR_SPEED
#	CURRENT_SPEED = SPEED_CHANGE.WALK_SPEED
	
	
	DIRECTION = Vector3()
	var top = CAMERA.get_global_transform().basis
	if Input.is_action_pressed("forward"):
		DIRECTION -= top.z
	if Input.is_action_pressed("backward"):
		DIRECTION += top.z
	if Input.is_action_pressed("left"):
		DIRECTION -= top.x
	if Input.is_action_pressed("right"):
		DIRECTION += top.x
	
	DIRECTION = DIRECTION.normalized()
	velocity.y += gravity * delta
	var tv = velocity
	tv = velocity.linear_interpolate(DIRECTION * CURRENT_SPEED,6 * delta)
	velocity.x = tv.x
	velocity.z = tv.z
	velocity = move_and_slide(velocity,Vector3(0,1,0))
	
	if is_on_floor():
		jump_num = 0
	
	pass

func Aim_Logic(delta):
	if AIM == true:
		BODY.rotation.y = lerp(BODY.rotation.y, $Head.rotation.y,0.1)
	else:
		if DIRECTION:
			BODY.rotation.y = lerp_angle(BODY.rotation.y, atan2(DIRECTION.x,DIRECTION.z),delta * ANGULAR_ACCELERATION)
	pass

func Jump():
	if Input.is_action_just_pressed("jump") && jump_num < extra_jump:
		velocity.y = jump_height
		jump_num += 1
