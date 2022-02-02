extends Node

# The following constants hold the IDs of the purple block tile, named "barrier" below, and the 
# and collision we'll replace it with.
# The IDs are generated by the GroundTiles' TileSet resource, and they depend on the order in which you created 
# the tiles, starting with `0` for the first tile.
const BARRIER_ID := 1
const INVISIBLE_BARRIER_ID := 2

# The GroundTiles node is the tilemap that holds our floor, where we want to replace
# the purple blocks with invisible barriers.
onready var _ground := $GameWorld/GroundTiles

func _ready() -> void:
	# Get an array of all tile coordinates that use the purple barrier block.
	var barriers: Array = _ground.get_used_cells_by_id(BARRIER_ID)
	
	# Iterate over each of those cells and replace them with the invisible barrier.
	for cellv in barriers:
		_ground.set_cellv(cellv, INVISIBLE_BARRIER_ID)
