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

    @Published public var selectedCourse: Course? = nil {
        didSet {
            recreateAssignmentViewModel()
            selectCourseButtonTitle = selectedCourse.map { Text($0.name) } ?? Self.selectCourseText
        }
        willSet { resetSelectedAssignmentIfNecesssary(newCourse: newValue) }
    }
    @Published public var selectedAssignment: AssignmentPickerViewModel.Assignment? {
        didSet {
            isSubmitButtonDisabled = (assignmentPickerViewModel == nil)
            selectAssignmentButtonTitle = selectedAssignment.map { Text($0.name) } ?? Self.selectAssignmentText
        }
    }
    @Published public private(set) var assignmentPickerViewModel: AssignmentPickerViewModel?
    @Published public private(set) var isSubmitButtonDisabled: Bool = true
    @Published public private(set) var selectCourseButtonTitle: Text = selectCourseText
    @Published public private(set) var selectAssignmentButtonTitle: Text = selectAssignmentText
    @Published public private(set) var isProcessingFiles: Bool = true

    public let coursePickerViewModel: CoursePickerViewModel

    private var selectedFileURLs: [URL] = []
    private let submissionService: AttachmentSubmissionService
    private var assignmentCopyServiceStateSubscription: AnyCancellable?
    private let shareCompleted: () -> Void

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
    }

    public func submitTapped() {
        submissionService.submit(urls: selectedFileURLs, courseID: selectedCourse!.id, assignmentID: selectedAssignment!.id, comment: "", callback: shareCompleted)
    }

    public func cancelTapped() {
        shareCompleted()
    }

    private func subscribeToAssignmentCopyServiceUpdates(_ attachmentCopyService: AttachmentCopyService) {
        assignmentCopyServiceStateSubscription = attachmentCopyService.state.sink { [weak self] state in
            self?.isProcessingFiles = {
                if case .completed(let result) = state, case .success(let urls) = result, urls.isEmpty == false {
                    return false
                } else {
                    return true
                }
            }()
            self?.selectedFileURLs = {
                if case .completed(let result) = state, case .success(let urls) = result {
                    return urls
                } else {
                    return []
                }
            }()
        }
    }

    private func recreateAssignmentViewModel() {
        if let selectedCourseId = selectedCourse?.id {
            assignmentPickerViewModel = AssignmentPickerViewModel(courseID: selectedCourseId)
        } else {
            assignmentPickerViewModel = nil
        }
    }

    private func resetSelectedAssignmentIfNecesssary(newCourse: Course?) {
        if newCourse != selectedCourse {
            selectedAssignment = nil
        }
    }
}

extension SubmitAssignmentExtensionViewModel {
    public struct Course: Identifiable, Equatable {
        public let id: String
        public let name: String
    }
}
