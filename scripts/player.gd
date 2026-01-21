extends CharacterBody2D

var radius = 4
var color = Color.DODGER_BLUE
var speed: float = 40

var acceleration = 240
var friction = 280

var aim_deadzone = 0.18
var aim_smoothness = 20
var aim_angle = 0

var is_vis = false

var fire_rate = 0.15
var fire_timer = 0

var aim_line_length = 20

@export var paintball_scene : PackedScene

@onready var aim_cont = $aim_container


func _physics_process(delta):
	var aim = get_aim_vector()
	
	if aim != Vector2.ZERO:
		var target_angle = aim.angle()
		aim_angle = lerp_angle(
			aim_angle,
			target_angle,
			1 - exp(-aim_smoothness * delta)
		)
		is_vis = true
	else:
		if velocity != Vector2.ZERO: 
			aim = velocity
			var target_angle = aim.angle()
			aim_angle = lerp_angle(
				aim_angle,
				target_angle,
				1 - exp(-aim_smoothness * delta)
			)
			is_vis = false
			
	update_aim()
	
	aim_cont.rotation = aim_angle
	
	#var aim_direction = Vector2(
		#Input.get_action_strength("right_aim") - Input.get_action_strength("left_aim"),
		#Input.get_action_strength("down_aim") - Input.get_action_strength("up_aim")
	#)
	#
	#if aim_direction.length() > 0.15:
		#aim_cont.rotation = aim_direction.angle()
	#
	var input = get_stick_vector()
	var target_velocity = input * speed
	
	if input != Vector2.ZERO:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
		
	fire_timer -= delta
	
	if Input.is_action_pressed("fire") and fire_timer <= 0:
		fire()
		fire_timer = fire_rate
	
	print(velocity)
	move_and_slide()
	
	
func _draw():
	draw_circle(Vector2.ZERO, radius, color)

func _ready():
	$MeshInstance2D.visible = false
	queue_redraw()

func get_stick_vector() -> Vector2:
	var v = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	var deadzone := 0.12
	var len = v.length()
	
	if len < deadzone:
		return Vector2.ZERO
	
	var scaled = (len - deadzone) / (1 - deadzone)
	return v.normalized() * scaled


func get_aim_vector() -> Vector2:
	var v = Vector2(
		Input.get_action_strength("right_aim") - Input.get_action_strength("left_aim"),
		Input.get_action_strength("down_aim") - Input.get_action_strength("up_aim")
	)
	
	var len = v.length()
	if len < aim_deadzone:
		return Vector2.ZERO
	
	var scaled = (len - aim_deadzone) / (1 - aim_deadzone)
	return v.normalized() * scaled
	
	
	

func fire():
	var paintball = paintball_scene.instantiate()
	get_tree().current_scene.add_child(paintball)
	
	paintball.global_position = $aim_container/spawner.global_position
	paintball.direction = Vector2.RIGHT.rotated(aim_angle)


func update_aim():
	var line = $aim_container/Line2D
	var aim = get_aim_vector()
	
	if aim == Vector2.ZERO:
		line.visible = false
		return
	else:
		line.visible = true
	
	line.clear_points()
	
	var start = Vector2.ZERO
	var end = Vector2.RIGHT * aim_line_length
	
	line.add_point(start)
	line.add_point(end)
	
	line.gradient = Gradient.new()
	line.gradient.set_color(0, Color(1, 1, 1, 0.8))
	line.gradient.set_color(1, Color(1, 1, 1, 0))
	
	line.width_curve = Curve.new()
	line.width_curve.add_point(Vector2(0, 1))
	line.width_curve.add_point(Vector2(1, 0))
	
	line.visible = visible
	
