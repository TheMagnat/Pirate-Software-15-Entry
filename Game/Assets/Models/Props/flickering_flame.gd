extends OmniLight3D

@export var noise: NoiseTexture3D
var t := 0.0
var max_energy := 0.017
var min_energy := 0.005

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta
	
	var sampled_noise = noise.noise.get_noise_1d(t)
	sampled_noise = abs(sampled_noise)
	
	light_energy = (sampled_noise * (max_energy - min_energy)) + min_energy 
	t += (sampled_noise + 1 ) * 0.5 * delta
	pass
