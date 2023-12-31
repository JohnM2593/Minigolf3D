extends Node3D

enum {AIM, SET_POWER, SHOOT, WIN}

@export var next_hole : PackedScene
@export var power_speed = 100
@export var angle_speed = 1.1

var angle_change = 1
var power = 0
var power_change = 1
var shots = 0
var state = AIM

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Arrow.hide()
	$Ball.position = $Tee.position
	change_state(AIM)
	$UI.show_message("Get Ready!")

func change_state(new_state):
	state = new_state
	match state:
		AIM:
			$Arrow.position = $Ball.position
			$Arrow.show()
		SET_POWER:
			power = 0
		SHOOT:
			$Arrow.hide()
			$Ball.shoot($Arrow.rotation.y, power / 15)
			shots += 1
			$UI.update_shots(shots)
		WIN:
			$Ball.hide()
			$Arrow.hide()
			print()
			await get_tree().create_timer(1).timeout
			if next_hole:
				get_tree().change_scene_to_packed(next_hole)


func _input(event):

	if event.is_action_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event.is_action_pressed("click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			return
		match state:
			AIM:
				change_state(SET_POWER)
			SET_POWER:
				change_state(SHOOT)

func _process(delta):
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
	
	match state:
		AIM:
			animate_arrow(delta)
		SET_POWER:
			animate_power(delta)
		SHOOT:
			pass
			
	if state != WIN:
		$CameraGimbal.position = $Ball.position

func animate_arrow(delta):
	$Arrow.rotation.y += angle_speed * angle_change * delta
	if $Arrow.rotation.y > PI / 2:
		angle_change = -1
	if $Arrow.rotation.y < -PI / 2:
		angle_change = 1

func animate_power(delta):
	power += power_speed * power_change * delta
	if power >= 100:
		power_change = -1
	if power <= 0:
		power_change = 1
	$UI.update_power_bar(power)

func _on_hole_body_entered(body):
	if body.name == "Ball":
		print("win!")
		change_state(WIN)

func _on_ball_stopped():
	if state == SHOOT:
		change_state(AIM)
