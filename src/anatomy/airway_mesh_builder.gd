class_name AirwayMeshBuilder
extends RefCounted

## Builds the visible airway wall from the tree's centreline graph.
##
## Each centreline segment becomes a tapered tube. Tubes overlap slightly at
## joints so bifurcations read as a continuous lumen; normals point inward
## because the operator's camera is inside the airway. Building this at runtime
## keeps the repository free of large binary meshes and lets CT-derived trees
## use exactly the same renderer.

const RADIAL_SEGMENTS := 24
const SLICES_PER_SEGMENT := 4
const JOINT_OVERLAP := 0.35   ## fraction of the radius added at each end


static func build(tree: AirwayTree, material: Material = null) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	if material != null:
		st.set_material(material)

	for node in tree.nodes:
		var label := str(node.get("label", ""))
		var start := tree.start_of(label)
		var end := tree.end_of(label)
		var dir := (end - start)
		if dir.length() < 0.01:
			continue
		dir = dir.normalized()
		var radius_end := tree.radius_of(label)
		var radius_start := radius_end
		var parent := str(node.get("parent", "")) if node.get("parent") != null else ""
		if not parent.is_empty() and tree.has_label(parent):
			# Match the parent's bore exactly. A shrunken start leaves an
			# uncovered annulus at the joint, which reads as a black ring when
			# you look down the lumen.
			radius_start = tree.radius_of(parent)
		radius_start = maxf(radius_start, 0.8)
		radius_end = maxf(radius_end, 0.7)

		var overlap := minf(radius_start, radius_end) * JOINT_OVERLAP
		var a := start - dir * overlap
		var b := end + dir * overlap
		_add_tapered_tube(st, a, b, radius_start, radius_end)

	# Carinal spur: where a segment splits, its children cannot tile the parent
	# bore, so a hole remains at the junction. A sphere parked just past the
	# bifurcation fills it and reads as the carina, which is a ridge anyway.
	for node in tree.nodes:
		var label := str(node.get("label", ""))
		var children: Array = tree.child_labels.get(label, [])
		if children.size() < 2:
			continue
		var r := tree.radius_of(label)
		var dir := tree.direction_of(label)
		var centre := tree.end_of(label) + dir * r * 0.55
		_add_spur(st, centre, r * 0.97)

	var mesh := st.commit()
	return mesh


static func _add_spur(st: SurfaceTool, centre: Vector3, radius: float) -> void:
	var rings := 8
	var segments := 20
	for row in rings:
		var phi0 := PI * float(row) / float(rings)
		var phi1 := PI * float(row + 1) / float(rings)
		for col in segments:
			var theta0 := TAU * float(col) / float(segments)
			var theta1 := TAU * float(col + 1) / float(segments)
			var p00 := _sphere_point(centre, radius, phi0, theta0)
			var p01 := _sphere_point(centre, radius, phi0, theta1)
			var p10 := _sphere_point(centre, radius, phi1, theta0)
			var p11 := _sphere_point(centre, radius, phi1, theta1)
			var n00 := (p00 - centre).normalized()
			var n01 := (p01 - centre).normalized()
			var n10 := (p10 - centre).normalized()
			var n11 := (p11 - centre).normalized()
			# outward normals: the spur is seen from the parent's lumen, so it
			# must face the viewer or it reads as a black disc
			_quad(st, p00, p10, p11, p01, n00, n10, n11, n01)


static func _sphere_point(centre: Vector3, radius: float, phi: float, theta: float) -> Vector3:
	return centre + Vector3(sin(phi) * cos(theta), cos(phi), sin(phi) * sin(theta)) * radius


static func default_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.80, 0.42, 0.42)
	mat.roughness = 0.75
	mat.metallic = 0.0
	# The camera lives inside the tube, so both sides are visible.
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	return mat


static func _add_tapered_tube(st: SurfaceTool, a: Vector3, b: Vector3,
		radius_a: float, radius_b: float) -> void:
	var axis := (b - a).normalized()
	var u := axis.cross(Vector3.UP)
	if u.length_squared() < 0.001:
		u = axis.cross(Vector3.RIGHT)
	u = u.normalized()
	var v := axis.cross(u).normalized()

	var rings: Array[PackedVector3Array] = []
	var ring_normals: Array[PackedVector3Array] = []
	for slice in SLICES_PER_SEGMENT + 1:
		var t := float(slice) / float(SLICES_PER_SEGMENT)
		var center := a.lerp(b, t)
		# Slight sinusoidal bulge keeps the wall from looking machined.
		var radius := lerpf(radius_a, radius_b, t) * (1.0 + 0.04 * sin(t * PI))
		var ring := PackedVector3Array()
		var normals := PackedVector3Array()
		for k in RADIAL_SEGMENTS:
			var angle := TAU * float(k) / float(RADIAL_SEGMENTS)
			var offset := u * cos(angle) * radius + v * sin(angle) * radius
			ring.append(center + offset)
			normals.append(-offset.normalized())
		rings.append(ring)
		ring_normals.append(normals)

	for slice in SLICES_PER_SEGMENT:
		var ring_a := rings[slice]
		var ring_b := rings[slice + 1]
		var normals_a := ring_normals[slice]
		var normals_b := ring_normals[slice + 1]
		for k in RADIAL_SEGMENTS:
			var next := (k + 1) % RADIAL_SEGMENTS
			_quad(st,
				ring_a[k], ring_b[k], ring_b[next], ring_a[next],
				normals_a[k], normals_b[k], normals_b[next], normals_a[next])


static func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3,
		na: Vector3, nb: Vector3, nc: Vector3, nd: Vector3) -> void:
	_vertex(st, a, na)
	_vertex(st, b, nb)
	_vertex(st, c, nc)
	_vertex(st, a, na)
	_vertex(st, c, nc)
	_vertex(st, d, nd)


static func _vertex(st: SurfaceTool, position: Vector3, normal: Vector3) -> void:
	st.set_normal(normal)
	st.add_vertex(position)
