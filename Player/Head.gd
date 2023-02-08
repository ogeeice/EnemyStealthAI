extends SpringArm

export var mouse_sensitivity = 0.05

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x,-90,90)
		
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
#		rotation_degrees.y  = wrapf(rotation_degrees.y, 0.0, 360.0)
