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

class SpeedGraderPageViewModel: ObservableObject {

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

    @Published private(set) var isDetailsTabEmpty: Bool = true

    @Published private(set) var contextColor = Color(Brand.shared.primary)

    let assignment: Assignment
    let submission: Submission

    // sub-viewmodels
    private(set) var studentAnnotationViewModel: StudentAnnotationSubmissionViewerViewModel
    let commentListViewModel: SubmissionCommentListViewModel
    let gradeStatusViewModel: GradeStatusViewModel
    let submissionWordCountViewModel: SubmissionWordCountViewModel
    let studentNotesViewModel: StudentNotesViewModel
    let rubricsViewModel: RubricsViewModel
    let gradeViewModel: SpeedGraderSubmissionGradesViewModel

    // MARK: - Inputs

    // MARK: - Private properties

    private var subscriptions = Set<AnyCancellable>()

    init(
        assignment: Assignment,
        latestSubmission: Submission,
        contextColor: AnyPublisher<Color, Never>,
        studentAnnotationViewModel: StudentAnnotationSubmissionViewerViewModel,
        gradeViewModel: SpeedGraderSubmissionGradesViewModel,
        gradeStatusViewModel: GradeStatusViewModel,
        commentListViewModel: SubmissionCommentListViewModel,
        rubricsViewModel: RubricsViewModel,
        submissionWordCountViewModel: SubmissionWordCountViewModel,
        studentNotesViewModel: StudentNotesViewModel
    ) {
        self.assignment = assignment
        self.submission = latestSubmission
        self.selectedAttempt = latestSubmission

        self.studentAnnotationViewModel = studentAnnotationViewModel
        self.gradeViewModel = gradeViewModel
        self.gradeStatusViewModel = gradeStatusViewModel
        self.commentListViewModel = commentListViewModel
        self.rubricsViewModel = rubricsViewModel
        self.submissionWordCountViewModel = submissionWordCountViewModel
        self.studentNotesViewModel = studentNotesViewModel

        contextColor.assign(to: &$contextColor)

        observeDetailsTabComponentsEmptyState()
        observeAttemptChangesInDatabase()
        didSelectAttempt(attemptNumber: submission.attempt)
    }

    private func observeDetailsTabComponentsEmptyState() {
        Publishers.CombineLatest(
            submissionWordCountViewModel.$hasContent,
            studentNotesViewModel.$hasContent
        )
        .sink { [weak self] in
            self?.isDetailsTabEmpty = !($0.0 || $0.1)
        }
        .store(in: &subscriptions)
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
        gradeStatusViewModel.didChangeAttempt.send(attemptNumber)
        submissionWordCountViewModel.didChangeAttempt.send(attemptNumber)
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
