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

final class CDCareerHelpTests: CoreTestCase {

    private static let testData = (
        id1: "some id 1",
        id2: "some id 2",
        title1: "some title 1",
        title2: "some title 2",
        type1: "some type 1",
        type2: "some type 2",
        url1: URL(string: "https://example1.com")!,
        url2: URL(string: "https://example2.com")!
    )
    private lazy var testData = Self.testData

    // MARK: - Save

    func test_save_shouldCreateNewEntity() {
        let response = GetCareerHelpResponse(
            id: testData.id1,
            type: testData.type1,
            availableTo: nil,
            text: testData.title1,
            subtext: nil,
            url: testData.url1,
            isFeatured: nil,
            isNew: nil,
            featureHeadline: nil
        )

        let entity = CDCareerHelp.save(apiEntity: response, in: databaseClient)

        XCTAssertEqual(entity.id, testData.id1)
        XCTAssertEqual(entity.title, testData.title1)
        XCTAssertEqual(entity.type, testData.type1)
        XCTAssertEqual(entity.url, testData.url1)
        XCTAssertEqual(entity.isBugReport, false)
    }

    func test_save_shouldUpdateExistingEntity() {
        let initialResponse = GetCareerHelpResponse(
            id: testData.id1,
            type: testData.type1,
            availableTo: nil,
            text: testData.title1,
            subtext: nil,
            url: testData.url1,
            isFeatured: nil,
            isNew: nil,
            featureHeadline: nil
        )
        CDCareerHelp.save(apiEntity: initialResponse, in: databaseClient)

        let updatedResponse = GetCareerHelpResponse(
            id: testData.id2,
            type: testData.type2,
            availableTo: nil,
            text: testData.title1,
            subtext: nil,
            url: testData.url2,
            isFeatured: nil,
            isNew: nil,
            featureHeadline: nil
        )
        let updatedEntity = CDCareerHelp.save(apiEntity: updatedResponse, in: databaseClient)
        let savedEntities: [CDCareerHelp] = databaseClient.fetch()

        XCTAssertEqual(savedEntities.count, 1)
        XCTAssertEqual(updatedEntity.id, testData.id2)
        XCTAssertEqual(updatedEntity.title, testData.title1)
        XCTAssertEqual(updatedEntity.type, testData.type2)
        XCTAssertEqual(updatedEntity.url, testData.url2)
    }

    func test_save_withIsBugReportTrue_shouldSetFlag() {
        let response = GetCareerHelpResponse(
            id: testData.id1,
            type: testData.type1,
            availableTo: nil,
            text: testData.title1,
            subtext: nil,
            url: testData.url1,
            isFeatured: nil,
            isNew: nil,
            featureHeadline: nil
        )

        let entity = CDCareerHelp.save(apiEntity: response, isBugReport: true, in: databaseClient)

        XCTAssertEqual(entity.isBugReport, true)
    }

    func test_save_withNilValues_shouldHandleDefaultToEmpty() {
        let response = GetCareerHelpResponse(
            id: nil,
            type: nil,
            availableTo: nil,
            text: nil,
            subtext: nil,
            url: nil,
            isFeatured: nil,
            isNew: nil,
            featureHeadline: nil
        )

        let entity = CDCareerHelp.save(apiEntity: response, in: databaseClient)

        XCTAssertEqual(entity.id, "")
        XCTAssertEqual(entity.title, "")
        XCTAssertEqual(entity.type, "")
        XCTAssertEqual(entity.url, nil)
        XCTAssertEqual(entity.isBugReport, false)
    }
}
