extends Node

var current_map_node: int = -1
var player_hp: int = 50
var max_hp: int = 50

# Состояние карты сохраняется между переходами map.tscn <-> battle.tscn.
var map_nodes: Array[Dictionary] = []
var map_connections: Array[Dictionary] = []
