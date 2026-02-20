# InstUI & SwiftUI Patterns

## SwiftUI Recipes

- For 1-physical-pixel borders: `@Environment(\.displayScale) private var displayScale` and `lineWidth: 1 / displayScale`
- `@Environment(\.dynamicTypeSize) private var dynamicTypeSize` declared but not used in body is intentional — it triggers view re-renders on font size changes. Do NOT remove it as "unused"
- When a view must pass a `CurrentValueSubject` to a child component but also react to its changes: use `@State` to persist the subject reference (class type, safe in `@State`) and `.onReceive` to bridge emissions into a separate `@State` var that drives the UI

### Fonts (`Core/Core/Common/CommonUI/Fonts/FontExtensions.swift`)
- Use named `Font` extensions instead of system fonts: `.regular14`, `.semibold16`, `.bold17`, etc.; weights: `regular`, `medium`, `semibold`, `bold`, `heavy`; monodigit variants: `.regular11Monodigit`, `.regular20Monodigit`
- All named fonts wrap `UIFont.scaledNamedFont(…)` and scale with Dynamic Type automatically
- Use `Font.scaledRestrictly(_:)` when you need the font to respect Dynamic Type size restrictions tied to its `Font.TextStyle`; use it instead of the static var when restriction is required

### Colors (`Core/Core/Common/Extensions/InstColorExtensions.swift`)
- Use semantic color tokens on `Color` (or `UIColor` for UIKit): `.textDarkest / .textDark / .textLight / .textLightest / .textLink / .textPlaceholder / .textDanger / .textSuccess / .textWarning / .textInfo`
- Background tokens: `.backgroundLightest / .backgroundLight / .backgroundMedium / .backgroundGrouped / .backgroundGroupedCell / .backgroundDark / .backgroundDarkest / .backgroundDanger / .backgroundSuccess / .backgroundWarning / .backgroundInfo / .backgroundLightestElevated / .backgroundMasquerade`
- Border tokens: `.borderLightest / .borderLight / .borderMedium / .borderDark / .borderDarkest / .borderDanger / .borderSuccess / .borderWarning / .borderInfo / .borderMasquerade`
- Course palette: `.course1` … `.course12` (available on `Color`, `UIColor`, and `ShapeStyle`)
- All tokens are available as `Color`, `UIColor`, and `ShapeStyle where Self == Color` — prefer `Color` in SwiftUI, `UIColor` in UIKit

## InstUI Component Reference

### Screen & Navigation
- **BaseScreen** — handles loading/error/empty/data states with pull-to-refresh and panda illustrations; wrap your screen content in this; `.data(loadingOverlay: true)` shows content but disables it behind a semi-transparent progress overlay (distinct from the `.loading` state which hides content entirely)
- **NavigationBarButton** — nav bar buttons with enabled/offline states; factory methods: `.cancel`, `.done`, `.add`, `.save`, `.moreIcon`, `.filterIcon`
- **NavigationBarTitleView** — title + optional subtitle for nav bar; fixes VoiceOver reading order issues on iOS 26
- **ListSectionHeader** — section header with title, item count (formatted with localized label), and optional trailing action button; uses `.sectionHeader` text style; also used internally by `CollapsibleListSection` and `SingleSelectionView`

### Cells (most common building blocks)
- **RadioButtonCell** — radio button with title/subtitle/header; use with `SingleSelectionView` (`OptionSelection/View/`) for proper a11y grouping
- **TrailingCheckmarkCell** — like RadioButtonCell but checkmark on the trailing side; use for item pickers
- **CheckboxCell** — checkbox with title/subtitle; manages its own a11y toggle representation
- **ToggleCell** — labeled toggle switch cell
- **LabelCell** — simple single-label cell
- **LabelValueCell** — label + value pair with optional disclosure indicator and tap action
- **TextFieldCell** — single-line text input cell with optional label
- **TextEditorCell** — multi-line text input cell with optional label
- **DatePickerCell** — date/time picker cell; modes: `.dateOnly`, `.timeOnly`, `.dateAndTime`; supports validation range and error message; `isClearable: true` shows a clear button (sets date to nil); `defaultDate` sets the date applied when the user taps a nil placeholder; `labelModifiers` for custom label styling
- **SelectionMenuCell** — cell with a menu-based picker; shows current value inline
- **ContextItemListCell / ContextItemListSubItemCell** — action list cells with icon and labels; sub-item variant is indented
- **RichContentEditorCell** — cell wrapping the HTML rich content editor with upload support and error handling

### Standalone Controls
- **Toggle** — custom toggle with animated knob, checkmark/X icon, drag gesture, and full a11y; use inside `ToggleCell` for list rows or standalone for custom layouts
- **Checkbox** — standalone scalable checkbox icon view reflecting selection state; use inside `CheckboxCell` for list rows
- **RadioButton** — standalone scalable radio button icon view; use inside `RadioButtonCell` or `SingleSelectionView` for groups

### Selection & Menus
- **SingleSelectionView** (`OptionSelection/View/`) — preferred component for radio button groups; handles a11y grouping, header trait, and identifier per item; style variants: `.radioButton` (default) and `.trailingCheckmark`; pair with `SingleSelectionOptions` when you need `.hasChanges` detection and `.resetSelection()`; `OptionItem` supports: `subtitle`, `headerTitle`, `color`, `customAccessibilityLabel`, `accessoryIcon`
- **SelectionMenu** — standalone menu picker (not a cell) with checkmark for selected option
- **PickerMenu** — menu-based picker using SwiftUI Picker under the hood; supports string or integer IDs
- **SegmentedPicker** — wraps UISegmentedControl; use when you need to detect taps on the already-selected segment
- **MultiPickerView** — two-column UIPickerView; useful for paired values (e.g. hours + minutes)

### Buttons
- **PillButtonStyle** — pill-shaped button style; variants: `.brandFilled`, `.defaultOutlined`, `.filled(color:)`, `.outlined(color:)`, `.outlined(textColor:borderColor:)` (separate text and border colors), `.pillButtonOutlined(color:)`
- **MenuItem** — pre-styled button for `Menu` content; variants: `.edit`, `.delete`

### Layout & Structure
- **Divider** — horizontal/vertical divider; styles: `.full`, `.padded`, `.hidden`; use `.full` for edge-to-edge, `.padded` for inset
- **TopDivider** — slides under content above it; use for top borders that only show when scrolled
- **Badge** — count badge overlay on icons; handles 1–99 and "99+" automatically
- **TapArea** — invisible full-area tap target; use to expand touch targets
- **JoinedSubtitleLabels** — two labels separated by a vertical divider; use for paired subtitle info
- **SubtitleTextDivider** — small rounded vertical divider for separating inline subtitle text
- **DisclosureIndicator** — right-pointing chevron for navigable cells; use instead of a custom chevron icon
- **Header** — title + optional subtitle with paragraph styling and accessibility header trait
- **PageIndicator** — dot-based page indicator for paged/carousel content; auto-scrolls when pages exceed `maxDotsBeforeScroll`; intentionally has no a11y (parent must handle it)

### Collapsible Content
- **CollapsibleListRow** — DisclosureGroup-based collapsible row with custom styling; manages its own expanded state internally; use `isInitiallyExpanded` param to set default
- **CollapsibleListSection** — Section-based collapsible container; use instead of CollapsibleListRow when you need pinned headers; requires `isExpanded: Binding<Bool>` — you own and manage the state externally
- **CollapseButtonIcon** — chevron icon that rotates based on expanded state; use as the toggle indicator in custom collapsible rows
- **CollapseButtonExpandedState** — provides a11y strings (value, hint, action label) for collapse/expand buttons

### Text Input
- **ScrollableTextEditor** — grows from 1 line up to a max height then scrolls; good for chat/comment inputs
- **NumericTextField** — numeric-only input with decimal support and a Done toolbar button

### Text Display
- **TextSectionView** — title + description section; supports plain text or rendered HTML via WebView

### Dropdowns
- **DropDownButton + DropDownDetailsViewModifier** — custom positioned dropdown overlay with spring animation and smart above/below positioning; wiring:
  1. `@State var dropdownState = DropDownButtonState()`
  2. `DropDownButton(state: $dropdownState) { /* label content */ }` in the view
  3. `.dropDownDetailsContainer(state: $dropdownState) { /* dropdown content */ }` on the parent view
  - Constraints: max width 320pt, 50pt margin from screen edges
- **DropDownCell** — cell combining a label and a DropDownButton; use for inline dropdown selection inside lists

### Styles & Modifiers (apply via modifiers, not instantiated directly)
- `.textStyle(.heading / .headingInfo / .infoTitle / .infoDescription / .sectionHeader / .cellLabel / .cellValue / .errorMessage …)` — predefined font + color combos
- `.paddingStyle(.horizontal/.vertical/.top/.bottom, .standard/.cellTop/.cellBottom …)` — semantic spacing
- `.elevation(.cardSmall / .cardLarge / .pill)` — corner radius + shadow presets
- `.swipeAction(…)` — left-swipe gesture with haptic feedback; `SwipeCompletionBehavior`: `.stayOpen` disables the gesture after trigger (no repeat without external reset), `.reset` re-enables immediately (repeatable)

### Debug / Preview Utilities
- **PreviewData** — Lorem Ipsum strings (`.short`, `.medium`, `.long(multiplier:)`) for preview canvases
- **Storybook** — in-app component browser for visual reference
