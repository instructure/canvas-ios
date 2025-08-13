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
        public let enrolledPrograms: [EnrolledProgram]?
    }

    public  struct EnrolledProgram: Codable {
       public let id, name: String?
        let publicName: String?
        let customerID: String?
        let description: String?
        let owner: String?
        let startDate, endDate: String?
        let variant: String?
        let progresses: [Progress]?
        public var requirements: [Requirement]?
        public let enrollments: [Enrollment]?

        enum CodingKeys: String, CodingKey {
            case id, name, publicName
            case customerID = "customerId"
            case description, owner, startDate, endDate, variant, progresses, requirements, enrollments
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
        public let dependency: Dependen?
        public let dependent: Dependen?
    }
}
