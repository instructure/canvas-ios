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

import Core
import UIKit
@testable import Student

class MockAppViewProxy: WidgetRouter.AppViewProxy {
    var env: AppEnvironment
    var rootViewController: UIViewController
    var selectedTabIndex: Int?

    init() {
        self.env = .shared
        self.rootViewController = UIViewController()
    }

    func selectTab(at index: Int) {
        selectedTabIndex = index
    }
}

extension StudentTestCase {

    func testURL(path: String, query: [String: String] = [:], in environment: AppEnvironment = .shared) -> URLComponents {
        var comps = URLComponents()
        comps.scheme = environment.api.baseURL.scheme
        comps.host = environment.api.baseURL.host()
        comps.path = path
        comps.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        return comps
    }
}
