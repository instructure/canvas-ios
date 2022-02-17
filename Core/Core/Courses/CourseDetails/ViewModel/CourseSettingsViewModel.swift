//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public class CourseSettingsViewModel: ObservableObject {
    public enum ViewModelState: Equatable {
        case loading
        case saving
        case ready
    }

    @Published public private(set) var state: ViewModelState = .loading
    @Published public private(set) var courseColor: UIColor?
    @Published public private(set) var courseName: String?
    @Published public private(set) var defaultView: CourseDefaultView?

    @Environment(\.appEnvironment) private var env

    private var context: Context
    private lazy var colors = env.subscribe(GetCustomColors())
    private lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.courseDidUpdate()
    }

    public init(context: Context) {
        self.context = context
    }

    public func viewDidAppear() {
        course.refresh()
        colors.refresh()
    }

    private func courseDidUpdate() {
        guard let course = course.first else { return }
        courseColor = course.color
        courseName = course.name
        getCourseImage(course: course)
    }

    private func getCourseImage(course: Course) {
        let hideColorOverlay = 

    }
}
