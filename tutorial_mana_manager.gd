extends Node

# チュートリアル専用の簡易マナ管理。
# 本物の mana_manager.gd は BattleManager 等チュートリアルに無いノードに依存しているため使わず、
# slot.gd の place() が読み書きする player_mana / max_mana だけを持たせた最小版。

var player_mana := 0
var max_mana := 3
var enemy_mana := 0
