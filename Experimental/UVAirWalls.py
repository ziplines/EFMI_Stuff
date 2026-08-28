import bpy

obj = bpy.context.active_object
mesh = obj.data
uv_layer = mesh.uv_layers.active.data
tri_uv = [(0, 0), (1, 0), (0, 1)]

for poly in mesh.polygons:
    for i, loop_index in enumerate(poly.loop_indices):
        uv_layer[loop_index].uv = tri_uv[i % 3]