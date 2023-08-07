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
    public lazy var user = env.subscribe(GetCourseContextUser(context: context, userID: userID)) { [weak self] in self?.updateLoadingState() }
    public lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in self?.updateLoadingState() }
    public lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in self?.updateLoadingState() }
    public lazy var sections = env.subscribe(GetCourseSections(courseID: courseID)) { [weak self] in self?.updateLoadingState() }
    public lazy var submissions = env.subscribe(GetContextSubmissionsForStudent(context: context, studentID: userID, courseID: courseID)) { [weak self] in self?.updateLoadingState() }
    public lazy var permissions = env.subscribe(GetContextPermissions(context: context, permissions: [ .sendMessages ])) { [weak self] in self?.updateLoadingState() }
    public lazy var gradingPeriods = env.subscribe(GetGradingPeriods(courseID: courseID)) { [weak self] in self?.gradingPeriodsDidUpdate() }

    public let isViewingAnotherUser: Bool
    public let context: Context
    public let isSubmissionRowsVisible: Bool
    public let isLastActivityVisible: Bool
    public let isModal: Bool
    public var enrollment: ContextEnrollment?

    private let env = AppEnvironment.shared
    private var isFirstAppear = true
    private let courseID: String
    private let userID: String
    private var enrollmentsAPICallResponsePending = true
    private var currentGradingPeriodID: String?
    private let offlineModeViewModel: OfflineModeViewModel

    private var subscriptions = Set<AnyCancellable>()

    public init(courseID: String, userID: String, currentUserID: String,
                isSubmissionRowsVisible: Bool = true, isLastActivityVisible: Bool = true, isModal: Bool = false,
                offlineModeViewModel: OfflineModeViewModel = OfflineModeViewModel(interactor: OfflineModeInteractorLive.shared)) {
        self.courseID = courseID
        self.userID = userID
        self.context = Context.course(courseID)
        self.isViewingAnotherUser = (userID != currentUserID)
        self.isSubmissionRowsVisible = isSubmissionRowsVisible
        self.isLastActivityVisible = isLastActivityVisible
        self.isModal = isModal
        self.offlineModeViewModel = offlineModeViewModel
    }

    public func viewAppeared() {
        guard isFirstAppear else { return }
        isFirstAppear = false
        user.refresh(force: true)
        course.refresh()
        colors.refresh()
        sections.refresh()
        submissions.exhaust(force: true)
        permissions.refresh()
        gradingPeriods.refresh()
    }

    func gradingPeriodsDidUpdate() {
        if offlineModeViewModel.isOffline {
            let predicates = [
                NSPredicate(format: "%K != nil", #keyPath(ContextEnrollment.id)),
                NSPredicate(key: #keyPath(ContextEnrollment.stateRaw), equals: EnrollmentState.active.rawValue),
                NSPredicate(key: #keyPath(ContextEnrollment.canvasContextID), equals: "course_\(courseID)"),
                NSPredicate(key: #keyPath(ContextEnrollment.userID), equals: userID),
            ]
            let scope = Scope(predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), order: [])
            let databaseContext = self.env.database.viewContext
            enrollment = databaseContext.fetch(scope: scope).first
            enrollmentsAPICallResponsePending = false
            pending = false
            return
        }
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
                        let enrollment: ContextEnrollment = databaseContext.first(where: #keyPath(ContextEnrollment.id), equals: id) ?? databaseContext.insert()
                        enrollment.update(fromApiModel: apiEnrollment, course: nil, in: databaseContext)
                        self.enrollment = enrollment
                    }
                    self.enrollmentsAPICallResponsePending = false
                    self.updateLoadingState()
                }
            }
        }
    }

    public func assignment(with id: String) -> ContextAssignment? {
        env.database.viewContext.first(where: #keyPath(ContextAssignment.id), equals: id)
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

        if !submissions.pending {
            submissions.all.forEach {
                print($0.assignment?.courseID)
            }
        }

        let newPending = user.pending || !user.requested ||
            course.pending ||
            colors.pending ||
            sections.pending ||
            submissions.pending || !submissions.requested || submissions.hasNextPage ||
            permissions.pending ||
            gradingPeriods.pending ||
            enrollmentsAPICallResponsePending
        if newPending == true { return }
        pending = newPending
    }
}
