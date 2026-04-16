//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import SwiftUI
import UIKit

// The generated `InstUI.Primitives.Colors.swift` adds `extension Color { public enum InstUI { ... } }`,
// which shadows our module-level `InstUI` enum inside any `extension Color` body.
// Declaring this alias at file scope (outside `extension Color`) resolves `InstUI` to our enum.
// It must be public so it can appear in the signature of the public `iuiSemantic` property below.
public typealias InstUISemanticColors = InstUI.Semantic.Colors

extension Color {
    public typealias iuiPrimitive = Color.InstUI.Primitives
    public var iuiSemantic: InstUISemanticColors { _instUIDefaultSemanticColors() }
}

extension UIColor {
    public typealias iuiPrimitive = UIColor.InstUI.Primitives
}

// Defined at file scope so `InstUI` resolves to our module's enum, not the `Color.InstUI` nested enum
// from the generated primitives file. The body of `iuiSemantic` delegates here to avoid the shadow.
private func _instUIDefaultSemanticColors() -> InstUISemanticColors {
    InstUI.Theme.default.colors
}
