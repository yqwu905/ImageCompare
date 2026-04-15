import QtQuick
import QtQuick.Effects

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
        visible: false
    }

    ShaderEffectSource {
        id: blurSource
        sourceItem: parent.parent // Grab background behind this item
        sourceRect: Qt.rect(root.x, root.y, root.width, root.height)
        anchors.fill: parent
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: blurSource
        maskEnabled: true
        maskSource: backgroundRect
        blurEnabled: true
        blurMax: 64
        blur: root.blurRadius / 64.0
    }

    // Semi-transparent overlay with subtle light border and inner glow
    Rectangle {
        id: overlayRect
        anchors.fill: parent
        radius: root.radius
        color: root.color
        border.color: root.borderColor
        border.width: 1
    }

    // Outer subtle shadow to create a suspension feel
    MultiEffect {
        anchors.fill: parent
        source: backgroundRect
        shadowEnabled: true
        shadowBlur: 1.0
        shadowColor: Qt.rgba(0, 0, 0, 0.05)
        shadowVerticalOffset: 4
        shadowHorizontalOffset: 0
    }
}
