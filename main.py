"""Community Pulse: a small Qt Quick (QML) app with a Python backend.

Run it with:  python main.py
"""
import json
import sys
from pathlib import Path

from PySide6.QtCore import QObject, Property, Signal, Slot
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, QmlElement

# These two names register our Python class as a QML module.
# In Main.qml we write `import Community` to use it.
QML_IMPORT_NAME = "Community"
QML_IMPORT_MAJOR_VERSION = 1

HERE = Path(__file__).resolve().parent


@QmlElement
class CommunityStats(QObject):
    """Loads community program data and exposes it to the QML UI."""

    # One signal tells QML "something changed, re-read the properties".
    changed = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        data = json.loads((HERE / "community.json").read_text(encoding="utf-8"))
        self._programs = data["programs"]
        self._region = "All"

    # ---- helpers (plain Python, not visible to QML) ----

    def _visible(self):
        if self._region == "All":
            return self._programs
        return [p for p in self._programs if p["region"] == self._region]

    def _sum(self, key):
        return sum(p[key] for p in self._visible())

    # ---- properties QML can read ----

    @Property("QVariantList", constant=True)
    def regions(self):
        return ["All"] + sorted({p["region"] for p in self._programs})

    def _get_region(self):
        return self._region

    def _set_region(self, value):
        if value != self._region:
            self._region = value
            self.changed.emit()

    # Read AND write: QML sets this when you pick a region.
    region = Property(str, _get_region, _set_region, notify=changed)

    @Property("QVariantList", notify=changed)
    def programs(self):
        return self._visible()

    @Property(int, notify=changed)
    def newDevelopers(self):
        return self._sum("newDevs")

    @Property(int, notify=changed)
    def returningDevelopers(self):
        return self._sum("returning")

    @Property(float, notify=changed)
    def retentionRate(self):
        new = self._sum("newDevs")
        return self._sum("returning") / new if new else 0.0

    # ---- a method QML can call ----

    @Slot(str, str)
    def addProgram(self, name, region):
        name = name.strip()
        if not name:
            return
        self._programs.append(
            {"name": name, "region": region, "channel": "New",
             "newDevs": 0, "returning": 0}
        )
        self.changed.emit()


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    engine.load(str(HERE / "Main.qml"))
    if not engine.rootObjects():
        sys.exit(1)
    sys.exit(app.exec())
