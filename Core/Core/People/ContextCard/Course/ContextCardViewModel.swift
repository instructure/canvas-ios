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

import Combine
import SwiftUI

public class ContextCardViewModel: ObservableObject {
    @Published public var pending = true
    public lazy var user = env.subscribe(GetCourseSingleUser(context: context, userID: userID)) { [weak self] in self?.updateLoadingState() }
    public lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in self?.updateLoadingState() }
    public lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in self?.updateLoadingState() }
    public lazy var sections = env.subscribe(GetCourseSections(courseID: courseID)) { [weak self] in self?.updateLoadingState() }
    public lazy var submissions = env.subscribe(GetSubmissionsForStudent(context: context, studentID: userID)) { [weak self] in self?.updateLoadingState() }
    public lazy var permissions = env.subscribe(GetContextPermissions(context: context, permissions: [ .sendMessages ])) { [weak self] in self?.updateLoadingState() }
    public lazy var gradingPeriods = env.subscribe(GetGradingPeriods(courseID: courseID)) { [weak self] in self?.gradingPeriodsDidUpdate() }

    public var apiUser: APIUser?
    public let isViewingAnotherUser: Bool
    public let context: Context
    public let isSubmissionRowsVisible: Bool
    public let isLastActivityVisible: Bool
    public let isModal: Bool
    public var enrollment: Enrollment?
    public var hideQuantitativeData: Bool {
        course.first?.hideQuantitativeData == true
    }

    private let env = AppEnvironment.shared
    private var isFirstAppear = true
    private let courseID: String
    private let userID: String
    private var userAPICallResponsePending = true
    private var enrollmentsAPICallResponsePending = true
    private var currentGradingPeriodID: String?

    public init(courseID: String, userID: String, currentUserID: String, isSubmissionRowsVisible: Bool = true, isLastActivityVisible: Bool = true, isModal: Bool = false) {
        self.courseID = courseID
        self.userID = userID
        self.context = Context.course(courseID)
        self.isViewingAnotherUser = (userID != currentUserID)
        self.isSubmissionRowsVisible = isSubmissionRowsVisible
        self.isLastActivityVisible = isLastActivityVisible
        self.isModal = isModal
    }

    public func viewAppeared() {
        guard isFirstAppear else { return }
        isFirstAppear = false
        user.refresh(force: true) { [weak self] response in
            self?.apiUser = response
            self?.userAPICallResponsePending = false
            self?.updateLoadingState()
        }
        course.refresh()
        colors.refresh()
        sections.refresh()
        submissions.exhaust(force: true)
        permissions.refresh()
        gradingPeriods.refresh()
    }

    func gradingPeriodsDidUpdate() {
        if gradingPeriods.pending == false && gradingPeriods.requested {
            currentGradingPeriodID = gradingPeriods.all.current?.id
            let request = GetEnrollmentsRequest(context: context, gradingPeriodID: currentGradingPeriodID, states: [ .active ])
            env.api.exhaust(request) { [weak self] (enrollments, _, _) in performUIUpdate {
                    guard let self = self else { return }

                    let apiEnrollment = enrollments?.first {
                        $0.id != nil &&
                        $0.enrollment_state == .active &&
                        $0.user_id.value == self.userID
                    }
                    if let apiEnrollment = apiEnrollment, let id = apiEnrollment.id?.value {
                        let databaseContext = self.env.database.viewContext
                        let enrollment: Enrollment = databaseContext.first(where: #keyPath(Enrollment.id), equals: id) ?? databaseContext.insert()
                        enrollment.update(fromApiModel: apiEnrollment, course: nil, in: databaseContext)
                        self.enrollment = enrollment
                    }
                    self.enrollmentsAPICallResponsePending = false
                    self.updateLoadingState()
                }
            }
        }
    }

    public func assignment(with id: String) -> Assignment? {
        env.database.viewContext.first(where: #keyPath(Assignment.id), equals: id)
    }

    public func openNewMessageComposer(controller: UIViewController) {
        guard let course = course.first, let user = user.first else { return }
        let recipient: [String: Any?] = [
            "id": user.id,
            "name": user.name,
            "avatar_url": user.avatarURL?.absoluteString,
        ]
        env.router.route(to: "/conversations/compose", userInfo: [
            "recipients": [recipient],
            "contextName": course.name ?? "",
            "contextCode": context.canvasContextID,
            "canSelectCourse": false,
        ], from: controller, options: .modal(embedInNav: true))
    }

    private func updateLoadingState() {
        let newPending = user.pending || !user.requested ||
            course.pending ||
            colors.pending ||
            sections.pending ||
            submissions.pending || !submissions.requested || submissions.hasNextPage ||
            permissions.pending ||
            gradingPeriods.pending ||
            enrollmentsAPICallResponsePending ||
            userAPICallResponsePending
        if newPending == true { return }
        pending = newPending
    }
}
