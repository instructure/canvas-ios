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

@testable import Horizon
import Combine

final class ProgramCourseInteractorMock: ProgramCourseInteractor {
    let isLinear: Bool

    init(isLinear: Bool = true) {
        self.isLinear = isLinear
    }

    func getCourses(
        programs: [Program],
        ignoreCache: Bool
    ) -> AnyPublisher<[Program], Error> {
        Just([program])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private var program: Program {
        Program(
            id: "d3aaa471-1eb6-4ae7-817a-f0582ea0f806",
            name: "iOS Developer Track",
            variant: isLinear ? "LINEAR" : "NON_LINEAR",
            description: "A comprehensive program designed to take you from beginner to advanced iOS developer.",
            date: "01/08/2025 - 10/10/2025",
            courseCompletionCount: 3,
            courses: courses
        )
    }

    private var courses: [ProgramCourse] {
        [
            ProgramCourse(
                id: "488",
                name: "Introduction to SwiftUI",
                isSelfEnrolled: true,
                isRequired: true,
                status: "ENROLLED",
                progressID: "p1",
                completionPercent: 1,
                enrollemtID: "e1",
                moduleItemsestimatedTime: ["PT4M", "PT1M"]
            ),
            ProgramCourse(
                id: "664",
                name: "Advanced iOS Development",
                isSelfEnrolled: false,
                isRequired: true,
                status: "ENROLLED",
                progressID: "p2",
                completionPercent: 0.45,
                enrollemtID: "e2",
                moduleItemsestimatedTime: ["PT4M", "PT32M", "PT10M"]
            ),
            ProgramCourse(
                id: "486",
                name: "Data Structures & Algorithms",
                isSelfEnrolled: true,
                isRequired: false,
                status: "ENROLLED",
                progressID: "p3",
                completionPercent: 0.0,
                enrollemtID: nil,
                moduleItemsestimatedTime: ["PT4M"]
            )
        ]
    }
}
