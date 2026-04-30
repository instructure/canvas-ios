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
    struct ColorResolver {
        private let primitivesByName: [TokenKey: Color]

        init() {
            primitivesByName = Dictionary(
                InstUI.Primitive.Color.all.map { ($0.name, $0.color) },
                uniquingKeysWith: { $1 }
            )
        }

        func adaptive(light: String, dark: String) throws -> Color {
            Color(light: try resolve(light), dark: try resolve(dark))
        }

        private func resolve(_ raw: String) throws -> Color {
            if raw.isColorToken {
                let inner = String(raw.dropFirst().dropLast())
                guard let color = primitivesByName[inner] else {
                    throw InstUI.TokenLoadError.unknownPrimitive(inner)
                }
                return color
            }
            if raw.isRGBAValue {
                return Color(rgba: raw)
            }
            return Color(hex: raw)
        }
    }
}

private extension String {
    var isColorToken: Bool { hasPrefix("{") }
}

extension String {
    var isRGBAValue: Bool { lowercased().hasPrefix("rgba") }
}
