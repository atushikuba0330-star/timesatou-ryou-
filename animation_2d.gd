extends Node2D

func play_effect(anim_name: String):

	$AnimationPlayer.play(anim_name)

	await $AnimationPlayer.animation_finished

	queue_free()
