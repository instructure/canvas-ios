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

    /// Initializes a `Color` from a hex string in **RGBA** order.
    /// Supported formats: `#RGB`, `#RRGGBB`, `#RRGGBBAA`.
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch hex.count {
        case 3:
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6:
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8:
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (255, 0, 255, 255)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }

    /// Initializes a `Color` from an rgba string.
    /// Supported format: `rgba(r, g, b, a)` where r/g/b are 0–255 integers and a is a 0.0–1.0 decimal.
    /// Falls back to magenta on invalid input.
    init(rgba: String) {
        let trimmed = rgba.trimmingCharacters(in: .whitespaces)
        guard trimmed.lowercased().hasPrefix("rgba("), trimmed.hasSuffix(")") else {
            self.init(.sRGB, red: 1, green: 0, blue: 1, opacity: 1)
            return
        }
        let parts = trimmed.dropFirst(5).dropLast()
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
        guard parts.count == 4,
              let r = Double(parts[0]),
              let g = Double(parts[1]),
              let b = Double(parts[2]),
              let a = Double(parts[3]) else {
            self.init(.sRGB, red: 1, green: 0, blue: 1, opacity: 1)
            return
        }
        self.init(.sRGB, red: r / 255, green: g / 255, blue: b / 255, opacity: a)
    }

    /// Initializes a light/dark adaptive `Color` resolved at render time via `UITraitCollection`.
    init(light: Color, dark: Color) {
        self = Color(UIColor { traits in
            UIColor(traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}
