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

import XCTest
@testable import Core

final class APIModuleItemsDiscussionCheckpointsTests: XCTestCase {
    private typealias Checkpoint = APIModuleItemsDiscussionCheckpoints.DiscussionCheckpoint

    private static let testData = (
        cursor: "some cursor",
        moduleItemId1: "some moduleItemId1",
        moduleItemId2: "some moduleItemId2",
        checkpoint1: Checkpoint.make(
            tag: "some tag1",
            dueAt: Date.make(year: 2025, month: 1, day: 15),
            pointsPossible: 142
        ),
        checkpoint2: Checkpoint.make(
            tag: "some tag2",
            dueAt: Date.make(year: 2025, month: 1, day: 20),
            pointsPossible: 242
        ),
        checkpoint3: Checkpoint.make(
            tag: "some tag3",
            dueAt: nil,
            pointsPossible: 342
        ),
        replyCount1: 11,
        replyCount2: 22,
        tag: "some tag1",
        date: Date.make(year: 2025, month: 1, day: 15),
        points: 10.0
    )
    private lazy var testData = Self.testData

    private var testee: APIModuleItemsDiscussionCheckpoints!

    // MARK: - Paging

    func test_pageInfo_shouldReturnNestedPageInfo() {
        let pageInfo = APIPageInfo(endCursor: testData.cursor, hasNextPage: true)
        testee = .make(pageInfo: pageInfo)

        XCTAssertEqual(testee.pageInfo?.endCursor, testData.cursor)
        XCTAssertEqual(testee.pageInfo?.hasNextPage, true)
    }

    func test_page_shouldReturnEdges() {
        testee = .make(
            moduleItems: [.make(id: "1"), .make(id: "2")]
        )

        XCTAssertEqual(testee.page.count, 1)
        XCTAssertEqual(testee.page, testee.data.course.modulesConnection.edges)
    }

    // MARK: - dataPerModuleItemId

    func test_dataPerModuleItemId_whenItemsHaveCheckpoints() {
        testee = .make(
            moduleItems: [
                .make(
                    id: testData.moduleItemId1,
                    checkpoints: [testData.checkpoint1, testData.checkpoint3],
                    replyToEntryRequiredCount: testData.replyCount1
                ),
                .make(
                    id: testData.moduleItemId2,
                    checkpoints: [testData.checkpoint2],
                    replyToEntryRequiredCount: testData.replyCount2
                )
            ]
        )

        let dataPerModuleItemId = testee.page.dataPerModuleItemId
        let item1 = dataPerModuleItemId[testData.moduleItemId1]
        let item2 = dataPerModuleItemId[testData.moduleItemId2]

        XCTAssertEqual(dataPerModuleItemId.count, 2)

        XCTAssertEqual(item1?.checkpoints.count, 2)
        XCTAssertEqual(item1?.checkpoints.first, testData.checkpoint1)
        XCTAssertEqual(item1?.checkpoints.last, testData.checkpoint3)
        XCTAssertEqual(item1?.replyToEntryRequiredCount, testData.replyCount1)

        XCTAssertEqual(item2?.checkpoints.count, 1)
        XCTAssertEqual(item2?.checkpoints.first, testData.checkpoint2)
        XCTAssertEqual(item2?.replyToEntryRequiredCount, testData.replyCount2)
    }

    func test_dataPerModuleItemId_whenItemHasNoCheckpoint() {
        testee = .make(
            moduleItems: [
                .make(
                    id: testData.moduleItemId1,
                    checkpoints: [],
                    replyToEntryRequiredCount: testData.replyCount1
                ),
                .make(
                    id: testData.moduleItemId2,
                    checkpoints: [testData.checkpoint2],
                    replyToEntryRequiredCount: testData.replyCount2
                )
            ]
        )

        let dataPerModuleItemId = testee.page.dataPerModuleItemId
        let item1 = dataPerModuleItemId[testData.moduleItemId1]
        let item2 = dataPerModuleItemId[testData.moduleItemId2]

        XCTAssertEqual(item1, nil)
        XCTAssertEqual(item2?.checkpoints.count, 1)
        XCTAssertEqual(item2?.checkpoints.first, testData.checkpoint2)
        XCTAssertEqual(item2?.replyToEntryRequiredCount, testData.replyCount2)
    }

    func test_dataPerModuleItemId_whenItemHasNoReplyCount() {
        testee = .make(
            moduleItems: [
                .make(
                    id: testData.moduleItemId1,
                    checkpoints: [],
                    replyToEntryRequiredCount: nil
                ),
                .make(
                    id: testData.moduleItemId2,
                    checkpoints: [testData.checkpoint2],
                    replyToEntryRequiredCount: nil
                )
            ]
        )

        let dataPerModuleItemId = testee.page.dataPerModuleItemId
        let item1 = dataPerModuleItemId[testData.moduleItemId1]
        let item2 = dataPerModuleItemId[testData.moduleItemId2]

        XCTAssertEqual(item1, nil)
        XCTAssertEqual(item2, nil)
    }

    func test_dataPerModuleItemId_whenReplyCountIsZeroOrNegative() {
        testee = .make(
            moduleItems: [
                .make(
                    id: testData.moduleItemId1,
                    checkpoints: [testData.checkpoint1],
                    replyToEntryRequiredCount: 0
                ),
                .make(
                    id: testData.moduleItemId2,
                    checkpoints: [testData.checkpoint2],
                    replyToEntryRequiredCount: -42
                )
            ]
        )

        let dataPerModuleItemId = testee.page.dataPerModuleItemId
        let item1 = dataPerModuleItemId[testData.moduleItemId1]
        let item2 = dataPerModuleItemId[testData.moduleItemId2]

        XCTAssertEqual(item1?.replyToEntryRequiredCount, 0)
        XCTAssertEqual(item2?.replyToEntryRequiredCount, -42)
    }

    // MARK: - JSON Decoding

    func test_decode_withValidJSON() {
        let json = """
        {
            "data": {
                "course": {
                    "modulesConnection": {
                        "pageInfo": {
                            "endCursor": "\(testData.cursor)",
                            "hasNextPage": true
                        },
                        "edges": [
                            {
                                "node": {
                                    "moduleItems": [
                                        {
                                            "_id": "\(testData.moduleItemId1)",
                                            "content": {
                                                "checkpoints": [
                                                    {
                                                        "tag": "\(testData.tag)",
                                                        "dueAt": "2025-01-15T10:00:00Z",
                                                        "pointsPossible": \(testData.points)
                                                    }
                                                ],
                                                "replyToEntryRequiredCount": \(testData.replyCount1)
                                            }
                                        }
                                    ]
                                }
                            }
                        ]
                    }
                }
            }
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        testee = try? decoder.decode(APIModuleItemsDiscussionCheckpoints.self, from: data)

        XCTAssertEqual(testee?.pageInfo?.endCursor, testData.cursor)
        XCTAssertEqual(testee?.pageInfo?.hasNextPage, true)
        XCTAssertEqual(testee?.page.count, 1)

        let moduleItems = testee?.page.first?.node.moduleItems
        XCTAssertEqual(moduleItems?.count, 1)
        XCTAssertEqual(moduleItems?.first?._id, testData.moduleItemId1)

        let content = moduleItems?.first?.content
        XCTAssertEqual(content?.checkpoints?.count, 1)
        XCTAssertEqual(content?.checkpoints?.first?.tag, testData.tag)
        XCTAssertEqual(content?.checkpoints?.first?.pointsPossible, testData.points)
        XCTAssertEqual(content?.replyToEntryRequiredCount, testData.replyCount1)
    }

    func test_decode_withNullValues() {
        let json = """
        {
            "data": {
                "course": {
                    "modulesConnection": {
                        "pageInfo": null,
                        "edges": [
                            {
                                "node": {
                                    "moduleItems": [
                                        {
                                            "_id": "\(testData.moduleItemId1)",
                                            "content": {
                                                "checkpoints": [
                                                    {
                                                        "tag": "\(testData.tag)",
                                                        "dueAt": null,
                                                        "pointsPossible": null
                                                    }
                                                ],
                                                "replyToEntryRequiredCount": \(testData.replyCount1)
                                            }
                                        }
                                    ]
                                }
                            }
                        ]
                    }
                }
            }
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        testee = try? decoder.decode(APIModuleItemsDiscussionCheckpoints.self, from: data)

        XCTAssertEqual(testee?.pageInfo, nil)

        let checkpoint = testee?.page.first?.node.moduleItems.first?.content.checkpoints?.first
        XCTAssertEqual(checkpoint?.tag, testData.tag)
        XCTAssertEqual(checkpoint?.dueAt, nil)
        XCTAssertEqual(checkpoint?.pointsPossible, nil)
    }
}
