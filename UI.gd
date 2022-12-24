extends Control

func _ready ():
	Signals.score_updated.connect(func (score):
		$Label.text = "Score: " + str(score)	
	)
