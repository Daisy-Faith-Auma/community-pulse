# Community Pulse

A small Qt Quick (QML) desktop app with a Python backend, built with PySide6. It shows developer community KPIs for a set of community programs: new developers, developers who returned after 30 days, and 30-day retention.

The data in `community.json` is sample data for a demo.

## What it shows

- **QML front end, Python back end.** The UI is declared in `Main.qml`; the data and logic live in `main.py`.
- **Exposing a Python class to QML** with `@QmlElement`, imported in QML as `import Community`.
- **Properties and signals.** Picking a region sets a Python property, which emits a signal, and the KPI cards update through QML bindings.
- **Slots.** The "Add program" button calls a Python method directly from QML.

## Run it

Requires Python 3.9 or later.

```bash
python3 -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install pyside6
python main.py
```

## Files

| File | Purpose |
|---|---|
| `main.py` | Python backend: loads data, exposes properties, signals and slots to QML |
| `Main.qml` | Qt Quick UI: KPI cards, region filter, program list, add-program form |
| `community.json` | Sample community program data |

## Built with

- [Qt for Python (PySide6)](https://doc.qt.io/qtforpython-6/)
- Qt Quick / QML
- AI-assisted development with Claude