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
import TestsFoundation
@testable import Core

class RouterInteractorTestCase: CoreTestCase {

    @discardableResult
    func saveTab(id: String = "", htmlUrl: String, fullUrl: String? = nil, context: Context) -> Tab {
        let fURL = fullUrl.flatMap({ URL(string: $0) })
        let apiTab = APITab.make(id: ID(id), html_url: URL(string: htmlUrl)!, full_url: fURL)
        let tab: Tab = databaseClient.insert()
        tab.save(apiTab, in: databaseClient, context: context)
        drainMainQueue()
        return tab
    }
}
