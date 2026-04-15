import QtQuick

Item {
    id: control
    property string textContent: ""
    property bool down: mouseArea.pressed
    property bool hovered: mouseArea.containsMouse

    width: 80
    height: 32

    GlassCard {
        anchors.fill: parent
        radius: 8
        color: control.down ? Qt.rgba(1.0, 1.0, 1.0, 0.25) :
               control.hovered ? Qt.rgba(1.0, 1.0, 1.0, 0.15) :
               Qt.rgba(1.0, 1.0, 1.0, 0.08)
        borderColor: control.hovered ? Qt.rgba(1.0, 1.0, 1.0, 0.5) : Qt.rgba(1.0, 1.0, 1.0, 0.3)
        blurRadius: 16

        Behavior on color {
            ColorAnimation { duration: 200; easing.type: Easing.OutQuad }
        }
        Behavior on borderColor {
            ColorAnimation { duration: 200; easing.type: Easing.OutQuad }
        }
    }

    Text {
        anchors.centerIn: parent
        text: control.textContent
        font.pixelSize: 14
        opacity: enabled ? 1.0 : 0.3
        color: "#1A1A1A"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    scale: control.down ? 0.98 : 1.0
    Behavior on scale {
        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
    }
}
