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

    @Published private(set) var attemptPickerOptions: [OptionItem] = []
    @Published private(set) var attempts: [Submission] = []
    @Published private(set) var selectedAttempt: Submission
    @Published private(set) var selectedAttemptNumber: Int = 0
    @Published private(set) var selectedAttemptTitle: String = ""
    @Published private(set) var hasSubmissions: Bool = false

    @Published private(set) var hasMultipleFiles: Bool = false
    @Published private(set) var filePickerOptions: [OptionItem] = []
    @Published private(set) var selectedFile: File?
    @Published private(set) var selectedFileNumber: Int = 0
    @Published private(set) var selectedFileName: String = ""

    @Published private(set) var contextColor = Color(Brand.shared.primary)
    let assignment: Assignment
    let submission: Submission
    let gradeStatuses: [GradeStatus]

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
        gradeStatuses: [GradeStatus],
        contextColor: AnyPublisher<Color, Never>,
        env: AppEnvironment
    ) {
        self.assignment = assignment
        self.submission = latestSubmission
        self.gradeStatuses = gradeStatuses
        selectedAttempt = latestSubmission
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
        didSelectAttempt(attemptNumber: submission.attempt)
    }

    func didSelectAttempt(attemptNumber: Int) {
        NotificationCenter.default.post(
            name: .SpeedGraderAttemptPickerChanged,
            object: SpeedGraderAttemptChangeInfo(attemptIndex: attemptNumber, userId: submission.userID)
        )
        selectedAttempt = attempts.first { $0.attempt == attemptNumber } ?? submission
        selectedAttemptNumber = attemptNumber
        selectedAttemptTitle = String.localizedAttemptNumber(attemptNumber)

        let hasFiles = selectedAttempt.type == .online_upload && selectedAttempt.attachments?.isNotEmpty ?? false
        hasMultipleFiles = hasFiles && selectedAttempt.attachments?.count ?? 0 > 1
        if hasFiles {
            let files = selectedAttempt.attachmentsSorted
            filePickerOptions = files.compactMap { file in
                guard let fileId = file.id else { return nil }
                return OptionItem(
                    id: fileId,
                    title: file.displayName ?? file.filename
                )
            }
            didSelectFile(files.first)
        } else {
            filePickerOptions = []
            didSelectFile(nil)
        }

        studentAnnotationViewModel = StudentAnnotationSubmissionViewerViewModel(submission: selectedAttempt)
    }

    func didSelectFile(fileId: String?) {
        let file = selectedAttempt.attachments?.first { $0.id == fileId }
        didSelectFile(file)
    }

    private func didSelectFile(_ file: File?) {
        self.selectedFile = file
        selectedFileName = file?.displayName ?? file?.filename ?? ""

        if let fileIndex = filePickerOptions.firstIndex(where: { $0.id == file?.id }) {
            selectedFileNumber = fileIndex + 1
        } else {
            selectedFileNumber = 0
        }
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
            .map { Array($0.reversed()) }
            .sink { [weak self] (attempts: [Submission]) in
                guard let self else { return }
                self.attempts = attempts
                let latestAttemptIndex = attempts.first?.attempt ?? 0
                hasSubmissions = latestAttemptIndex > 0
                updateAttemptPickerOptions()
            }
            .store(in: &subscriptions)
    }

    private func updateAttemptPickerOptions() {
        attemptPickerOptions = attempts.map { attempt in
            let title = String.localizedAttemptNumber(attempt.attempt)
            let subtitle = attempt.submittedAt?.dateTimeString
            let accessibilityLabel = subtitle.map {
                let format = String(localized: "%1$@, submitted on %2$@", bundle: .teacher, comment: "Attempt 30, submitted on 2025. Feb 6. at 18:21")
                return String.localizedStringWithFormat(format, title, $0)
            }

            return OptionItem(
                id: String(attempt.attempt),
                title: title,
                subtitle: subtitle,
                customAccessibilityLabel: accessibilityLabel
            )
        }
    }
}

extension NSNotification.Name {
    public static var SpeedGraderAttemptPickerChanged = NSNotification.Name("com.instructure.core.speedgrader-attempt-changed")
}

struct SpeedGraderAttemptChangeInfo {
    let attemptIndex: Int
    let userId: String
}
