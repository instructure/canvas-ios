//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/enrollment_terms.html#EnrollmentTerm
public struct APITerm: Codable, Equatable {
    public enum WorkflowState: String, Codable {
        case active, deleted
    }

    public let id: String
    public let name: String
    public let start_at: Date?
    public let end_at: Date?
    public let workflow_state: WorkflowState?
}

extension APITerm: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
