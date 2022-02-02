class_name Entity
extends Node2D

## Specifies the object type that is allowed to deconstruct this entity.
## Deconstructing means harvesting a resource or turning an entity in the world into an item.
## For example, the player must hold an Axe to chop down a tree,
## so we'll store that requirement as a text string here.
export var deconstruct_filter: String

## Specifies number of entities to create when deconstructing the object.
## For example, a tree could drop 5 logs. In that case, we'd set the `pickup_count` to `5` in the Inspector.
export var pickup_count := 1

## Any initialization step occurs in this override-able `_setup()` function. Overriding it
## is optional, but if the entity requires information from the blueprint,
## such as the direction of power, this is where we will code provide this information.
## We haven't created the blueprint's type yet, so for now we leave it out. We'll code a `BlueprintEntity` type in a moment.
func _setup(_blueprint) -> void:
	pass
