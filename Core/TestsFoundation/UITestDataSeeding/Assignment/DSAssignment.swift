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

import Core
import Foundation

public struct DSAssignment: Codable {
    public let name: String
    public let id: String
    public let position: Int
    public let submission_types: [SubmissionType]
    public let points_possible: Int?
    public let grading_type: GradingType?
    public let description: String?
    // due_at accepts times in ISO 8601 format, e.g. 2014-10-21T18:48:00Z.
    public let due_at: Date?
    public let published: Bool?
    public let allowed_attemps: Int?
    public let anonymous_grading: Bool?
}
