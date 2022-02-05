## Holds references to entities in the world, and a series of paths that go from power sources
## to power receivers. Every system tick, it sends power from the sources to the
## receivers in order.
class_name PowerSystem
extends Reference

## Holds a set of power source components keyed by their map position. We keep
## track of components to create "paths" that go from source to receiver,
## which informs the system update loop to notify those components of power flow.
var power_sources := {}

## Holds a set of power receiver components keyed by their map position.
## Same purpose as power sources, we use them to create paths between source and
## receiver used in the update loop.
var power_receivers := {}

## Holds a set of entities that transmit power, like wires, keyed by their map
## position. Used exclusively to create a path from a source to receiver(s).
var power_movers := {}

## An array of 'power paths'. Those arrays are map positions with [0] being
## the location of a power source and the rest being receivers.
## We use these power paths in the update loop to calculate the amount of power
## in any given path (which has one source and one or more receivers) and inform
## the source and receivers of the final number.
var paths := []

## The cells that are already verified while building a power path. This
## allows us to skip revisiting cells that are already in the list so we
## only travel outwards.
var cells_travelled := []

## We use this set to keep track of how much power each receiver has already gotten.
## If you have two power sources with `10` units of power each feeding a machine
## that takes `20`, then each will provide `10` over both paths.
var receivers_already_provided := {}

func _init() -> void:
	Events.connect("entity_placed", self, "_on_entity_placed")
	Events.connect("entity_removed", self, "_on_entity_removed")
	Events.connect("systems_ticked", self, "_on_systems_ticked")

func _get_power_source_from(entity: Node) -> PowerSource:
	for child in entity.get_children():
		if child is PowerSource:
			return child
	return null

## Searches for a PowerReceiver component in the entity's children. Returns null
## if missing.
func _get_power_receiver_from(entity: Node) -> PowerReceiver:
	for child in entity.get_children():
		if child is PowerSource:
			return child
	return null

## Detects when the simulation places a new entity and puts its location in the respective
## dictionary if it's part of the powers groups. Triggers an update of power paths.
func _on_entity_placed(entity: Entity, cellv: Vector2) -> void:
	# A running tally of if we should update paths. If the new entity
	# is in none of the power groups, we don't need to update anything, so false
	# is the default.
	var retrace := false

	# Check if the entity is in the power sources or receivers groups.
	# Get its component using a helper function and trigger a power path update.
	if entity.is_in_group(Types.POWER_SOURCES):
		power_sources[cellv] = _get_power_source_from(entity)
		retrace = true

	if entity.is_in_group(Types.POWER_RECEIVERS):
		power_receivers[cellv] = _get_power_receiver_from(entity)
		retrace = true

	# If a power mover, store the entity and trigger a power path update.
	if entity.is_in_group(Types.POWER_MOVERS):
		power_movers[cellv] = entity
		retrace = true

	# Update the power paths only if necessary.
	if retrace:
		_retrace_paths()

func _on_entity_removed(_entity, cellv: Vector2) -> void:
	var retrace := power_sources.erase(cellv)
	retrace = power_receivers.erase(cellv) or retrace
	retrace = power_movers.erase(cellv) or retrace

	if retrace:
		_retrace_paths()

func _retrace_paths() -> void:
	pass
