extends KinematicBody2D

const RUNNING_SPEED = 60
const DASH_SPEED = RUNNING_SPEED * 4
const GRAVITY = 10
const JUMP_POWER = -250
const FLOOR = Vector2(0, -1);
const FIREBALL = preload("res://Fireball.tscn")

var speed = RUNNING_SPEED
var velocity = Vector2()
var is_on_ground = false
var is_on_wall = false
var is_attacking = false
var is_running = false
var is_dash_on_cooldown = false
var is_dashing = false

func get_sprite_direction():
	if sign($Position2D.position.x) == -1:
		return "left"
	if sign($Position2D.position.x) == 1:
		return "right"

func run(direction):
	if is_attacking == false || is_on_ground == false:
		velocity.x = -speed if direction == "left" else speed
		if is_attacking == false && is_dashing == false:
			is_running = true
			$AnimatedSprite.play("run")
			$AnimatedSprite.flip_h = true if direction == "left" else false
			if get_sprite_direction() == "left" && direction == "right":
				$Position2D.position.x *= -1
			if get_sprite_direction() == "right" && direction == "left":
				$Position2D.position.x *= -1
								
func attack():
	if is_on_ground:
		velocity.x = 0
	is_attacking = true
	$AnimatedSprite.play("attack")
	var fireball = FIREBALL.instance()
	var direction = sign($Position2D.position.x)
	fireball.set_fireball_direction(direction)
	get_parent().add_child(fireball)
	fireball.position = $Position2D.global_position

func idle():
	velocity.x = 0
	is_running = false
	if is_on_ground && is_attacking == false:
		$AnimatedSprite.play("idle")

func jump():
	if is_attacking == false && is_on_ground:
		velocity.y = JUMP_POWER
		is_on_ground = false

func _physics_process(delta):
	if Input.is_action_pressed("ui_right"):
		run("right")
	elif Input.is_action_pressed("ui_left"):
		run("left")
	else:
		idle()
		
	if Input.is_action_pressed("ui_up"):
		jump()
		
	if Input.is_action_just_pressed("ui_accept"):
		if is_attacking == false:
			attack()
		
	if Input.is_action_just_pressed("ui_shift"):
		if is_attacking == false && is_running == true:
			if is_dash_on_cooldown == false:
				dash()
	
	update_player_status()
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, FLOOR)

func update_player_status():
	if is_on_floor():
		if is_on_ground == false:
			is_attacking = false
		is_on_ground = true
		is_on_wall = false
	else:
		if is_attacking == false && is_dashing == false:
			is_on_ground = false
			if velocity.y < 0:
				$AnimatedSprite.play("jump")
				is_on_wall = false
			else:
				$AnimatedSprite.play("fall")

func _on_AnimatedSprite_animation_finished():
	is_attacking = false

func dash():
	is_dashing = true
	speed = DASH_SPEED
	$AnimatedSprite.play("dash")
	is_dash_on_cooldown = true
	$DashDuration.start()

func _on_DashDuration_timeout():
	speed = RUNNING_SPEED
	is_dashing = false
	$DashCooldown.start()

func _on_DashCooldown_timeout():
	is_dash_on_cooldown = false
