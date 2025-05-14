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

public struct K5ResourcesApplicationViewModel {
    public let image: URL?
    public let name: String
    public let routesBySubjectNames: [(String, URL)]

    public init(image: URL?, name: String, routesBySubjectNames: [(String, URL)]) {
        self.image = image
        self.name = name
        self.routesBySubjectNames = routesBySubjectNames
    }

    public func applicationTapped(router: Router, route: URL, viewController: WeakViewController) {
        router.route(to: route, from: viewController)
    }
}

extension K5ResourcesApplicationViewModel: Identifiable {
    public var id: String { name }
}

extension K5ResourcesApplicationViewModel: Equatable {
    public static func == (lhs: K5ResourcesApplicationViewModel, rhs: K5ResourcesApplicationViewModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension K5ResourcesApplicationViewModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
