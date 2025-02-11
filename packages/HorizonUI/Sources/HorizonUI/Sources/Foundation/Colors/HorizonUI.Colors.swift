//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public extension HorizonUI {
    struct Colors: Sendable {
        fileprivate init() {}
        public let primitives = Primitives()
        public let icon = IconColor()
        public let text = TextColor()
        public let surface = Surface()
        public let lineAndBorders = LineAndBorders()
    }

    static let colors = HorizonUI.Colors()

    static func setInstitutionColor(_ color: UIColor) {
        HorizonUI.Colors.Surface.institutionWrapper.color = color
    }
}

extension Color {
    public static let huiColors = HorizonUI.colors
}

// TODO: - Set in if DEBG later
public protocol ColorCollection {}
extension ColorCollection {
    func extractColorsWithIDs() -> [HorizonUI.Colors.ColorWithID] {
        var colorList: [HorizonUI.Colors.ColorWithID] = []
        let mirror = Mirror(reflecting: self)
        let typeName = String(describing: Self.self)
        for child in mirror.children {
            if let name = child.label {
                if let color = child.value as? Color {
                    colorList.append(HorizonUI.Colors.ColorWithID(name, color, id: "\(typeName) \(name)"))
                } else if let gradient = child.value as? [Color] {
                    for (index, gradientColor) in gradient.enumerated() {
                        colorList.append(HorizonUI.Colors.ColorWithID("\(name)\(index)", gradientColor))
                    }
                }
            }
        }
        return colorList
    }
}
