class_name LeverMapper
extends RefCounted

## Normalises a physical deflection lever into the −1 … +1 the endoscope expects.
##
## The printed prop reports an absolute lever angle as a HID joystick axis. Real
## bronchoscope levers have a soft centre and hard stops, and cheap encoders
## rarely land exactly at 0, so a deadzone plus optional inversion and a response
## curve are needed before the value is usable.

var deadzone := 0.03      ## fraction of full travel ignored around centre
var invert := false       ## flip direction to match the scope's convention
var expo := 1.0           ## >1 softens small movements, <1 sharpens them


## Map a raw axis value (−1 … +1, or any range) to a cleaned lever command.
func map_axis(raw: float) -> float:
	var value := clampf(raw, -1.0, 1.0)
	if invert:
		value = -value
	if absf(value) <= deadzone:
		return 0.0
	# rescale so the deadzone edge becomes 0 and full travel stays 1
	var magnitude := (absf(value) - deadzone) / maxf(1.0 - deadzone, 0.0001)
	magnitude = clampf(magnitude, 0.0, 1.0)
	if not is_equal_approx(expo, 1.0):
		magnitude = pow(magnitude, expo)
	return signf(value) * magnitude


## Map a raw 12-bit encoder angle using a calibration captured from the prop.
func map_angle(angle: int, centre: int, half_span: int) -> float:
	if half_span <= 0:
		return 0.0
	return map_axis(float(angle - centre) / float(half_span))
