import "root:/modules/common"
import "root:/modules/common/widgets"
import QtQuick

RippleButton {
    id: button
    property string buttonText
    property real buttonRadius: down ? Appearance.rounding.verysmall : Appearance.rounding.small

    implicitWidth: contentItem.implicitWidth + 16
    implicitHeight: contentItem.implicitHeight + 12

    colBackground: Appearance.colors.colLayer2
    colBackgroundHover: Appearance.colors.colLayer2Hover
    colBackgroundActive: Appearance.colors.colLayer2Active

    contentItem: StyledText {
        horizontalAlignment: Text.AlignHCenter
        text: buttonText
        font.pixelSize: Appearance.font.pixelSize.textSmall
        color: Appearance.m3colors.m3onSurface
    }
}
