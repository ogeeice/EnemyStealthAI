extends KinematicBody

onready var Ball = get_node("Body").get_surface_material(0)

export var gravity = 30.0
var DIRECTION = Vector3()
var velocity = Vector3.ZERO
var snap = Vector3.DOWN

var jump_count = 0
export var jump_height = 20
export var extra_jumps = 1

export var CAMERA_PATH : NodePath
var CAMERA : Camera

var Walking = false
var CURRENT_SPEED = 10

export var ANGULAR_ACCELERATION = 10
onready var BODY = get_node("Body")

func _ready():
	CAMERA = get_node(CAMERA_PATH)

func _process(delta):
	WalK(delta)
	Jump()
	if DIRECTION:
		BODY.rotation.y = lerp_angle(BODY.rotation.y, atan2(DIRECTION.x,DIRECTION.z),delta * ANGULAR_ACCELERATION)

func WalK(delta):
	DIRECTION = Vector3.ZERO
	DIRECTION.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	DIRECTION.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	DIRECTION = DIRECTION.rotated(Vector3.UP,$Head.rotation.y).normalized()
	
	velocity.x = DIRECTION.x * CURRENT_SPEED
	velocity.z = DIRECTION.z * CURRENT_SPEED
	velocity.y -= gravity * delta
	
	var just_landed = is_on_floor() and snap == Vector3.ZERO
	if is_on_floor():
		jump_count = 0
	elif just_landed:
		snap = Vector3.DOWN
	velocity = move_and_slide_with_snap(velocity,snap,Vector3.UP,true)

func Jump():
	if Input.is_action_just_pressed("jump") && jump_count < extra_jumps:
		velocity.y = jump_height
		jump_count += 1
		snap = Vector3.ZERO
