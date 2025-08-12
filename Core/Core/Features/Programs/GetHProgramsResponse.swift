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
    let data: Programs?

    struct Programs: Codable {
        let enrolledPrograms: [EnrolledProgram]?
    }

    struct EnrolledProgram: Codable {
        let id, name: String?
        let publicName: String?
        let customerID: String?
        let description: String?
        let owner: String?
        let startDate, endDate: String?
        let variant: String?
        let progresses: [Progress]?
        let requirements: [RequirementElement]?
        let enrollments: [Enrollment]?

        enum CodingKeys: String, CodingKey {
            case id, name, publicName
            case customerID = "customerId"
            case description, owner, startDate, endDate, variant, progresses, requirements, enrollments
        }

        struct Enrollment: Codable {
            let id, enrollee: String?
        }

        struct Progress: Codable {
            let id: String?
            let completionPercentage: Double?
            let courseEnrollmentStatus: String?
            let requirement: ProgressRequirement?
        }

        struct ProgressRequirement: Codable {
            let id: String?
            let dependent: Dependen?
        }

        struct Dependen: Codable {
            let id, canvasCourseID: String?
            let canvasURL: String?

            enum CodingKeys: String, CodingKey {
                case id
                case canvasCourseID = "canvasCourseId"
                case canvasURL = "canvasUrl"
            }
        }

        struct RequirementElement: Codable {
            let id: String?
            let isCompletionRequired: Bool?
            let courseEnrollment: String?
            let dependency: Dependen?
            let dependent: Dependen
        }
    }
}
