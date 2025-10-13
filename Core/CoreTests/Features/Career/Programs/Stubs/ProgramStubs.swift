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

@testable import Core
import Foundation

enum ProgramStubs {
    static let dependen = GetHProgramsResponse.Dependen(
        id: "Dependen-ID",
        canvasCourseID: "477",
        canvasURL: nil
    )
    static let dependency = GetHProgramsResponse.Dependen(
        id: "Dependency-ID",
        canvasCourseID: "477",
        canvasURL: nil
    )

    static let progressRequirement = GetHProgramsResponse.ProgressRequirement(
        id: "progress-ID",
        dependent: dependen
    )

    static let requirement = GetHProgramsResponse.Requirement(
        id: "Requirement-ID",
        isCompletionRequired: true,
        courseEnrollment: "courseEnrollment-ID",
        position: 10,
        dependency: dependency,
        dependent: dependen
    )

    static let progress = GetHProgramsResponse.Progress(
        id: "123",
        completionPercentage: 0.6,
        courseEnrollmentStatus: "Blocked",
        requirement: progressRequirement
    )

    static let programsResponse = GetHProgramsResponse.EnrolledProgram(
        id: "EnrolledProgram-id",
        name: "Program 1",
        courseCompletionCount: 2,
        publicName: nil,
        customerID: nil,
        description: "description - description",
        owner: nil,
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400),
        variant: "Linear",
        progresses: [progress],
        requirements: [requirement],
        enrollments: nil
    )

    static let programsResponseWithNilValues = GetHProgramsResponse.EnrolledProgram(
        id: "EnrolledProgram-id",
        name: "Program 1",
        courseCompletionCount: 2,
        publicName: nil,
        customerID: nil,
        description: "description - description",
        owner: nil,
        startDate: Date(timeIntervalSince1970: 0),
        endDate: Date(timeIntervalSince1970: 86400),
        variant: "Linear",
        progresses: nil,
        requirements: nil,
        enrollments: nil
    )
}
