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

public struct GetHProgramsResponse: Codable {
    public let data: Programs?

    public struct Programs: Codable {
        public var enrolledPrograms: [EnrolledProgram]?
    }

    public struct EnrolledProgram: Codable {
        public let id, name: String?
        public let courseCompletionCount: Int?
        let publicName: String?
        let customerID: String?
        let description: String?
        let owner: String?
        let startDate, endDate: Date?
        let variant: String?
        let progresses: [Progress]?
        public var requirements: [Requirement]?
        public let enrollments: [Enrollment]?

        enum CodingKeys: String, CodingKey {
            case id, name, publicName
            case customerID = "customerId"
            case description, owner, startDate, endDate, variant, progresses, requirements, enrollments, courseCompletionCount
        }

        public init(
            id: String? = nil,
            name: String? = nil,
            courseCompletionCount: Int? = nil,
            publicName: String? = nil,
            customerID: String? = nil,
            description: String? = nil,
            owner: String? = nil,
            startDate: Date? = nil,
            endDate: Date? = nil,
            variant: String? = nil,
            progresses: [Progress]? = nil,
            requirements: [Requirement]? = nil,
            enrollments: [Enrollment]? = nil
        ) {
            self.id = id
            self.name = name
            self.courseCompletionCount = courseCompletionCount
            self.publicName = publicName
            self.customerID = customerID
            self.description = description
            self.owner = owner
            self.startDate = startDate
            self.endDate = endDate
            self.variant = variant
            self.progresses = progresses
            self.requirements = requirements
            self.enrollments = enrollments
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            id = try container.decodeIfPresent(String.self, forKey: .id)
            name = try container.decodeIfPresent(String.self, forKey: .name)
            courseCompletionCount = try container.decodeIfPresent(Int.self, forKey: .courseCompletionCount)
            publicName = try container.decodeIfPresent(String.self, forKey: .publicName)
            customerID = try container.decodeIfPresent(String.self, forKey: .customerID)
            description = try container.decodeIfPresent(String.self, forKey: .description)
            owner = try container.decodeIfPresent(String.self, forKey: .owner)
            variant = try container.decodeIfPresent(String.self, forKey: .variant)
            progresses = try container.decodeIfPresent([Progress].self, forKey: .progresses)
            requirements = try container.decodeIfPresent([Requirement].self, forKey: .requirements)
            enrollments = try container.decodeIfPresent([Enrollment].self, forKey: .enrollments)

            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            if let startString = try container.decodeIfPresent(String.self, forKey: .startDate) {
                startDate = isoFormatter.date(from: startString)
            } else {
                startDate = nil
            }

            if let endString = try container.decodeIfPresent(String.self, forKey: .endDate) {
                endDate = isoFormatter.date(from: endString)
            } else {
                endDate = nil
            }
        }
    }

    public struct Enrollment: Codable {
        let id, enrollee: String?
    }

    public  struct Progress: Codable {
        let id: String?
        let completionPercentage: Double?
        let courseEnrollmentStatus: String?
        let requirement: ProgressRequirement?
    }

    public struct ProgressRequirement: Codable {
        let id: String?
        let dependent: Dependen?
    }

    public struct Dependen: Codable {
        public let id, canvasCourseID: String?
        public let canvasURL: String?

        enum CodingKeys: String, CodingKey {
            case id
            case canvasCourseID = "canvasCourseId"
            case canvasURL = "canvasUrl"
        }
    }

    public struct Requirement: Codable {
        let id: String?
        let isCompletionRequired: Bool?
        let courseEnrollment: String?
        public var position: Int?
        public let dependency: Dependen?
        public let dependent: Dependen?
    }
}
