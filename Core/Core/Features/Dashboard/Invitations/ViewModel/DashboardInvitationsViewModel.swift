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

public class DashboardInvitationsViewModel: ObservableObject {
    // MARK: - Public Properties
    @Published public private(set) var items: [DashboardInvitationViewModel] = []
    public lazy var coursesChanged: AnyPublisher<Void, Never> = coursesChangedSubject
        .delay(for: 1, scheduler: RunLoop.main) // we delay a sec to allow the invitation remove animation to finish on the parent view
        .eraseToAnyPublisher()

    // MARK: - Private Properties
    private var isLoading: Bool = false
    private let env: AppEnvironment
    private let coursesChangedSubject = PassthroughSubject<Void, Never>()

    // MARK: - Public Methods

    public init(env: AppEnvironment = .shared) {
        self.env = env
        self.requestInvitations()
    }

    public func refresh() {
        // Skip if there is a request in place
        if isLoading { return }

        requestInvitations()
    }

    // MARK: - Private Methods

    private func requestInvitations() {
        isLoading = true

        let request = GetEnrollmentsRequest(context: .currentUser, states: [.invited, .current_and_future])
        env.api.makeRequest(request) { [weak self] invitations, _, _ in
            self?.requestCourses(for: (invitations ?? []).invitationAPIItems)
        }
    }

    private func requestCourses(for items: [DashboardInvitationAPIItem]) {
        if items.isEmpty {
            performUIUpdate {
                self.isLoading = false
                self.items = []
            }
            return
        }

        let request = GetCoursesRequest(enrollmentState: .invited_or_pending, perPage: 100)
        env.api.makeRequest(request) { [weak self] courses, _, _ in
            let invitations = Self.makeInvitations(from: items, courses: courses ?? [], onDismiss: { invitation in
                withAnimation {
                    self?.items.removeAll { $0.id == invitation.id }
                }

                if invitation.state == .accepted {
                    self?.coursesChangedSubject.send()
                }
            })
            performUIUpdate {
                self?.isLoading = false
                self?.items = invitations
            }
        }
    }

    private static func makeInvitations(from items: [DashboardInvitationAPIItem], courses: [APICourse], onDismiss: @escaping (DashboardInvitationViewModel) -> Void) -> [DashboardInvitationViewModel] {
        let invitations: [DashboardInvitationViewModel] = items.reduce(into: []) { partialResult, enrollmentItem in
            guard let course = courses.first(where: { $0.id == enrollmentItem.courseId }) else { return }

            let displayName = String.dashboardInvitationName(courseName: course.name, sectionName: course.sections?.first { $0.id == enrollmentItem.sectionId }?.name)
            let invitation = DashboardInvitationViewModel(name: displayName,
                                                          courseId: course.id.value,
                                                          enrollmentId: enrollmentItem.enrollmentId.value,
                                                          offlineModeInteractor: OfflineModeAssembly.make(),
                                                          onDismiss: onDismiss)
            partialResult.append(invitation)
        }
        return invitations
    }
}
