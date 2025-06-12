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

struct APIGradeStatuses: Codable, Equatable {

    // MARK: - Public Properties

    var customGradeStatuses: [CustomGradeStatus] {
        data.course.customGradeStatusesConnection.nodes
    }

    var defaultGradeStatuses: [String] {
        data.course.gradeStatuses
    }

    let data: Data

    // MARK: - Types

    struct CustomGradeStatus: Codable, Equatable {
        let color: String
        let name: String
        let restId: String
        // TODO: Remove if unused
        let graphId: String

        private enum CodingKeys: String, CodingKey {
            case color, name, restId = "_id", graphId = "id"
        }
    }

    struct Data: Codable, Equatable {
        let course: Course
    }

    struct Course: Codable, Equatable {
        let customGradeStatusesConnection: CustomGradeStatusesConnection
        let gradeStatuses: [String]
    }

    struct CustomGradeStatusesConnection: Codable, Equatable {
        let nodes: [CustomGradeStatus]
    }
}
