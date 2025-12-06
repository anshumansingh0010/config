import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Layouts

PanelWindow {
    id: root

    // Set to Bottom layer (Wallpaper-like behavior)
    WlrLayershell.layer: WlrLayer.Bottom
    
    // Fill the screen so we can center the clock content easily
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    // Mask Region follows the clock container
    // This allows clicks to pass through everywhere EXCEPT the clock itself
    mask: Region {
        item: clockContainer
    }

    // Dynamic Colors extracted from config
    property string bgColor: "#1e0f0f" // Default fallback (Background)
    property string textColor: "#ffffff" // Default fallback (Primary)

    Process {
        id: colorReader
        // Run immediately and stay running
        running: true 
        
        // Complex command to:
        // 1. Define extractor function to print "BG FG X Y"
        // 2. Watch directory
        command: ["sh", "-c", "
            extract() { 
                bg=$(grep '^\\$background =' /home/jay/.config/hypr/scheme/current.conf | cut -d'=' -f2 | tr -d ' ')
                fg=$(grep '^\\$primary =' /home/jay/.config/hypr/scheme/current.conf | cut -d'=' -f2 | tr -d ' ')
                res=$(hyprctl monitors -j | jq -r '.[0] | \"\\(.width) \\(.height)\"')
                coords=$(python3 /home/jay/tmptasks/experiment/newsomething/auto_position.py $res)
                echo \"$bg $fg $coords\"
            }
            extract
            inotifywait -m -e close_write -q --format '%f' /home/jay/.config/hypr/scheme/ | while read -r file; do
                if [ \"$file\" = \"current.conf\" ]; then extract; fi
            done
        "]
        
        stdout: SplitParser {
            onRead: function(data) {
                var parts = data.trim().split(" ")
                if (parts.length >= 4) {
                    var bg = parts[0].trim()
                    var fg = parts[1].trim()
                    var x = parseInt(parts[2])
                    var y = parseInt(parts[3])
                    
                    if (bg.length === 6) bgColor = "#" + bg
                    if (fg.length === 6) textColor = "#" + fg
                    
                    // Update position automatically
                    if (!isNaN(x) && !isNaN(y)) {
                        clockContainer.x = x
                        clockContainer.y = y
                    }
                    
                    console.log("Update: BG=" + bgColor + " FG=" + textColor + " Pos=" + x + "," + y)
                }
            }
        }
    }

    // Timer to update time
    Timer {
        interval: 1000 // Seconds precision is enough now
        running: true
        repeat: true
        onTriggered: {
            var date = new Date()
            hoursText.text = Qt.formatTime(date, "hh")
            minsText.text = Qt.formatTime(date, "mm")
        }
    }

    Item {
        id: clockContainer
        width: 300
        height: 300
        
        // Initial Position: Center of screen
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        // Smooth transition when position changes (e.g. from Python script)
        // Disabled during dragging so it follows mouse instantly
        Behavior on x { 
            enabled: !dragArea.pressed
            NumberAnimation { duration: 3000; easing.type: Easing.InOutQuart } 
        }
        Behavior on y { 
            enabled: !dragArea.pressed
            NumberAnimation { duration: 3000; easing.type: Easing.InOutQuart } 
        }

        // Drag Handler
        MouseArea {
            id: dragArea
            anchors.fill: parent
            drag.target: parent
            cursorShape: Qt.OpenHandCursor
            
            // Keep in frame with 50px padding
            drag.minimumX: 50
            drag.maximumX: root.width - parent.width - 50
            drag.minimumY: 50
            drag.maximumY: root.height - parent.height - 50
            
            onPressed: cursorShape = Qt.ClosedHandCursor
            onReleased: cursorShape = Qt.OpenHandCursor
        }

        // Background radial rings - REMOVED

        // Organic Material-You Blob (Simulated with QML Shapes)
        Item {
            id: blob
            anchors.centerIn: parent
            width: clockContainer.width * 0.9 
            height: width

            // Stack multiple rotated rectangles to make a "star/blob" shape
            // Animate them to "breath" and rotate slowly for organic feel
            Repeater {
                model: 3
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    color: bgColor
                    radius: width * 0.4 // Soft organic corners
                    rotation: index * 30 + timeRotation 
                    opacity: 0.9

                    property real timeRotation: 0
                    
                    // Wobble animation
                    NumberAnimation on rotation {
                        from: index * 30 - 10
                        to: index * 30 + 10
                        duration: 3000 + (index * 1000)
                        loops: Animation.Infinite
                        easing.type: Easing.InOutSine
                        running: true
                    }
                    
                    // Breathing animation (scale)
                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        running: true
                        NumberAnimation { to: 0.95; duration: 2000 + (index * 500); easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 1.05; duration: 2000 + (index * 500); easing.type: Easing.InOutQuad }
                    }
                }
            }
        }
        
        // Clock Content (Text on top of the blob)
        ColumnLayout {
            anchors.centerIn: parent
            spacing: -10

            // HOURS
            Text {
                id: hoursText
                text: "12"
                color: textColor 
                font.pixelSize: 80
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            // MINS
            Text {
                id: minsText
                text: "00"
                color: textColor 
                font.pixelSize: 80
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

}
