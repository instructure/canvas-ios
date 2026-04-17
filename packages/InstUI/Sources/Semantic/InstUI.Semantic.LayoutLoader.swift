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

import CoreGraphics
import Foundation
import SwiftUI

public extension InstUI.Semantic {

    struct LayoutSections: Sendable {
        public let size: Size
        public let spacing: Spacing
        public let borderRadius: BorderRadius
        public let borderWidth: BorderWidth
        public let fontSize: FontSize
        public let opacity: Opacity
        public let fontWeights: FontWeights
        public let fontFamilies: FontFamilies
    }

    final class LayoutLoader: Sendable {
        private let url: URL

        public init() throws {
            guard let url = Bundle.module.url(forResource: "default", withExtension: "json") else {
                throw InstUI.TokenLoadError.missingTokenFile("Bundled layout JSON not found")
            }
            self.url = url
        }

        public init(url: URL) {
            self.url = url
        }

        public func load() throws -> LayoutSections {
            let data = try Data(contentsOf: url)

            let sizeResolver = InstUI.SizeResolver()
            let opacityResolver = InstUI.OpacityResolver()
            let fontWeightResolver = InstUI.FontWeightResolver()
            let fontFamilyResolver = InstUI.FontFamilyResolver()

            let sizeLeaves = try InstUI.TokenExtractor.extractLeaves(from: data, section: "size")
            let spacingLeaves = try InstUI.TokenExtractor.extractLeaves(from: data, section: "spacing")
            let borderRadiusLeaves = try InstUI.TokenExtractor.extractLeaves(from: data, section: "borderRadius")
            let borderWidthLeaves = try InstUI.TokenExtractor.extractLeaves(from: data, section: "borderWidth")
            let fontSizeLeaves = try InstUI.TokenExtractor.extractLeaves(from: data, section: "fontSize")
            let opacityLeaves = try InstUI.TokenExtractor.extractLeaves(from: data, section: "opacity")
            let fontWeightLeaves = try InstUI.TokenExtractor.extractLeaves(from: data, section: "fontWeight")
            let fontFamilyLeaves = try InstUI.TokenExtractor.extractLeaves(from: data, section: "fontFamily")

            func cgFloat(from leaves: [InstUI.TokenKey: String]) -> (InstUI.TokenKey) throws -> CGFloat {
                { path in
                    guard let raw = leaves[path] else { throw InstUI.TokenLoadError.missingTokenFile(path) }
                    return try sizeResolver.resolve(raw)
                }
            }
            func opacity(_ path: InstUI.TokenKey) throws -> Double {
                guard let raw = opacityLeaves[path] else { throw InstUI.TokenLoadError.missingTokenFile(path) }
                return try opacityResolver.resolve(raw)
            }
            func fontWeight(_ path: InstUI.TokenKey) throws -> Font.Weight {
                guard let raw = fontWeightLeaves[path] else { throw InstUI.TokenLoadError.missingTokenFile(path) }
                return try fontWeightResolver.resolve(raw)
            }
            func fontFamily(_ path: InstUI.TokenKey) throws -> String {
                guard let raw = fontFamilyLeaves[path] else { throw InstUI.TokenLoadError.missingTokenFile(path) }
                return try fontFamilyResolver.resolve(raw)
            }

            return try LayoutSections(
                size: Size.build(cgFloat(from: sizeLeaves)),
                spacing: Spacing.build(cgFloat(from: spacingLeaves)),
                borderRadius: BorderRadius.build(cgFloat(from: borderRadiusLeaves)),
                borderWidth: BorderWidth.build(cgFloat(from: borderWidthLeaves)),
                fontSize: FontSize.build(cgFloat(from: fontSizeLeaves)),
                opacity: Opacity.build(opacity),
                fontWeights: FontWeights.build(fontWeight),
                fontFamilies: FontFamilies.build(fontFamily)
            )
        }
    }
}
