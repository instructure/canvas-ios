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
    @Published public var assignmentPickerViewModel: AssignmentPickerViewModel?
    @Published public var isSubmitButtonDisabled: Bool = true
    @Published public var selectCourseButtonTitle: Text = selectCourseText
    @Published public var selectAssignmentButtonTitle: Text = selectAssignmentText

    public let coursePickerViewModel = CoursePickerViewModel()

    public init() {
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
