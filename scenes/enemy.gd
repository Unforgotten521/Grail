class_name Enemy
extends Node

signal intention_changed(text: String)

@export var enemy_name: String = "Манекен"
@export var base_damage: int = 8

var current_intention: String = ""
var rng = RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()
    _choose_intention()

func _choose_intention() -> void:
    var roll = rng.randi_range(0, 2)
    match roll:
        0:
            current_intention = "Атака: %d" % base_damage
        1:
            current_intention = "Сильная атака: %d" % (base_damage + 3)
        2:
            current_intention = "Пропуск хода"
    intention_changed.emit(current_intention)

func execute_intention(player_stats: CombatStats) -> String:
    # Защита от вызова хода после смерти врага.
    for child in get_children():
        if child is CombatStats and child.current_hp <= 0:
            return "%s не может ходить: враг повержен." % enemy_name

    if player_stats == null or player_stats.current_hp <= 0:
        return "%s не может атаковать." % enemy_name

    var result = ""
    if current_intention.begins_with("Атака"):
        var damage = base_damage
        if current_intention.contains("Сильная"):
            damage = base_damage + 3
        player_stats.take_damage(damage)
        result = "%s атакует на %d урона!" % [enemy_name, damage]
    else:
        result = "%s пропускает ход" % enemy_name
    _choose_intention()
    return result
