## Blueprint for a wire. Provides functions and data to calculate the sprite's region to use
## depending on where the player places the wire and whether there are wires and machines
## in adjacent cells.
class_name WireBlueprint
extends BlueprintEntity

## Constant dictionary that holds the sprite region information for the wire's spritesheet.
## The numbers used as keys represent combinations of the direction values we
## wrote in `Types.Directions`.
## Note how some of them repeat: `LEFT`, `RIGHT`, and `LEFT+RIGHT` are all the same region.
## This keeps the helper functions below input safe. In case the user ever passes in a
## single direction, Godot will not crash because of a missing dictionary key.
## All 15 possible numbers have a corresponding sprite region we've chosen.
const DIRECTIONS_DATA := {
	# The `Rect2` values below correspond to different wire sprites in our `tileset.svg` sprite sheet.
	# each sprite fits in a `100` by `100` pixels square.
	# Also, I separated them from other cells by `10` pixels, and there's a `10`
	# pixels margin from the edge of the texture.
	# That's why the width and height of the rectangles below are always `100`, but their start
	# position is a multiple of 110 + 10.
	1: Rect2(120, 10, 100, 100),
	4: Rect2(120, 10, 100, 100),
	5: Rect2(120, 10, 100, 100),
	2: Rect2(230, 10, 100, 100),
	8: Rect2(230, 10, 100, 100),
	10: Rect2(230, 10, 100, 100),
	15: Rect2(340, 10, 100, 100),
	6: Rect2(450, 10, 100, 100),
	12: Rect2(560, 10, 100, 100),
	3: Rect2(670, 10, 100, 100),
	9: Rect2(780, 10, 100, 100),
	7: Rect2(890, 10, 100, 100),
	14: Rect2(10, 120, 100, 100),
	13: Rect2(120, 120, 100, 100),
	11: Rect2(230, 120, 100, 100)
}

onready var sprite := $Sprite

static func set_sprite_for_direction(sprite: Sprite, directions: int) -> void:
	sprite.region_rect = get_region_for_direction(directions)

static func get_region_for_direction(directions: int) -> Rect2:
	if not DIRECTIONS_DATA.has(directions):
		directions = 10
	return DIRECTIONS_DATA[directions]
