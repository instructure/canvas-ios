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
import XCTest

final class CDHCommentAttachmentTests: CoreTestCase {
    func testSave() {
        let apiEntity = GetHSubmissionCommentsResponse.Attachment(
            id: "attachment-123",
            url: "https://example.com/test.pdf",
            displayName: "test.pdf"
        )

        let savedEntity = CDHCommentAttachment.save(apiEntity, in: databaseClient)

        XCTAssertEqual(savedEntity.id, "attachment-123")
        XCTAssertEqual(savedEntity.displayName, "test.pdf")
        XCTAssertEqual(savedEntity.url, "https://example.com/test.pdf")

        let fetchedEntity: CDHCommentAttachment? = databaseClient.first(where: #keyPath(CDHCommentAttachment.id), equals: "attachment-123")
        XCTAssertNotNil(fetchedEntity)
        XCTAssertEqual(fetchedEntity?.id, "attachment-123")
    }

    func testSaveWithExistingEntity() {
        let attachmentId = "attachment-123"
        let initialEntity: CDHCommentAttachment = databaseClient.insert()
        initialEntity.id = attachmentId
        initialEntity.displayName = "old.pdf"
        initialEntity.url = "https://example.com/old.pdf"
        try! databaseClient.save()

        let apiEntity = GetHSubmissionCommentsResponse.Attachment(
            id: attachmentId,
            url: "https://example.com/new.pdf",
            displayName: "new.pdf"
        )

        let updatedEntity = CDHCommentAttachment.save(apiEntity, in: databaseClient)

        XCTAssertEqual(updatedEntity.objectID, initialEntity.objectID)
        XCTAssertEqual(updatedEntity.displayName, "new.pdf")
        XCTAssertEqual(updatedEntity.url, "https://example.com/new.pdf")
    }

    func testSaveWithNilValues() {
        let apiEntity = GetHSubmissionCommentsResponse.Attachment(
            id: "attachment-123",
            url: nil,
            displayName: nil
        )

        let savedEntity = CDHCommentAttachment.save(apiEntity, in: databaseClient)

        XCTAssertEqual(savedEntity.id, "attachment-123")
        XCTAssertNil(savedEntity.displayName)
        XCTAssertNil(savedEntity.url)
    }
}
