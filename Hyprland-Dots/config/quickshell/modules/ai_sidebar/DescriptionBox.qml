import "root:/modules/common"
import "root:/modules/common/widgets"
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property alias text: tagDescriptionText.text
    property bool showArrows: true
    property bool showTab: true

    visible: tagDescriptionText.text.length > 0
    Layout.fillWidth: true
    implicitHeight: tagDescriptionBackground.implicitHeight

    Rectangle {
        id: tagDescriptionBackground
        color: Appearance.colors.colLayer2
        anchors.fill: parent
        radius: Appearance.rounding.verysmall
        implicitHeight: descriptionRow.implicitHeight + 10

        RowLayout {
            id: descriptionRow
            spacing: 4
            anchors {
                fill: parent
                leftMargin: 10
                rightMargin: 10
            }

        StyledText {
            id: tagDescriptionText
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.textSmall
            color: Appearance.colors.colOnLayer2
            wrapMode: Text.Wrap
        }
        StyledText {
            visible: root.showArrows
            text: "↑↓"
            font.pixelSize: Appearance.font.pixelSize.textSmall
            color: Appearance.colors.colOnLayer2
        }
        StyledText {
            visible: root.showArrows && root.showTab
            text: "or"
            font.pixelSize: Appearance.font.pixelSize.textSmall
            color: Appearance.colors.colOnLayer2
        }
        StyledText {
            visible: root.showTab
            text: "Tab"
            font.pixelSize: Appearance.font.pixelSize.textSmall
            color: Appearance.colors.colOnLayer2
        }
        }
    }
}
