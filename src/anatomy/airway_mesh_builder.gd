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
			radius_start = tree.radius_of(parent) * 0.75
		radius_start = maxf(radius_start, 0.8)
		radius_end = maxf(radius_end, 0.7)

		var overlap := minf(radius_start, radius_end) * JOINT_OVERLAP
		var a := start - dir * overlap
		var b := end + dir * overlap
		_add_tapered_tube(st, a, b, radius_start, radius_end)

	var mesh := st.commit()
	return mesh


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
