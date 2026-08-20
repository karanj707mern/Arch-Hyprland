import "root:/modules/common"
import "root:/modules/common/widgets"
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property string icon: "api"
    property string text: ""
    property string tooltipText: ""
    implicitHeight: rowLayout.implicitHeight + 8
    implicitWidth: rowLayout.implicitWidth + 8

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 4

        MaterialSymbol {
            text: root.icon
            iconSize: Appearance.font.pixelSize.textBase
            color: Appearance.colors.colSubtext
        }
        StyledText {
            font.pixelSize: Appearance.font.pixelSize.textSmall
            text: root.text
            color: Appearance.colors.colSubtext
            animateChange: true
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.tooltipText.length > 0

        StyledToolTip {
            text: root.tooltipText
            extraVisibleCondition: false
            alternativeVisibleCondition: parent.containsMouse
        }
    }
}
