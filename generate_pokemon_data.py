#!/usr/bin/env python3
"""
Script to generate Pokemon data for the Godot project.
This script reads the JSON data files and generates the Pokemons variable
in the correct format for pokemon_data.gd
"""

import json
import os
import random
from typing import Dict, List, Any

# Type mapping from JSON to Godot enum
TYPE_MAPPING = {
    "Normal": "TYPES.NORMAL",
    "Fire": "TYPES.FIRE", 
    "Water": "TYPES.WATER",
    "Electric": "TYPES.ELECTRIC",
    "Grass": "TYPES.GRASS",
    "Ice": "TYPES.ICE",
    "Fighting": "TYPES.FIGHTING",
    "Poison": "TYPES.POISON",
    "Ground": "TYPES.GROUND",
    "Flying": "TYPES.FLYING",
    "Psychic": "TYPES.PSYCHIC",
    "Bug": "TYPES.BUG",
    "Rock": "TYPES.ROCK",
    "Ghost": "TYPES.GHOST",
    "Dragon": "TYPES.DRAGON",
    "Dark": "TYPES.DARK",
    "Steel": "TYPES.STEEL"
}

def load_json_file(filepath: str) -> Any:
    """Load and parse a JSON file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)

def get_moves_by_type(moves_data: List[Dict]) -> Dict[str, List[Dict]]:
    """Group moves by their type."""
    moves_by_type = {}
    for move in moves_data:
        move_type = move.get("type", "Normal")
        if move_type not in moves_by_type:
            moves_by_type[move_type] = []
        moves_by_type[move_type].append(move)
    return moves_by_type

def get_pokemon_moves(pokemon_data: Dict, moves_by_type: Dict[str, List[Dict]]) -> List[str]:
    """Get 10 moves for a Pokemon: 5 of their own type and 5 compatible moves."""
    pokemon_moves = []
    
    # Get the Pokemon's primary type
    primary_type = pokemon_data["type"][0] if pokemon_data["type"] else "Normal"
    
    # Filter out moves with None values for power or accuracy
    def is_valid_move(move):
        return (move.get("power") is not None and 
                move.get("accuracy") is not None and
                move.get("ename") is not None)
    
    # Get moves of the same type
    type_moves = [move for move in moves_by_type.get(primary_type, []) if is_valid_move(move)]
    
    # Get Normal type moves as fallback
    normal_moves = [move for move in moves_by_type.get("Normal", []) if is_valid_move(move)]
    
    # Define compatible move types for each Pokemon type
    compatible_types = {
        "Normal": ["Fighting", "Flying", "Ground", "Rock", "Steel"],
        "Fire": ["Fighting", "Ground", "Rock", "Steel"],
        "Water": ["Ground", "Rock", "Steel"],
        "Electric": ["Flying", "Ground", "Rock", "Steel"],
        "Grass": ["Fighting", "Ground", "Rock"],
        "Ice": ["Flying", "Ground", "Rock", "Steel"],
        "Fighting": ["Normal", "Rock", "Steel", "Ice", "Dark"],
        "Poison": ["Grass", "Fairy"],
        "Ground": ["Fire", "Electric", "Poison", "Rock", "Steel"],
        "Flying": ["Grass", "Fighting", "Bug"],
        "Psychic": ["Fighting", "Poison"],
        "Bug": ["Grass", "Psychic", "Dark"],
        "Rock": ["Fire", "Ice", "Flying", "Bug"],
        "Ghost": ["Psychic", "Ghost"],
        "Dragon": ["Dragon"],
        "Dark": ["Psychic", "Ghost"],
        "Steel": ["Ice", "Rock"]
    }
    
    # Get compatible moves
    compatible_moves = []
    compatible_type_list = compatible_types.get(primary_type, ["Normal"])
    
    for move_type in compatible_type_list:
        if move_type in moves_by_type:
            valid_moves = [move for move in moves_by_type[move_type] if is_valid_move(move)]
            compatible_moves.extend(valid_moves[:5])  # Take up to 5 moves from each compatible type
    
    # If we don't have enough compatible moves, add more Normal moves
    if len(compatible_moves) < 5:
        compatible_moves.extend(normal_moves[:10])
    
    # Select 5 moves of the same type
    if len(type_moves) >= 5:
        selected_type_moves = random.sample(type_moves, 5)
    elif len(type_moves) > 0:
        selected_type_moves = type_moves + random.sample(normal_moves, 5 - len(type_moves))
    else:
        selected_type_moves = random.sample(normal_moves, 5)
    
    # Select 5 compatible moves
    if len(compatible_moves) >= 5:
        selected_compatible_moves = random.sample(compatible_moves, 5)
    else:
        selected_compatible_moves = random.sample(normal_moves, 5)
    
    # Combine all selected moves
    all_selected_moves = selected_type_moves + selected_compatible_moves
    
    # Create move entries as array
    for move in all_selected_moves:
        move_name = move.get("ename", "Unknown")
        power = move.get("power", 40)
        accuracy = move.get("accuracy", 100)
        move_type = move.get("type", "Normal")
        godot_type = TYPE_MAPPING.get(move_type, "TYPES.NORMAL")
        
        pokemon_moves.append(f'Move.new("{move_name}", {power}, {accuracy}, {godot_type})')
    
    return pokemon_moves

def generate_pokemon_entry(pokemon_data: Dict, moves_by_type: Dict[str, List[Dict]]) -> str:
    """Generate a single Pokemon entry as a class instance."""
    pokemon_id = pokemon_data["id"]
    name = pokemon_data["name"]["english"]
    
    # Get the primary type (first type in the array)
    primary_type = pokemon_data["type"][0] if pokemon_data["type"] else "Normal"
    godot_type = TYPE_MAPPING.get(primary_type, "TYPES.NORMAL")
    
    # Get base stats
    base_stats = pokemon_data.get("base", {})
    hp = base_stats.get("HP", 50)
    attack = base_stats.get("Attack", 50)
    defense = base_stats.get("Defense", 50)
    speed = base_stats.get("Speed", 50)
    
    # Get moves for this Pokemon
    moves = get_pokemon_moves(pokemon_data, moves_by_type)
    
    # Generate the moves array string
    moves_str = "["
    for i, move_str in enumerate(moves):
        moves_str += f"\n\t\t\t{move_str},"
    moves_str += "\n\t\t]"
    
    # Generate the entry as a Pokemon class instance (without texture parameter)
    entry = f"""\t{pokemon_id}: Pokemon.new({pokemon_id}, "{name}", {godot_type}, {hp}, {attack}, {defense}, {speed}, {moves_str}),"""
    
    return entry

def generate_pokemon_data():
    """Generate the complete Pokemons dictionary."""
    # Load data files
    pokedex_data = load_json_file("data/pokedex.json")
    moves_data = load_json_file("data/moves.json")
    
    # Group moves by type
    moves_by_type = get_moves_by_type(moves_data)
    
    # Set random seed for reproducible results
    random.seed(42)
    
    # Generate entries for all Pokemon (limit to first 251 for Gen 2)
    pokemon_entries = []
    for pokemon in pokedex_data[:251]:  # First 251 Pokemon (Gen 2)
        entry = generate_pokemon_entry(pokemon, moves_by_type)
        pokemon_entries.append(entry)
    
    # Create the complete Pokemons dictionary
    pokemons_dict = "var Pokemons = {\n"
    pokemons_dict += "\n".join(pokemon_entries)
    pokemons_dict += "\n}"
    
    return pokemons_dict

def update_pokemon_data_gd():
    """Update the pokemon_data.gd file with the generated Pokemons variable."""
    # Read the current file
    with open("scripts/pokemon_data.gd", "r", encoding="utf-8") as f:
        content = f.read()
    
    # Generate new Pokemons data
    new_pokemons_data = generate_pokemon_data()
    
    # Find the current Pokemons variable and replace it
    # Look for the start of the Pokemons variable
    start_marker = "var Pokemons = {"
    end_marker = "}"
    
    start_pos = content.find(start_marker)
    if start_pos == -1:
        print("Could not find Pokemons variable in the file")
        return
    
    # Find the end of the current Pokemons variable
    brace_count = 0
    end_pos = start_pos
    for i in range(start_pos, len(content)):
        if content[i] == '{':
            brace_count += 1
        elif content[i] == '}':
            brace_count -= 1
            if brace_count == 0:
                end_pos = i + 1
                break
    
    # Replace the Pokemons variable
    new_content = content[:start_pos] + new_pokemons_data + content[end_pos:]
    
    # Write the updated content back to the file
    with open("scripts/pokemon_data.gd", "w", encoding="utf-8") as f:
        f.write(new_content)
    
    print("Successfully updated pokemon_data.gd with generated Pokemon data!")

if __name__ == "__main__":
    print("Generating Pokemon data...")
    update_pokemon_data_gd()
    print("Done!") 