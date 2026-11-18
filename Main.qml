import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Community   // our Python class, registered in main.py

ApplicationWindow {
    id: window
    width: 780
    height: 600
    visible: true
    color: "white"
    title: "Community Pulse"

    // The Python backend object
    CommunityStats { id: stats }

    // A reusable KPI card: defined once, used three times below
    component KpiCard: Rectangle {
        id: card
        property string label
        property string value
        property color accent: "#41cd52"

        Layout.fillWidth: true
        implicitHeight: 90
        radius: 10
        color: "#f4f6f8"
        border.color: card.accent
        border.width: 2

        Column {
            anchors.centerIn: parent
            spacing: 4
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: card.value
                font.pixelSize: 28
                font.bold: true
                color: "#1d1d1d"
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: card.label
                color: "#555555"
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Header with region filter
        RowLayout {
            Layout.fillWidth: true
            Label {
                text: "Community Pulse"
                font.pixelSize: 26
                font.bold: true
                color: "#1d1d1d"
                Layout.fillWidth: true
            }
            Label { text: "Region:"; color: "#1d1d1d" }
            ComboBox {
                model: stats.regions
                onActivated: stats.region = currentText   // calls the Python setter
            }
        }

        // KPI cards: these update automatically when the region changes
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            KpiCard {
                label: "New developers"
                value: String(stats.newDevelopers)
            }
            KpiCard {
                label: "Returned after 30 days"
                value: String(stats.returningDevelopers)
            }
            KpiCard {
                label: "30-day retention"
                value: Math.round(stats.retentionRate * 100) + "%"
                accent: stats.retentionRate >= 0.4 ? "#41cd52" : "#e8a33d"
            }
        }

        Label {
            text: "Programs"
            font.pixelSize: 18
            font.bold: true
            color: "#1d1d1d"
        }

        // List of programs from Python
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 6
            model: stats.programs

            delegate: Rectangle {
                required property var modelData
                width: ListView.view.width
                height: 48
                radius: 6
                color: "#f4f6f8"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    Label {
                        text: modelData.name
                        font.bold: true
                        color: "#1d1d1d"
                        Layout.fillWidth: true
                    }
                    Label {
                        text: modelData.region + " · " + modelData.channel
                        color: "#555555"
                    }
                    Label {
                        text: modelData.returning + " / " + modelData.newDevs + " returned"
                        color: "#555555"
                        horizontalAlignment: Text.AlignRight
                        Layout.preferredWidth: 140
                    }
                }
            }
        }

        // Add a program: QML calls a Python method
        RowLayout {
            Layout.fillWidth: true
            TextField {
                id: nameField
                placeholderText: "New program, e.g. Python meetup"
                Layout.fillWidth: true
            }
            ComboBox {
                id: regionField
                model: stats.regions.slice(1)   // all regions except "All"
            }
            Button {
                text: "Add program"
                onClicked: {
                    stats.addProgram(nameField.text, regionField.currentText)
                    nameField.clear()
                }
            }
        }
    }
}
