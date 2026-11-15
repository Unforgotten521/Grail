extends Control

@onready var ui: BattleUI = $BattleUI

var deck_manager: DeckManager
var player_stats: CombatStats
var enemy_stats: CombatStats
var enemy: Enemy
var is_player_turn: bool = true
var victory_text := "Победа! Противник повержен!"

func _ready() -> void:
    _setup_combat()
    _connect_signals()
    ui.update_energy(deck_manager.energy, deck_manager.max_energy)
    ui.update_log("Бой начался! Ваш ход.")

func _setup_combat() -> void:
    player_stats = CombatStats.new()
    player_stats.max_hp = 50
    add_child(player_stats)

    var encounter := _get_encounter()
    enemy = Enemy.new()
    enemy.enemy_name = encounter.name
    enemy.base_damage = encounter.damage
    enemy.enemy_type = encounter.type
    add_child(enemy)

    enemy_stats = CombatStats.new()
    enemy_stats.max_hp = encounter.hp
    enemy.add_child(enemy_stats)
    victory_text = "Победа! %s повержен!" % enemy.enemy_name

    deck_manager = DeckManager.new()
    add_child(deck_manager)
    deck_manager.setup(ui.get_hand_container(), player_stats, enemy_stats, ui.update_log)
    ui.set_deck_manager(deck_manager)
    ui.player_stats = player_stats
    ui.enemy_stats = enemy_stats
    ui.enemy = enemy
    ui.update_player_hp(player_stats.current_hp, player_stats.max_hp)
    ui.update_enemy_hp(enemy_stats.current_hp, enemy_stats.max_hp)

func _get_encounter() -> Dictionary:
    var node_index: int = GameData.current_map_node
    if node_index < 0 or node_index >= GameData.map_nodes.size():
        return {"name":"Манекен", "type":"training", "hp":30, "damage":0}
    var node: Dictionary = GameData.map_nodes[node_index]
    var row := int(node.get("row", 0))
    var kind := str(node.get("kind", "battle"))
    # Первая точка всегда остаётся учебным боем с манекеном.
    if row == 0:
        return {"name":"Манекен", "type":"training", "hp":30, "damage":0}
    if kind == "elite":
        return {"name":"Падший рыцарь", "type":"elite", "hp":72, "damage":9}
    if kind == "boss":
        return {"name":"Древний демон", "type":"boss", "hp":120, "damage":11}
    var pool: Array[Dictionary] = [
        {"name":"Скелет-воин", "type":"guard", "hp":38, "damage":7},
        {"name":"Пепельный гончий", "type":"heavy", "hp":34, "damage":9},
        {"name":"Болотный мародёр", "type":"guard", "hp":44, "damage":6}
    ]
    var seed: int = absi(node_index * 17 + row * 31)
    return pool[seed % pool.size()]

func _connect_signals() -> void:
    ui.back_pressed.connect(_on_back_pressed)
    ui.end_turn_pressed.connect(_on_end_turn_pressed)
    deck_manager.energy_changed.connect(ui.update_energy)
    player_stats.hp_changed.connect(ui.update_player_hp)
    player_stats.block_changed.connect(func(_b): ui.update_player_hp(player_stats.current_hp, player_stats.max_hp))
    enemy_stats.hp_changed.connect(ui.update_enemy_hp)
    enemy_stats.block_changed.connect(func(_b): ui.update_enemy_hp(enemy_stats.current_hp, enemy_stats.max_hp))
    enemy_stats.died.connect(_on_enemy_died)
    player_stats.died.connect(_on_player_died)
    enemy.intention_changed.connect(ui.update_intention)

func _on_end_turn_pressed() -> void:
    if not is_player_turn:
        return
    is_player_turn = false
    ui.set_end_turn_enabled(false)
    deck_manager.end_turn()
    player_stats.reset_block()
    await get_tree().create_timer(0.6).timeout
    if enemy_stats.current_hp > 0 and player_stats.current_hp > 0:
        ui.update_log(enemy.execute_intention(player_stats))
    await get_tree().create_timer(0.6).timeout
    if player_stats.current_hp > 0 and enemy_stats.current_hp > 0:
        deck_manager.start_player_turn()
        is_player_turn = true
        ui.set_end_turn_enabled(true)
        ui.update_log("Ваш ход! Энергия: %d/%d." % [deck_manager.energy, deck_manager.max_energy])

func _on_back_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_enemy_died() -> void:
    ui.update_log(victory_text)
    ui.set_end_turn_enabled(false)
    await get_tree().create_timer(1.2).timeout
    get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_player_died() -> void:
    ui.update_log("Поражение...")
    ui.set_end_turn_enabled(false)
