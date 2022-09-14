//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Combine

/**
 The purposes of this class are
 - Allow the task of calling the background completion block in a reactive environment.
 - Make possible to lazy init the upload chain in `FileSubmissionAssembly` and setup the background callback after the assembly has been created.
 - Make sure the callback block is executed on the main thread.
 */
public class BackgroundSessionCompletion {
    public var callback: (() -> Void)?

    public init() {}

    public func backgroundOperationsFinished() -> Future<Void, Never> {
        Future<Void, Never> { [weak self] promise in
            guard let callback = self?.callback else {
                promise(.success(()))
                return
            }

            DispatchQueue.main.async {
                callback()
                self?.callback = nil
                promise(.success(()))
            }
        }
    }
}
