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
import Core
import SwiftUI

public class StudentAnnotationSubmissionViewModel: ObservableObject {
    @Published public var error: SubmissionError?
    @Published public var isSaving: Bool = false
    @Published public var doneButton = makeDoneButton(isSaving: false)
    public let dismissView = PassthroughSubject<Void, Never>()
    public let documentURL: URL
    public let navBar: (title: String, subtitle: String, color: UIColor, closeButtonTitle: String)

    private let submissionUseCase: CreateSubmission

    public init(documentURL: URL, agent: SubmissionAgent, annotatableAttachmentID: String?, assignmentName: String, courseColor: UIColor) {
        self.documentURL = documentURL
        self.navBar = (title: String(localized: "Student Annotation", bundle: .student),
                       subtitle: assignmentName,
                       color: courseColor,
                       closeButtonTitle: String(localized: "Close", bundle: .student))
        self.submissionUseCase = CreateSubmission(agent: agent,
                                                  submissionType: .student_annotation,
                                                  annotatableAttachmentID: annotatableAttachmentID)
    }

    public func postSubmission() {
        doneButton = Self.makeDoneButton(isSaving: true)

        submissionUseCase.fetch { submission, _, error in performUIUpdate {
            self.doneButton = Self.makeDoneButton(isSaving: false)

            if submission != nil {
                self.dismissView.send()
            } else {
                self.error = .init(title: String(localized: "Submission Failed", bundle: .student), message: error?.localizedDescription ?? String(localized: "Unknown Error", bundle: .student))
            }
        }}
    }

    public func closeTapped() {
        dismissView.send()
    }

    private static func makeDoneButton(isSaving: Bool) -> (title: String, isDisabled: Bool, opacity: Double) {
        (title: isSaving ? String(localized: "Submitting...", bundle: .student) : String(localized: "Submit", bundle: .student), isDisabled: isSaving, opacity: isSaving ? 0.5 : 1)
    }
}

public struct SubmissionError: Identifiable {
    public var id: String { UUID.string }
    public let title: String
    public let message: String
}
