class_name TrackingSanity
extends RefCounted

## Detects a 3-DoF headset that should be 6-DoF.
##
## Monado built without the Lighthouse drivers silently runs a Vive in 3-DoF:
## rotation works, translation is frozen. For bronchoscopy that is not a minor
## degradation — depth judgement comes from head translation and stereo, and a
## trainee cannot tell whether they are 20 cm or 60 cm from the carina.
##
## The check is deliberately crude: over a few seconds of use, a real 6-DoF
## session produces both head rotation and head translation. Rotation without
## translation is the signature of a 3-DoF pose.

const MIN_ROTATION_DEG := 15.0   ## must turn the head at least this much
const MIN_POSITION_MM := 20.0    ## and move it at least this much for 6-DoF


## Classify a session from observed head motion spans.
##
## Returns one of: "insufficient_motion", "3dof_suspected", "6dof_ok".
static func classify(position_span_mm: float, rotation_span_deg: float) -> String:
	if rotation_span_deg < MIN_ROTATION_DEG:
		return "insufficient_motion"
	if position_span_mm < MIN_POSITION_MM:
		return "3dof_suspected"
	return "6dof_ok"


## Human-readable consequence for the debrief / console.
static func advice(verdict: String) -> String:
	match verdict:
		"3dof_suspected":
			return ("Head tracking looks 3-DoF: rotation works but position does not change. "
				+ "Rebuild Monado with XRT_BUILD_DRIVER_SURVIVE or "
				+ "XRT_BUILD_DRIVER_STEAMVR_LIGHTHOUSE, or start SteamVR instead. "
				+ "Depth judgement is unreliable like this.")
		"insufficient_motion":
			return "Could not judge tracking: move and look around for a few seconds."
		_:
			return "Head tracking is 6-DoF."
