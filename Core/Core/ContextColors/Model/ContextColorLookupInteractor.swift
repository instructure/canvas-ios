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

import Foundation

/// This class is responsible for calculating context colors from an API response.
public protocol ContextColorLookupInteractor {
    typealias HexColor = String

    func contextColors(from apiResponse: APIContextColorsResponse) -> [Context: HexColor]
}

public class ContextColorLookupInteractorLive: ContextColorLookupInteractor {

    public init() {}

    public func contextColors(from apiResponse: APIContextColorsResponse) -> [Context: HexColor] {
        let elementaryCourseContexts: [Context] = apiResponse.dashboardCards.compactMap { dashboardCard in
            guard dashboardCard.isK5Subject == true else {
                return nil
            }

            return Context(canvasContextID: dashboardCard.assetString)
        }

        let isElementaryCourse: (Context) -> Bool = { context in
            elementaryCourseContexts.contains(context)
        }
        let elementaryColorForCourse: (Context) -> HexColor = { context in
            let course = apiResponse.courses.first { $0.context == context }
            return course?.course_color ?? UIColor.defaultElementaryColor.hexString
        }
        let customColorFor: (Context) -> HexColor = { context in
            apiResponse.customColors.custom_colors[context.canvasContextID] ?? UIColor.defaultContextColor.hexString
        }
        let colorForCourse: (Context) -> HexColor = { context in
            if isElementaryCourse(context) {
                return elementaryColorForCourse(context)
            } else {
                return customColorFor(context)
            }
        }

        let contextColors: [Context: HexColor] = {
            var colorMap: [Context: HexColor] = [:]

            for course in apiResponse.courses {
                colorMap[course.context] = colorForCourse(course.context)
            }
            for group in apiResponse.groups {
                if let groupCourseContext = group.courseContext {
                    colorMap[group.context] = colorForCourse(groupCourseContext)
                } else {
                    colorMap[group.context] = customColorFor(group.context)
                }
            }
            // Save user colors for calendar events
            let userCanvasContextIDs = apiResponse.customColors.custom_colors.keys.filter { $0.starts(with: "user_") }
            let userContexts = userCanvasContextIDs.compactMap { Context(canvasContextID: $0) }

            for userContext in userContexts {
                colorMap[userContext] = apiResponse.customColors.custom_colors[userContext.canvasContextID]
            }

            return colorMap
        }()

        return contextColors
    }
}

extension UIColor {

    static var defaultContextColor: UIColor { .ash }
    static var defaultElementaryColor: UIColor { .oxford }
}
