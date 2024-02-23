//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public struct DSRubric: Codable {
    public let id: String
    public let title: String
    public let context_id: String
    public let context_type: String
    public let data: [DSRubricData]
    public let points_possible: Float?
}

public struct DSRubricAssociation: Codable {
    public let id: String
    public let rubric_id: String
    public let association_id: String
    public let association_type: String
}

public struct DSRubricResponse: Codable {
    public let rubric: DSRubric
    public let rubric_association: DSRubricAssociation
}

public struct DSRubricData: Codable {
    public let id: String
    public let ratings: [DSRubricRating]
    public let long_description: String?
}

public struct DSRubricRating: Codable {
    public let description: String
}
