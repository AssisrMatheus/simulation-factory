## The Stirling engine consumes fuel and acts as a power source.
extends Entity

## The following two constants are respectively the amount of time the tween animation takes
## to ramp up to full speed and to shutdown.
## We will use that to speed up or slow down the animation player
const BOOTUP_TIME := 6.0
const SHUTDOWN_TIME := 3.0

onready var animation_player := $AnimationPlayer
onready var tween := $Tween
onready var shaft := $PistonShaft

func _ready() -> void:
	# Play the animation, which loops.
	animation_player.play("Work")
	
	# We use a tween to control the animation player's `playback_speed`.
	# It goes up, making it feel like the engine is slowly starting up until it reaches its maximum speed.
	tween.interpolate_property(animation_player, "playback_speed", 0, 1, BOOTUP_TIME)
	
	# We also animate the color of the `shaft` to enhance the animation, going from white to green.
	tween.interpolate_property(shaft, "modulate", Color.white, Color(0.5, 1, 0.5), BOOTUP_TIME)
	tween.start()
