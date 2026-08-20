import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "root:/modules/common"
import "root:/modules/common/widgets"

PanelWindow {
    id: aiSidebar
    required property var screen

    property string query: ""
    property string response: ""
    property bool loading: false
    property var history: []
    property var suggestionList: []
    property string commandPrefix: "/"

    anchors {
        top: true
        bottom: true
        left: true
        right: false
    }

    x: 0
    y: 0
    width: Appearance.sizes.sidebarWidth
    visible: GlobalStates.aiSidebarOpen

    WlrLayershell.namespace: "quickshell:ai_sidebar"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: "transparent"

    IpcHandler {
        id: ipc
        target: "ai_sidebar"

        function toggle() {
            visible = !visible
            GlobalStates.aiSidebarOpen = visible
        }

        function show() {
            visible = true
            GlobalStates.aiSidebarOpen = true
        }

        function hide() {
            visible = false
            GlobalStates.aiSidebarOpen = false
        }
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            visible = false
            GlobalStates.aiSidebarOpen = false
            event.accepted = true
        }
        if (event.modifiers === Qt.ControlModifier) {
            if (event.key === Qt.Key_O) {
                history = []
                response = ""
                query = ""
                event.accepted = true
            }
        }
    }

    StyledRectangularShadow {
        target: sidebarBackground
    }

    Rectangle {
        id: sidebarBackground
        anchors.fill: parent
        color: Appearance.colors.colLayer0
        border.width: 1
        border.color: Appearance.colors.colLayer0Border
        radius: Appearance.rounding.screenRounding

        ColumnLayout {
            anchors.fill: parent
            spacing: 4
            padding: 4

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: parent.width
                        height: parent.height
                        radius: Appearance.rounding.small
                    }
                }

                ColumnLayout {
                    id: contentColumn
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        id: statusBg
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        radius: Appearance.rounding.normal - 4
                        color: messageListView.atYBeginning ? Appearance.colors.colLayer2 : Appearance.colors.colLayer2Base
                        Behavior on color {
                            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 10

                            ApiInputBoxIndicator {
                                icon: "neurology"
                                text: "KiloCode"
                                tooltipText: "AI Assistant\nAsk anything..."
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }

                    ListView {
                        id: messageListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 10
                        topMargin: statusBg.implicitHeight + 12
                        clip: true
                        add: null

                        model: aiSidebar.history
                        delegate: Rectangle {
                            required property var modelData
                            width: parent.width
                            color: modelData.role === 'user' ? Appearance.colors.colPrimary + "33" : Appearance.colors.colSecondary + "33"
                            radius: 8
                            padding: 8

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 4

                                StyledText {
                                    text: modelData.role === 'user' ? "You" : "KiloCode"
                                    font.bold: true
                                    color: modelData.role === 'user' ? Appearance.colors.colPrimary : Appearance.colors.colSecondary
                                    font.pixelSize: Appearance.font.pixelSize.textSmall
                                }

                                StyledText {
                                    text: modelData.text
                                    wrapMode: Text.Wrap
                                    color: Appearance.m3colors.m3primaryText
                                    font.pixelSize: Appearance.font.pixelSize.textBase
                                }
                            }
                        }

                        Label {
                            visible: aiSidebar.loading
                            text: "Thinking..."
                            color: Appearance.colors.colPrimary
                            font.italic: true
                            anchors.centerIn: parent
                        }
                    }

                    DescriptionBox {
                        text: aiSidebar.suggestionList[0]?.description ?? ""
                        showArrows: aiSidebar.suggestionList.length > 1
                    }

                    Flow {
                        id: suggestions
                        Layout.fillWidth: true
                        spacing: 5
                        visible: aiSidebar.suggestionList.length > 0 && messageInputField.text.length > 0

                        Repeater {
                            model: aiSidebar.suggestionList.slice(0, 10)
                            delegate: ApiCommandButton {
                                buttonText: modelData.displayName ?? modelData.name
                                onClicked: {
                                    const words = messageInputField.text.trim().split(/\s+/)
                                    if (words.length > 0) {
                                        words[words.length - 1] = modelData.name
                                    } else {
                                        words.push(modelData.name)
                                    }
                                    messageInputField.text = words.join(" ") + " "
                                    messageInputField.cursorPosition = messageInputField.text.length
                                    messageInputField.forceActiveFocus()
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: inputWrapper
                        Layout.fillWidth: true
                        radius: Appearance.rounding.normal - 4
                        color: Appearance.colors.colLayer2
                        implicitHeight: Math.max(inputFieldRowLayout.implicitHeight + inputFieldRowLayout.anchors.topMargin + commandButtonsRow.implicitHeight + commandButtonsRow.anchors.bottomMargin + 5, 45)
                        clip: true

                        Behavior on implicitHeight {
                            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                        }

                        RowLayout {
                            id: inputFieldRowLayout
                            anchors {
                                bottom: commandButtonsRow.top
                                left: parent.left
                                right: parent.right
                                bottomMargin: 5
                            }
                            spacing: 0

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Math.min(aiSidebar.height * 3 / 5, messageInputField.height)
                                clip: true
                                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                                StyledTextArea {
                                    id: messageInputField
                                    anchors.fill: parent
                                    wrapMode: TextArea.Wrap
                                    leftPadding: 10
                                    rightPadding: 10
                                    topPadding: 10
                                    bottomPadding: 10
                                    color: activeFocus ? Appearance.m3colors.m3onSurface : Appearance.m3colors.m3onSurfaceVariant
                                    placeholderText: "Message the model... \"/\" for commands"
                                    background: null

                                    onTextChanged: {
                                        if (messageInputField.text.length === 0) {
                                            aiSidebar.suggestionList = []
                                            return
                                        }

                                        if (messageInputField.text.startsWith(aiSidebar.commandPrefix)) {
                                            const query = messageInputField.text.substring(1)
                                            aiSidebar.suggestionList = [
                                                { name: "model", description: "Choose model" },
                                                { name: "tool", description: "Set tool for the model" },
                                                { name: "prompt", description: "Set system prompt" },
                                                { name: "key", description: "Set API key" },
                                                { name: "save", description: "Save chat" },
                                                { name: "load", description: "Load chat" },
                                                { name: "clear", description: "Clear chat history" },
                                                { name: "temp", description: "Set temperature" }
                                            ].filter(cmd => cmd.name.startsWith(query)).map(cmd => ({
                                                name: `${aiSidebar.commandPrefix}${cmd.name}`,
                                                displayName: cmd.name,
                                                description: cmd.description
                                            }))
                                        } else {
                                            aiSidebar.suggestionList = []
                                        }
                                    }

                                    Keys.onPressed: (event) => {
                                        if (event.key === Qt.Key_Tab) {
                                            if (aiSidebar.suggestionList.length > 0) {
                                                messageInputField.text = aiSidebar.suggestionList[0].name + " "
                                                messageInputField.cursorPosition = messageInputField.text.length
                                                aiSidebar.suggestionList = []
                                            }
                                            event.accepted = true
                                        } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                            if (event.modifiers & Qt.ShiftModifier) {
                                                messageInputField.insert(messageInputField.cursorPosition, "\n")
                                                event.accepted = true
                                            } else {
                                                const inputText = messageInputField.text
                                                messageInputField.clear()
                                                aiSidebar.handleInput(inputText)
                                                event.accepted = true
                                            }
                                        } else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_V) {
                                            if (event.modifiers & Qt.ShiftModifier) {
                                                messageInputField.text += Quickshell.clipboardText
                                                event.accepted = true
                                                return
                                            }
                                            event.accepted = false
                                        } else if (event.key === Qt.Key_Escape) {
                                            event.accepted = false
                                        }
                                    }
                                }
                            }

                            RippleButton {
                                id: sendButton
                                Layout.alignment: Qt.AlignBottom
                                Layout.rightMargin: 5
                                implicitWidth: 40
                                implicitHeight: 40
                                buttonRadius: Appearance.rounding.small
                                enabled: messageInputField.text.length > 0
                                toggled: enabled

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: sendButton.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: {
                                        const inputText = messageInputField.text
                                        messageInputField.clear()
                                        aiSidebar.handleInput(inputText)
                                    }
                                }

                                contentItem: MaterialSymbol {
                                    anchors.centerIn: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    iconSize: 22
                                    color: sendButton.enabled ? Appearance.m3colors.m3onPrimary : Appearance.colors.colOnLayer2Disabled
                                    text: "arrow_upward"
                                }
                            }
                        }

                        RowLayout {
                            id: commandButtonsRow
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                                leftMargin: 10
                                rightMargin: 5
                                bottomMargin: 5
                            }
                            spacing: 4

                            ApiInputBoxIndicator {
                                icon: "api"
                                text: "KiloCode"
                                tooltipText: "Current model: KiloCode\nSet it with /model MODEL"
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            ApiCommandButton {
                                buttonText: "/clear"
                                onClicked: {
                                    aiSidebar.history = []
                                    aiSidebar.response = ""
                                    aiSidebar.query = ""
                                    messageInputField.text = ""
                                }
                            }
                        }
                    }
                }

                ScrollToBottomButton {
                    z: 3
                    target: messageListView
                }
            }
        }
    }

    function handleInput(inputText) {
        if (inputText.startsWith(commandPrefix)) {
            const command = inputText.split(" ")[0].substring(1)
            const args = inputText.split(" ").slice(1)
            if (command === "clear") {
                history = []
                response = ""
                query = ""
            } else if (command === "model") {
                if (args.length > 0) {
                    addMessage("Model set to: " + args[0], "interface")
                }
            } else if (command === "temp") {
                if (args.length > 0) {
                    addMessage("Temperature set to: " + args[0], "interface")
                }
            } else if (command === "key") {
                if (args.length > 0) {
                    addMessage("API key set", "interface")
                }
            } else if (command === "tool") {
                if (args.length > 0) {
                    addMessage("Tool set to: " + args[0], "interface")
                }
            } else if (command === "prompt") {
                if (args.length > 0) {
                    addMessage("System prompt set", "interface")
                }
            } else if (command === "save") {
                if (args.length > 0) {
                    addMessage("Chat saved: " + args[0], "interface")
                }
            } else if (command === "load") {
                if (args.length > 0) {
                    addMessage("Chat loaded: " + args[0], "interface")
                }
            } else {
                addMessage("Unknown command: " + command, "interface")
            }
        } else {
            query = inputText
            runQuery()
        }
        messageListView.positionViewAtEnd()
    }

    function addMessage(message, role) {
        if (message.length === 0) return
        history.push({ role: role, text: message })
    }

    function shellEscape(str) {
        return String(str).replace(/'/g, "'\\''")
    }

    function runQuery() {
        if (!query || loading) return

        loading = true
        history.push({ role: 'user', text: query })

        const proc = Io.Process {
            command: ["bash", "-c", `timeout 120 kilo run --format default --auto '${shellEscape(query)}' 2>/dev/null`]
            running: true

            onExited: (exitCode, exitStatus) => {
                loading = false
                const raw = exitCode === 0 ? proc.readStdOut() : "Error: KiloCode command failed"
                const cleaned = raw.trim().length > 0 ? raw.trim() : "No response"
                response = cleaned
                history.push({ role: 'assistant', text: response })
            }
        }
    }
}
