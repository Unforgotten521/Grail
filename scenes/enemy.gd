class_name Enemy
extends Node

signal intention_changed(text: String)

@export var enemy_name: String = "Манекен"
@export var base_damage: int = 8
@export var enemy_type: String = "training"

var current_intention: String = ""
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()
    _choose_intention()

func _choose_intention() -> void:
    var roll := rng.randi_range(0, 99)
    match enemy_type:
        "training":
            current_intention = "Атака: %d" % base_damage if roll < 45 else "Пропуск хода"
        "guard":
            if roll < 55:
                current_intention = "Атака: %d" % base_damage
            else:
                current_intention = "Защита: 5"
        "heavy":
            current_intention = "Сильная атака: %d" % (base_damage + 4) if roll < 65 else "Атака: %d" % base_damage
        "elite":
            if roll < 45:
                current_intention = "Сильная атака: %d" % (base_damage + 5)
            elif roll < 75:
                current_intention = "Защита: 8"
            else:
                current_intention = "Атака: %d" % base_damage
        "boss":
            if roll < 50:
                current_intention = "Сильная атака: %d" % (base_damage + 6)
            elif roll < 80:
                current_intention = "Защита: 10"
            else:
                current_intention = "Атака: %d" % (base_damage + 2)
        _:
            current_intention = "Атака: %d" % base_damage
    intention_changed.emit(current_intention)

func execute_intention(player_stats: CombatStats) -> String:
    for child in get_children():
        if child is CombatStats and child.current_hp <= 0:
            return "%s не может ходить: враг повержен." % enemy_name
    if player_stats == null or player_stats.current_hp <= 0:
        return "%s не может атаковать." % enemy_name

    var result := ""
    if current_intention.begins_with("Сильная"):
        var damage := base_damage + (6 if enemy_type == "boss" else 5 if enemy_type == "elite" else 4)
        player_stats.take_damage(damage)
        result = "%s наносит мощный удар: %d урона!" % [enemy_name, damage]
    elif current_intention.begins_with("Атака"):
        var damage := base_damage + (2 if enemy_type == "boss" else 0)
        player_stats.take_damage(damage)
        result = "%s атакует на %d урона!" % [enemy_name, damage]
    elif current_intention.begins_with("Защита"):
        var amount := 10 if enemy_type == "boss" else 8 if enemy_type == "elite" else 5
        for child in get_children():
            if child is CombatStats:
                child.add_block(amount)
        result = "%s получает %d блока." % [enemy_name, amount]
    else:
        result = "%s пропускает ход." % enemy_name
    _choose_intention()
    return result
