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

class SubmissionGraderViewModel: ObservableObject {

    // MARK: - Outputs

    @Published private(set) var selectedAttemptIndex: Int {
        didSet {
            selectedAttempt = attempts.first { selectedAttemptIndex == $0.attempt } ?? submission
        }
    }
    @Published private(set) var selectedAttempt: Submission {
        didSet {
            studentAnnotationViewModel = StudentAnnotationSubmissionViewerViewModel(submission: selectedAttempt)
        }
    }
    @Published private(set) var studentAnnotationViewModel: StudentAnnotationSubmissionViewerViewModel
    @Published private(set) var attempts: [Submission] = [] {
        didSet {
            print("attempts: \(attempts)")
        }
    }

    var hasSubmissions: Bool {
        attempts.count > 1
    }
    var isSingleSubmission: Bool {
        attempts.count == 2
    }

    var fileTabTitle: String {
        if selectedAttempt.type == .online_upload, let count = selectedAttempt.attachments?.count, count > 0 {
            return String(localized: "Files (\(count))", bundle: .teacher)
        } else {
            return String(localized: "Files", bundle: .teacher)
        }
    }
    let assignment: Assignment
    let submission: Submission
    var file: File? {
        selectedAttempt.attachments?.first { fileID == $0.id } ??
            selectedAttempt.attachments?.sorted(by: File.idCompare).first
    }

    // MARK: - Inputs

    /** This is mainly used by `SubmissionCommentList` but since it's re-created on rotation and app backgrounding the entered text is lost. */
    @Published var enteredComment: String = ""
    var fileID: String?

    private var subscriptions = Set<AnyCancellable>()

    init(assignment: Assignment, submission: Submission) {
        self.assignment = assignment
        self.submission = submission
        selectedAttemptIndex = submission.attempt
        selectedAttempt = submission
        studentAnnotationViewModel = StudentAnnotationSubmissionViewerViewModel(submission: submission)
        observeAttemptChangesInDatabase()
    }

    func didSelectNewAttempt(attemptIndex: Int) {
        NotificationCenter.default.post(name: .SpeedGraderAttemptPickerChanged, object: attemptIndex)
        selectedAttemptIndex = attemptIndex
        fileID = nil
    }

    private func observeAttemptChangesInDatabase() {
        let scope = Scope(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(key: #keyPath(Submission.assignmentID), equals: assignment.id),
                NSPredicate(key: #keyPath(Submission.userID), equals: submission.userID),
                NSPredicate(format: "%K != nil", #keyPath(Submission.submittedAt))
            ]),
            orderBy: #keyPath(Submission.attempt)
        )
        let useCase = LocalUseCase<Submission>(scope: scope)
        ReactiveStore(useCase: useCase)
            .getEntities(keepObservingDatabaseChanges: true)
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .print()
            .assign(to: &$attempts)
    }
}
