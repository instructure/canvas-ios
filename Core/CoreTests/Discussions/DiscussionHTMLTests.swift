//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class DiscussionHTMLTests: CoreTestCase {
    private var file: File!

    override func setUp() {
        super.setUp()

        file = File(context: databaseClient)
        file.displayName = "testfile.txt"
        file.url = URL(string: "https://instructure.com")!
    }

    func testAttachmentRenderedForNonRemovedComment() {
        let entry = DiscussionEntry(context: databaseClient)
        entry.isRemoved = false
        entry.attachment = file

        let result = DiscussionHTML.js(entry: entry, depth: 1, maxDepth: 1)
        XCTAssertTrue(result.contains("attachment:{displayName:'testfile.txt',url:'https://instructure.com'},"))
    }

    func testAttachmentNotRenderedForRemovedComment() {
        let entry = DiscussionEntry(context: databaseClient)
        entry.isRemoved = true
        entry.attachment = file

        let result = DiscussionHTML.js(entry: entry, depth: 1, maxDepth: 1)
        XCTAssertTrue(result.contains("attachment:null,"))
    }
}
