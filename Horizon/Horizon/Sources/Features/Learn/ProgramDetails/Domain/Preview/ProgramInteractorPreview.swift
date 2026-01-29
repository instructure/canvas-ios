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

#if DEBUG
import Combine
import Foundation

class ProgramInteractorPreview: ProgramInteractor {
    // MARK: - Sample Data

    private var sampleCourses: [ProgramCourse] {
        [
            ProgramCourse(
                id: "c1",
                name: "Introduction to SwiftUI",
                isSelfEnrolled: true,
                isRequired: true,
                status: "ENROLLED",
                progressID: "p1",
                completionPercent: 100.0,
                moduleItemsestimatedTime: ["2PT", "3PT"]
            ),
            ProgramCourse(
                id: "c2",
                name: "Advanced iOS Development",
                isSelfEnrolled: false,
                isRequired: true,
                status: "self-enrollment",
                progressID: "p2",
                completionPercent: 45.0,
                moduleItemsestimatedTime: ["5PT", "2PT", "1PT"]
            ),
            ProgramCourse(
                id: "c3",
                name: "Data Structures & Algorithms",
                isSelfEnrolled: true,
                isRequired: false,
                status: "ENROLLED",
                progressID: "p3",
                completionPercent: 0.0,
                moduleItemsestimatedTime: ["4PT"]
            )
        ]
    }

    private var sampleProgram: Program {
        Program(
            id: "p123",
            name: "iOS Developer Track",
            variant: "Full-Time",
            description: "A comprehensive program designed to take you from beginner to advanced iOS developer.",
            date: "2025-09-01",
            courseCompletionCount: 1,
            courses: sampleCourses
        )
    }

    private func publisherWithProgram() -> AnyPublisher<[Program], Error> {
        Just([sampleProgram])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    // MARK: - Protocol Conformance

    func getPrograms(ignoreCache: Bool) -> AnyPublisher<[Program], Never> {
        Just([sampleProgram])
            .eraseToAnyPublisher()
    }

    func getProgramsWithCourses(ignoreCache: Bool) -> AnyPublisher<[Program], any Error> {
        publisherWithProgram()
    }

    func enrollInProgram(progressID: String) -> AnyPublisher<[Program], any Error> {
        publisherWithProgram()
    }

    func getProgramsWithObserving(ignoreCache: Bool) -> AnyPublisher<[Program], Error> {
        Just([sampleProgram])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
#endif
