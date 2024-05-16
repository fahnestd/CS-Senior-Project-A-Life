extends Node

var time: float = 0.0
# Species tracking
var species_catalog = {}  # Stores each species with a unique genome as the key
var species_count = {}    # Tracks the number of individuals per species

var print_debug_messages = false

func _process(delta: float) -> void:
	time += delta
	if time >= 1.0:
		time -= 1.0
		check_for_extinct_species()

func check_for_extinct_species():
	for species_key in species_count.keys():
		if species_count[species_key] <= 0:
			if print_debug_messages:
				print("species_extinct", species_catalog[species_key])
			species_catalog.erase(species_key)
			species_count.erase(species_key)

func creature_dead(genome):
	var genome_key = str(genome)
	if print_debug_messages:
		print("Creature Dead")
		print(genome)
	if genome_key in species_catalog:
		species_count[genome_key] -= 1

func _on_genetics_track_species(genome):
	var genome_key = str(genome)  # Convert genome dict to string to use as a key
	if genome_key not in species_catalog:
		species_catalog[genome_key] = genome
		species_count[genome_key] = 1
		if print_debug_messages:
			print("species_identified", genome)
	else:
		species_count[genome_key] += 1
		if print_debug_messages:
			print("Added existing species to species count")
