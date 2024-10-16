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

import SwiftUI
import Combine

public protocol SearchContextInfo {
    typealias EnvironmentKey = SearchEnvironmentKey<Self>
    typealias EnvironmentKeyPath = WritableKeyPath<EnvironmentValues, CoreSearchContext<Self>>

    static var environmentKeyPath: EnvironmentKeyPath { get }
    static var defaultInfo: Self { get }

    var searchPrompt: String { get }
    var navBarColor: UIColor? { get }
    var clearButtonColor: UIColor? { get }
}

extension SearchContextInfo {
    var navBarColor: UIColor? { nil }
    var clearButtonColor: UIColor? { nil }
}

public class CoreSearchContext<Info: SearchContextInfo> {
    let info: Info
    var didSubmit = PassthroughSubject<String, Never>()
    var searchText = CurrentValueSubject<String, Never>("")

    private var visitedRecord = CurrentValueSubject<Set<ID>, Never>([])
    weak var controller: CoreSearchController?

    public init(info: Info) {
        self.info = info
    }

    var visitedRecordPublisher: AnyPublisher<Set<ID>, Never> {
        visitedRecord.eraseToAnyPublisher()
    }

    func markVisited(_ id: ID) {
        var list = visitedRecord.value
        list.insert(id)
        visitedRecord.send(list)
    }

    func reset() {
        visitedRecord.value = []
        searchText.value = ""
    }

    var navBarColor: UIColor? { info.navBarColor }
    var clearButtonColor: UIColor? { info.clearButtonColor }
    var searchPrompt: String { info.searchPrompt }
}

// MARK: - Environment Property

public struct SearchEnvironmentKey<Info: SearchContextInfo>: EnvironmentKey {
    public static var defaultValue: CoreSearchContext<Info> {
        return CoreSearchContext<Info>(info: .defaultInfo)
    }
}
