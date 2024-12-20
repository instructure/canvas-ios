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

/// This type includes key variables (search text, visit history) and publishers
/// that need to be accessed/listened to across search experience components.
/// Especially after presenting the content view. Therefore, there is only single
/// instance of it per search experience.
///
/// Use this type, by accessing environment object associated with
/// `Attributes.EnvironmentKey` on one of the inner search content SwiftUI
/// views, to access the following:
/// - A publisher for Search field submission.
/// - A Combine's subject for search text.
/// - View attributes associated with the current experience.
/// - A publisher for visited record IDs set.
/// - A method to add result ID to visited record.
///
public class SearchViewContext<Attributes: SearchViewAttributes> {
    let attributes: Attributes

    private(set) var didSubmit = PassthroughSubject<String, Never>()
    private(set) var searchText = CurrentValueSubject<String, Never>("")
    private var visitedRecord = CurrentValueSubject<Set<ID>, Never>([])

    init(attributes: Attributes) {
        self.attributes = attributes
    }

    var visitedRecordPublisher: AnyPublisher<Set<ID>, Never> {
        visitedRecord.eraseToAnyPublisher()
    }

    func markVisited(_ id: ID) {
        var list = visitedRecord.value
        list.insert(id)
        visitedRecord.send(list)
    }

    var accentColor: UIColor? { attributes.accentColor }
    var searchPrompt: String { attributes.searchPrompt }
}
