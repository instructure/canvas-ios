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

import Combine
import Core
import SwiftUI

struct LearnerDashboardColorData: Identifiable {
    let color: Color
    let description: String

    var id: String { description }
}

protocol LearnerDashboardColorInteractor: AnyObject {
    var availableColors: [LearnerDashboardColorData] { get }
    var dashboardColor: CurrentValueSubject<Color, Never> { get }
    func selectColor(_ color: Color)
}

final class LearnerDashboardColorInteractorLive: LearnerDashboardColorInteractor {
    var availableColors: [LearnerDashboardColorData] { Self.allColors }
    let dashboardColor: CurrentValueSubject<Color, Never>

    private var defaults: SessionDefaults

    init(defaults: SessionDefaults) {
        self.defaults = defaults
        let index = defaults.learnerDashboardColorIndex
        let initialColor: Color
        if let index, Self.allColors.indices.contains(index) {
            initialColor = Self.allColors[index].color
        } else {
            initialColor = Self.defaultColor
        }
        self.dashboardColor = CurrentValueSubject(initialColor)
    }

    func selectColor(_ color: Color) {
        guard let index = availableColors.firstIndex(where: { $0.color == color }) else {
            return
        }

        defaults.learnerDashboardColorIndex = index
        dashboardColor.send(color)
    }
}

extension LearnerDashboardColorInteractorLive {

    private static let defaultColor: Color = Color(CourseColorsInteractorLive.colors[0].key)
    private static let allColors: [LearnerDashboardColorData] = {
        let courseColors = CourseColorsInteractorLive.colors.map {
            LearnerDashboardColorData(color: $0.key.asColor, description: $0.value)
        }
        let additionalColors = [
            LearnerDashboardColorData(
                color: .backgroundLightest.variantForLightMode,
                description: String(localized: "White", bundle: .core, comment: "This is a name of a color.")
            ),
            LearnerDashboardColorData(
                color: .backgroundLightest.variantForDarkMode,
                description: String(localized: "Black", bundle: .core, comment: "This is a name of a color.")
            )
        ]
        return courseColors + additionalColors
    }()
}
