//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import TestsFoundation
import SwiftUI
@testable import Core
import XCTest

class HelpViewTests: CoreTestCase {
    private lazy var links: [HelpLink] = {
        let item0: HelpLink = databaseClient.insert()
        item0.text = "Search the Canvas Guides"
        item0.subtext = "Find answers to common questions"
        item0.url = URL(string: "https://community.canvaslms.com/t5/Canvas/ct-p/canvas")
        let item1: HelpLink = databaseClient.insert()
        item1.text = "Ask Your Instructor a Question"
        item1.url = URL(string: "#teacher_feedback")
        let item2: HelpLink = databaseClient.insert()
        item2.text = "Report a Problem"
        item2.subtext = "If Canvas misbehaves, tell us about it"
        item2.url = URL(string: "#create_ticket")
        return [item0, item1, item2]
    }()
    private lazy var controller: CoreHostingController<HelpView> = {
        return hostSwiftUIController(HelpView(helpLinks: links, tapAction: { _ in }))
    }()
    private var tree: TestTree? {
        _ = controller
        drainMainQueue()
        return controller.testTree
    }

    func testLayout() {
        let cells: [TestTree] = tree?.findAll(kind: .cell) ?? []
        XCTAssertEqual(cells[0].findAll(kind: .text)[0].info("value"), "Search the Canvas Guides")
        XCTAssertEqual(cells[0].findAll(kind: .text)[1].info("value"), "Find answers to common questions")
        XCTAssertEqual(cells[1].findAll(kind: .text)[0].info("value"), "Ask Your Instructor a Question")
        XCTAssertEqual(cells[2].findAll(kind: .text)[0].info("value"), "Report a Problem")
        XCTAssertEqual(cells[2].findAll(kind: .text)[1].info("value"), "If Canvas misbehaves, tell us about it")
    }
}
