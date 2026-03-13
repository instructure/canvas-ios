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

protocol LearnerDashboardColorInteractor: AnyObject {
    var availableColors: [CourseColorData] { get }
    var dashboardColor: CurrentValueSubject<Color, Never> { get }
    func selectColor(_ color: Color)
}

final class LearnerDashboardColorInteractorLive: LearnerDashboardColorInteractor {
    var availableColors: [CourseColorData] { Self.allColors }
    let dashboardColor: CurrentValueSubject<Color, Never>

    private var defaults: SessionDefaults

    init(defaults: SessionDefaults) {
        self.defaults = defaults
        let savedId = defaults.learnerDashboardColorId
        let initialColor = Self.allColors.first(where: { $0.persistentId == savedId })?.color.asColor ?? Self.defaultColor
        self.dashboardColor = CurrentValueSubject(initialColor)
    }

    func selectColor(_ color: Color) {
        guard let colorData = availableColors.first(where: { $0.color.asColor == color }) else {
            return
        }

        defaults.learnerDashboardColorId = colorData.persistentId
        dashboardColor.send(color)
    }
}

extension LearnerDashboardColorInteractorLive {

    private static let defaultColor: Color = CourseColorData.all[0].color.asColor
    private static let allColors: [CourseColorData] = {
        let courseColors = CourseColorData.all
        let additionalColors = [
            CourseColorData(
                persistentId: "black",
                color: UIColor.backgroundDarkest,
                name: String(localized: "Black", bundle: .core, comment: "This is a name of a color.")
            )
        ]
        return courseColors + additionalColors
    }()
}
