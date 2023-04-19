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

public class DashboardInvitationViewModel: Identifiable, ObservableObject {
    public enum State: Int, Equatable {
        case active
        case accepted
        case declined
    }
    @Published public private(set) var state: State = .active
    public let name: String
    public var stateText: Text {
        switch state {
        case .active: return Text("You have been invited", bundle: .core)
        case .accepted: return Text("Invite accepted!", bundle: .core)
        case .declined: return Text("Invite declined!", bundle: .core)
        }
    }
    public var id: String { enrollmentId }

    private let courseId: String
    private let enrollmentId: String
    private let onDismiss: ((DashboardInvitationViewModel) -> Void)?
    private var stateChangeAnimationStartTime = Date()

    public init(name: String, courseId: String, enrollmentId: String, onDismiss: ((DashboardInvitationViewModel) -> Void)? = nil) {
        self.name = name
        self.courseId = courseId
        self.enrollmentId = enrollmentId
        self.onDismiss = onDismiss
    }

    public func accept() {
        stateChangeAnimationStartTime = Date()
        withAnimation {
            state = .accepted
        }
        postResponse(isAccepted: true)
    }

    public func decline() {
        stateChangeAnimationStartTime = Date()
        withAnimation {
            state = .declined
        }
        postResponse(isAccepted: false)
    }

    private func postResponse(isAccepted: Bool) {
        let request = HandleCourseInvitationRequest(courseID: courseId, enrollmentID: enrollmentId, isAccepted: isAccepted)
        AppEnvironment.shared.api.makeRequest(request, callback: { [weak self] _, _, _ in
            self?.handleAPIResponse()
        })
    }

    private func handleAPIResponse() {
        let stateChangeAnimationTime: TimeInterval = 1.5
        let elapsedTime = min(Date().timeIntervalSince1970 - stateChangeAnimationStartTime.timeIntervalSince1970, stateChangeAnimationTime)
        let remainingTimeToShowNewState = stateChangeAnimationTime - elapsedTime
        DispatchQueue.main.asyncAfter(deadline: .now() + remainingTimeToShowNewState) {
            self.onDismiss?(self)
        }
    }
}
