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

public protocol InboxMessageInteractor {
    // MARK: - Outputs
    var state: CurrentValueSubject<StoreState, Never> { get }
    var messages: CurrentValueSubject<[InboxMessageListItem], Never> { get }
    var courses: CurrentValueSubject<[InboxCourse], Never> { get }
    var hasNextPage: CurrentValueSubject<Bool, Never> { get }
    var isParentApp: Bool { get }

    // MARK: - Inputs
    func refresh() -> Future<Void, Never>
    func setContext(_ context: Context?) -> Future<Void, Never>
    func setScope(_ scope: InboxMessageScope) -> Future<Void, Never>
    func updateState(message: InboxMessageListItem, state: ConversationWorkflowState) -> Future<Void, Never>
    func loadNextPage() -> Future<Void, Never>
}
