//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import XCTest

final class GetCareerHelpUseCaseTests: CoreTestCase {

    private static let testData = (
        title1: "some title 1",
        title2: "some title 2",
        title3: "some title 3",
        title4: "some title 4",
        url1: URL(string: "https://example1.com")!,
        url2: URL(string: "https://example2.com")!
    )
    private lazy var testData = Self.testData

    private var testee: GetCareerHelpUseCase!

    override func setUp() {
        super.setUp()
        testee = GetCareerHelpUseCase()
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - Basic properties

    func test_cacheKey() {
        XCTAssertEqual(testee.cacheKey, "Career-Help")
    }

    func test_scope() {
        XCTAssertEqual(testee.scope, .all)
    }

    func test_request() {
        let request = testee.request
        XCTAssertEqual(request.path, "/help_links")
        XCTAssertEqual(request.shouldAddNoVerifierQuery, false)
    }

    // MARK: - Write

    func test_write_withReportAProblem_shouldSaveWithBugReportFlag() {
        let responses = [
            GetCareerHelpResponse(
                id: "report_a_problem",
                type: "some type",
                availableTo: nil,
                text: testData.title1,
                subtext: nil,
                url: testData.url1,
                isFeatured: nil,
                isNew: nil,
                featureHeadline: nil
            )
        ]

        testee.write(response: responses, urlResponse: nil, to: databaseClient)
        let savedEntities: [CDCareerHelp] = databaseClient.fetch()

        XCTAssertEqual(savedEntities.count, 1)
        XCTAssertEqual(savedEntities.first?.id, "report_a_problem")
        XCTAssertEqual(savedEntities.first?.isBugReport, true)
    }

    func test_write_withTrainingServicesPortal_shouldSave() {
        let responses = [
            GetCareerHelpResponse(
                id: "training_services_portal",
                type: "some type",
                availableTo: nil,
                text: testData.title1,
                subtext: nil,
                url: testData.url1,
                isFeatured: nil,
                isNew: nil,
                featureHeadline: nil
            )
        ]

        testee.write(response: responses, urlResponse: nil, to: databaseClient)
        let savedEntities: [CDCareerHelp] = databaseClient.fetch()

        XCTAssertEqual(savedEntities.count, 1)
        XCTAssertEqual(savedEntities.first?.id, "training_services_portal")
        XCTAssertEqual(savedEntities.first?.isBugReport, false)
    }

    func test_write_withCustomType_shouldSave() {
        let responses = [
            GetCareerHelpResponse(
                id: "some other id",
                type: "custom",
                availableTo: nil,
                text: testData.title1,
                subtext: nil,
                url: testData.url1,
                isFeatured: nil,
                isNew: nil,
                featureHeadline: nil
            )
        ]

        testee.write(response: responses, urlResponse: nil, to: databaseClient)
        let savedEntities: [CDCareerHelp] = databaseClient.fetch()

        XCTAssertEqual(savedEntities.count, 1)
        XCTAssertEqual(savedEntities.first?.type, "custom")
        XCTAssertEqual(savedEntities.first?.isBugReport, false)
    }

    func test_write_withNonEnabledId_shouldNotSave() {
        let responses = [
            GetCareerHelpResponse(
                id: "some random id",
                type: "not custom",
                availableTo: nil,
                text: testData.title1,
                subtext: nil,
                url: testData.url1,
                isFeatured: nil,
                isNew: nil,
                featureHeadline: nil
            )
        ]

        testee.write(response: responses, urlResponse: nil, to: databaseClient)
        let savedEntities: [CDCareerHelp] = databaseClient.fetch()

        XCTAssertEqual(savedEntities.count, 0)
    }

    func test_write_withMixedResponses_shouldSaveOnlyEnabledOnes() {
        let responses = [
            GetCareerHelpResponse(
                id: "report_a_problem",
                type: "some type",
                availableTo: nil,
                text: testData.title1,
                subtext: nil,
                url: testData.url1,
                isFeatured: nil,
                isNew: nil,
                featureHeadline: nil
            ),
            GetCareerHelpResponse(
                id: "not enabled",
                type: "not custom",
                availableTo: nil,
                text: testData.title2,
                subtext: nil,
                url: testData.url2,
                isFeatured: nil,
                isNew: nil,
                featureHeadline: nil
            ),
            GetCareerHelpResponse(
                id: "training_services_portal",
                type: "some type",
                availableTo: nil,
                text: testData.title3,
                subtext: nil,
                url: testData.url1,
                isFeatured: nil,
                isNew: nil,
                featureHeadline: nil
            ),
            GetCareerHelpResponse(
                id: "another id",
                type: "custom",
                availableTo: nil,
                text: testData.title4,
                subtext: nil,
                url: testData.url2,
                isFeatured: nil,
                isNew: nil,
                featureHeadline: nil
            )
        ]

        testee.write(response: responses, urlResponse: nil, to: databaseClient)
        let savedEntities: [CDCareerHelp] = databaseClient.fetch()

        XCTAssertEqual(savedEntities.count, 3)
        XCTAssertEqual(savedEntities.filter { $0.isBugReport }.count, 1)
    }

    func test_write_withNilResponse_shouldNotSave() {
        testee.write(response: nil, urlResponse: nil, to: databaseClient)
        let savedEntities: [CDCareerHelp] = databaseClient.fetch()

        XCTAssertEqual(savedEntities.count, 0)
    }

    func test_write_withEmptyResponse_shouldNotSave() {
        testee.write(response: [], urlResponse: nil, to: databaseClient)
        let savedEntities: [CDCareerHelp] = databaseClient.fetch()

        XCTAssertEqual(savedEntities.count, 0)
    }
}
