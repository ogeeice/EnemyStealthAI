extends KinematicBody


onready var Agent = get_node("Agent")
onready var Player = get_node("/root/Test/Player")
onready var Anim = get_node("Base/AnimationPlayer")
onready var PLastSpottedLoc = get_node("LastSpottedLoc")

export var Target_Path : NodePath
var Target
var TargetID

var STATE = PATROL

var DIRECTION = Vector3()

var SPEED

export var PatrolSpeed = 100.0
export var SearchSpeed = 100.0
export var FollowSpeed = 100.0

export var Attack_Distance = 10

enum {
	IDLE,
	PATROL,
	MOVE,
	SEARCH,
	FOLLOW,
	ATTACK,
	DEAD
}

enum AI_Detection {
	Not_Spotted,
	Spotted,
	Searching
}

export(AI_Detection) var DetctionState = AI_Detection.Not_Spotted


func _ready():
	Target = get_node(Target_Path).get_children()
	PatrolDirections()
	randomize()
	PLastSpottedLoc.set_as_toplevel(true)

func _process(delta):
	match STATE:
		IDLE:
			DIRECTION = Vector3(0,0,0)
			pass
		PATROL:
			SPEED = PatrolSpeed
			PatrolDirections()
			STATE = MOVE
			pass
		MOVE:
			move()
			pass
		SEARCH:
			SPEED = SearchSpeed
			Search()
			STATE = MOVE
			pass
		FOLLOW:
			SPEED = FollowSpeed
			FollowDirection()
			move()
			pass
		ATTACK:
			DIRECTION = Vector3(0,0,0)
			pass
		DEAD:
			dead()
			pass
	
	
	if STATE != ATTACK:
		if DIRECTION == Vector3.ZERO:
			Anim.play("RifleIdle(1)")
		else:
			if STATE != FOLLOW:
				Anim.play("WalkWithRifle",0.1,1)
			else:
				Anim.play("RifleRun",0.1,1)
	else:
		Anim.play("FiringRifle",0.1,1)
	
	Direction_Look()
	
	if STATE != ATTACK:
		DIRECTION = move_and_slide(DIRECTION * SPEED * delta,Vector3.UP)

func PatrolDirections():
	TargetID = randi()% Target.size()
	Agent.set_target_location(Target[TargetID].transform.origin)

func Search():
	Agent.set_target_location(PLastSpottedLoc.transform.origin)

func FollowDirection():
	var Dist2Player = self.translation.distance_to(Player.translation)
	
	if DetctionState == AI_Detection.Spotted:
		if Dist2Player >= Attack_Distance:
			Agent.set_target_location(Player.transform.origin)
		else:
			STATE = ATTACK

func Direction_Look():
	if DetctionState == AI_Detection.Not_Spotted:
		self.look_at(Target[TargetID].transform.origin,Vector3.UP)
	elif DetctionState == AI_Detection.Spotted:
		self.look_at(Player.transform.origin,Vector3.UP)
	else:
		self.look_at(PLastSpottedLoc.transform.origin,Vector3.UP)
	
	self.rotation_degrees.z = 0
	self.rotation_degrees.x = 0

func move():
	var next = Agent.get_next_location()
	DIRECTION = (next - self.transform.origin).normalized()

func dead():
	set_process(false)
	set_physics_process(false)

func _on_ResetSTATE_timeout():
	if STATE == IDLE:
		$TimerHolder/ResetSTATE.wait_time = rand_range(8.0,24.0)
		STATE = PATROL

func _on_Agent_navigation_finished():
	STATE = IDLE
	if DetctionState == AI_Detection.Searching:
		DetctionState = AI_Detection.Not_Spotted

func _on_AI_Vision_Scan_timeout():
	var overlaps = $AI_Fov.get_overlapping_bodies()
	if overlaps.size() > 0:
		for i in overlaps:
			if i.is_in_group("player"):
				var PlayerPos = i.global_transform.origin
				$AI_Vision.look_at(PlayerPos,Vector3.UP)
				$AI_Vision.force_raycast_update()
				
				if $AI_Vision.is_colliding():
					var collider = $AI_Vision.get_collider()
					
					if collider.is_in_group("player"):
						DetctionState = AI_Detection.Spotted
						STATE = FOLLOW
					else:
						DetctionState = AI_Detection.Searching
						$TimerHolder/AlarmedTimer.start()

func _on_AlarmedTimer_timeout():
	PLastSpottedLoc.transform = Player.transform
	STATE = SEARCH


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FiringRifle":
		var Dist2Player = self.translation.distance_to(Player.translation)
		if Dist2Player >= Attack_Distance:
			if DetctionState == AI_Detection.Spotted:
				STATE = FOLLOW
			else:
				STATE = ATTACK
