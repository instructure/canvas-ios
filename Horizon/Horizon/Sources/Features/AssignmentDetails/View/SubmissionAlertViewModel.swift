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

import Observation
import HorizonUI
import Foundation

@Observable
final class SubmissionAlertViewModel {
    let id = UUID().uuidString
    let title: String
    let body: String
    var isPresented: Bool
    let type: ModalType
    let submission: HSubmission?
    let button: HorizonUI.ButtonAttribute

    init(title: String = "",
         body: String = "",
         isPresented: Bool = false,
         type: ModalType = .confirmation,
         submission: HSubmission? = nil,
         button: HorizonUI.ButtonAttribute = .init(title: "") {}
    ) {
        self.title = title
        self.body = body
        self.button = button
        self.isPresented = isPresented
        self.submission = submission
        self.type = type
    }
    enum ModalType {
        case confirmation
        case success
    }
}

extension SubmissionAlertViewModel: Equatable {
    static func == (lhs: SubmissionAlertViewModel, rhs: SubmissionAlertViewModel) -> Bool {
        lhs.id == rhs.id && lhs.isPresented == rhs.isPresented
    }
}

@Observable
final class ToastViewModel: Equatable {
    let title: String
    var isPresented: Bool

    init(
        title: String = "",
        isPresented: Bool = false
    ) {
        self.title = title
        self.isPresented = isPresented
    }

    static func == (lhs: ToastViewModel, rhs: ToastViewModel) -> Bool {
        lhs.title == rhs.title && lhs.isPresented == rhs.isPresented
    }
}
