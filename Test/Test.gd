extends Spatial

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		OS.window_fullscreen = !OS.window_fullscreen
