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
import Foundation

class AddressbookInteractorPreview: AddressbookInteractor {
    var state: CurrentValueSubject<StoreState, Never> = CurrentValueSubject<StoreState, Never>(.loading)

    var recipients: CurrentValueSubject<[SearchRecipient], Never>

    init(env: AppEnvironment) {
        self.recipients = CurrentValueSubject<[SearchRecipient], Never>([
            .make(id: "1", name: "Test user 1", in: env.database.viewContext),
            .make(id: "2", name: "Test user 2", in: env.database.viewContext),
        ])
    }

    func refresh() -> Future<Void, Never> {
        Future<Void, Never> {_ in }
    }

}

#endif
