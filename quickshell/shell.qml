import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    property color colBg0: "#1E2020"  
    property color colBg1: "#333535"  
    property color colBg2: "#464848"  
    property color colBg3: "#5C5E5E"  
    property color colFg: "#EAEBEB"  
    property color colFgD: "#919393"  
    property color colGray: "#7A7C7C"  
    property color colBorder: "#333535"
    property string fontFamily: "GeistMono Nerd Font Propo"
    property int fontSize: 14

    property int cpuUsage: 0
    property int memUsage: 0

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 30
    color: root.colBg0

    // Force a title check on every major Hyprland event
    Connections {
        target: Hyprland
        function onActiveToplevelChanged() { updateTitle() }
        function onFocusedWorkspaceChanged() { updateTitle() }
    }

    // Safety timer to clear titles when moving to empty workspaces
    Timer {
        interval: 300
        running: true
        repeat: true
        onTriggered: updateTitle()
    }

    function updateTitle() {
        const top = Hyprland.activeToplevel;
        const currentWs = Hyprland.focusedWorkspace?.id;
        
        // Ensure the window exists, has a title, and belongs to the visible workspace
        if (top && top.title && top.workspace && top.workspace.id === currentWs) {
            titleLabel.text = top.title;
        } else {
            titleLabel.text = "Welcome! /home/JustZiad";
        }
    }

    // Using a simple Item + Anchors instead of RowLayout for the center title
    // helps prevent the title from "shifting" when the left/right items change size.
    Item {
        anchors.fill: parent

        // --- Left Side: Workspaces ---
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            Repeater {
                model: 10
                delegate: Text {
                    property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                    property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                    text: index + 1
                    color: isActive ? root.colFg : (ws ? root.colFgD : root.colBg3)
                    font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("workspace " + (index + 1))
                    }
                }
            }
        }

        // --- Center: Window Title ---
        Text {
            id: titleLabel
            anchors.centerIn: parent // This forces absolute centering regardless of other items
            text: "Welcome! /home/JustZiad"
            color: root.colFg
            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
            
            width: parent.width * 0.4 // Restrict width so it doesn't overlap stats
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }

        // --- Right Side: Stats & Clock ---
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Text {
                text: "CPU: " + cpuUsage + "%"
                color: root.colGray
                font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("exec [float; size 900 600; center] ghostty -e btop")
                }
            }

            Rectangle { width: 1; height: 14; color: root.colBorder; anchors.verticalCenter: parent.verticalCenter }

            Text {
                text: "Mem: " + memUsage + "%"
                color: root.colBg2
                font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("exec [float; size 900 600; center] ghostty -e htop")
                }
            }

            Rectangle { width: 1; height: 14; color: root.colBorder; anchors.verticalCenter: parent.verticalCenter }

            Text {
                id: clock
                color: root.colBg3
                font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
                
                Timer {
                    interval: 1000; running: true; repeat: true
                    onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
                }
            }
        }
    }

    Component.onCompleted: updateTitle()
}
