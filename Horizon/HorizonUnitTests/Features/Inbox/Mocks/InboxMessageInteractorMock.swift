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

@testable import Core
import Combine
import Foundation

final class InboxMessageInteractorMock: InboxMessageInteractor {

    // MARK: - Outputs
    var state = CurrentValueSubject<StoreState, Never>(.data)
    var messages = CurrentValueSubject<[InboxMessageListItem], Never>([])
    var courses = CurrentValueSubject<[InboxCourse], Never>([])
    var hasNextPage = CurrentValueSubject<Bool, Never>(false)
    var isParentApp: Bool = false

    // MARK: - Tracking
    var refreshCallCount = 0
    var setContextCallCount = 0
    var setScopeCallCount = 0
    var updateStateCallCount = 0
    var loadNextPageCallCount = 0
    var lastSetContext: Context?
    var lastSetScope: InboxMessageScope?

    // MARK: - Inputs
    func refresh() -> Future<Void, Never> {
        refreshCallCount += 1
        return Future { promise in
            promise(.success(()))
        }
    }

    func setContext(_ context: Context?) -> Future<Void, Never> {
        setContextCallCount += 1
        lastSetContext = context
        return Future { promise in
            promise(.success(()))
        }
    }

    func setScope(_ scope: InboxMessageScope) -> Future<Void, Never> {
        setScopeCallCount += 1
        lastSetScope = scope
        return Future { promise in
            promise(.success(()))
        }
    }

    func updateState(message: InboxMessageListItem, state: ConversationWorkflowState) -> Future<Void, Never> {
        updateStateCallCount += 1
        return Future { promise in
            promise(.success(()))
        }
    }

    func loadNextPage() -> Future<Void, Never> {
        loadNextPageCallCount += 1
        return Future { promise in
            promise(.success(()))
        }
    }
}
