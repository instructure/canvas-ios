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

#if DEBUG

import Combine
import Core
import Foundation

extension CoursesAndGroupsWidgetInteractor where Self == CoursesAndGroupsWidgetInteractorMock {
    static func preview(
        mockCourses: [CoursesAndGroupsWidgetCourseItem] = CourseCardView.previewData,
        mockGroups: [CoursesAndGroupsWidgetGroupItem] = GroupCardView.previewData
    ) -> CoursesAndGroupsWidgetInteractorMock {
        let interactor = CoursesAndGroupsWidgetInteractorMock()
        interactor.getCoursesAndGroupsOutput = (mockCourses, mockGroups)
        return interactor
    }
}

final class CoursesAndGroupsWidgetInteractorMock: CoursesAndGroupsWidgetInteractor {

    // MARK: - showGrades

    let showGrades: CurrentValueSubject<Bool, Never> = .init(false)

    // MARK: - showColorOverlay

    let showColorOverlay: CurrentValueSubject<Bool, Never> = .init(true)

    // MARK: - getCoursesAndGroups

    var getCoursesAndGroupsCallCount: Int = 0
    var getCoursesAndGroupsInput: Bool?
    var getCoursesAndGroupsOutput: Model = ([], [])
    var getCoursesAndGroupsOutputError: Error?

    func getCoursesAndGroups(ignoreCache: Bool) -> AnyPublisher<Model, Error> {
        getCoursesAndGroupsInput = ignoreCache
        getCoursesAndGroupsCallCount += 1

        if let error = getCoursesAndGroupsOutputError {
            return Publishers.typedFailure(error: error)
        }

        return Publishers.typedJust(getCoursesAndGroupsOutput)
    }

    // MARK: - reorderCourses

    var reorderCoursesCallCount: Int = 0
    var reorderCoursesInput: [String]?

    func reorderCourses(newOrder: [String]) {
        reorderCoursesCallCount += 1
        reorderCoursesInput = newOrder
    }
}

#endif
