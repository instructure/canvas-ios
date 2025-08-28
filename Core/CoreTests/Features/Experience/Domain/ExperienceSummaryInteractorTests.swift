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
import Combine
import CombineSchedulers
import TestsFoundation
import XCTest

class ExperienceSummaryInteractorLiveTests: CoreTestCase {
    private var scheduler: TestSchedulerOf<DispatchQueue>!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        scheduler = DispatchQueue.test
        cancellables = []
        environment.userDefaults?.appExperience = nil
    }

    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }

    func testGetExperienceSummaryFromUserDefaults() {
        environment.userDefaults?.appExperience = .careerLearner
        let testee = ExperienceSummaryInteractorLive(environment: environment, scheduler: scheduler.eraseToAnyScheduler())

        let expectation = expectation(description: "Experience received")
        testee.getExperienceSummary()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { experience in
                    XCTAssertEqual(experience, .careerLearner)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testGetExperienceSummaryFromAPI() {
        environment.userDefaults?.appExperience = nil
        let testee = ExperienceSummaryInteractorLive(environment: environment, scheduler: scheduler.eraseToAnyScheduler())

        let apiResponse = APIExperienceSummary(
            current_app: .academic,
            available_apps: [.academic, .careerLearner]
        )
        CDExperienceSummary.save(apiResponse, in: databaseClient)

        let expectation = expectation(description: "Experience received")
        testee.getExperienceSummary()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { experience in
                    XCTAssertEqual(experience, .academic)
                    XCTAssertEqual(self.environment.userDefaults?.appExperience, .academic)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testGetExperienceSummaryFromAPIError() {
        let testee = ExperienceSummaryInteractorLive(environment: environment, scheduler: scheduler.eraseToAnyScheduler())
        let useCase = GetExperienceSummaryUseCase()
        api.mock(useCase.request, error: NSError.instructureError("Error"))

        let expectation = expectation(description: "Experience received")
        testee.getExperienceSummary()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { experience in
                    XCTAssertEqual(experience, .academic)
                    XCTAssertEqual(self.environment.userDefaults?.appExperience, nil)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testIsExperienceSwitchAvailableWhenBothExperiencesExist() {
        let apiResponse = APIExperienceSummary(
            current_app: .academic,
            available_apps: [.academic, .careerLearner]
        )
        CDExperienceSummary.save(apiResponse, in: databaseClient)

        let testee = ExperienceSummaryInteractorLive(environment: environment, scheduler: scheduler.eraseToAnyScheduler())

        let expectation = expectation(description: "Switch availability received")
        testee.isExperienceSwitchAvailable()
            .sink { isAvailable in
                XCTAssertTrue(isAvailable)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testIsExperienceSwitchAvailableWhenOnlyOneExperienceExists() {
        let apiResponse = APIExperienceSummary(
            current_app: .academic,
            available_apps: [.academic]
        )
        CDExperienceSummary.save(apiResponse, in: databaseClient)

        let testee = ExperienceSummaryInteractorLive(environment: environment, scheduler: scheduler.eraseToAnyScheduler())

        let expectation = expectation(description: "Switch availability received")
        testee.isExperienceSwitchAvailable()
            .sink { isAvailable in
                XCTAssertFalse(isAvailable)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testIsExperienceSwitchAvailableWithError() {
        let testee = ExperienceSummaryInteractorLive(environment: environment, scheduler: scheduler.eraseToAnyScheduler())

        let expectation = expectation(description: "Switch availability received")
        testee.isExperienceSwitchAvailable()
            .sink { isAvailable in
                XCTAssertFalse(isAvailable)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testSwitchExperience() {
        let testee = ExperienceSummaryInteractorLive(environment: environment, scheduler: scheduler.eraseToAnyScheduler())

        let expectation = expectation(description: "Experience switched")
        testee.switchExperience(to: .careerLearner)
            .sink { _ in
                XCTAssertEqual(self.environment.userDefaults?.appExperience, .careerLearner)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        scheduler.advance(by: .seconds(1))
        wait(for: [expectation], timeout: 2)
    }
}
