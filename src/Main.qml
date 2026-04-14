import QtQuick
import QtQuick.Window

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("ImageComparator")

    Text {
        anchors.centerIn: parent
        text: qsTr("Hello ImageComparator")
    }
}
