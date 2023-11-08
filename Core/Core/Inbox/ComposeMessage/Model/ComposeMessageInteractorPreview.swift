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

#if DEBUG

import Combine
import CombineExt

public class ComposeMessageInteractorPreview: ComposeMessageInteractor {
    // MARK: - Outputs
    public var state = CurrentValueSubject<StoreState, Never>(.loading)
    public var courses = CurrentValueSubject<[InboxCourse], Never>([])

    public init(env: AppEnvironment) {
        self.courses = CurrentValueSubject<[InboxCourse], Never>([
            .save(.make(id: "1", name: "Test Course"), in: env.database.viewContext),
        ])
    }

    public func send(parameters: MessageParameters) -> Future<Void, Error> {
        Future<Void, Error> { promise in
            promise(.success(()))
        }
    }
}

#endif
