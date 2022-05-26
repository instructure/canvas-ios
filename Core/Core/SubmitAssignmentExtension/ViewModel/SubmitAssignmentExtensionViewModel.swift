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

public class SubmitAssignmentExtensionViewModel: ObservableObject {
    private static let selectAssignmentText = Text("Select assignment", bundle: .core)
    private static let selectCourseText = Text("Select course", bundle: .core)

    @Published public var comment = ""
    @Published public private(set) var isSubmitButtonDisabled: Bool = true
    @Published public private(set) var selectCourseButtonTitle: Text = selectCourseText
    @Published public private(set) var selectAssignmentButtonTitle: Text = selectAssignmentText
    @Published public private(set) var isProcessingFiles: Bool = true
    @Published public private(set) var previews: [URL] = []
    public var isUserLoggedIn: Bool { LoginSession.mostRecent != nil }
    public let coursePickerViewModel: CoursePickerViewModel
    public let assignmentPickerViewModel = AssignmentPickerViewModel()

    private var selectedFileURLs: [URL] = []
    private let submissionService: AttachmentSubmissionService
    private var assignmentCopyServiceStateSubscription: AnyCancellable?
    private let shareCompleted: () -> Void
    private var subscriptions: Set<AnyCancellable> = []

    #if DEBUG

    // MARK: - Preview Support

    public init(coursePickerViewModel: CoursePickerViewModel) {
        self.submissionService = AttachmentSubmissionService()
        self.shareCompleted = {}
        self.coursePickerViewModel = coursePickerViewModel
    }

    // MARK: Preview Support -

    #endif

    public init(attachmentCopyService: AttachmentCopyService,
                submissionService: AttachmentSubmissionService,
                shareCompleted: @escaping () -> Void) {
        self.submissionService = submissionService
        self.shareCompleted = shareCompleted
        self.coursePickerViewModel = CoursePickerViewModel()
        subscribeToAssignmentCopyServiceUpdates(attachmentCopyService)
        updateCourseNameOnCourseSelection()
        refreshAssignmentListOnCourseSelection()
        updateAssignmentNameOnAssignmentSelection()
        updateSubmitButtonStateOnAssignmentChange()
        attachmentCopyService.startCopying()
    }

    public func submitTapped() {
        Analytics.shared.logEvent("submit_tapped")
        submissionService.submit(urls: selectedFileURLs,
                                 courseID: coursePickerViewModel.selectedCourse!.id,
                                 assignmentID: assignmentPickerViewModel.selectedAssignment!.id,
                                 comment: comment,
                                 callback: shareCompleted)
    }

    public func cancelTapped() {
        Analytics.shared.logEvent("share_cancelled")
        shareCompleted()
    }

    private func subscribeToAssignmentCopyServiceUpdates(_ attachmentCopyService: AttachmentCopyService) {
        assignmentCopyServiceStateSubscription = attachmentCopyService.state.sink { [weak self] state in
            guard let self = self else { return }

            self.isProcessingFiles = {
                if case .completed(let result) = state, case .success(let attachments) = result, attachments.isEmpty == false {
                    return false
                } else {
                    return true
                }
            }()
            self.previews = {
                if case .completed(let result) = state, case .success(let data) = result {
                    return data
                } else {
                    return []
                }
            }()
            self.selectedFileURLs = self.previews
        }
    }

    private func updateCourseNameOnCourseSelection() {
        coursePickerViewModel.$selectedCourse
            .removeDuplicates()
            .compactMap { $0 }
            .map { Text($0.name) }
            .assign(to: \.selectCourseButtonTitle, on: self)
            .store(in: &subscriptions)
    }

    private func refreshAssignmentListOnCourseSelection() {
        coursePickerViewModel.$selectedCourse
            .removeDuplicates()
            .map { $0?.id }
            .assign(to: \.courseID, on: assignmentPickerViewModel)
            .store(in: &subscriptions)
    }

    private func updateAssignmentNameOnAssignmentSelection() {
        assignmentPickerViewModel.$selectedAssignment
            .removeDuplicates()
            .map { assignment -> Text in
                if let assignment = assignment {
                    return Text(assignment.name)
                } else {
                    return Self.selectAssignmentText
                }
            }
            .assign(to: \.selectAssignmentButtonTitle, on: self)
            .store(in: &subscriptions)
    }

    private func updateSubmitButtonStateOnAssignmentChange() {
        assignmentPickerViewModel.$selectedAssignment
            .removeDuplicates()
            .map { $0 == nil }
            .assign(to: \.isSubmitButtonDisabled, on: self)
            .store(in: &subscriptions)
    }
}
