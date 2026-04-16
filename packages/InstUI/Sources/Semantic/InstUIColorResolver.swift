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

enum InstUIColorLoadError: Error {
    case missingTokenFile(String)
    case unknownPrimitive(String)
}

struct InstUIColorResolver {
    private let primitivesByName: [String: Color]

    init() {
        primitivesByName = Dictionary(
            InstUI.Primitives.Colors.all.map { ($0.name, $0.color) },
            uniquingKeysWith: { first, _ in first }
        )
    }

    /// Resolves a light/dark token value pair into a single adaptive `Color`.
    /// - Parameters:
    ///   - light: Raw token value from the light theme JSON — hex, rgba, or `{primitive.ref}`
    ///   - dark:  Raw token value from the dark theme JSON — hex, rgba, or `{primitive.ref}`
    func adaptive(light: String, dark: String) throws -> Color {
        Color(light: try resolve(light), dark: try resolve(dark))
    }

    private func resolve(_ raw: String) throws -> Color {
        if raw.isColorToken {
            let inner = String(raw.dropFirst().dropLast())
            guard let color = primitivesByName[inner] else {
                throw InstUIColorLoadError.unknownPrimitive(inner)
            }
            return color
        }
        if raw.isRGBAValue {
            return Color(rgba: raw)
        }
        return Color(hex: raw)
    }
}

private extension String {
    var isColorToken: Bool { hasPrefix("{") }
    var isRGBAValue: Bool { lowercased().hasPrefix("rgba") }
}
