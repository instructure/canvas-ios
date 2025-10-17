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

final class TimeSpentWidgetUseInteractorLiveTests: HorizonTestCase {

    func testGetTimeSpent() {
        // Given
        let useCase = GetHTimeSpentWidgetUseCase(journey: DomainServiceMock(result: .success(api)))
        let testee = TimeSpentWidgetUseInteractorLive(timeSpentUseCase: useCase)

        api.mock(
            DomainService.JWTTokenRequest(domainServiceOption: .journey),
            value: DomainService.JWTTokenRequest.Result(token: HTimeSpentWidgetStubs.token)
        )
        api.mock(GetTimeSpentWidgetRequest(), value: HTimeSpentWidgetStubs.response)

        // When / Then
        XCTAssertFirstValueAndCompletion(testee.getTimeSpent(ignoreCache: true)) { models in
            // Expect 3 aggregated courses (C1 merged 10+5)
            XCTAssertEqual(models.count, 3)
            let dict = Dictionary(uniqueKeysWithValues: models.map { ($0.id, $0) })
            let c1 = dict["C1"]
            let c2 = dict["C2"]
            let c3 = dict["C3"]
            XCTAssertEqual(c1?.courseName, "Course 1")
            XCTAssertEqual(c1?.minutesPerDay, 15)
            XCTAssertEqual(c2?.minutesPerDay, 20)
            XCTAssertEqual(c3?.minutesPerDay, 0)
        }
    }

    func testGetTimeSpentEmptyResponse() {
        // Given an empty response
        let emptyResponse = GetTimeSpentWidgetResponse(
            data: .init(widgetData: .init(data: [], lastModifiedDate: nil))
        )
        let useCase = GetHTimeSpentWidgetUseCase(journey: DomainServiceMock(result: .success(api)))
        let testee = TimeSpentWidgetUseInteractorLive(timeSpentUseCase: useCase)

        api.mock(
            DomainService.JWTTokenRequest(domainServiceOption: .journey),
            value: DomainService.JWTTokenRequest.Result(token: HTimeSpentWidgetStubs.token)
        )
        api.mock(GetTimeSpentWidgetRequest(), value: emptyResponse)

        // When / Then
        XCTAssertFirstValueAndCompletion(testee.getTimeSpent(ignoreCache: true)) { models in
            XCTAssertEqual(models.count, 0)
        }
    }
}
