//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import BackgroundTasks

/**
 Core is an extension API only project that forbids calling various methods on `BGTaskScheduler`
 so we have to abstract it away using a protocol and inject its live implementation from a higher level project.
 */
public protocol CoreBGTaskScheduler {

    func register(forTaskWithIdentifier identifier: String,
                  using queue: DispatchQueue?,
                  launchHandler: @escaping (CoreBGTask) -> Void)
    -> Bool

    func submit(_ request: BGTaskRequest) throws
    func cancel(taskRequestWithIdentifier identifier: String)
}
