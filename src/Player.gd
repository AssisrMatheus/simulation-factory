extends KinematicBody2D

## Movement speed in pixels per second
export var movement_speed := 200.0

func _physics_process(_delta: float) -> void:
	# We move the player at a constant speed based on the input direction.
	# The `_get_direction()` function calculates the move direction based on the player's input.
	var direction := _get_direction()
	move_and_slide(direction * movement_speed)

## Returns a normalized direction vector based on the current input actions that are pressed.
func _get_direction() -> Vector2:
	return Vector2(
		# As we're using an isometric view, with a 2:1 ratio, we have to double the horizontal input for horizontal movement to feel consistent.
		Input.get_action_strength("right") - Input.get_action_strength("left") * 2.0,
		Input.get_action_strength("down") - Input.get_action_strength("up")
	# We then normalize the vector to ensure it has a length of 1, making it a direction vector.
	).normalized()
