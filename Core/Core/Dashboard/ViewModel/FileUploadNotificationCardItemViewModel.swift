//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import CoreData
import Foundation
import SwiftUI

final class FileUploadNotificationCardItemViewModel: ObservableObject, Identifiable {
    enum State {
        case uploading, success, failure

        var text: String {
            switch self {
            case .uploading: return NSLocalizedString("Uploading Submission", comment: "")
            case .success: return NSLocalizedString("Submission Uploaded", comment: "")
            case .failure: return NSLocalizedString("Submission Failed", comment: "")
            }
        }

        var image: Image {
            switch self {
            case .uploading: return .share
            case .success: return .checkLine
            case .failure: return .warningBorderlessLine
            }
        }

        var color: Color {
            switch self {
            case .uploading: return .electric
            case .success: return .backgroundSuccess
            case .failure: return .crimson
            }
        }
    }

    // MARK: - Dependencies

    public let id: NSManagedObjectID
    public let assignmentName: String
    public var state: State
    private let cardDidTap: (
        NSManagedObjectID,
        WeakViewController
    ) -> Void
    private let dismissDidTap: () -> Void

    // MARK: - Outputs

    @Published public private(set) var isHiddenByUser: Bool

    // MARK: - Init

    init(
        id: NSManagedObjectID,
        assignmentName: String,
        state: State,
        isHiddenByUser: Bool,
        cardDidTap: @escaping (
            NSManagedObjectID,
            WeakViewController
        ) -> Void,
        dismissDidTap: @escaping () -> Void
    ) {
        self.id = id
        self.assignmentName = assignmentName
        self.state = state
        self.isHiddenByUser = isHiddenByUser
        self.cardDidTap = cardDidTap
        self.dismissDidTap = dismissDidTap
    }

    public func hideDidTap() {
        isHiddenByUser = true
        dismissDidTap()
    }
}
