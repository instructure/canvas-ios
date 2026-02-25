//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import Foundation
import SwiftUI

struct FileUploadCardState: Hashable, Identifiable {
    let id: String
    let assignmentName: String
    let assignmentRoute: String
    let state: UploadState
    let progress: Float?

    enum UploadState: Hashable {
        case uploading
        case success
        case failed

        var backgroundColor: Color {
            switch self {
            case .uploading: .backgroundDarkest
            case .success: .backgroundSuccess
            case .failed: .backgroundDanger
            }
        }

        var title: String {
            switch self {
            case .uploading: String(localized: "Uploading Submission", bundle: .student)
            case .success: String(localized: "Submission Uploaded Successfully", bundle: .student)
            case .failed: String(localized: "Submission Upload Failed", bundle: .student)
            }
        }

        func subtitleText(assignmentName: String) -> String {
            switch self {
            case .uploading, .success: assignmentName
            case .failed: String(localized: "We couldn't upload your submission.\nTry again, or come back later", bundle: .student)
            }
        }
    }
}
