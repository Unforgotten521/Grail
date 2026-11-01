class_name CombatStats
extends Node

signal hp_changed(current: int, max_hp: int)
signal block_changed(amount: int)
signal died

@export var max_hp: int = 100
var current_hp: int
var block: int = 0

func _ready() -> void:
    current_hp = max_hp
    hp_changed.emit(current_hp, max_hp)

func take_damage(amount: int) -> int:
    var actual_damage = amount
    if block > 0:
        if block >= amount:
            block -= amount
            actual_damage = 0
        else:
            actual_damage -= block
            block = 0
        block_changed.emit(block)
    
    current_hp = max(0, current_hp - actual_damage)
    hp_changed.emit(current_hp, max_hp)
    
    if current_hp <= 0:
        died.emit()
    
    return actual_damage

func add_block(amount: int) -> void:
    block += amount
    block_changed.emit(block)

func reset_block() -> void:
    block = 0
    block_changed.emit(block)
