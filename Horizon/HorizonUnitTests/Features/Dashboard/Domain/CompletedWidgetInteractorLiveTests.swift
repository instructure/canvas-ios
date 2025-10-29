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
@testable import Core
import XCTest
import Combine

final class CompletedWidgetInteractorLiveTests: HorizonTestCase {

    func testGetCompletedWidgets() {
        // Given
        let useCase = CompletedWidgetUseCase(journey: DomainServiceMock(result: .success(api)))
        let testee = CompletedWidgetInteractorLive(completedWidget: useCase)

        api.mock(
            DomainService.JWTTokenRequest(domainServiceOption: .journey),
            value: DomainService.JWTTokenRequest.Result(token: HActivitiesWidgetStubs.token)
        )
        api.mock(GetHActivitiesWidgetRequest(), value: HActivitiesWidgetStubs.response)

        // When / Then
        XCTAssertSingleOutputAndFinish(testee.getCompletedWidgets(ignoreCache: true)) { models in
            XCTAssertEqual(models.count, 3)
            let dict = Dictionary(uniqueKeysWithValues: models.map { ($0.courseID, $0) })

            let course1 = dict["101"]
            XCTAssertEqual(course1?.courseName, "Course 1")
            XCTAssertEqual(course1?.moduleCountCompleted, 5)

            let course2 = dict["102"]
            XCTAssertEqual(course2?.courseName, "Course 2")
            XCTAssertEqual(course2?.moduleCountCompleted, 3)

            let course3 = dict["103"]
            XCTAssertEqual(course3?.courseName, "Course 3")
            XCTAssertEqual(course3?.moduleCountCompleted, 8)
        }
    }

    func testGetCompletedWidgetsEmptyResponse() {
        // Given
        let emptyResponse = GetHActivitiesWidgetResponse(
            data: .init(widgetData: .init(data: [], lastModifiedDate: nil))
        )
        let useCase = CompletedWidgetUseCase(journey: DomainServiceMock(result: .success(api)))
        let testee = CompletedWidgetInteractorLive(completedWidget: useCase)

        api.mock(
            DomainService.JWTTokenRequest(domainServiceOption: .journey),
            value: DomainService.JWTTokenRequest.Result(token: HActivitiesWidgetStubs.token)
        )
        api.mock(GetHActivitiesWidgetRequest(), value: emptyResponse)

        // When / Then
        XCTAssertSingleOutputAndFinish(testee.getCompletedWidgets(ignoreCache: true)) { models in
            XCTAssertEqual(models.count, 0)
        }
    }
}
