//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

final class CompositeBackgroundTask: BackgroundTask {
    private let first: BackgroundTask
    private let second: BackgroundTask

    init(
        first: BackgroundTask,
        second: BackgroundTask
    ) {
        self.first = first
        self.second = second
    }

    func start(completion: @escaping () -> Void) {
        first.start { [second] in
            second.start(completion: completion)
        }
    }

    func cancel() {
        first.cancel()
        second.cancel()
    }
}
