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

extension InstUI {
    struct ComponentResolver {
        private let leaves: [TokenKey: String]
        private let colorMap: [String: Color]
        private let sizeResolver: SizeResolver
        private let opacityResolver: OpacityResolver
        private let fontWeightResolver: FontWeightResolver
        private let fontFamilyResolver: FontFamilyResolver

        init(
            colors: InstUI.Semantic.Color,
            size: InstUI.Semantic.Size,
            spacing: InstUI.Semantic.Spacing,
            borderRadius: InstUI.Semantic.BorderRadius,
            borderWidth: InstUI.Semantic.BorderWidth,
            fontSize: InstUI.Semantic.FontSize,
            opacity: InstUI.Semantic.Opacity,
            fontWeights: InstUI.Semantic.FontWeight,
            fontFamilies: InstUI.Semantic.FontFamily,
            leaves: [TokenKey: String]
        ) {
            self.leaves = leaves
            colorMap = Dictionary(
                colors.all.map { ("color.\($0.name)", $0.value) },
                uniquingKeysWith: { $1 }
            )
            sizeResolver = SizeResolver(map: Dictionary(
                size.all.map { ("size.\($0.name)", $0.value) } +
                spacing.all.map { ("spacing.\($0.name)", $0.value) } +
                borderRadius.all.map { ("borderRadius.\($0.name)", $0.value) } +
                borderWidth.all.map { ("borderWidth.\($0.name)", $0.value) } +
                fontSize.all.map { ("fontSize.\($0.name)", $0.value) },
                uniquingKeysWith: { $1 }
            ))
            opacityResolver = OpacityResolver(map: Dictionary(
                opacity.all.map { ("opacity.\($0.name)", $0.value) },
                uniquingKeysWith: { $1 }
            ))
            fontWeightResolver = FontWeightResolver(map: Dictionary(
                fontWeights.all.map { ("fontWeight.\($0.name)", $0.value) },
                uniquingKeysWith: { $1 }
            ))
            fontFamilyResolver = FontFamilyResolver(map: Dictionary(
                fontFamilies.all.map { ("fontFamily.\($0.name)", $0.value) },
                uniquingKeysWith: { $1 }
            ))
        }

        private init(
            colorMap: [String: Color],
            sizeResolver: SizeResolver,
            opacityResolver: OpacityResolver,
            fontWeightResolver: FontWeightResolver,
            fontFamilyResolver: FontFamilyResolver,
            leaves: [TokenKey: String]
        ) {
            self.leaves = leaves
            self.colorMap = colorMap
            self.sizeResolver = sizeResolver
            self.opacityResolver = opacityResolver
            self.fontWeightResolver = fontWeightResolver
            self.fontFamilyResolver = fontFamilyResolver
        }

        init(theme: InstUI.Theme, leaves: [TokenKey: String]) {
            self.init(
                colors: theme.color,
                size: theme.size,
                spacing: theme.spacing,
                borderRadius: theme.borderRadius,
                borderWidth: theme.borderWidth,
                fontSize: theme.fontSize,
                opacity: theme.opacity,
                fontWeights: theme.fontWeight,
                fontFamilies: theme.fontFamily,
                leaves: leaves
            )
        }

        func withLeaves(_ leaves: [TokenKey: String]) -> ComponentResolver {
            ComponentResolver(
                colorMap: colorMap,
                sizeResolver: sizeResolver,
                opacityResolver: opacityResolver,
                fontWeightResolver: fontWeightResolver,
                fontFamilyResolver: fontFamilyResolver,
                leaves: leaves
            )
        }

        func color(_ key: TokenKey) throws -> Color {
            guard let raw = leaves[key] else { throw TokenLoadError.missingToken(key) }
            if raw == "transparent" { return .clear }
            if raw.hasPrefix("{"), raw.hasSuffix("}") {
                let ref = String(raw.dropFirst().dropLast())
                guard let value = colorMap[ref] else { throw TokenLoadError.missingToken(ref) }
                return value
            }
            if raw.isRGBAValue { return Color(rgba: raw) }
            if raw.hasPrefix("#") { return Color(hex: raw) }
            throw TokenLoadError.invalidValue(raw)
        }

        func dimension(_ key: TokenKey) throws -> CGFloat {
            guard let raw = leaves[key] else { throw TokenLoadError.missingToken(key) }
            return try sizeResolver.resolve(raw)
        }

        func opacity(_ key: TokenKey) throws -> Double {
            guard let raw = leaves[key] else { throw TokenLoadError.missingToken(key) }
            return try opacityResolver.resolve(raw)
        }

        func fontWeight(_ key: TokenKey) throws -> Font.Weight {
            guard let raw = leaves[key] else { throw TokenLoadError.missingToken(key) }
            return try fontWeightResolver.resolve(raw)
        }

        func fontFamily(_ key: TokenKey) throws -> String {
            guard let raw = leaves[key] else { throw TokenLoadError.missingToken(key) }
            return try fontFamilyResolver.resolve(raw)
        }
    }
}
