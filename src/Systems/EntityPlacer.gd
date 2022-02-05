extends TileMap

## Distance from the player when the mouse stops being able to interact.
const MAXIMUM_WORK_DISTANCE := 275.0

## When using `world_to_map()` or `map_to_world()`, `TileMap` reports values from the
## top-left corner of the tile. In isometric perspective, it's the top corner
## from the middle. Since we want our entities to be in the middle of the tile,
## we must add an offset to any world position that comes from the map that is
## half the vertical height of our tiles, 25 pixels on the Y-axis here.
const POSITION_OFFSET := Vector2(0,25)

## Temporary variable to hold the active blueprint.
## For testing purposes, we hold it here until we build the inventory.
var _blueprint: BlueprintEntity

## The simulation's entity tracker. We use its functions to know if a cell is available or it
## already has an entity.
var _tracker: EntityTracker

## The ground tiles. We can check the position we're trying to put an entity down on
## to see if the mouse is over the tilemap.
var _ground: TileMap

## The player entity. We can use it to check the distance from the mouse to prevent
## the player from interacting with entities that are too far away.
var _player: KinematicBody2D

## Temporary variable to store references to entities and blueprint scenes.
## We split it in two: blueprints keyed by their names and entities keyed by their blueprints.
## See the `_ready()` function below for an example of how we map a blueprint to a scene.
## Replace the `preload()` resource paths below with the paths where you saved your scenes.
onready var Library := {
	"StirlingEngine": preload("res://Entities/Blueprints/StirlingEngineBlueprint.tscn").instance()
}

func _ready() -> void:
	# Use the existing blueprint to act as a key for the entity scene, so we can instance
	# entities given their blueprint.
	Library[Library.StirlingEngine] = preload("res://Entities/Entities/StirlingEngine/StirlingEngineEntity.tscn")

func _process(delta: float) -> void:
	var has_placeable_blueprint: bool = _blueprint and _blueprint.placeable
	
	# If we have a blueprint in hand, keep it updated and snapped to the grid
	if has_placeable_blueprint:
		_move_blueprint_in_world(world_to_map(get_global_mouse_position()))

## Since we are temporarily instancing blueprints for the library until we have
## an inventory system, we must clean up the blueprints when the object leaves the tree.
func _exit_tree() -> void:
	Library.StirlingEngine.queue_free()

## Here's our setup() function. It sets the placer up with the data that it needs to function,
## and adds any pre-placed entities to the tracker.
func setup(tracker: EntityTracker, ground: TileMap, player: KinematicBody2D) -> void:
	# We use the function to initialize our private references. As mentioned before, this approach
	# makes refactoring easier, as the EntityPlacer doesn't need hard-coded paths to the EntityTracker,
	# GroundTiles, and Player nodes.
	_tracker = tracker
	_ground = ground
	_player = player
	
	# For each child of EntityPlacer, if it extends Entity, add it to the tracker
	# and ensure its position snaps to the isometric grid.	
	for child in get_children():
		if child is Entity:
			# Get the world position of the child into map coordinates. These are
			# integer coordinates, which makes them ideal for repeatable
			# Dictionary keys, instead of the more rounding-error prone
			# decimal numbers of world coordinates.
			var map_position := world_to_map(child.global_position)
			_tracker.place_entity(child, map_position)

# Below, we start by storing the result of calculations and comparisons in variables. Doing so makes
# the code easy to read.
func _unhandled_input(event: InputEvent) -> void:
	# Get the mouse position in world coordinates relative to world entities.
	# event.global_position and event.position return mouse positions relative
	# to the screen, but we have a camera that can move around the world.
	# That's why we call `get_global_mouse_position()`
	var global_mouse_position := get_global_mouse_position()
	
	# We check whether we have a blueprint in hand and that the player can place it in the world.
	var has_placeable_blueprint: bool = _blueprint and _blueprint.placeable
	
	# We check if the mouse is close enough to the Player node.
	var is_close_to_player:= (
		global_mouse_position.distance_to(_player.global_position) < MAXIMUM_WORK_DISTANCE
	)
	
	# Here, we calculate the coordinates of the cell the mouse is hovering.
	var cellv := world_to_map(global_mouse_position)
	
	# We check whether an entity exists at that map coordinate or not, to not
	# add entities in occupied cells.
	var cell_is_occupied := _tracker.is_cell_occupied(cellv)
	
	# We check whether there is a ground tile underneath the current map coordinates.
	# We don't want to place entities out in the air.
	var is_on_ground := _ground.get_cellv(cellv) == 0
	
	# When left-clicking, we use all our boolean variables to check the player can place an entity.
	# Using variables with clear names helps to write code that reads *almost* like English.
	if event.is_action_pressed("left_click"):
		if has_placeable_blueprint:
			if not cell_is_occupied and is_close_to_player and is_on_ground:
				_place_entity(cellv)
	# If the mouse moved and we have a blueprint in hand, we update the blueprint's ghost so it
	# follows the mouse cursor.
#	elif event is InputEventMouseMotion:
#		if has_placeable_blueprint:
#			_move_blueprint_in_world(cellv)
	# When the user presses the drop button and we are holding a blueprint, we would
	# drop the entity as a dropable entity that the player can pick up.
	# For testing purposes, the following code clears the blueprint from the active slot instead.
	elif event.is_action_pressed("drop") and _blueprint:
		remove_child(_blueprint)
		_blueprint = null
	# We put our quickbar actions for testing purposes and hardcode them to specific entities.
	elif event.is_action_pressed("quickbar_1"):
		if _blueprint:
			remove_child(_blueprint)

		_blueprint = Library.StirlingEngine
		add_child(_blueprint)
		_move_blueprint_in_world(cellv)

## Places the entity corresponding to the active `_blueprint` in the world at the specified
## location, and informs the `EntityTracker`.
func _place_entity(cellv: Vector2) -> void:
	# Use the blueprint we prepared in _ready to instance a new entity.
	var new_entity: Entity = Library[_blueprint].instance()
	
	# Add it to the tilemap as a child so it gets sorted properly.
	add_child(new_entity)
	
	# Snap its position to the map, adding `POSITION_OFFSET` to get the center of the grid cell.
	new_entity.global_position = map_to_world(cellv) + POSITION_OFFSET
	
	# Call `setup()` on the entity so it can use any data the blueprint holds to configure itself.
	new_entity._setup(_blueprint)

	# Register the new entity in the `EntityTracker` so all the signals can go up, as with systems.
	_tracker.place_entity(new_entity, cellv)

## Moves the active blueprint in the world according to mouse movement,
## and tints the blueprint based on whether the tile is valid.
func _move_blueprint_in_world(cellv: Vector2) -> void:
	# Snap the blueprint's position to the mouse with an offset
	_blueprint.global_position = map_to_world(cellv) + POSITION_OFFSET
	
	# Determine each of the placeable conditions
	var is_close_to_player := (
		get_global_mouse_position().distance_to(_player.global_position) < MAXIMUM_WORK_DISTANCE
	)
	
	var is_on_ground: bool = _ground.get_cellv(cellv) == 0
	var cell_is_occupied := _tracker.is_cell_occupied(cellv)
	
	# Tint according to whether the current tile is valid or not.
	if not cell_is_occupied and is_close_to_player and is_on_ground:
		_blueprint.modulate = Color.white
	else:
		_blueprint.modulate = Color.red
