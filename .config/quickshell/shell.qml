import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Layouts

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Bottom

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    mask: Region {
        item: clockContainer
    }

    property string bgColor: "#121415"
    property string textColor: "#bde0f0"

    function updateTime() {
        var date = new Date()
        hoursText.text = Qt.formatTime(date, "hh")
        minsText.text = Qt.formatTime(date, "mm")
    }

    Component.onCompleted: updateTime()

    Process {
        id: colorReader
        running: true
        command: ["sh", "-c", "
            extract() { 
                sleep 0.3
                bg=$(grep -E '^\\s*background\\s*=' /home/jay/.config/hypr/scheme/current.lua 2>/dev/null | cut -d'\"' -f2)
                fg=$(grep -E '^\\s*primary\\s*=' /home/jay/.config/hypr/scheme/current.lua 2>/dev/null | cut -d'\"' -f2)
                raw_res=$(hyprctl monitors -j 2>/dev/null | jq -r '.[0] | \"\\((.width / .scale) | round) \\((.height / .scale) | round)\"' 2>/dev/null)
                if [ -z \"$raw_res\" ] || [ \"$raw_res\" = \"null null\" ]; then res=\"1600 1000\"; else res=\"$raw_res\"; fi
                coords=$(python3 /home/jay/.config/quickshell/auto_position.py $res 2>/dev/null)
                echo \"$bg $fg $coords\"
            }
            extract
            while true; do
                inotifywait -e close_write,moved_to,create,modify -q --format '%f' /home/jay/.config/hypr/scheme/ /home/jay/.local/state/caelestia/wallpaper/ 2>/dev/null | while read -r file; do
                    if [ \"$file\" = \"current.lua\" ] || [ \"$file\" = \"path.txt\" ]; then extract; fi
                done
                sleep 0.5
            done
        "]

        stdout: SplitParser {
            onRead: function(data) {
                var parts = data.trim().split(" ")
                if (parts.length >= 4) {
                    var bg = parts[0].trim().replace(/^#/, "")
                    var fg = parts[1].trim().replace(/^#/, "")
                    var x = parseInt(parts[2])
                    var y = parseInt(parts[3])

                    if (bg.length === 6) bgColor = "#" + bg
                    if (fg.length === 6) textColor = "#" + fg

                    if (!isNaN(x) && !isNaN(y)) {
                        clockContainer.x = x
                        clockContainer.y = y
                    }

                    console.log("Update: BG=" + bgColor + " FG=" + textColor + " Pos=" + x + "," + y)
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.updateTime()
    }

    Item {
        id: clockContainer
        width: 300
        height: 300
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        Behavior on x {
            enabled: !dragArea.pressed
            NumberAnimation { duration: 3000; easing.type: Easing.InOutQuart }
        }
        Behavior on y {
            enabled: !dragArea.pressed
            NumberAnimation { duration: 3000; easing.type: Easing.InOutQuart }
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            drag.target: parent
            cursorShape: Qt.OpenHandCursor
            drag.minimumX: 50
            drag.maximumX: root.width - parent.width - 50
            drag.minimumY: 50
            drag.maximumY: root.height - parent.height - 50
            onPressed: cursorShape = Qt.ClosedHandCursor
            onReleased: cursorShape = Qt.OpenHandCursor
        }

        // --- ENHANCED BLOB ---
        Item {
            id: blob
            anchors.centerIn: parent
            width: clockContainer.width * 0.9
            height: width

            // Background soft glow
            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 0.8
                height: width
                radius: width / 2
                color: bgColor
                opacity: 0.3
                scale: 1.1
            }

            Repeater {
                model: 3 
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    
                    // Gradient for depth
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.lighter(bgColor, 1.1) }
                        GradientStop { position: 1.0; color: bgColor }
                    }

                    radius: width * (0.45 + index * 0.02)
                    rotation: index * 45 + timeRotation 
                    opacity: 0.75 - (index * 0.15)

                    property real timeRotation: 0

                    NumberAnimation on rotation {
                        from: index * 45
                        to: index * 45 + 360
                        duration: 10000 + (index * 5000)
                        loops: Animation.Infinite
                        running: true
                    }

                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        running: true
                        NumberAnimation { to: 0.93; duration: 2500 + (index * 700); easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.07; duration: 2500 + (index * 700); easing.type: Easing.InOutSine }
                    }
                }
            }
        }

        // --- CLOCK TEXT ---
        ColumnLayout {
            anchors.centerIn: parent
            spacing: -10

            Text {
                id: hoursText
                text: ""
                color: textColor
                font.pixelSize: 80
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                
                // Subtle text styling
                style: Text.Outline
                styleColor: Qt.rgba(0,0,0,0.15)
            }

            Text {
                id: minsText
                text: ""
                color: textColor
                font.pixelSize: 80
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                opacity: 0.95
                
                style: Text.Outline
                styleColor: Qt.rgba(0,0,0,0.15)
            }
        }
    }
}


 
