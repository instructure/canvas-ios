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

extension Color {
    public typealias iuiPrimitive = Color.InstUI.Primitives
    public static var iuiSemantic: InstUISemanticColors { _iuiSemanticColors() }
}

extension UIColor {
    public typealias iuiPrimitive = UIColor.InstUI.Primitives
}

extension Font.Weight {
    public typealias iuiPrimitive = Font.Weight.InstUI.Primitives
    public static var iuiSemantic: InstUISemanticFontWeights { _iuiSemanticFontWeights() }
}

extension String {
    public typealias iuiPrimitiveFontFamily = String.InstUI.Primitives
    public static var iuiSemanticFontFamily: InstUISemanticFontFamilies { _iuiSemanticFontFamilies() }
}

extension Double {
    public typealias iuiPrimitiveOpacity = Double.InstUI.Primitives
    public static var iuiSemanticOpacity: InstUISemanticOpacity { _iuiSemanticOpacity() }
}

extension CGFloat {
    public typealias iuiPrimitiveSize = CGFloat.InstUI.Primitives
    public static var iuiSemanticSize: InstUISemanticSize { _iuiSemanticSize() }
    public static var iuiSemanticSpacing: InstUISemanticSpacing { _iuiSemanticSpacing() }
    public static var iuiSemanticBorderRadius: InstUISemanticBorderRadius { _iuiSemanticBorderRadius() }
    public static var iuiSemanticBorderWidth: InstUISemanticBorderWidth { _iuiSemanticBorderWidth() }
    public static var iuiSemanticFontSize: InstUISemanticFontSize { _iuiSemanticFontSize() }
}

// MARK: - Helpers

// Each generated Primitives file adds `extension SomeType { public enum InstUI { ... } }`,
// shadowing our module-level `InstUI` enum inside any extension on that type.
// File-scope typealiases and private helpers keep `InstUI` unambiguous — use them
// for any reference to InstUI types inside the extensions below.
public typealias InstUISemanticColors = InstUI.Semantic.Colors
public typealias InstUISemanticFontWeights = InstUI.Semantic.FontWeights
public typealias InstUISemanticFontFamilies = InstUI.Semantic.FontFamilies
public typealias InstUISemanticOpacity = InstUI.Semantic.Opacity
public typealias InstUISemanticSize = InstUI.Semantic.Size
public typealias InstUISemanticSpacing = InstUI.Semantic.Spacing
public typealias InstUISemanticBorderRadius = InstUI.Semantic.BorderRadius
public typealias InstUISemanticBorderWidth = InstUI.Semantic.BorderWidth
public typealias InstUISemanticFontSize = InstUI.Semantic.FontSize

private func _iuiSemanticColors() -> InstUISemanticColors { InstUI.Theme.default.colors }
private func _iuiSemanticFontWeights() -> InstUISemanticFontWeights { InstUI.Theme.default.fontWeights }
private func _iuiSemanticFontFamilies() -> InstUISemanticFontFamilies { InstUI.Theme.default.fontFamilies }
private func _iuiSemanticOpacity() -> InstUISemanticOpacity { InstUI.Theme.default.opacity }
private func _iuiSemanticSize() -> InstUISemanticSize { InstUI.Theme.default.size }
private func _iuiSemanticSpacing() -> InstUISemanticSpacing { InstUI.Theme.default.spacing }
private func _iuiSemanticBorderRadius() -> InstUISemanticBorderRadius { InstUI.Theme.default.borderRadius }
private func _iuiSemanticBorderWidth() -> InstUISemanticBorderWidth { InstUI.Theme.default.borderWidth }
private func _iuiSemanticFontSize() -> InstUISemanticFontSize { InstUI.Theme.default.fontSize }
