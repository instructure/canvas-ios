//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Foundation
import TestsFoundation
import SwiftUI
import Combine
@testable import Core

class SearchContextTests: CoreTestCase {

    private var subscriptions = Set<AnyCancellable>()

    override func tearDown() {
        subscriptions.removeAll()
        super.tearDown()
    }

    func test_coloring() throws {
        // Given
        let info = TestSearchInfo(value: 5, accentColor: .red)
        let context = SearchContext(info: info)

        // Then
        XCTAssertEqual(context.accentColor, .red)
    }

    func test_visited_logic() throws {
        // Given
        let info = TestSearchInfo(value: 10)
        let context = SearchContext(info: info)
        var visited: Set<ID> = []

        context
            .visitedRecordPublisher
            .sink(receiveValue: { visited = $0 })
            .store(in: &subscriptions)

        context.searchText.send("Demo")

        // When
        context.markVisited(5443)
        context.markVisited(7866)
        context.markVisited(2300)
        context.markVisited(1234)

        // Then
        XCTAssertTrue(visited.subtracting([5443, 2300, 1234, 7866]).isEmpty)

        // When
        context.reset()

        // Then
        XCTAssertTrue(visited.isEmpty)
        XCTAssertTrue(context.searchText.value.isEmpty)
    }
}

// MARK: - Mocks

struct TestSearchInfo: SearchContextInfo {
    static var environmentKeyPath: EnvironmentKeyPath { \.testSearchContext }
    static var defaultInfo = TestSearchInfo()

    var value: Int = 0
    var searchPrompt: String { "Search placeholder" }

    var accentColor: UIColor?
}

extension EnvironmentValues {
    var testSearchContext: SearchContext<TestSearchInfo> {
        get { self[TestSearchInfo.EnvironmentKey.self] }
        set { self[TestSearchInfo.EnvironmentKey.self] = newValue }
    }
}
