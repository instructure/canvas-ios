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

extension InstUI {
    struct SizeResolver {
        private let map: [TokenKey: CGFloat]

        init() {
            map = Dictionary(
                InstUI.Primitive.Size.all.map { ($0.name, $0.size) },
                uniquingKeysWith: { first, _ in first }
            )
        }

        init(map: [TokenKey: CGFloat]) {
            self.map = map
        }

        func resolve(_ raw: String) throws -> CGFloat {
            if raw.hasPrefix("{") {
                let inner = String(raw.dropFirst().dropLast())
                guard let size = map[inner] else {
                    throw InstUI.TokenLoadError.unknownPrimitive(inner)
                }
                return size
            }
            // 1rem = 1em = 16pt, matching the standard CSS base font size used by design tokens
            if raw.hasSuffix("rem"), let value = Double(raw.dropLast(3)) {
                return CGFloat(value * 16)
            }
            if raw.hasSuffix("em"), let value = Double(raw.dropLast(2)) {
                return CGFloat(value * 16)
            }
            // 1px = 1pt (logical pixels map 1:1 to points in design tokens)
            if raw.hasSuffix("px"), let value = Double(raw.dropLast(2)) {
                return CGFloat(value)
            }
            if let value = Double(raw) {
                return CGFloat(value)
            }
            throw InstUI.TokenLoadError.unknownPrimitive(raw)
        }
    }
}
