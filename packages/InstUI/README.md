# InstUI

A Swift Package that exposes Instructure design-system **primitives** — raw design tokens (colors, sizes, font weights, font families, opacities) — as typed Swift constants for use in SwiftUI and UIKit.

Tokens are sourced from the [instructure-ui](https://github.com/instructure/instructure-ui) repository and generated automatically via `yarn build-instui`. Do not edit the generated source files by hand.

---

## Requirements

- iOS 17+
- Swift 6

---

## Package structure

```
packages/InstUI/
├── Package.swift
├── Sources/
│   ├── InstUI.swift                              # Namespace declarations
│   ├── Primitives/
│   │   ├── Generated/
│   │   │   ├── InstUI.Primitives.Colors.swift        # DO NOT EDIT — auto-generated
│   │   │   ├── InstUI.Primitives.Sizes.swift         # DO NOT EDIT — auto-generated
│   │   │   ├── InstUI.Primitives.FontWeights.swift   # DO NOT EDIT — auto-generated
│   │   │   ├── InstUI.Primitives.FontFamilies.swift  # DO NOT EDIT — auto-generated
│   │   │   └── InstUI.Primitives.Opacities.swift     # DO NOT EDIT — auto-generated
│   │   └── Storybook/
│   │       └── *.Storybook.swift                     # In-app previews (one per primitive)
│   └── Utils/
│       ├── CheckeredTexture.swift                # Internal storybook helper
│       ├── Color+HexInit.swift                   # Internal hex initializer
│       └── FontRegistration.swift                # Internal font registration
├── Resources/
│   └── Fonts/
│       ├── Lato/
│       ├── Inclusive_Sans/
│       └── Atkinson_Hyperlegible_Next/
└── README.md
```

---

## Public API

Everything lives under the `InstUI` namespace, scoped further under `InstUI.Primitives`.

### Namespace hierarchy

```swift
InstUI
└── Primitives
    ├── Colors
    ├── Sizes
    ├── FontWeights
    ├── FontFamilies
    └── Opacities
```

Each primitive group also extends the relevant Swift/SwiftUI type so tokens are reachable via dot syntax in contexts where the expected type is already known.

---

### Colors — `InstUI.Primitives.Colors`

Static `Color` constants. Tokens are grouped by hue; each hue has steps from `10` (lightest) to `180` (darkest).

**Hue groups:** `green`, `grey`, `blue`, `red`, `orange`, `plum`, `violet`, `stone`, `sky`, `honey`, `sea`, `aurora`, `navy`

**Special tokens:** `white`, `transparent`

**Semi-transparent tokens:** `whiteOpacity10`, `whiteOpacity20`, `whiteOpacity75`, `greyOpacity10`, `greyOpacity75`, `navyOpacity10`

**Three access styles for the same value:**

```swift
import InstUI
import SwiftUI

// 1. Canonical — via the primitive namespace (preferred)
let c: Color = InstUI.Primitives.Colors.blue100

// 2. SwiftUI dot syntax — when the type is already Color
let c: Color = .InstUI.Primitives.blue100

// 3. UIKit
let c: UIColor = UIColor.InstUI.Primitives.blue100
```

---

### Sizes — `InstUI.Primitives.Sizes`

Static `CGFloat` constants covering the spacing and sizing scale. Token names reflect their intended point size (e.g. `size16` is 16 pt). For the current set of tokens and their values, see the generated source file or browse the Storybook.

```swift
// Canonical
let padding: CGFloat = InstUI.Primitives.Sizes.size16

// CGFloat dot syntax
let padding: CGFloat = .InstUI.Primitives.size16
```

---

### Font Weights — `InstUI.Primitives.FontWeights`

Static `Font.Weight` constants following the CSS / design-token weight naming convention (`thin`, `extraLight`, `light`, `regular`, `medium`, `semiBold`, `bold`, `extraBold`, `black`).

> Note: CSS and SwiftUI use the same numeric weight values but different names (e.g. CSS `thin` = SwiftUI `.ultraLight`). The mapping is by numeric value, not by name.

```swift
// Canonical
Text("Hello").fontWeight(InstUI.Primitives.FontWeights.semiBold)

// Font.Weight dot syntax
Text("Hello").fontWeight(.InstUI.Primitives.semiBold)
```

---

### Font Families — `InstUI.Primitives.FontFamilies`

Static `String` constants (PostScript family names) for the fonts available to the package: `lato`, `inclusiveSans`, `atkinson`, and `menlo`. The first three are bundled under OFL licenses; `menlo` is a system font.

Accessing any property automatically registers the bundled font files with Core Text on first use — no additional setup required.

```swift
// Canonical
Font.custom(InstUI.Primitives.FontFamilies.lato, size: 16)

// String dot syntax
Font.custom(.InstUI.Primitives.fontLato, size: 16)
```

> Note: Font family string tokens on `String.InstUI.Primitives` are prefixed with `font` (e.g. `fontLato`, `fontAtkinson`) to avoid collisions with any existing `String` members.

---

### Opacities — `InstUI.Primitives.Opacities`

Static `Double` constants for opacity values. Token names reflect their percentage (e.g. `opacity50` = 50% opacity). For the current set of tokens, see the generated source file or browse the Storybook.

```swift
// Canonical
view.opacity(InstUI.Primitives.Opacities.opacity50)

// Double dot syntax
view.opacity(.InstUI.Primitives.opacity50)
```

---

## Storybook

A live in-app component browser that shows all primitive tokens organized by category. To use it:

```swift
import InstUI

NavigationStack {
    InstUI.Storybook()
}
```

---

## Updating design tokens

Tokens are generated from [instructure-ui](https://github.com/instructure/instructure-ui) at a pinned version. To update:

1. Bump `INSTUI_VERSION` in `scripts/instui/build-instui.js`.
2. Run `yarn build-instui` from the repo root.
3. Commit the regenerated `Sources/Primitives/Generated/*.swift` files.

The five generated files are marked `// DO NOT EDIT` — all token changes must go through the build script.
