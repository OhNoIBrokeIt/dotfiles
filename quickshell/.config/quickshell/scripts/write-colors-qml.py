#!/usr/bin/env python3
import json
import sys
from pathlib import Path

if len(sys.argv) != 3:
    print("Usage: write-colors-qml.py <palette-json> <output-qml>")
    sys.exit(1)

palette_path = Path(sys.argv[1]).expanduser()
out_path = Path(sys.argv[2]).expanduser()

data = json.loads(palette_path.read_text())

def get(name, fallback):
    return data.get(name, fallback)

qml = f'''pragma Singleton
import QtQuick

QtObject {{
    id: root

    property color mPrimary:          "{get("mPrimary", "#83d0f4")}"
    property color mOnPrimary:        "{get("mOnPrimary", "#003546")}"
    property color mSecondary:        "{get("mSecondary", "#aecbda")}"
    property color mOnSecondary:      "{get("mOnSecondary", "#183440")}"
    property color mTertiary:         "{get("mTertiary", "#e5b6f9")}"
    property color mOnTertiary:       "{get("mOnTertiary", "#452058")}"
    property color mError:            "{get("mError", "#ffb4ab")}"
    property color mOnError:          "{get("mOnError", "#690005")}"
    property color mSurface:          "{get("mSurface", "#101416")}"
    property color mOnSurface:        "{get("mOnSurface", "#e0e3e5")}"
    property color mSurfaceVariant:   "{get("mSurfaceVariant", "#1c2022")}"
    property color mOnSurfaceVariant: "{get("mOnSurfaceVariant", "#bfc8ce")}"
    property color mOutline:          "{get("mOutline", "#3f484d")}"
    property color mShadow:           "{get("mShadow", "#000000")}"
    property color mHover:            "{get("mHover", "#2a2f33")}"
    property color mOnHover:          "{get("mOnHover", "#e0e3e5")}"

    function pillBg(alpha) {{
        return Qt.rgba(mSurface.r, mSurface.g, mSurface.b, alpha === undefined ? 0.75 : alpha)
    }}

    function hoverBg(alpha) {{
        return Qt.rgba(mSurfaceVariant.r, mSurfaceVariant.g, mSurfaceVariant.b, alpha === undefined ? 0.90 : alpha)
    }}

    function borderCol() {{
        return Qt.rgba(mOutline.r, mOutline.g, mOutline.b, 0.4)
    }}
}}
'''

out_path.write_text(qml)
print(f"Wrote {out_path}")
