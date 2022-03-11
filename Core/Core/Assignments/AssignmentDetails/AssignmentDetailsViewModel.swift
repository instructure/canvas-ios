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

public class AssignmentDetailsViewModel: ObservableObject {

    @Environment(\.appEnvironment) private var env

    public let assignmentID: String
    public let courseID: String

    public var assignment: Store<GetAssignment>

    @Published public private(set) var courseColor: UIColor?
    public var title: String { NSLocalizedString("Assignment Details", comment: "") }
    public var subtitle: String { course.first?.name ?? "" }
    public var showSubmissions: Bool { course.first?.enrollments?.contains(where: { $0.isTeacher || $0.isTA }) == true }

    private lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.courseDidUpdate()
    }

    public init(courseID: String, assignmentID: String) {
        self.assignmentID = assignmentID
        self.courseID = courseID

        assignment = AppEnvironment.shared.subscribe(GetAssignment(courseID: courseID, assignmentID: assignmentID))
        course = AppEnvironment.shared.subscribe(GetCourse(courseID: courseID))
    }

    public func viewDidAppear() {
        assignment.refresh()
        course.refresh()
    }

    public func editTapped(router: Router, viewController: WeakViewController) {
        env.router.route(
            to: "courses/\(courseID)/assignments/\(assignmentID)/edit",
            from: viewController,
            options: .modal(.formSheet, isDismissable: false, embedInNav: true)
        )
    }

    func launchLTITool(router: Router, viewController: WeakViewController) {
        LTITools.launch(
            context: "course_\(courseID)",
            id: assignment.first?.externalToolContentID,
            url: nil,
            launchType: "assessment",
            assignmentID: assignmentID,
            from: viewController.value
        )
    }

    private func courseDidUpdate() {
        courseColor = course.first?.color
    }
}

