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

extension InstUI.Component {
    struct Resolver {
        private let leaves: [InstUI.TokenKey: String]
        private let colorMap: [String: Color]
        private let sizeResolver: InstUI.SizeResolver
        private let opacityResolver: InstUI.OpacityResolver
        private let fontWeightResolver: InstUI.FontWeightResolver
        private let fontFamilyResolver: InstUI.FontFamilyResolver

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
            leaves: [InstUI.TokenKey: String]
        ) {
            self.leaves = leaves
            colorMap = Dictionary(
                colors.all.map { ("color.\($0.name)", $0.value) },
                uniquingKeysWith: { $1 }
            )
            sizeResolver = InstUI.SizeResolver(map: Dictionary(
                size.all.map { ("size.\($0.name)", $0.value) } +
                spacing.all.map { ("spacing.\($0.name)", $0.value) } +
                borderRadius.all.map { ("borderRadius.\($0.name)", $0.value) } +
                borderWidth.all.map { ("borderWidth.\($0.name)", $0.value) } +
                fontSize.all.map { ("fontSize.\($0.name)", $0.value) },
                uniquingKeysWith: { $1 }
            ))
            opacityResolver = InstUI.OpacityResolver(map: Dictionary(
                opacity.all.map { ("opacity.\($0.name)", $0.value) },
                uniquingKeysWith: { $1 }
            ))
            fontWeightResolver = InstUI.FontWeightResolver(map: Dictionary(
                fontWeights.all.map { ("fontWeight.\($0.name)", $0.value) },
                uniquingKeysWith: { $1 }
            ))
            fontFamilyResolver = InstUI.FontFamilyResolver(map: Dictionary(
                fontFamilies.all.map { ("fontFamily.\($0.name)", $0.value) },
                uniquingKeysWith: { $1 }
            ))
        }

        private init(
            colorMap: [String: Color],
            sizeResolver: InstUI.SizeResolver,
            opacityResolver: InstUI.OpacityResolver,
            fontWeightResolver: InstUI.FontWeightResolver,
            fontFamilyResolver: InstUI.FontFamilyResolver,
            leaves: [InstUI.TokenKey: String]
        ) {
            self.leaves = leaves
            self.colorMap = colorMap
            self.sizeResolver = sizeResolver
            self.opacityResolver = opacityResolver
            self.fontWeightResolver = fontWeightResolver
            self.fontFamilyResolver = fontFamilyResolver
        }

        init(theme: InstUI.Theme, leaves: [InstUI.TokenKey: String]) {
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

        func withLeaves(_ leaves: [InstUI.TokenKey: String]) -> Resolver {
            Resolver(
                colorMap: colorMap,
                sizeResolver: sizeResolver,
                opacityResolver: opacityResolver,
                fontWeightResolver: fontWeightResolver,
                fontFamilyResolver: fontFamilyResolver,
                leaves: leaves
            )
        }

        func color(_ key: InstUI.TokenKey) throws -> Color {
            guard let raw = leaves[key] else { throw InstUI.TokenLoadError.missingToken(key) }
            if raw == "transparent" { return .clear }
            if raw.hasPrefix("{"), raw.hasSuffix("}") {
                let ref = String(raw.dropFirst().dropLast())
                guard let value = colorMap[ref] else { throw InstUI.TokenLoadError.missingToken(ref) }
                return value
            }
            if raw.isRGBAValue { return Color(rgba: raw) }
            if raw.hasPrefix("#") { return Color(hex: raw) }
            throw InstUI.TokenLoadError.invalidValue(raw)
        }

        func dimension(_ key: InstUI.TokenKey) throws -> CGFloat {
            guard let raw = leaves[key] else { throw InstUI.TokenLoadError.missingToken(key) }
            return try sizeResolver.resolve(raw)
        }

        func opacity(_ key: InstUI.TokenKey) throws -> Double {
            guard let raw = leaves[key] else { throw InstUI.TokenLoadError.missingToken(key) }
            return try opacityResolver.resolve(raw)
        }

        func fontWeight(_ key: InstUI.TokenKey) throws -> Font.Weight {
            guard let raw = leaves[key] else { throw InstUI.TokenLoadError.missingToken(key) }
            return try fontWeightResolver.resolve(raw)
        }

        func fontFamily(_ key: InstUI.TokenKey) throws -> String {
            guard let raw = leaves[key] else { throw InstUI.TokenLoadError.missingToken(key) }
            return try fontFamilyResolver.resolve(raw)
        }
    }
}
