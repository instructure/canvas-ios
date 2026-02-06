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
    let displayName: String
    var isShowingErrorAlert = false
    private(set) var errorAlert = ErrorAlertViewModel()
    private(set) var isAccepting: Bool = false
    private(set) var isDeclining: Bool = false
    var isProcessing: Bool { isAccepting || isDeclining }

    private let courseId: String
    private let interactor: CoursesInteractor
    private let snackBarViewModel: SnackBarViewModel
    private let onDismiss: (String) -> Void
    private var subscriptions = Set<AnyCancellable>()

    init(
        id: String,
        courseId: String,
        courseName: String,
        sectionName: String?,
        interactor: CoursesInteractor,
        snackBarViewModel: SnackBarViewModel,
        onDismiss: @escaping (String) -> Void
    ) {
        self.id = id
        self.courseId = courseId
        self.interactor = interactor
        self.snackBarViewModel = snackBarViewModel
        self.onDismiss = onDismiss

        if let sectionName, sectionName.isNotEmpty, sectionName != courseName {
            self.displayName = "\(courseName), \(sectionName)"
        } else {
            self.displayName = courseName
        }
    }

    func accept() {
        if isProcessing { return }

        isAccepting = true
        interactor.acceptInvitation(courseId: courseId, enrollmentId: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                isAccepting = false
                if completion.isFailure {
                    errorAlert.message = String(localized: "Failed to accept invitation. Please try again.", bundle: .student)
                    isShowingErrorAlert = true
                }
            } receiveValue: { [weak self] _ in
                if let self {
                    snackBarViewModel.showSnack(
                        String(localized: "Accepted invitation to \(displayName)", bundle: .student)
                    )
                    onDismiss(id)
                }
            }
            .store(in: &subscriptions)
    }

    func decline() {
        if isProcessing { return }

        isDeclining = true
        interactor.declineInvitation(courseId: courseId, enrollmentId: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isDeclining = false
                if case .failure = completion {
                    self.errorAlert.message = String(localized: "Failed to decline invitation. Please try again.", bundle: .student)
                    self.isShowingErrorAlert = true
                }
            } receiveValue: { [weak self] _ in
                if let self {
                    self.snackBarViewModel.showSnack(
                        String(localized: "Declined invitation to \(self.displayName)", bundle: .student)
                    )
                    self.onDismiss(self.id)
                }
            }
            .store(in: &subscriptions)
    }
}

extension CourseInvitationCardViewModel: Equatable {
    static func == (lhs: CourseInvitationCardViewModel, rhs: CourseInvitationCardViewModel) -> Bool {
        lhs.id == rhs.id &&
        lhs.displayName == rhs.displayName &&
        lhs.isAccepting == rhs.isAccepting &&
        lhs.isDeclining == rhs.isDeclining &&
        lhs.errorAlert == rhs.errorAlert
    }
}
