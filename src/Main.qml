import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import ImageComparator 1.0

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

    FolderTreeModel {
        id: fileTreeModel
    }

    ListModel {
        id: comparisonModel
        // Dynamically populated when user right-clicks and adds to comparison
    }

    FolderDialog {
        id: folderDialog
        title: "Please choose a folder"
        onAccepted: {
            fileTreeModel.addRootPath(currentFolder)
        }
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
                    GlassButton {
                        textContent: "Add"
                        Layout.fillWidth: true
                        onClicked: folderDialog.open()
                    }
                    GlassButton {
                        textContent: "Refresh"
                        Layout.fillWidth: true
                        onClicked: fileTreeModel.refreshAllPopulated()
                    }
                    GlassButton {
                        textContent: "Clear"
                        Layout.fillWidth: true
                        onClicked: {
                            fileTreeModel.clear()
                            comparisonModel.clear()
                        }
                    }
                }

                TreeView {
                    id: fileTreeView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: fileTreeModel
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: TreeViewDelegate {
                        id: treeDelegate
                        implicitWidth: fileTreeView.width
                        implicitHeight: 40
                        indentation: 20

                        required property int row
                        required property var treeModel

                        // We use the entire row for click handling
                        contentItem: Item {
                            implicitHeight: 40

                            RowLayout {
                                anchors.fill: parent
                                spacing: 8

                                // Expansion indicator
                                Item {
                                    Layout.preferredWidth: 20
                                    Layout.preferredHeight: 20
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: model.hasChildren

                                    Text {
                                        anchors.centerIn: parent
                                        text: treeDelegate.expanded ? "▼" : "▶"
                                        color: "#666"
                                        font.pixelSize: 12
                                    }
                                }

                                // Placeholder if no children to keep alignment
                                Item {
                                    Layout.preferredWidth: 20
                                    Layout.preferredHeight: 20
                                    visible: !model.hasChildren
                                }

                                Text {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    text: model.name
                                    color: "#333333"
                                    font.pixelSize: 14
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: (mouse) => {
                                    if (mouse.button === Qt.LeftButton) {
                                        fileTreeView.toggleExpanded(row)
                                    } else if (mouse.button === Qt.RightButton) {
                                        contextMenu.popup()
                                    }
                                }
                            }

                            Menu {
                                id: contextMenu
                                MenuItem {
                                    text: "Refresh"
                                    onTriggered: {
                                        var idx = fileTreeView.index(row, 0)
                                        fileTreeModel.refreshNode(idx)
                                    }
                                }
                                MenuItem {
                                    text: "Remove"
                                    onTriggered: {
                                        var idx = fileTreeView.index(row, 0)
                                        fileTreeModel.removeNode(idx)
                                    }
                                }
                                MenuItem {
                                    text: "Add to comparison"
                                    onTriggered: {
                                        comparisonModel.append({
                                            "name": model.name,
                                            "path": model.path
                                        })
                                    }
                                }
                            }
                        }

                        background: Rectangle {
                            color: treeDelegate.hovered ? Qt.rgba(1.0, 1.0, 1.0, 0.3) : Qt.rgba(1.0, 1.0, 1.0, 0.15)
                            radius: 8
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
                        model: Math.min(comparisonModel.count, 4)
                        delegate: ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 8
                            model: imageModel // Mock: normally filtered by folder

                            header: Text {
                                text: comparisonModel.get(index).name
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
                    columns: comparisonModel.count <= 2 ? Math.max(1, comparisonModel.count) : 2
                    rows: comparisonModel.count <= 2 ? 1 : 2
                    columnSpacing: 12
                    rowSpacing: 12

                    Repeater {
                        model: Math.min(comparisonModel.count, 4)
                        delegate: GlassCard {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 12
                            color: Qt.rgba(1.0, 1.0, 1.0, 0.1)

                            Text {
                                anchors.centerIn: parent
                                text: "Comparison View\n" + comparisonModel.get(index).name
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
