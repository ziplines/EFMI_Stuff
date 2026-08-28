"""
Reconstructs invisible-wall geometry from World Ender air-wall-export JSON files.

Run inside Blender's Scripting tab, or headless:
    blender --background --python import_air_walls.py

Reads every file matching air-wall-export*.json in SOURCE_DIR and builds one
combined mesh. Vertices are welded by rounded position (merge-by-distance
style), so a wall re-exported from a later pass over the same area shares
verts with the earlier one -- duplicate triangles then fail to build (bmesh
raises on an exact duplicate face) and are skipped automatically. Each face
is oriented to match its exported normal.
"""

import bpy
import bmesh
import json
import glob
import os
import mathutils

# ---------------- CONFIG ----------------
SOURCE_DIR = r"C:\Users\RedCraft86\Desktop\Games\SussyBaka\EndingTheField\WorldEnder"
FILE_PATTERN = "air-wall-export*.json"

# Set True if the export is in Unity space (m, left-handed, Y-up) and you
# want it converted into Blender space (m, right-handed, Z-up). Set False if
# the JSON is already in Blender-compatible coordinates.
CONVERT_UNITY_TO_BLENDER = True
UNITY_UNIT_SCALE = 1.0  # Unity default units are meters already

# Vertices within this distance (in final Blender-space units) are welded
# into one, same idea as Blender's Merge by Distance. Bump this up if
# repeated exports produce slightly-off duplicate positions (float drift).
MERGE_DISTANCE = 0.0001

OBJECT_NAME = "AirWalls"
COLLECTION_NAME = "AirWalls"
# -----------------------------------------


def convert_point(p):
    x, y, z = p
    if CONVERT_UNITY_TO_BLENDER:
        # Unity (X, Y up, Z) -> Blender (X, Z up, -Y)
        return mathutils.Vector((x * UNITY_UNIT_SCALE, -z * UNITY_UNIT_SCALE, y * UNITY_UNIT_SCALE))
    return mathutils.Vector((x, y, z))


def convert_normal(n):
    x, y, z = n
    if CONVERT_UNITY_TO_BLENDER:
        return mathutils.Vector((x, -z, y)).normalized()
    return mathutils.Vector((x, y, z)).normalized()


def get_or_create_collection(name):
    if name in bpy.data.collections:
        return bpy.data.collections[name]
    coll = bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(coll)
    return coll


def main():
    pattern = os.path.join(SOURCE_DIR, FILE_PATTERN)
    files = sorted(glob.glob(pattern))

    if not files:
        print(f"No files matched: {pattern}")
        return

    bm = bmesh.new()
    vert_lookup = {}  # snapped-position tuple -> BMVert

    def get_vert(pos):
        key = tuple(round(c / MERGE_DISTANCE) for c in pos)  # snap to grid of MERGE_DISTANCE
        v = vert_lookup.get(key)
        if v is None:
            v = bm.verts.new(pos)
            vert_lookup[key] = v
        return v

    total_tris = 0
    built = 0
    duplicate_or_degenerate = 0

    for filepath in files:
        with open(filepath, "r") as f:
            data = json.load(f)

        triangles = data.get("triangles", [])
        print(f"Importing {os.path.basename(filepath)}: {len(triangles)} triangles "
              f"(expected {data.get('triangleCount', '?')})")
        total_tris += len(triangles)

        for tri in triangles:
            pts = [convert_point(p) for p in tri["points"]]
            verts = [get_vert(p) for p in pts]

            try:
                face = bm.faces.new(verts)
            except ValueError:
                # Degenerate triangle, or an identical face already built
                # (i.e. a duplicate wall from an earlier export pass)
                duplicate_or_degenerate += 1
                continue

            given_normal = convert_normal(tri["normal"])
            face.normal_update()
            if face.normal.dot(given_normal) < 0:
                face.normal_flip()

            built += 1

    bm.normal_update()

    mesh = bpy.data.meshes.new(OBJECT_NAME)
    bm.to_mesh(mesh)
    bm.free()

    obj = bpy.data.objects.new(OBJECT_NAME, mesh)
    collection = get_or_create_collection(COLLECTION_NAME)
    collection.objects.link(obj)

    print(f"Done. {total_tris} triangles read, {built} faces built, "
          f"{duplicate_or_degenerate} duplicate/degenerate skipped.")
    print(f"Object '{OBJECT_NAME}' added to collection '{COLLECTION_NAME}'.")


if __name__ == "__main__":
    main()
