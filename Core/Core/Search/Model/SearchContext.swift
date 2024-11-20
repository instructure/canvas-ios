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

import UIKit
import Combine

public class SearchContext<Info: SearchContextInfo> {
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

    var accentColor: UIColor? { info.accentColor }
    var searchPrompt: String { info.searchPrompt }
}
