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
import CoreData
import SwiftUI

class SubmissionGraderViewModel: ObservableObject {

    // MARK: - Outputs

    @Published private(set) var selectedAttemptIndex: Int
    @Published private(set) var selectedAttempt: Submission
    @Published private(set) var attempts: [Submission] = []
    @Published private(set) var hasSubmissions = false
    @Published private(set) var isSingleSubmission = false
    @Published private(set) var file: File?
    @Published private(set) var fileID: String?
    @Published private(set) var fileTabTitle: String = ""
    @Published private(set) var contextColor = Color(Brand.shared.primary)
    let assignment: Assignment
    let submission: Submission

    // sub-viewmodels
    private(set) var studentAnnotationViewModel: StudentAnnotationSubmissionViewerViewModel
    let commentListViewModel: SubmissionCommentListViewModel

    // MARK: - Inputs

    /** This is mainly used by `SubmissionCommentList` but since it's re-created on rotation and app backgrounding the entered text is lost. */
    @Published var enteredComment: String = ""

    private let env: AppEnvironment
    private var subscriptions = Set<AnyCancellable>()

    init(
        assignment: Assignment,
        latestSubmission: Submission,
        contextColor: AnyPublisher<Color, Never>,
        env: AppEnvironment
    ) {
        self.assignment = assignment
        self.submission = latestSubmission
        selectedAttempt = latestSubmission
        selectedAttemptIndex = latestSubmission.attempt
        studentAnnotationViewModel = StudentAnnotationSubmissionViewerViewModel(submission: submission)
        commentListViewModel = SubmissionCommentsAssembly.makeCommentListViewModel(
            assignment: assignment,
            latestSubmission: latestSubmission,
            latestAttemptNumber: latestSubmission.attempt,
            contextColor: contextColor,
            env: env
        )
        self.env = env

        contextColor.assign(to: &$contextColor)

        observeAttemptChangesInDatabase()
        didSelectNewAttempt(attemptIndex: submission.attempt)
    }

    func didSelectNewAttempt(attemptIndex: Int) {
        NotificationCenter.default.post(name: .SpeedGraderAttemptPickerChanged, object: attemptIndex)
        selectedAttemptIndex = attemptIndex
        selectedAttempt = attempts.first { selectedAttemptIndex == $0.attempt } ?? submission
        fileTabTitle = {
            if selectedAttempt.type == .online_upload, let count = selectedAttempt.attachments?.count, count > 0 {
                return String(localized: "Files (\(count))", bundle: .teacher)
            } else {
                return String(localized: "Files", bundle: .teacher)
            }
        }()
        studentAnnotationViewModel = StudentAnnotationSubmissionViewerViewModel(submission: selectedAttempt)
        didSelectFile(fileID: nil)
    }

    func didSelectFile(fileID: String?) {
        self.fileID = fileID
        updateSelectedFile()
    }

    private func updateSelectedFile() {
        file = selectedAttempt.attachments?.first { fileID == $0.id } ??
                selectedAttempt.attachments?.sorted(by: File.idCompare).first
    }

    private func observeAttemptChangesInDatabase() {
        let useCase = GetSubmissionAttemptsLocal(
            assignmentId: assignment.id,
            userId: submission.userID
        )
        ReactiveStore(useCase: useCase)
            .getEntities(keepObservingDatabaseChanges: true)
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] attempts in
                guard let self else { return }
                self.attempts = attempts
                hasSubmissions = attempts.lastAttemptIndex > 0
                isSingleSubmission = attempts.lastAttemptIndex == 1
            }
            .store(in: &subscriptions)
    }
}

extension [Submission] {

    fileprivate var lastAttemptIndex: Int {
        last?.attempt ?? 0
    }
}

extension NSNotification.Name {
    public static var SpeedGraderAttemptPickerChanged = NSNotification.Name("com.instructure.core.speedgrader-attempt-changed")
}
