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

/**
 Model to group all to-do items related to a single subject.
 */
public class K5ScheduleSubjectViewModel: Identifiable {
    public let subject: K5ScheduleSubject
    public let entries: [K5ScheduleEntryViewModel]
    public var isTappable: Bool { subject.route != nil }

    public init(subject: K5ScheduleSubject, entries: [K5ScheduleEntryViewModel]) {
        self.subject = subject
        self.entries = entries
    }

    func profileButtonPressed(router: Router, viewController: WeakViewController) {
        router.route(to: "/profile", from: viewController, options: .modal())
    }

    public func viewTapped(router: Router, viewController: WeakViewController) {
        guard let route = subject.route else { return }
        router.route(to: route, from: viewController.value)
    }
}
