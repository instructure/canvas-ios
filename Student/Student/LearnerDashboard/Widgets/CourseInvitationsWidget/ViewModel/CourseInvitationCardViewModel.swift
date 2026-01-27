//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Core
import Foundation
import Observation
import UIKit

@Observable
final class CourseInvitationCardViewModel: Identifiable {
    let id: String
    let courseId: String
    let courseName: String
    let sectionName: String?

    private(set) var isLoadingAccept: Bool = false
    private(set) var isLoadingDecline: Bool = false
    var error: CourseInvitationError?

    var isProcessing: Bool {
        isLoadingAccept || isLoadingDecline
    }

    var displayName: String {
        if let sectionName, sectionName != courseName {
            return "\(courseName), \(sectionName)"
        }
        return courseName
    }

    private let interactor: CoursesInteractor
    private let offlineModeInteractor: OfflineModeInteractor
    private let onDismiss: (String) -> Void
    private var subscriptions = Set<AnyCancellable>()

    init(
        id: String,
        courseId: String,
        courseName: String,
        sectionName: String?,
        interactor: CoursesInteractor,
        offlineModeInteractor: OfflineModeInteractor,
        onDismiss: @escaping (String) -> Void
    ) {
        self.id = id
        self.courseId = courseId
        self.courseName = courseName
        self.sectionName = sectionName
        self.interactor = interactor
        self.offlineModeInteractor = offlineModeInteractor
        self.onDismiss = onDismiss
    }

    func accept() {
        if isProcessing { return }
        if offlineModeInteractor.isOfflineModeEnabled() {
            UIAlertController.showItemNotAvailableInOfflineAlert()
            return
        }

        isLoadingAccept = true
        interactor.acceptInvitation(courseId: courseId, enrollmentId: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if let self {
                    self.isLoadingAccept = false
                    if case .failure = completion {
                        self.error = CourseInvitationError(
                            title: String(localized: "Error", bundle: .core),
                            message: String(localized: "Failed to accept invitation. Please try again.", bundle: .student)
                        )
                    }
                }
            } receiveValue: { [weak self] _ in
                if let self {
                    self.onDismiss(self.id)
                }
            }
            .store(in: &subscriptions)
    }

    func decline() {
        if isProcessing { return }
        if offlineModeInteractor.isOfflineModeEnabled() {
            UIAlertController.showItemNotAvailableInOfflineAlert()
            return
        }

        isLoadingDecline = true
        interactor.declineInvitation(courseId: courseId, enrollmentId: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if let self {
                    self.isLoadingDecline = false
                    if case .failure = completion {
                        self.error = CourseInvitationError(
                            title: String(localized: "Error", bundle: .core),
                            message: String(localized: "Failed to decline invitation. Please try again.", bundle: .student)
                        )
                    }
                }
            } receiveValue: { [weak self] _ in
                if let self {
                    self.onDismiss(self.id)
                }
            }
            .store(in: &subscriptions)
    }
}

struct CourseInvitationError: Identifiable {
    var id: String { UUID.string }
    let title: String
    let message: String
}
