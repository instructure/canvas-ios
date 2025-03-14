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

import Foundation
import Core

enum ModuleItemSequenceViewState {
    case externalURL(url: URL, name: String)
    case externalTool(tools: LTITools, name: String?)
    case moduleItem(controller: UIViewController, id: String)
    case error
    case locked(title: String, lockExplanation: String)
    case assignment(
        courseID: String,
        assignmentID: String,
        isMarkedAsDone: Bool,
        isCompletedItem: Bool,
        moduleID: String,
        itemID: String
    )
    case file(context: Context, fileID: String)

    var isModuleItem: Bool {
        switch self {
        case .moduleItem, .assignment, .file:
            return true
        default:
            return false
        }
    }

    var isAssignment: Bool {
        switch self {
        case .assignment:
            return true
        default:
            return false
        }
    }

    var isExternalURL: Bool {
        switch self {
        case .externalURL:
            return true
        default:
            return false
        }
    }
}
