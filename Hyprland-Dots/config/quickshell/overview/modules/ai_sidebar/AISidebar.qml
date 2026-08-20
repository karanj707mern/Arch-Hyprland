import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "../../common"
import "../../common/widgets"

Scope {
    id: sidebar

    property bool open: false
    property bool loading: false
    property string draft: ""
    property string selectedModel: ""
    property string modelLoadError: ""
    property bool allowChanges: true
    property bool pointerInside: false

    ListModel {
        id: messages
    }

    ListModel {
        id: freeModels
    }

    function toggle() {
        open = !open
    }

    function addMessage(sender, body) {
        if (body.trim().length > 0)
            messages.append({ sender: sender, body: body.trim() })
    }

    function submit() {
        const text = draft.trim()
        if (text.length === 0 || loading)
            return

        startRequest(text, allowChanges)
    }

    function shellEscape(str) {
        return String(str).replace(/'/g, "'\\''")
    }

    function startRequest(text, allowChanges) {
        draft = ""
        addMessage("You", text)
        loading = true

        const modelArg = selectedModel.length > 0 ? "--model " + shellEscape(selectedModel) : ""
        const autoArg = allowChanges ? "--auto" : ""
        const prompt = buildAgentPrompt(text)

        const proc = Process {
            command: ["bash", "-c", `timeout 120 kilo run --format default ${modelArg} ${autoArg} '${shellEscape(prompt)}' 2>/dev/null`]
            running: true

            onExited: (exitCode, exitStatus) => {
                sidebar.loading = false
                const output = exitCode === 0 ? proc.readStdOut() : "Error: KiloCode command failed"
                const cleaned = output.trim().length > 0 ? output.trim() : "KiloCode could not complete that request."
                sidebar.addMessage("KiloCode", cleaned)
            }
        }
    }

    function buildAgentPrompt(userRequest) {
        const recentMessages = []
        // Keep the current request fast. The Kilo daemon retains its own runtime
        // state, so the sidebar only needs the most recent conversational turns.
        const start = Math.max(0, messages.count - 6)
        for (let i = start; i < messages.count; i++) {
            const message = messages.get(i)
            recentMessages.push(`${message.sender}: ${message.body}`)
        }

        return `You are the user's autonomous system assistant, operating like KiloCode in VS Code.\n\n` +
            `Resolve clear requests independently: inspect the system, choose sensible defaults, and complete the work using available tools. ` +
            `Only ask the user a short, concrete question when requirements are genuinely ambiguous, there are incompatible options with material consequences, an irreversible deletion/overwrite is not clearly intended, or elevation credentials are required. ` +
            `Do not ask for routine confirmation when the requested outcome is clear. State what you changed and any important limitation at the end.\n\n` +
            `Recent conversation:\n${recentMessages.join("\n")}\n\n` +
            `Current request: ${userRequest}`
    }

    Component.onCompleted: {
        daemonStarter.running = true
        modelDiscovery.running = true
    }

    IpcHandler {
        target: "ai_sidebar"

        function toggle() {
            sidebar.toggle()
        }

        function show() {
            sidebar.open = true
        }

        function hide() {
            sidebar.open = false
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData
            visible: sidebar.open
            implicitWidth: 400

            anchors {
                top: true
                bottom: true
                left: true
            }

            WlrLayershell.namespace: "quickshell:ai_sidebar"
            WlrLayershell.layer: WlrLayer.Overlay
            // Mirror normal focus-follows-mouse behavior without retaining focus
            // after the pointer moves back to another application.
            WlrLayershell.keyboardFocus: sidebar.pointerInside
                ? WlrKeyboardFocus.Exclusive
                : WlrKeyboardFocus.None
            color: "transparent"

            Item {
                id: keyTarget
                anchors.fill: parent
                focus: sidebar.pointerInside

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        sidebar.open = false
                        event.accepted = true
                    } else if (event.key === Qt.Key_Return && (event.modifiers & Qt.ControlModifier)) {
                        sidebar.submit()
                        event.accepted = true
                    }
                }

                StyledRectangularShadow {
                    target: surface
                }

                Rectangle {
                    id: surface
                    anchors {
                        fill: parent
                        topMargin: 10
                        bottomMargin: 10
                        leftMargin: 10
                        rightMargin: 10
                    }
                    radius: Appearance.rounding.large
                    color: Appearance.colors.colLayer0
                    border.width: 1
                    border.color: Appearance.colors.colLayer0Border

                    HoverHandler {
                        onHoveredChanged: sidebar.pointerInside = hovered
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 42

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                StyledText {
                                    text: "AI Assistant"
                                    font.pixelSize: Appearance.font.pixelSize.larger
                                    font.bold: true
                                }
                                StyledText {
                                    text: sidebar.loading ? "KiloCode is thinking…" : "Ask anything about your system"
                                    color: Appearance.colors.colSubtext
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                }

                                ComboBox {
                                    id: modelPicker
                                    Layout.fillWidth: true
                                    implicitHeight: 32
                                    model: freeModels
                                    textRole: "label"
                                    enabled: freeModels.count > 0 && !sidebar.loading
                                    displayText: freeModels.count === 0
                                        ? (sidebar.modelLoadError.length > 0 ? "No free models found" : "Loading free models…")
                                        : sidebar.selectedModel.replace(/^kilo\//, "")
                                    onActivated: index => sidebar.selectedModel = freeModels.get(index).id
                                    background: Rectangle {
                                        radius: Appearance.rounding.verysmall
                                        color: modelPicker.hovered ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer2
                                        border.width: 1
                                        border.color: Appearance.colors.colLayer0Border
                                    }
                                    contentItem: StyledText {
                                        leftPadding: 10
                                        rightPadding: 10
                                        text: modelPicker.displayText
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                        color: Appearance.colors.colOnLayer2
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                    }
                                    indicator: StyledText {
                                        text: "⌄"
                                        x: modelPicker.width - width - 10
                                        y: (modelPicker.height - height) / 2
                                        color: Appearance.colors.colSubtext
                                        font.pixelSize: Appearance.font.pixelSize.small
                                    }
                                }
                            }

                            Button {
                                text: "×"
                                implicitWidth: 38
                                implicitHeight: 38
                                onClicked: sidebar.open = false
                                background: Rectangle {
                                    radius: Appearance.rounding.small
                                    color: parent.hovered ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer2
                                }
                                contentItem: StyledText {
                                    text: "×"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: Appearance.font.pixelSize.larger
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 1
                            color: Appearance.colors.colLayer0Border
                        }

                        ListView {
                            id: conversation
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 8
                            model: messages

                            delegate: Rectangle {
                                required property string sender
                                required property string body
                                width: conversation.width
                                radius: Appearance.rounding.small
                                color: sender === "You" ? Appearance.colors.colSecondaryContainer : Appearance.colors.colLayer2
                                implicitHeight: messageColumn.implicitHeight + 20

                                ColumnLayout {
                                    id: messageColumn
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 4

                                    StyledText {
                                        text: sender
                                        color: sender === "You" ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colSubtext
                                        font.bold: true
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                    }
                                    StyledText {
                                        Layout.fillWidth: true
                                        text: body
                                        wrapMode: Text.Wrap
                                        font.pixelSize: Appearance.font.pixelSize.small
                                    }
                                }
                            }

                            StyledText {
                                anchors.centerIn: parent
                                visible: messages.count === 0
                                text: "Start a conversation\nwith KiloCode"
                                horizontalAlignment: Text.AlignHCenter
                                color: Appearance.colors.colSubtext
                                font.pixelSize: Appearance.font.pixelSize.normal
                            }

                            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Button {
                                text: "Clear"
                                enabled: messages.count > 0 && !sidebar.loading
                                onClicked: messages.clear()
                                implicitWidth: 68
                                implicitHeight: 32
                                background: Rectangle {
                                    radius: Appearance.rounding.small
                                    color: parent.hovered ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer2
                                }
                                contentItem: StyledText {
                                    text: "Clear"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: parent.enabled ? Appearance.colors.colOnLayer2 : Appearance.colors.colSubtext
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                }
                            }
                            Button {
                                id: applyChanges
                                checkable: true
                                checked: sidebar.allowChanges
                                text: checked ? "Auto approve: On" : "Auto approve: Off"
                                enabled: !sidebar.loading
                                onToggled: sidebar.allowChanges = checked
                                implicitWidth: 150
                                implicitHeight: 32
                                background: Rectangle {
                                    radius: Appearance.rounding.small
                                    color: applyChanges.checked
                                        ? Appearance.colors.colSecondaryContainer
                                        : (applyChanges.hovered ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer2)
                                    border.width: 1
                                    border.color: applyChanges.checked ? Appearance.colors.colPrimary : Appearance.colors.colLayer0Border
                                }
                                contentItem: StyledText {
                                    text: applyChanges.text
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: applyChanges.checked ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnLayer2
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                }
                                ToolTip.visible: hovered
                                ToolTip.text: "On: KiloCode runs with --auto and can apply clear requests. Off: it is read-only and only reports or proposes changes."
                            }
                            Item { Layout.fillWidth: true }
                            StyledText {
                                text: sidebar.allowChanges ? "Acts on clear requests" : "Read-only mode"
                                color: Appearance.colors.colSubtext
                                font.pixelSize: Appearance.font.pixelSize.smaller
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 92
                            spacing: 8

                            TextArea {
                                id: prompt
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                placeholderText: "Message KiloCode…"
                                text: sidebar.draft
                                wrapMode: TextEdit.Wrap
                                color: Appearance.m3colors.m3onSurface
                                placeholderTextColor: Appearance.colors.colSubtext
                                padding: 12
                                selectByMouse: true
                                onTextChanged: {
                                    if (text !== sidebar.draft)
                                        sidebar.draft = text
                                }

                                Connections {
                                    target: sidebar
                                    function onDraftChanged() {
                                        if (prompt.text !== sidebar.draft)
                                            prompt.text = sidebar.draft
                                    }
                                }
                                background: Rectangle {
                                    radius: Appearance.rounding.small
                                    color: Appearance.colors.colLayer2
                                    border.width: prompt.activeFocus ? 2 : 1
                                    border.color: prompt.activeFocus ? Appearance.colors.colPrimary : Appearance.colors.colLayer0Border
                                }
                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Return && (event.modifiers & Qt.ControlModifier)) {
                                        sidebar.submit()
                                        event.accepted = true
                                    }
                                }
                            }

                            Button {
                                Layout.alignment: Qt.AlignBottom
                                implicitWidth: 48
                                implicitHeight: 48
                                enabled: sidebar.draft.trim().length > 0 && !sidebar.loading
                                onClicked: sidebar.submit()
                                background: Rectangle {
                                    radius: Appearance.rounding.small
                                    color: parent.enabled ? Appearance.colors.colPrimary : Appearance.colors.colLayer2
                                }
                                contentItem: StyledText {
                                    text: "↑"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: parent.enabled ? Appearance.colors.colOnPrimary : Appearance.colors.colSubtext
                                    font.pixelSize: Appearance.font.pixelSize.larger
                                    font.bold: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // `kilo run` attaches to this daemon automatically. Starting it here makes
    // the sidebar responsive even if the user service was not yet started.
    Process {
        id: daemonStarter
        command: ["kilo", "daemon", "start"]
    }

    Process {
        id: modelDiscovery
        command: ["kilo", "models"]
        stdout: StdioCollector {
            id: modelsCollector
            onStreamFinished: {
                const modelIds = modelsCollector.text.split("\n")
                    .map(model => model.trim())
                    .filter(model => model.startsWith("kilo/") && model.endsWith(":free"))
                    .slice(0, 250)

                freeModels.clear()
                for (const model of modelIds)
                    freeModels.append({ id: model, label: model.replace(/^kilo\//, "") })

                if (freeModels.count > 0)
                    sidebar.selectedModel = freeModels.get(0).id
                else
                    sidebar.modelLoadError = "No free KiloCode models are configured"
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 && freeModels.count === 0)
                sidebar.modelLoadError = "Could not load free models"
        }
    }

}
