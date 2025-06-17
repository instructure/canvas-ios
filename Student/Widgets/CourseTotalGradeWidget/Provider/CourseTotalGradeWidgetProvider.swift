//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Core
import WidgetKit
import AppIntents

class CourseTotalGradeWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = CourseTotalGradeModel
    typealias Intent = SelectCourseIntent

    private let refreshTime: TimeInterval = 1 * 60 * 60 // 1 hour

    func placeholder(in context: TimelineProviderContext) -> CourseTotalGradeModel {
        CourseTotalGradeModel.publicPreview
    }

    func snapshot(for configuration: SelectCourseIntent, in context: TimelineProviderContext) async -> CourseTotalGradeModel {
        placeholder(in: context)
    }

    func timeline(for configuration: SelectCourseIntent, in context: TimelineProviderContext) async -> Timeline<CourseTotalGradeModel> {

        if context.isPreview {
            return Timeline(
                entries: [placeholder(in: context)],
                policy: .never
            )
        }

        guard CourseTotalGradeInteractor.shared.isLoggedIn else {
            return Timeline(
                entries: [CourseTotalGradeModel(isLoggedIn: false)],
                policy: .after(Date.now.addingTimeInterval(refreshTime))
            )
        }

        guard let course = configuration.course else {
            return Timeline(
                entries: [CourseTotalGradeModel()],
                policy: .never
            )
        }

        let totalGrade = await CourseTotalGradeInteractor
            .shared
            .fetchCourseTotalGrade(courseID: course.id)

        return Timeline(
            entries: [CourseTotalGradeModel(data: totalGrade)],
            policy: .after(Date.now.addingTimeInterval(refreshTime))
        )
    }
}
