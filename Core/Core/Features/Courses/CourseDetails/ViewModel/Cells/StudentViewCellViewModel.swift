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

class StudentViewCellViewModel: CourseDetailsCellViewModel {
    private let env = AppEnvironment.shared
    private var studentViewStudentRequest: APITask?
    private let courseID: String

    public init(course: Course) {
        self.courseID = course.id
        super.init(courseColor: course.color,
                   iconImage: .userLine,
                   label: String(localized: "Student View", bundle: .core),
                   subtitle: String(localized: "Opens in Degrees edX", bundle: .core),
                   accessoryIconType: .externalLink,
                   tabID: "student_view",
                   selectedCallback: nil)
    }

    public override func selected(environment: AppEnvironment, viewController: WeakViewController) {
        accessoryIconType = .loading
        launchStudentView()
    }

    private func launchStudentView() {
        guard studentViewStudentRequest == nil else { return }
        let request = GetStudentViewStudent(courseID: courseID)
        studentViewStudentRequest = env.api.makeRequest(request) { [weak self] user, _, _ in
            self?.handleStudentViewStudentResponse(user)
        }
    }

    private func handleStudentViewStudentResponse(_ user: APIUser?) {
        studentViewStudentRequest = nil
        performUIUpdate { [weak self] in
            self?.accessoryIconType = .externalLink

            guard let user = user else {
                self?.showGenericError = true
                return
            }

            if let loginDelegate = self?.env.loginDelegate {
                loginDelegate.actAsStudentViewStudent(studentViewStudent: user)
            }
        }
    }
}
