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
@testable import Horizon
import XCTest

final class ProgramInteractorLiveTests: HorizonTestCase {
    func testGetPrograms() {
        // Given
        let interactor = ProgramCourseInteractorMock()
        let useCase = GetHProgramsUseCase(journey: DomainServiceMock(result: .success(api)))
        let testee = ProgramInteractorLive(programCourseInteractor: interactor, programsUseCase: useCase)

        // When
        api.mock(
            DomainService.JWTTokenRequest(domainServiceOption: .journey),
            value: DomainService.JWTTokenRequest.Result(token: HProgramStubs.token)
        )
        api.mock(GetHProgramsRequest(), value: HProgramStubs.response)
        // Then
        XCTAssertFirstValueAndCompletion(testee.getPrograms(ignoreCache: true)) { programs in
            let firstProgram = programs.first(where: { $0.id == "d3aaa471-1eb6-4ae7-817a-f0582ea0f806" })
            let courses = firstProgram?.courses ?? []
            XCTAssertTrue(firstProgram?.isLinear ?? false)
            XCTAssertEqual(courses[0].id, "488")
            XCTAssertEqual(courses[1].id, "664")
            XCTAssertEqual(courses[2].id, "486")
            XCTAssertEqual(firstProgram?.countOfRequiredCourses, 2)
        }
    }

    func testGetProgramsWithCourses() {
        // Given
        let interactor = ProgramCourseInteractorMock()
        let useCase = GetHProgramsUseCase(journey: DomainServiceMock(result: .success(api)))
        let testee = ProgramInteractorLive(programCourseInteractor: interactor, programsUseCase: useCase)

        // When
        api.mock(
            DomainService.JWTTokenRequest(domainServiceOption: .journey),
            value: DomainService.JWTTokenRequest.Result(token: HProgramStubs.token)
        )
        api.mock(GetHProgramsRequest(), value: HProgramStubs.response)
        // Then
        XCTAssertFirstValueAndCompletion(testee.getProgramsWithCourses(ignoreCache: true)) { programs in
            let firstProgram = programs[0]
            let courses = firstProgram.courses
            XCTAssertTrue(firstProgram.isLinear)
            XCTAssertEqual(firstProgram.date, "01/08/2025 - 10/10/2025")
            XCTAssertEqual(firstProgram.estimatedTime, "51 mins")
            XCTAssertTrue(firstProgram.hasPills)
            XCTAssertFalse(firstProgram.isOptionalProgram)
            XCTAssertEqual(firstProgram.completionPercent, 0.725)

            XCTAssertEqual(courses[0].name, "Introduction to SwiftUI")
            XCTAssertEqual(courses[1].name, "Advanced iOS Development")
            XCTAssertEqual(courses[2].name, "Data Structures & Algorithms")

            XCTAssertTrue(courses[0].isCompleted)
            XCTAssertTrue(courses[0].isEnrolled)
            XCTAssertEqual(courses[0].estimatedTime, "5 mins")
            XCTAssertEqual(courses[0].courseStatus, .enrolled)
        }
    }

    func testGetProgramsWithCoursesNonLinear() {
        // Given
        let interactor = ProgramCourseInteractorMock(isLinear: false)
        let useCase = GetHProgramsUseCase(journey: DomainServiceMock(result: .success(api)))
        let testee = ProgramInteractorLive(programCourseInteractor: interactor, programsUseCase: useCase)

        // When
        api.mock(
            DomainService.JWTTokenRequest(domainServiceOption: .journey),
            value: DomainService.JWTTokenRequest.Result(token: HProgramStubs.token)
        )
        api.mock(GetHProgramsRequest(), value: HProgramStubs.response)
        // Then
        XCTAssertFirstValueAndCompletion(testee.getProgramsWithCourses(ignoreCache: true)) { programs in
            let firstProgram = programs[0]
            XCTAssertFalse(firstProgram.isLinear)
            XCTAssertEqual(firstProgram.date, "01/08/2025 - 10/10/2025")
            XCTAssertEqual(firstProgram.estimatedTime, "51 mins")
            XCTAssertTrue(firstProgram.hasPills)
            XCTAssertFalse(firstProgram.isOptionalProgram)
            XCTAssertEqual(round(firstProgram.completionPercent * 100) / 100, 0.48)
        }
    }
}
