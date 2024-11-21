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

class SearchViewContextTests: CoreTestCase {

    private var subscriptions = Set<AnyCancellable>()

    override func tearDown() {
        subscriptions.removeAll()
        super.tearDown()
    }

    func test_coloring() throws {
        // Given
        let attrs = TestSearchViewAttributes(value: 5, accentColor: .red)
        let context = SearchViewContext(attributes: attrs)

        // Then
        XCTAssertEqual(context.accentColor, .red)
    }

    func test_visited_logic() throws {
        // Given
        let attrs = TestSearchViewAttributes(value: 10)
        let context = SearchViewContext(attributes: attrs)
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

struct TestSearchViewAttributes: SearchViewAttributes {
    typealias Environment = TestSearchViewEnvironment
    static var `default`: TestSearchViewAttributes { .init() }

    var value: Int = 0
    var accentColor: UIColor?
    var searchPrompt: String { "Search placeholder" }
}

struct TestSearchViewEnvironment: SearchViewEnvironment {
    typealias Attributes = TestSearchViewAttributes
    static var keyPath: EnvKeyPath { \.testSearchContext }
}

extension EnvironmentValues {
    var testSearchContext: SearchViewContext<TestSearchViewAttributes> {
        get { self[TestSearchViewAttributes.EnvironmentKey.self] }
        set { self[TestSearchViewAttributes.EnvironmentKey.self] = newValue }
    }
}
