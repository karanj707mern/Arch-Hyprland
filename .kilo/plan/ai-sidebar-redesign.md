# AI Sidebar Redesign Plan

## Objective
Redesign the AI sidebar UI to match end4's implementation found at `/tmp/ai_repo/dots/.config/quickshell/ii/modules/ii/sidebarLeft/`

## Current State Analysis

### Current Implementation (`/home/karran/Arch-Hyprland/Hyprland-Dots/config/quickshell/modules/ai_sidebar/AISidebar.qml`)
- Simple vertical sidebar (380px width)
- Basic chat interface with user/assistant messages
- Process-based API calls with `timeout 120 kilo run --auto`
- Quick action buttons (Diagnostics, Bug Fix, Clear)
- Basic styling with hardcoded colors (#1e1e2e, #cba6f7, etc.)
- No command system, autocomplete, or advanced features

### End4 Implementation Reference
- **AiChat.qml**: Advanced chat interface (795 lines)
  - Command system (`/model`, `/tool`, `/prompt`, `/key`, `/save`, `/load`, `/clear`, `/temp`)
  - Autocomplete/suggestions for commands
  - Status indicators (API key status, temperature, token count)
  - File attachment support (clipboard images, file paths)
  - Markdown rendering in messages
  - Keyboard shortcuts (Ctrl+O, Ctrl+P, Ctrl+D)
  - Material Design 3 theming via `Appearance` system
  
- **SidebarLeft.qml**: Sophisticated sidebar container (255 lines)
  - Detach/pin functionality
  - Focus grab system integration
  - Animated width transitions
  - Shadow effects
  - Global shortcuts for toggle/open/close/detach

- **SidebarLeftContent.qml**: Content management

## Redesign Strategy

### Phase 1: Core UI Structure Update
**Files to modify:**
1. `/home/karran/Arch-Hyprland/Hyprland-Dots/config/quickshell/modules/ai_sidebar/AISidebar.qml` - Complete rewrite
2. `/home/karran/Arch-Hyprland/Hyprland-Dots/config/quickshell/GlobalStates.qml` - Add new state properties if needed

**Changes:**
- Replace simple Rectangle-based layout with ColumnLayout matching end4's structure
- Add status bar at top (API key, temperature, tokens)
- Add message list with scroll-to-bottom button
- Add suggestion/autocomplete system
- Add command buttons row
- Add file attachment indicator
- Implement proper input area with send button

### Phase 2: Advanced Features
**Features to add:**
1. **Command System**
   - Parse input starting with `/`
   - Support commands: `/model`, `/tool`, `/prompt`, `/key`, `/save`, `/load`, `/clear`, `/temp`
   - Show command suggestions while typing

2. **Autocomplete System**
   - Fuzzy search for commands
   - Tab completion
   - Up/Down arrow navigation through suggestions

3. **Status Indicators**
   - API key status (key/key_off icon)
   - Temperature display
   - Token count (input/output/total)

4. **File Attachments**
   - Clipboard image paste (Ctrl+V)
   - File path attachment
   - Visual indicator for attached files
   - Remove attachment option

5. **Keyboard Shortcuts**
   - Ctrl+O: Clear chat
   - Ctrl+P: Pin sidebar
   - Ctrl+D: Detach sidebar
   - Escape: Remove attachment or close

### Phase 3: Theming and Animations
**Changes:**
- Use `Appearance` system colors instead of hardcoded values
- Add smooth animations for:
  - Sidebar width changes
  - Message appearance
  - Status bar transitions
  - Suggestion popup
- Add shadow effects
- Implement proper rounding and spacing

### Phase 4: API Integration
**Changes:**
- Keep existing `kilo run --auto` command structure
- Add support for streaming responses (if possible)
- Improve error handling
- Add loading states

## Implementation Steps

### Step 1: Create New AISidebar.qml
- Rewrite the file with end4's structure
- Maintain compatibility with existing IPC handlers
- Keep the same visual identity but improve UX

### Step 2: Add Supporting Components
Create new QML files:
- `ApiCommandButton.qml` - For command buttons
- `ApiInputBoxIndicator.qml` - For status indicators
- `DescriptionBox.qml` - For suggestion descriptions
- `ScrollToBottomButton.qml` - For scroll-to-bottom functionality

### Step 3: Update GlobalStates.qml
Add new properties:
- `sidebarLeftOpen` (already exists)
- `aiSidebarOpen` (already exists)
- Consider adding `sidebarLeftDetached` if needed

### Step 4: Testing
- Test command parsing
- Test autocomplete
- Test file attachments
- Test keyboard shortcuts
- Test animations
- Test with actual AI API calls

## Risk Assessment

### Low Risk
- Visual redesign (cosmetic changes)
- Adding new UI components
- Improving animations

### Medium Risk
- Command system implementation
- Autocomplete functionality
- File attachment handling

### High Risk
- API integration changes
- Breaking existing functionality

## Rollback Plan
- Keep backup of current `AISidebar.qml`
- Implement changes incrementally
- Test each phase before proceeding

## Success Criteria
1. UI matches end4's visual design
2. All commands work correctly
3. Autocomplete functions properly
4. File attachments work
5. Animations are smooth
6. No regression in existing functionality

## Timeline
- Phase 1 (Core UI): 2-3 hours
- Phase 2 (Advanced Features): 2-3 hours
- Phase 3 (Theming): 1-2 hours
- Phase 4 (Testing): 1-2 hours

**Total estimated time: 6-10 hours**
