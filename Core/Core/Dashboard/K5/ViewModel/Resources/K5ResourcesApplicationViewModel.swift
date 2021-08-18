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

import SwiftUI

public struct K5ResourcesApplicationViewModel: Equatable, Identifiable, Hashable {
    public var id: String { name }

    public let image: URL?
    public let name: String
    private let route: URL

    public init(image: URL?, name: String, route: URL) {
        self.image = image
        self.name = name
        self.route = route
    }

    public func applicationTapped(router: Router, viewController: WeakViewController) {
        let webViewController = CoreWebViewController()
        webViewController.webView.load(URLRequest(url: route))
        router.show(webViewController, from: viewController, options: .modal(.automatic, isDismissable: false, embedInNav: true, addDoneButton: true))
    }
}
