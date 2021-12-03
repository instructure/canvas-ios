//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public class CoursePickerViewModel: ObservableObject {
    public typealias Course = IdentifiableName

    @Published public var selectedCourse: CoursePickerViewModel.Course?
    @Published public var state: ViewModelState<[Course]> = .loading

    #if DEBUG

    // MARK: - Preview Support

    public init(state: ViewModelState<[Course]>) {
        self.state = state
    }

    // MARK: Preview Support -

    #endif

    public init() {
        let request = GetCoursesRequest(enrollmentState: .active, perPage: 100)
        AppEnvironment.shared.api.makeRequest(request) { courses, _, error in
            let newState: ViewModelState<[Course]>

            if let courses = courses {
                let validCourses: [Course] = courses.compactMap {
                    guard let name = $0.name else { return nil }
                    return Course(id: $0.id.value, name: name)
                }
                newState = .data(validCourses)
            } else {
                let errorMessage = error?.localizedDescription ?? NSLocalizedString("Something went wrong", comment: "")
                newState = .error(errorMessage)
            }

            performUIUpdate {
                self.state = newState
                self.selectDefaultCourse()
            }
        }
    }

    private func selectDefaultCourse() {
        guard
            case .data(let courses) = state,
            let defaultCourseID = AppEnvironment.shared.userDefaults?.submitAssignmentCourseID,
            let defaultCourse = courses.first(where: { $0.id == defaultCourseID })
        else { return }

        selectedCourse = defaultCourse
    }
}
