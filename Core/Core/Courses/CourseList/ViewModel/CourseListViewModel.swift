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

public class CourseListViewModel: ObservableObject {
    public enum ViewModelState<T: Equatable>: Equatable {
        case loading
        case empty
        case data(T)
        case error(String)
    }
    public struct Sections: Equatable {
        public let current: [Course]
        public let past: [Course]
        public let future: [Course]
    }

    @Published public private(set) var state = ViewModelState<Sections>.loading
    public var filter = "" {
        didSet {
            guard case .data = state else { return }
            state = .data(sections)
        }
    }

    private let courseSectionStatus = CourseSectionStatus()
    private lazy var allCourses: Store<GetAllCourses> = AppEnvironment.shared.subscribe(GetAllCourses()) { [weak self] in
        self?.update()
    }

    public init() {
    }

#if DEBUG

    // MARK: - Preview Support

    public init(state: ViewModelState<Sections>) {
        self.state = state
    }

    // MARK: Preview Support -

#endif

    public func viewDidAppear() {
        allCourses.exhaust()
        courseSectionStatus.refresh { [weak self] in
            self?.update()
        }
    }

    public func refresh(completion: @escaping () -> Void) {
        allCourses.exhaust(force: true) { _ in
            if self.allCourses.hasNextPage == false {
                completion()
            }
            return true
        }
        courseSectionStatus.refresh { [weak self] in
            self?.update()
        }
    }

    private func update() {
        guard allCourses.requested, !allCourses.pending, !courseSectionStatus.isUpdatePending else { return }

        guard allCourses.state != .error else {
            state = .error(NSLocalizedString("Something went wrong", comment: ""))
            return
        }

        state = .data(sections)
    }

    private var sections: Sections {
        let filter = self.filter.lowercased()
        var current: [Course] = []
        var past: [Course] = []
        var future: [Course] = []

        for course in allCourses {
            let matches = filter.isEmpty ||
                course.name?.lowercased().contains(filter) == true ||
                course.courseCode?.lowercased().contains(filter) == true
            guard !course.accessRestrictedByDate, matches else { continue }
            if course.isFutureEnrollment {
                future.append(course)
            } else if course.isPastEnrollment || courseSectionStatus.isAllSectionsExpired(in: course) || courseSectionStatus.isNoActiveEnrollments(in: course) {
                past.append(course)
            } else {
                current.append(course)
            }
        }
        return Sections(current: current, past: past, future: future)
    }
}
