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
import CoreData
import Foundation
import XCTest
import TestsFoundation

class DiscussionCheckpointStepTests: XCTestCase {

    func test_init() {
        var testee: DiscussionCheckpointStep?

        testee = .init(tag: "reply_to_topic", requiredReplyCount: nil)
        XCTAssertEqual(testee, .replyToTopic)

        testee = .init(tag: "reply_to_topic", requiredReplyCount: 42)
        XCTAssertEqual(testee, .replyToTopic)

        testee = .init(tag: "reply_to_entry", requiredReplyCount: nil)
        XCTAssertEqual(testee, nil)

        testee = .init(tag: "reply_to_entry", requiredReplyCount: 42)
        XCTAssertEqual(testee, .requiredReplies(42))

        testee = .init(tag: "some_unknown_tag", requiredReplyCount: nil)
        XCTAssertEqual(testee, nil)
    }

    func test_comparison() {
        let replyToTopic = DiscussionCheckpointStep.replyToTopic
        let requiredReplies7 = DiscussionCheckpointStep.requiredReplies(7)
        let requiredReplies42 = DiscussionCheckpointStep.requiredReplies(42)

        XCTAssertEqual(replyToTopic < requiredReplies7, true)
        XCTAssertEqual(requiredReplies7 > replyToTopic, true)

        // matching cases do not affect sorting
        XCTAssertEqual(replyToTopic < replyToTopic, false)
        XCTAssertEqual(replyToTopic > replyToTopic, false)

        // count parameter is ignored
        XCTAssertEqual(requiredReplies7 < requiredReplies42, false)
        XCTAssertEqual(requiredReplies7 > requiredReplies42, false)
    }

    func test_text() {
        var testee: DiscussionCheckpointStep

        testee = .replyToTopic
        XCTAssertEqual(testee.text, "Reply to topic")

        testee = .requiredReplies(42)
        XCTAssertEqual(testee.text, "Additional replies (42)")
    }

    func test_coding_whenCaseIsReplyToTopic() throws {
        let testee = DiscussionCheckpointStepWrapper(value: .replyToTopic)
        let encodedData = try NSKeyedArchiver.archivedData(withRootObject: testee, requiringSecureCoding: true)

        let decodedTestee = try NSKeyedUnarchiver.unarchivedObject(ofClass: DiscussionCheckpointStepWrapper.self, from: encodedData)

        XCTAssertEqual(decodedTestee?.value, .replyToTopic)
    }

    func test_coding_whenCaseIsRequiredReplies() throws {
        let testee = DiscussionCheckpointStepWrapper(value: .requiredReplies(42))
        let encodedData = try NSKeyedArchiver.archivedData(withRootObject: testee, requiringSecureCoding: true)

        let decodedTestee = try NSKeyedUnarchiver.unarchivedObject(ofClass: DiscussionCheckpointStepWrapper.self, from: encodedData)

        XCTAssertEqual(decodedTestee?.value, .requiredReplies(42))
    }

    func test_transformerClasses() {
        XCTAssertContains(
            DiscussionCheckpointStepTransformer.allowedTopLevelClasses,
            { $0 == DiscussionCheckpointStepWrapper.self }
        )
    }

    func test_transformerRegistration() {
        let name = DiscussionCheckpointStepTransformer.name
        ValueTransformer.setValueTransformer(nil, forName: name)
        XCTAssertNotContains(ValueTransformer.valueTransformerNames(), name)

        NSPersistentContainer.registerCoreTransformers()

        XCTAssertContains(ValueTransformer.valueTransformerNames(), name)
    }
}
