import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property int radius: 16
    property color color: Qt.rgba(1.0, 1.0, 1.0, 0.1)
    property color borderColor: Qt.rgba(1.0, 1.0, 1.0, 0.3)
    property int blurRadius: 32

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: "transparent"
        radius: root.radius
    }

    ShaderEffectSource {
        id: blurSource
        sourceItem: parent.parent // Grab background behind this item
        sourceRect: Qt.rect(root.x, root.y, root.width, root.height)
        anchors.fill: parent
        visible: false
    }

    FastBlur {
        id: blurEffect
        anchors.fill: parent
        source: blurSource
        radius: root.blurRadius
        transparentBorder: false
        visible: false
    }

    OpacityMask {
        anchors.fill: parent
        source: blurEffect
        maskSource: backgroundRect
    }

    // Semi-transparent overlay with subtle light border and inner glow
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.color
        border.color: root.borderColor
        border.width: 1
    }

    // Outer subtle shadow to create a suspension feel
    DropShadow {
        anchors.fill: parent
        source: backgroundRect
        radius: 12
        samples: 25
        color: Qt.rgba(0, 0, 0, 0.05)
        verticalOffset: 4
        transparentBorder: true
    }
}
