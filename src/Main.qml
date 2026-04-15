import QtQuick
import QtQuick.Window
import QtQuick.Layouts

Window {
    width: 1200
    height: 800
    visible: true
    title: qsTr("ImageComparator")

    // Light futuristic gradient background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#e0eaf5" } // Soft light blue
            GradientStop { position: 1.0; color: "#f3e7e9" } // Soft light pink/purple
        }
    }

    ListModel {
        id: folderModel
        ListElement { name: "Dataset_A" }
        ListElement { name: "Dataset_B" }
        ListElement { name: "Dataset_C" }
        ListElement { name: "Dataset_D" }
    }

    ListModel {
        id: imageModel
        ListElement { fileName: "img_001.png"; folderName: "Dataset_A" }
        ListElement { fileName: "img_002.png"; folderName: "Dataset_A" }
        ListElement { fileName: "img_003.png"; folderName: "Dataset_A" }
        ListElement { fileName: "img_004.png"; folderName: "Dataset_B" }
        ListElement { fileName: "img_005.png"; folderName: "Dataset_B" }
        ListElement { fileName: "img_006.png"; folderName: "Dataset_C" }
        ListElement { fileName: "img_007.png"; folderName: "Dataset_D" }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Left Column: File Management
        GlassCard {
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            radius: 16

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: "File Management"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#333333"
                    Layout.alignment: Qt.AlignHCenter
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    GlassButton { textContent: "Add"; Layout.fillWidth: true }
                    GlassButton { textContent: "Refresh"; Layout.fillWidth: true }
                    GlassButton { textContent: "Clear"; Layout.fillWidth: true }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: folderModel
                    clip: true
                    spacing: 8
                    delegate: GlassCard {
                        width: ListView.view.width
                        height: 40
                        radius: 8
                        color: Qt.rgba(1.0, 1.0, 1.0, 0.15)
                        Text {
                            anchors.centerIn: parent
                            text: model.name
                            color: "#333333"
                        }
                    }
                }
            }
        }

        // Middle Column: Image Browsing
        GlassCard {
            Layout.preferredWidth: 350
            Layout.fillHeight: true
            radius: 16

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: "Image Browsing"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#333333"
                    Layout.alignment: Qt.AlignHCenter
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8

                    Repeater {
                        model: Math.min(folderModel.count, 4)
                        delegate: ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 8
                            model: imageModel // Mock: normally filtered by folder

                            header: Text {
                                text: folderModel.get(index).name
                                font.pixelSize: 12
                                color: "#555"
                                bottomPadding: 8
                            }

                            delegate: GlassCard {
                                width: ListView.view.width
                                height: width
                                radius: 8
                                color: Qt.rgba(1.0, 1.0, 1.0, 0.2)
                                Text {
                                    anchors.centerIn: parent
                                    text: model.fileName
                                    font.pixelSize: 10
                                    color: "#555"
                                }
                            }
                        }
                    }
                }
            }
        }

        // Right Column: Image Comparison
        GlassCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 16

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: "Image Comparison"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#333333"
                    Layout.alignment: Qt.AlignHCenter
                }

                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: folderModel.count <= 2 ? folderModel.count : 2
                    rows: folderModel.count <= 2 ? 1 : 2
                    columnSpacing: 12
                    rowSpacing: 12

                    Repeater {
                        model: Math.min(folderModel.count, 4)
                        delegate: GlassCard {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 12
                            color: Qt.rgba(1.0, 1.0, 1.0, 0.1)

                            Text {
                                anchors.centerIn: parent
                                text: "Comparison View\n" + folderModel.get(index).name
                                horizontalAlignment: Text.AlignHCenter
                                color: "#444"
                            }
                        }
                    }
                }
            }
        }
    }
}
